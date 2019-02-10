# Foo3.pm
package Foo;
use Private;
hide Private;
sub public { local(%Foo::); show Private; Foo->_private(); }
sub _private { print "OK\n"; }
1;
