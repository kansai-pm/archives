# Simple Template
# <nakajima@netstock.co.jp>
package ST;
use strict;

my $PkgNum = 0;

sub embed {
	my $source = shift;
	my $package = 'ST'.$PkgNum++;
	no strict 'refs';
	@{$package.'::Argv'} = @_;
	my $eval = "package $package; no strict; my \$_result;";
	while( $source =~ /([\$%])\[(.+?)\]\1/s ) {
		my($lit, $type, $cmd) = ($`, $1, $2);
		$source = $';
		$lit =~ s/\'/\\\'/g;
		$eval .= "\$_result .= \'$lit\';" if $lit ne '';
		if( $type eq '%' ) {
			if( $cmd =~ /^(for|while|if|unless)\s*\((.+)\)$/ ) {
				$eval .= "$1($2) {";
			} elsif( $cmd =~ /^for\s+((?:my\s+)?\$[_a-zA-Z]\w*)\s*\((.+)\)$/ ) {
				$eval .= "for $1 ($2) {";
			} elsif( $cmd =~ /^elsif\s*\((.+)\)$/ ) {
				$eval .= "} elsif($1) {";
			} elsif( $cmd eq 'else' ) {
				$eval .= "} else {";
			} elsif( $cmd eq 'end' ) {
				$eval .= "}";
			} else {
				$eval .= "$cmd;";
			}
		} else { # $type eq '$'
			$eval .= "\$_result .= $cmd;";
		}
	}
	$source =~ s/\'/\\\'/g;
	$eval .= "\$_result .= \'$source\';" if $source ne '';
	my $result = eval $eval;
	my $error = $@;
	($result, $error, $eval);
}

1;
