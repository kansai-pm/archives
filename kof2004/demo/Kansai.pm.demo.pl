use strict;
use Tk;
#use Tk::JPEG;
use Tk::PNG;
use Win32::Sound;
#--------------------------------------------------------------------
#メイン
#--------------------------------------------------------------------
# soundディレクトリにWAV形式の音楽ファイルを用意
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
# KOFディレクトリにPowerPointで作成したスライドを保存
# imgが画像ファイル名、waitは待ち時間(1/1000秒単位)
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
my $oPauseBtn = $oCvs->Button(-text => '-', -command => \&pause);
$oCvs->createWindow(0, 0, -window => $oPauseBtn, -anchor => 'nw');
MainLoop;
#--------------------------------------------------------------------
# ポーズボタンの動作
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
# 画像ファイルの表示
#--------------------------------------------------------------------
sub dispImg {
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
    if( $SndChgPos{$iPos} ) {       #音楽の切替位置なら
        $iSnd %= scalar(scalar(@aSnd));
        if($aSnd[$iSnd] ne '') {
            Win32::Sound::Stop; 
            sleep 1;
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
    ++$iPos unless $fPause;
}
