# test1.pl
use Foo1;
Foo::public();   # OK
Foo::_private(); # ERROR
