use Kansai;
use strict;
my $outfile = pop @ARGV;
#open OUT, ">:encoding(shiftjis):via(Kansai):utf8", $outfile or die;
open OUT, ">:encoding(shiftjis)", $outfile or die;
for my $file(@ARGV) {
	#open IN, "<:encoding(shiftjis)", $file or die;
	open IN, "<:encoding(shiftjis):via(Kansai):utf8", $file or die;
	print "$file\n";
	while(<IN>) {
		print OUT $_;
	}
	close IN;
}
close OUT;

