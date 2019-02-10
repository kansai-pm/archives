# test2.pl
use Foo2;
Foo::public();   # ERROR
Foo::_private(); # ERROR
