#!/usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp 'fatalsToBrowser';

# A script to get all the quotes of a passed character 
# from the HTML version of John Ford's 'Tis Pity She's a Whore,
# and display them in an easy-to-use webpage.
# Files can be downloaded from here:
# ebooks.adelaide.edu.au/cgi-bin/zip/f/ford/john/pity

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

# Create a CGI object:
my $q = CGI->new;

# Prints the header:
print	$q->header,
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
			 { -href=>"https://github.com/kirbyman62/play-quote-search/blob/master/pity.pl" },
	 		 "By Alex Kerr"),
		$q->p("#teamgiovanni"),
		$q->end_html;

sub get_quotes
{
	my $c = shift;

	# Just hard code the directory name:
	my $DIR_PATH = "/home/alex/TisPity/";

	# Open the directory:
	opendir DIR, $DIR_PATH or die "Could not open '$DIR_PATH': $!\n";

	#Each act is split into files:
	foreach my $filename(sort readdir DIR)
	{
		#Only read the act files:
		next unless($filename =~ /^act([1-5])\.html$/);

		#Get the full filepath to open the file:
		my $filepath = $DIR_PATH . $filename;
		open FILE, $filepath or die "Cannot open '$filepath': $!\n";

		print $q->p("<font size = 4>ACT $1</font>");

		#Slurp the file (poor memory):
		local $/;
		my $contents = <FILE>;

		#Read the file for any quotes with the given character:
		while($contents =~ m{<p><span class="speaker">$c</span>\. (.*?)</p>}gis)
		{
			#Remove any wayward HTML:
			(my $quote = $1) =~ s/<.*?>//gs;

			#Remove any numbers, leftover from notes:
			$quote =~ s/\d//g;

			#Make stage directions italic:
			$quote =~ s{(\[.*\.\]?)}{<em>$1</em>}g;

			#Make apostrophes normal (grr):
			$quote =~ s/€™/'/g;

			print $q->p("$quote");
		}
	}
}
