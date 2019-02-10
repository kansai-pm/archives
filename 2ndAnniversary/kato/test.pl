#!/usr/bin/perl

use Character;
use strict;

my $one = Character->new;
my $another = Character->new;

$one->named('atsushi');
$another->named('akira');

print $one->whoami;
print "\n";
print $another->whoami;
