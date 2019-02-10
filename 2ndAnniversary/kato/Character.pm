package Character;

use strict;

sub new{
  my $class = shift;
  my $object = bless {}, $class;
  return $object;
}

sub named{
  my $self = shift;
  $self->{name} = shift;
}

sub whoami{
  my $self = shift;
  return $self->{name};
}

1;
