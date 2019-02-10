chdir 'wmf';
my @f = <*.wmf>;
for(@f) {
	my $f = $_;
	s/ƒXƒ‰ƒCƒh/slide/;
	rename $f, $_;
}
