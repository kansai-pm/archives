# !!! This file must be UTF-8 !!!
package Kansai;
require v5.6.0;

use utf8;
use Exporter;
# use Japanese;

our $VERSION = "1.1";
our @ISA = qw(Exporter);
our @EXPORT = qw(kansai);

sub kansai {
    local($_) = @_;
    s/なぜ(?:なんだ|でしょうか?|ですか?)/なんでやねん/g;
    s/ありがとう(?:ございま(?:す|した))?/おおきに/g;
    s/(の?)でしょう/($1?'ん':'').'やろ'/ge;
    s/になられる/してくれはる/g;
    s/([てで])(いる|います)/
	{'て'=>'と','で'=>'ど'}->{$1}.
	{'いる'=>'る','います'=>'ります'}->{$2}/ge;
    s/(?<=まし)た\b/てん/g;
    s/りますが/るけど/g;
    s/いです([よがね])/
    {'よ'=>'いでっしゃろ','が'=>'いねんけど','ね'=>'いわな'}->{$1}/ge;
    s/((い)?[のん])?(?:だ|です)([よがとね])/
	($2 ? 'いねん' : $1 ? 'んや' : 'や').
	    {'よ'=>'で','が'=>'けど','と'=>'と','ね'=>'な'}->{$3}/ge;
    s/(?<=[^幸][いた])です\b/で/g;
    s/(?:です|である)\b/や/g;
    s/しない(で)/'せえへん'.($1?'といて':'')/ge;
    s/てください/とくんなはれ/g;
    s/てしまう/てまう/g;
    s/ていません/てまへん/g;
    s/ございません/ありまへん/g;
    s/すみません/すんまへん/g;
    s/すいません/すんまへん/g;
    s/(いけ?)?ません/
    {'い'=>'おり','いけ'=>'あき',''=>''}->{$1}.'まへん'/ge;
    s/(?<=[てで])いない/ない/g;
    s/(?<=もう|しか)ない/あらへん/g;
    s/(?<=[が、])ない/あらへん/g;
    s/(?<!で)はない/はあらへん/g;
    s/(?<=[かさなまらわきちりえけせてねめれ])ない/へん/g;
    s/だ(?=と|った|けど)/や/g;
    s/いる/おる/g;
    s/いない/おらん/g;
    s/いい(?=です|こと|[なのよ]|\b)/ええ/g;
    s/という/ちゅう/g;
    s/なぜ(?=[だでな])/なんで/g;
    s/(<?=[なた])んだ/んや/g;
    s/いただいて/もろうて/g;
    s/[私俺]は/わしは/g;
    s/よろしく/よろしゅう/g;
    s/あなた/あんた/g;
    s/だろう/やろ/g;
    s/かな？/かいな？/g;
    s/ってる/っとる/g;
    s/んでる/んどる/g;
    $_;
} 

# For PerlIO::via
sub PUSHED { bless \*PUSHED,$_[0] } 
sub UTF8 { 1; } # does NOT WORK! It may be a bug in via.xs(5.8.5).
sub FILL {
    my $line = readline($_[1]);
    my $cooked = kansai($line);
    defined($line) ? $cooked : undef;
}
sub WRITE {
    my $str = $_[1];
    utf8::decode($str);
    my $cooked = kansai($str);
    my $len = do {use bytes; length($cooked)};
    (print {$_[2]} $cooked) ? $len : -1;
}

1;

__END__

=head1 NAME

Kansai.pm - convert Standard Japanese to Kansai Japanese

=head1 SYNOPSIS

use Kansai;
$kansai = kansai($tokyo);
open IN, "<:encoding(shiftjis):via(Kansai):utf8", $infile;
open OUT, ">:encoding(shiftjis):via(Kansai):utf8", $outfile;

=head1 DESCRIPTION

This module converts Standard Japanse to Kansai dialect Japanese.

This module exports 'kansai' subroutine. It takes one string argument and
returns converted string.

This module provides PerlIO::via functions (for Perl 5.8 and later). 
See SYNOPSIS. Note that In and Out both convert with same direction: 
Standard to Kansai. Kansai to Standard conversion is not available. 
Secondly note that ':utf8' must follow 'via(Kansai)'. In the future, 
the ':utf8' may be not necessary.

=head1 AUTHOR

MISHIMA Masahiro <mishima@momo.so-net.ne.jp>
Yasushi Nakajima <nakajima@netstock.co.jp>

=head1 SEE ALSO

PerlIO::via

=cut
