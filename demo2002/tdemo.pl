use strict;
use Tk;
use Tk::JPEG;
use Win32::Sound;
#--------------------------------------------------------------------
#���C��
#--------------------------------------------------------------------
# sound�f�B���N�g����WAV�`���̉��y�t�@�C����p��
my @aSnd = ( 'sound/gentei129.wav', '', 'sound/gentei136.wav', '',
             'sound/wa_002.wav', , '');
# KOF�f�B���N�g����PowerPoint�ō쐬�����X���C�h��ۑ�
# img���摜�t�@�C�����Await�͑҂�����(1/1000�b�P��)
my @aImg = (
    { img => 'KOF/�X���C�h1.jpg',   },
    { img => 'KOF/�X���C�h2.jpg',  },
    { img => 'KOF/�X���C�h3.jpg',  },
    { img => 'KOF/�X���C�h4.jpg',  },
    { img => 'KOF/�X���C�h5.jpg',  },
    { img => 'KOF/�X���C�h6.jpg',  },
    { img => 'KOF/�X���C�h7.jpg',  wait  => 2000, },
   { img => 'KOF/�X���C�h8.jpg',  wait  => 2000,  },
    { img => 'KOF/�X���C�h9.jpg',  wait  => 1000,  },
   { img => 'KOF/�X���C�h10.jpg', wait  => 3000,  },
    { img => 'KOF/�X���C�h11.jpg', },
    { img => 'KOF/�X���C�h12.jpg', },
    { img => 'KOF/�X���C�h13.jpg', },
    { img => 'KOF/�X���C�h14.jpg', },
    { img => 'KOF/�X���C�h15.jpg', wait  => 1000, },
    { img => 'KOF/�X���C�h16.jpg', wait  => 1000,},
    { img => 'KOF/�X���C�h17.jpg', wait  => 1000,},
    { img => 'KOF/�X���C�h18.jpg', },
    { img => 'KOF/�X���C�h19.jpg', wait  => 6000},
    { img => 'KOF/�X���C�h20.jpg', },
    { img => 'KOF/�X���C�h21.jpg', },
    { img => 'KOF/�X���C�h22.jpg', wait  => 2000 },
    { img => 'KOF/�X���C�h23.jpg', },
    { img => 'KOF/�X���C�h24.jpg', },
    { img => 'KOF/�X���C�h25.jpg', wait  => 7000, },
    { img => 'KOF/�X���C�h26.jpg', wait  => 3000, },
);
my @aoImg = ();
my $iSnd=0;
my $iPos = 0;
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
MainLoop;
#--------------------------------------------------------------------
# �摜�t�@�C���̕\��
#--------------------------------------------------------------------
sub dispImg() {
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
    if($iPos == 0) {                #$iPos==0�܂�擪�ɂ�����
        $iSnd %= scalar(scalar(@aSnd));
        if($aSnd[$iSnd] ne '') {
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
    ++$iPos;
}
