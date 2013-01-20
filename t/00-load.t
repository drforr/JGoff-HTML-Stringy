#!perl

use strict;
use warnings;
use Test::More tests => 17;

BEGIN {
  use_ok( 'JGoff::HTML::Stringy' ) || print "Bail out!\n";
}

#
# The API:
#
# Html($url) # Returns a stringy object consisting of the HTML of the URL
# Html(\$string) # Returns a stringy object consisting of the HTML in the string
#
# Html($url)->Head # Returns a stringy object consisting of the <head>..</head>
#                  # text of the object.
#
# Html($url)->Body # Similar to ->head(), but the <body>..</body> text.
# 

my $parser = JGoff::HTML::Stringy->new;

# {{{ Sample HTML
my $html =
'<html lang="en">
    <head>
        <title>Test Title</title>
        <meta description="Meta Desc" name="Meta Name" />
    </head>
    <body>
        <h1>
          <span id="foo">Span Foo</span>
          <span id="bar">Span Bar</span>
        </h1>
    </body>
</html>';

# }}}

is( $parser->Html(\$html), $html );

# {{{ Html()->Head() chained accessor

is(
  $parser->Html(\$html)->Head,
    '<head>
        <title>Test Title</title>
        <meta description="Meta Desc" name="Meta Name" />
    </head>'
);

# }}}

# {{{ Html()->[Head()->]Title() chained accessor

is(
  $parser->Html(\$html)->Head->Title,
  '<title>Test Title</title>'
);
is(
  $parser->Html(\$html)->Title,
  '<title>Test Title</title>'
);

# }}}

# {{{ Html()->[Head()->]Meta() chained accessor

is(
  $parser->Html(\$html)->Head->Meta,
  '<meta description="Meta Desc" name="Meta Name" />'
);
is(
  $parser->Html(\$html)->Meta,
  '<meta description="Meta Desc" name="Meta Name" />'
);

is(
  $parser->Html(\$html)->Head->Meta,
  $parser->Html(\$html)->Head->Meta( name => 'Meta Name' )
);
is(
  $parser->Html(\$html)->Head->Meta,
  $parser->Html(\$html)->Head->Meta( description => 'Meta Desc' )
);

# }}}

# {{{ html()->[body()->h1()->]span([id => 'foo']) chained accessor

is(
  $parser->Html(\$html)->Body->H1->Span( id => 'foo' ),
  '<span id="foo">Span Foo</span>'
);
is(
  $parser->Html(\$html)->Body->Span( id => 'foo' ),
  '<span id="foo">Span Foo</span>'
);
is(
  $parser->Html(\$html)->H1->Span( id => 'foo' ),
  '<span id="foo">Span Foo</span>'
);
is(
  $parser->Html(\$html)->Span( id => 'foo' ),
  '<span id="foo">Span Foo</span>'
);

is(
  $parser->Html(\$html)->Body->H1->Span( id => 'bar' ),
  '<span id="bar">Span Bar</span>'
);
is(
  $parser->Html(\$html)->Body->Span( id => 'bar' ),
  '<span id="bar">Span Bar</span>'
);
is(
  $parser->Html(\$html)->H1->Span( id => 'bar' ),
  '<span id="bar">Span Bar</span>'
);

is_deeply( $parser->Html(\$html)->Body->H1->Span, [
    '<span id="foo">Span Foo</span>',
    '<span id="bar">Span Bar</span>'
  ]
);

# }}}
