use strict;
use Tk;
use Tk::JPEG;
use Win32::Sound;
#--------------------------------------------------------------------
#メイン
#--------------------------------------------------------------------
# soundディレクトリにWAV形式の音楽ファイルを用意
my @aSnd = ( 'sound/gentei129.wav', '', 'sound/gentei136.wav', '',
             'sound/wa_002.wav', , '');
# KOFディレクトリにPowerPointで作成したスライドを保存
# imgが画像ファイル名、waitは待ち時間(1/1000秒単位)
my @aImg = (
    { img => 'KOF/スライド1.jpg',   },
    { img => 'KOF/スライド2.jpg',  },
    { img => 'KOF/スライド3.jpg',  },
    { img => 'KOF/スライド4.jpg',  },
    { img => 'KOF/スライド5.jpg',  },
    { img => 'KOF/スライド6.jpg',  },
    { img => 'KOF/スライド7.jpg',  wait  => 2000, },
   { img => 'KOF/スライド8.jpg',  wait  => 2000,  },
    { img => 'KOF/スライド9.jpg',  wait  => 1000,  },
   { img => 'KOF/スライド10.jpg', wait  => 3000,  },
    { img => 'KOF/スライド11.jpg', },
    { img => 'KOF/スライド12.jpg', },
    { img => 'KOF/スライド13.jpg', },
    { img => 'KOF/スライド14.jpg', },
    { img => 'KOF/スライド15.jpg', wait  => 1000, },
    { img => 'KOF/スライド16.jpg', wait  => 1000,},
    { img => 'KOF/スライド17.jpg', wait  => 1000,},
    { img => 'KOF/スライド18.jpg', },
    { img => 'KOF/スライド19.jpg', wait  => 6000},
    { img => 'KOF/スライド20.jpg', },
    { img => 'KOF/スライド21.jpg', },
    { img => 'KOF/スライド22.jpg', wait  => 2000 },
    { img => 'KOF/スライド23.jpg', },
    { img => 'KOF/スライド24.jpg', },
    { img => 'KOF/スライド25.jpg', wait  => 7000, },
    { img => 'KOF/スライド26.jpg', wait  => 3000, },
);
my @aoImg = ();
my $iSnd=0;
my $iPos = 0;
my $oImg;
my $oMw = new MainWindow;
$oMw->geometry('+0+0');
$oMw->title('DEMO');
$oMw->FullScreen(1);    #これで全画面表示
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
# 画像ファイルの表示
#--------------------------------------------------------------------
sub dispImg() {
    $oCvs->delete($oImg) if($oImg); #キャンバスからImageを削除
    $iPos %=scalar(@aImg);          #表示する画像を計算

    if(! defined($aoImg[$iPos])) {  
        my $oWk = $oMw->Photo(-file => $aImg[$iPos]->{img});
        $aoImg[$iPos]= $oWk;    
            #PhotoメソッドでImageを用意、配列に入れておけば一度きり
    }
    $oImg = $oCvs->createImage(     #キャンバスにImageを作成
                ($oMw->width)/2,
                ($oMw->height)/2,
                -image => $aoImg[$iPos]);
    if($iPos == 0) {                #$iPos==0つまり先頭にきたら
        $iSnd %= scalar(scalar(@aSnd));
        if($aSnd[$iSnd] ne '') {
            Win32::Sound::Play($aSnd[$iSnd], SND_ASYNC|SND_LOOP);
                    #指定されているファイルを演奏開始（非同期、繰り返し）
        }
        else {
            Win32::Sound::Stop; #ファイル名がなければ演奏停止
        }
        ++$iSnd;
    }
    $oMw->after($aImg[$iPos]->{wait}||5000, \&dispImg);
                                #指定された時間（デフォルトは5秒）後に
                                #この関数dispImgを呼び出し
    ++$iPos;
}
