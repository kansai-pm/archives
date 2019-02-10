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
    $oImg->Write(sprintf('img/slide%02d.gif', ++$i));
}
