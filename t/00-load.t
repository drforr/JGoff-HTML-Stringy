#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'JGoff::HTML::Stringy' ) || print "Bail out!\n";
}

diag( "Testing JGoff::HTML::Stringy $JGoff::HTML::Stringy::VERSION, Perl $], $^X" );
