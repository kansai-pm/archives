# Foo2.pm
package Foo;
use Private;
hide Private;
sub public { Foo->_private(); }
sub _private { print "OK\n"; }
1;
