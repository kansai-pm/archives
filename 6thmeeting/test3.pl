# test3.pl
use Foo3;
Foo::public();   # OK
Foo::_private(); # ERROR
