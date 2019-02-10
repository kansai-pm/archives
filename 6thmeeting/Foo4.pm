# Foo4.pm
package Foo;
use Private;
hide Private;
$_private = 'OK';
sub public { print $_private; }
1;
