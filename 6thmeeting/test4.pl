# test4.pl
use Foo4;
Foo::public();   # OK
print $Foo::_private; # 
