  # Foo.pm
  package Foo;
  use Private qw(_private_var _private_func);
  hide Private; # hide private symbols at runtime
  $public_var = 5;
  $_private_var = 0;
  # private symbols recognized at compile time are available normally
  sub _private_func { ++$_private_var; } 
  sub public_func { _private_func(); }
  # if you want to use private symbols at runtime:
  sub public_func2 {
      local(%Foo::); # save symbol table and recover at block end
      show Private; # show private symbols at runtime
      Foo->_private_func() + $public_var + $_private_var;
  }
1;
