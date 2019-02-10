use strict;
use Tk;
#use Tk::JPEG;
use Tk::PNG;
use Win32::Sound;
#--------------------------------------------------------------------
#���C��
#--------------------------------------------------------------------
# sound�f�B���N�g����WAV�`���̉��y�t�@�C����p��
my $SndDir = 'sound';
my $SndOrderFile = 'sndorder';
my @aSnd = ();
open F, $SndOrderFile or die;
while(<F>) {
	chomp;
	my $file = "$SndDir/$_";
	die "missing $file" unless -f $file;
	push @aSnd, $file;
}
close F;
my %SndChgPos;
# KOF�f�B���N�g����PowerPoint�ō쐬�����X���C�h��ۑ�
# img���摜�t�@�C�����Await�͑҂�����(1/1000�b�P��)
my $ImgDir = 'KOF';
my $ImgOrderFile = 'imgorder';
my @aImg = ();
open F, $ImgOrderFile or die;
while(<F>) {
	chomp;
	my($file, $wait) = split /\s+/;
	if( $file =~ s/^\*// ) {
		$SndChgPos{scalar(@aImg)} = 1;
	}
	$file = "$ImgDir/$file";
	die "missing $file" unless -f $file;
	my $hash = {img => $file};
	$hash->{wait} = $wait * 1000 if $wait;
	push @aImg, $hash;
}
close F;
my @aoImg = ();
my $iSnd = 0;
my $iPos = 0;
my $fPause = 0;
my $oImg;
my $oMw = new MainWindow;
$oMw->geometry('+0+0');
$oMw->title('DEMO');
$oMw->FullScreen(1);    #����őS��ʕ\��
my $oCvs = $oMw->Canvas(
                -background  => '#402500',
                -width       => $oMw->width,
                -height      => $oMw->height,
                -relief      => 'raised',
                -borderwidth => 0,
                -cursor =>'trek',
        )->grid;
dispImg();
my $oPauseBtn = $oCvs->Button(-text => '-', -command => \&pause);
$oCvs->createWindow(0, 0, -window => $oPauseBtn, -anchor => 'nw');
MainLoop;
#--------------------------------------------------------------------
# �|�[�Y�{�^���̓���
#--------------------------------------------------------------------
sub pause {
	if( $fPause ) {
		++$iPos;
		$fPause = 0;
		$oPauseBtn->configure(-text => '-');
	} else {
		--$iPos;
		$fPause = 1;
		$oPauseBtn->configure(-text => '|');
	}
}
#--------------------------------------------------------------------
# �摜�t�@�C���̕\��
#--------------------------------------------------------------------
sub dispImg {
    $oCvs->delete($oImg) if($oImg); #�L�����o�X����Image���폜
    $iPos %=scalar(@aImg);          #�\������摜���v�Z

    if(! defined($aoImg[$iPos])) {  
        my $oWk = $oMw->Photo(-file => $aImg[$iPos]->{img});
        $aoImg[$iPos]= $oWk;    
            #Photo���\�b�h��Image��p�ӁA�z��ɓ���Ă����Έ�x����
    }
    $oImg = $oCvs->createImage(     #�L�����o�X��Image���쐬
                ($oMw->width)/2,
                ($oMw->height)/2,
                -image => $aoImg[$iPos]);
    if( $SndChgPos{$iPos} ) {       #���y�̐ؑֈʒu�Ȃ�
        $iSnd %= scalar(scalar(@aSnd));
        if($aSnd[$iSnd] ne '') {
            Win32::Sound::Stop; 
            sleep 1;
            Win32::Sound::Play($aSnd[$iSnd], SND_ASYNC|SND_LOOP);
                    #�w�肳��Ă���t�@�C�������t�J�n�i�񓯊��A�J��Ԃ��j
        }
        else {
            Win32::Sound::Stop; #�t�@�C�������Ȃ���Ή��t��~
        }
        ++$iSnd;
    }
    $oMw->after($aImg[$iPos]->{wait}||5000, \&dispImg);
                                #�w�肳�ꂽ���ԁi�f�t�H���g��5�b�j���
                                #���̊֐�dispImg���Ăяo��
    ++$iPos unless $fPause;
}
