use strict;
use Image::Magick;
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
#1.画像を幅:200、高さ:150に縮小し、gifで出力
my $rhImg;
my $i=0;
foreach $rhImg (@aImg) {
    my $oImg = Image::Magick->new;
    $oImg->Read($rhImg->{img});
    $oImg->Resize('200x150');
    $oImg->Write(sprintf('KOF/slide%02d.gif', ++$i));
}
#2.そのファイルをまとめてGIFアニメ化
my $iDly;
my $oImg = Image::Magick->new;
$i=0;
#2.1 loopで繰り返しを設定
$oImg->Set(loop =>-1);
foreach my $rhImg (@aImg) {
    $oImg->Read(sprintf('KOF/slide%02d.gif', ++$i));
    $iDly = $rhImg->{wait};
    $iDly||=3000;   #本物よりも時間をちょっと短めに設定
    $iDly/=10;      #GIFアニメでは1/100秒単位
    #2.2　delayで移り変わるタイミングを調整
    $oImg->[$i-1]->Set(delay=>$iDly);
}
$oImg->Write('demo.gif');
