#!/usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use utf8;

# A script to get all the quotes of a passed character 
# from the HTML version of John Ford's 'Tis Pity She's a Whore,
# and display them in an easy-to-use webpage.
# Files can be downloaded as a zip archive from here:
# ebooks.adelaide.edu.au/cgi-bin/zip/f/ford/john/pity

# The path of the extracted zip archive:
my $DIR_PATH = "/srv/http/cgi-bin/TisPity/";

# A list of characters in the play:
my @characters = (
	"annabella",
	"giovanni",
	"florio",
	"putana",
	"friar",
	"soranzo",
	"vasques",
	"grimaldi",
	"donado",
	"bergetto",
	"poggio",
	"hippolita",
	"richardetto",
	"philotis",
	"cardinal"
);

@characters = sort @characters;
unshift(@characters, "");

#Non-serious messages for the footer:
my @footers = (
	"#teamgiovanni",
	"(\N{U+261E}\N{U+00B0}\N{U+2200}\N{U+00B0})\N{U+261E}",
	"gl;hf",
);

# Create a CGI object:
my $q = CGI->new;

# Prints the header:
print	$q->header(-charset=>"UTF-8"),
		$q->start_html("Tis Pity Quotes"),
		$q->h1("'Tis Pity She's a Whore Quotes");

# Prints the form:
print	$q->start_form,
		$q->p("Pick a character: "),
		$q->popup_menu(-name=>"characters", -values=>\@characters, -default=>""),
		$q->submit,
		$q->end_form,
		$q->hr;

my $c = $q->param("characters");
unless($c eq "")
{
	get_quotes($c);
	print $q->hr;
}

# Prints the footer:
print	$q->a(
			 { -href =>
			   "https://github.com/kirbyman62/play-quote-search/blob/master/pity.pl" },
	 		 "By Alex Kerr"),
		$q->p($footers[rand @footers]),
		$q->end_html;

# Gets all the quotes said by the given character in the play:
sub get_quotes
{
	my $c = shift;

	#Open the directory:
	opendir my $dir, $DIR_PATH or die "Could not open '$DIR_PATH': $!\n";

	#Each act is split into files:
	foreach my $filename(sort readdir $dir)
	{
		#Only read the act files:
		next unless($filename =~ /^act([1-5])\.html$/);

		#Get the full filepath to open the file:
		my $filepath = $DIR_PATH . $filename;
		open my $file, $filepath or die "Could not open '$filepath': $!\n";

		print $q->p("<font size = 4>ACT $1</font>");

		#Slurp the file (poor memory):
		local $/;
		my $contents = <$file>;

		#Read the file for any quotes by the given character:
		while($contents =~ m{<p><span class="speaker">$c</span>\. (.*?)</p>}gis)
		{
			#Remove any wayward HTML:
			(my $quote = $1) =~ s/<.*?>//gs;

			#Remove any non-breaking spaces:
			$quote =~ s/&#160;/ /g;

			#Remove any numbers, leftover from notes:
			$quote =~ s/\d//g;

			#Make stage directions italic:
			$quote =~ s{(\[.*\.\]?)}{<em>$1</em>}g;

			print $q->p("$quote");
		}
		close $file;
	}
}
