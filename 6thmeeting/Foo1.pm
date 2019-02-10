# Foo1.pm
package Foo;
use Private;
hide Private;
sub public { _private(); }
sub _private { print "OK\n"; }
1;
