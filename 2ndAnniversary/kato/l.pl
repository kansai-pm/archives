#!/usr/bin/perl

use strict;
use Character;

my %code;
my %mod;

set_var();
main();

sub main{
  clear();
  while( my $s = <STDIN>){
    chomp($s);
    if($s eq '0'){
      clear();
      print $code{0};
      <STDIN>;
      print "\n--------- execute ---------\n\n";
      no strict;
      eval($code{0});
    }elsif($s eq '1'){
      clear();
      print $code{1},"\n\n";
    }elsif($s eq '2'){
      clear();
      print $code{2};
      <STDIN>;
      print "\n--------- execute ---------\n\n";
      eval($code{2});
      print "\n\n";
    }elsif($s eq '3'){
      clear();
      print $code{3};
      <STDIN>;
      print "\n--------- execute ---------\n\n";
      eval($code{3});
      print "\n\n";
    }elsif($s eq '4'){
      clear();
      print $mod{1},"\n\n";
    }elsif($s eq '5'){
      clear();
      print $mod{2},"\n\n";
    }elsif($s eq '6'){
      clear();
      print $mod{3},"\n\n";
    }elsif($s eq '7'){
      clear();
      print $code{4};
      <STDIN>;
      print "\n--------- execute ---------\n\n";
      eval($code{4});
      print "\n\n";
    }elsif($s eq '8'){
      clear();
      print join("\n",@mod{1,2,3},"1","\n");
      print "\n\n";
    }elsif($s eq 'q'){
      clear();
      last;
    }elsif($s eq 'c'){
      clear();
    }elsif($s eq 'a'){
      clear();
      print $code{a};
      print "\n\n";
    }elsif($s eq 'b'){
      clear();
      print $code{b};
      print "\n\n";
    }
  }
}

sub clear{
   system($^O =~/^MSWin/ ? 'cls' : 'clear');
}

sub set_var{

$code{1} = q{
use Character;

my $c = Character->new;
};

$code{2} = q{
use Character;

my $c = Character->new;

print ref $c;
};

$code{3} = q{
use Character;
my $c = Character->new;

print $c
};

$mod{1} = q{
package Character;

use strict;

sub new{
  my $class = shift;
  my $object = bless {}, $class;
  return $object;
}
};

$mod{2} = q{
sub named{
  my $self = shift;
  $self->{name} = shift;
}
};
$mod{3} = q{
sub whoami{
  my $self = shift;
  return $self->{name};
}
};

$code{4} = q{
#!/usr/bin/perl

use Character;

my $one = Character->new;
my $another = Character->new;

$one->named('atsushi');
$another->named('akira');

print $one->whoami;
print "\n";
print $another->whoami;
};

$code{0} = q{
#!/usr/bin/perl

package main;

$bar = '$bar is in main package';

{
  package hoge;

  $bar = '$bar is in hoge package';
  print $bar,"\n";
}
{
  package hoo;

  $bar = '$bar is in hoo package';
  print $bar,"\n";
}

print $bar;
};

$code{a} = q{
#!/usr/bin/perl -w

$hoge = 1;

};

$code{b} = q{
#!/usr/bin/perl -w

package hoge;

$hoge = 1;

};

}# set_var end

