use strict;
use Image::Magick;
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
#1.�摜��:200�A����:150�ɏk�����Agif�ŏo��
my $rhImg;
my $i=0;
foreach $rhImg (@aImg) {
    my $oImg = Image::Magick->new;
    $oImg->Read($rhImg->{img});
    $oImg->Write(sprintf('img/slide%02d.gif', ++$i));
}
