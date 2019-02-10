# showFoo.pl
use Foo1;
for my $name(sort keys %Foo::) {
  print "$name => $Foo::{$name}\n";
}
