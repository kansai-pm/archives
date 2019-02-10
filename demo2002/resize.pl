use strict;
use GD;
while(my $sFile =glob('objimg/*.jpg')) {
    my $oGd=GD::Image->newFromJpeg($sFile);
    my($iW, $iH) = $oGd->getBounds();
    print "W:$iW H:$iH\n";
    my $oGdN = new GD::Image(1024, 768);
    my($iWN, $iHN) = $oGdN->getBounds();
    $oGdN->copyResized($oGd, 0, 0, 0, 0, $iWN, $iHN, $iW, $iH);
    my $sDst = $sFile;
    $sDst =~ s|^objimg|dstimg|;
    open(OUT, ">$sDst");
    binmode OUT;
    print OUT $oGdN->jpeg;
    close OUT;
}
