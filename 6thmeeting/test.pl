  # other script file
  use Foo;
  # cannot access private symbols of Foo
  $Foo::_private_var = 10; # uneffective to change original private variable
  print Foo::public_func(),"\n"; # 1 
  print Foo::public_func2(),"\n"; # 2
  #Foo::_private_func(); # Error!
  #Foo->_private_func(); # Error!
#for(keys %Foo::){print "$_ => $Foo::{$_}\n"}
