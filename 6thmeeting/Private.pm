# Private.pm
# 2002 Sey
package Private;
use strict;
use vars qw($VERSION);

$VERSION = '0.01';

sub hide {
	my($me, @symbols) = @_;
	push @symbols, '^_' unless @symbols;
	my $pattern = join '|', map {/\W/ ? $_ : "^$_\$"} @symbols;
	my $pkg = caller;
	no strict 'refs';
	for(keys %{"${pkg}::"}) { 
		if( /$pattern/ ) {
			*{"Private::${pkg}::$_"} = ${"${pkg}::"}{$_};
			delete ${"${pkg}::"}{$_};
		}
	}
}

sub show {
	my($me) = @_;
	my $pkg = caller;
	no strict 'refs';
	for(keys %{"Private::${pkg}::"}) { 
		*{"${pkg}::$_"} = ${"Private::${pkg}::"}{$_};
	}
}

1;
__END__

=head1 NAME

Private - hide and show package private symbols at rumtime

=head1 SYNOPSIS

  # Foo.pm
  package Foo;
  use Private;
  hide Private; 
  $_private_var = 0;
  sub _private_func { ++$_private_var; } 
  sub public_func { _private_func(); }
  1;
  
  # other script file
  use Foo;
  $Foo::_private_var = 5; # no error but cannot change original private variable
  print Foo::public_func(),"\n"; # 1 
  Foo::_private_func(); # Error!
  Foo->_private_func(); # Error!

=head1 DESCRIPTION

=head2 Summary

The Private module makes some variables or subroutines private in a module. It means that a script which uses the module cannot access the private variables or subroutines. We have file-scope 'my' operation to make private variables, so this module provides a way of making private subroutines practically.

The name of private variables or subroutines can be specified by string list or regular expressions but the default is names prefixed by a underscore character.

In the module itself you can use private varables or subroutines normally. But if your code searches the private varables or subroutines at runtime (e.g. method call) it causes an error. A way of showing private variables or subroutines temporarily is ready.

=head2 Preparing

Currently you need only 'Private.pm' to use the Private module. Please save it in a directory in @INC.

=head2 Simple usage

Write two lines after package declaration as following:

  package Foo;
  use Private;
  hide Private;

Then the variables or subroutines which have underscore prefixed name in the package Foo become private.

=head2 Private name

To specify private names, write as following:

  hide Private qw(foo bar);

If you need regular exipression specification, write as following:

  hide Private '^__';

A string which contains some characters except alphabet or number or underscore is treated as a regular expression. This example means prefixed by two underscore characters.

=head2 Showing temporarily 

You can use private varables or subroutines normally in the module itself.

  # in Foo.pm
  sub func {
    $_private_var++; # OK
    _private_subroutine(); # OK
  }

But searching private varables or subroutines at runtime causes an error even if the code is in the module itself.

  # in Foo.pm
  sub func {
    Foo->_private_method(); # Error!
  }

To show private varables or subroutines temporarily, write as following:

  # in Foo.pm
  sub func {
    local(%Foo::);
    show Private;
    Foo->_private_method(); # OK
  }

The code 'local(%Foo::);' saves the package Foo symbol table and restore at block end. If you miss it, private varables or subroutines are revealed permanently after calling func();

=head2 Note

=over 4

=item AUTOLOAD

If AUTOLOAD defines a private subroutine at runtime, you must call 'hide Private' again. So please be carefull to use SelfLoader or AutoLoader with Private.

=item Private variables access from outside

When you access a private variable from outside of the module, NO error causes and Perl makes a new variable by the specified name. But that new variable is different from the original private variable. The codes in the module still access the original private variable. This situation will make you confused.

So I recommend you that DO NOT use Private to make private variables. Please use file-scope 'my' instead.

=item Tricky

This module is experimental and tricky. Please use carefully.

=back

=head1 AUTHOR

Sey Nakajima <sey@jkc.co.jp>

=head1 SEE ALSO

perl(1).

=cut
