chdir 'wmf';
my @f = <*.wmf>;
for(@f) {
	my $f = $_;
	s/�X���C�h/slide/;
	rename $f, $_;
}
