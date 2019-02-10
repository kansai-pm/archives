use lib 'c:/My Documents/develop/PDFJ';
use XPDFJ;
use strict;

my $xpdfj = XPDFJ->new(dopath => 'c:/My Documents/develop/PDFJ/macro');
$xpdfj->parsefile('modlist.xp', outfile => 'modlist.pdf');
