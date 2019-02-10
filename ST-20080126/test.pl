use ST;
use strict;

my($templatefile, $datafile) = @ARGV;

open F, $templatefile or die;
my $template = join '', <F>;
close F;

open F, $datafile or die;
my $data = join '', <F>;
close F;
my @args = eval $data;
die $@ if $@;

print ST::embed($template, @args);
