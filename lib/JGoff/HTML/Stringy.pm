package JGoff::HTML::Stringy;

use 5.006;
use strict;
use warnings;

use Moose;
#use HTML::TreeBuilder -weak;
use XML::LibXML;
use Carp qw( croak );

has string => ( is => 'rw' );
has dom => ( is => 'rw' );

# {{{ _quote()

sub _quote {
  my $self = shift;
  return $self->string;
}

# }}}

# {{{ _cmp( $lhs, $rhs )

sub _cmp {
  my ( $lhs, $rhs ) = @_;
  if ( ref( $lhs ) and $lhs->isa( 'JGoff::HTML::Stringy' ) ) {
    $lhs = $lhs->string;
  }
  if ( ref( $rhs ) and $rhs->isa( 'JGoff::HTML::Stringy' ) ) {
    $rhs = $rhs->string;
  }
  return $lhs cmp $rhs;
}

# }}}

use overload (
  '""' => \&_quote,
  'cmp' => \&_cmp
);

#HTML

our @html3_2_elements = qw(
ADDRESS APPLET AREA A
BASE BASEFONT BIG BLOCKQUOTE BODY BR B
CAPTION CENTER CITE CODE
DD DFN DIR DIV DL DT
EM
FONT FORM
H1 H2 H3 H4 H5 H6 HEAD HR
IMG INPUT ISINDEX I
KBD
LINK LI
MAP MENU META
OL OPTION
PARAM PRE P
SAMP SCRIPT SELECT SMALL STRIKE STRONG STYLE SUB SUP
TABLE TD TEXTAREA TH TITLE TR TT
UL U VAR
);

our @html4_elements = qw(
A ABBR ACRONYM ADDRESS APPLET AREA
B BASE BASEFONT BDO BIG BLOCKQUOTE BODY BR BUTTON
CAPTION CENTER CITE CODE COL COLGROUP
DD DEL DFN DIR DIV DL DT
EM
FIELDSET FONT FORM FRAME FRAMESET
H1 H2 H3 H4 H5 H6 HEAD HR
I IFRAME IMG INPUT INS ISINDEX
KBD
LABEL LEGEND LI LINK
MAP MENU META
NOFRAMES NOSCRIPT
OBJECT OL OPTGROUP OPTION
P PARAM PRE
Q
S SAMP SCRIPT SELECT SMALL SPAN STRIKE STRONG STYLE SUB SUP
TABLE TBODY TD TEXTAREA TFOOT TH THEAD TITLE TR TT
U UL
VAR
);

our @html5_elements = qw(
a abbr address area article aside audio
b base bdi bdo blockquote body br button
canvas caption cite code col colgroup
menuitem
datalist dd del details dfn dialog div dl dt
em embed
fieldset figcaption figure footer form
h1 h2 h3 h4 h5 h6 head header hgroup hr
i iframe img input ins
kbd keygen
label legend li link
main map mark menu meta meter
nav noscript
object ol optgroup option output
p param pre progress
q
rp rt ruby
s samp script section select small source span strong style sub summary sup
table tbody td textarea tfoot th thead time title tr track
u ul
var video
wbr
);

my %all_elements = map { $_ => 1 } (
  @html3_2_elements,
  @html4_elements,
  @html5_elements
);

no strict 'refs';
for my $tag_name ( keys %all_elements ) {
  *{ucfirst(lc($tag_name))} = sub {
    my $self = shift;
    $self->_args_to_find( lc( $tag_name ), @_ );
    $self
  }
}

=head1 NAME

JGoff::HTML::Stringy - The great new JGoff::HTML::Stringy!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

# {{{ _args_to_find( 'meta', [...] )

sub _args_to_find {
  my $self = shift;
  my $path = shift;
  my $quantifier = '';
  if ( @_ and @_ > 1 ) {
    my ( %attributes ) = @_;
    $quantifier =
      "[" .
      join(";", map { qq{\@$_="$attributes{$_}"} } keys %attributes ) .
      "]";
  }
  elsif ( @_ and @_ == 1 ) {
    my ( $index ) = @_;
    $quantifier = "[$index]";
  }

  my $xpath = qq{//} . $path . $quantifier;
  my $tags = $self->dom->find( $xpath );
  if ( @$tags and @$tags > 1 ) {
    $self->string( [
      map { $_->toString( 1 ) } @$tags
    ] );
  }
  elsif ( @$tags ) {
    $self->string( $tags->[0]->toString( 1 ) );
  }
  else {
croak "Traversing '$xpath', no tags found!";
  }
}

# }}}

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use JGoff::HTML::Stringy;

    my $parser = JGoff::HTML::Stringy->new();
    my $url = "http://www.google.co.uk/#hl=en&tbo=d&output=search&sclient=psy-ab&q=foo&oq=foo&gs_l=hp.3..0l4.25597.25938.0.26653.3.3.0.0.0.0.121.263.2j1.3.0.les%3B..0.0...1c.1.o2KCPLA0oKk&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.&bvm=bv.41248874,d.d2k&fp=ab9bec1cef6ba957&biw=1024&bih=643";

    my $first_hit =
    $parser->
      Html( $url )->
      Body->
      Div( 4 )->Div( 2 )->Div->Div( 7 )->Div->Div( 3 )->Div->Div( 2 )->
      Div -> Ol -> Li -> Div -> H2;

#/html/body/div[4]/div[2]/div/div[7]/div/div[3]/div/div[2]/div/ol/li/div/h3
    
    ...

=head1 METHODS

=head2 Html( $value )

Accepts one of: Scalar reference, Filehandle reference, scalar.

Scalar references are assumed to reference strings, and the string is read and parsed as if it were HTML. If the argument is a filehandle, the file is read to exhaustion and treated as HTML.

Scalars beginning with 'http://' or 'https://' are treated as URLs and are downloaded. Otherwise the content is assumed to be a local filename and the module tries to read that from disk.

=cut

# {{{ Html()

sub Html {
  my $self = shift;
  my ( $input ) = @_;

  if ( ref( $input ) and ref( $input ) eq 'SCALAR' ) {
    $self->dom( XML::LibXML->load_xml( string => $$input ) );
    $self->string( $$input );
  }
  else {
croak "URL / filehandle not implemented yet";
  }
  return $self;
}

# }}}

=head2 Head

Returns the content of the HTML's <head/> section, if any. There should only be one of these, so no other options are offered. Note that while you can print the stringified version of the text, this is also an object, so you can proceed to use any of the methods below on it.

For instance, C<< $p->Html( $url )->Head->Title >> will return the <title/> tag embedded within the head. Directly calling C<< $p->Html( $url )->Title >> will have the same effect due to how the method calls are chained.

=cut

=head2 Body

Much like C<Head()>, but it returns the <body/> section of the document. Again, there should only be one <body/> in a well-formed HTML document, so no other options are offered. C<< $p->Html( $url )->Body >> should return the content of the body portion of the document.

=cut

=head2 Title

Again, a well-formed HTML document should only have one <title/> section, so no options are on offer here. C<< $p->Html( $url )->Head->Title >> will return the HTML document's <title/> section, as will C<< $p->Html( $url )->Title >>, because these are simply handy shortcuts for the XPath '//title'.

=cut

=head2 Meta( ... )

This method is slightly different than the ones before, because documents can have more than one <meta/> tag within them. Without arguments, this returns an arrayref of all <meta/> tags at the current document level. While there is probably a way to force it to return an array, I'd rather go this route than delve deeper into L< perldoc overload > than I have to.

If you want the Nth <meta/> tag (zero-indexed, simply pass the desired number to Meta() like so: C<< $p->Html( $url )->Meta( 5 ) >> to return the 6th <meta/> tag on the page.

Searching for a <meta/> tag by name is as simple as C<< $html->Meta( name => 'keywords' ) >>, and searching for all property tags can be done with C<< $html->Meta( property => '*' ) >>. Of course if you happen to have a property named '*' that may be problematic, I'll probably come up with a better syntax than this shortly.

This convention will work for all other tag types. At release, all tag names through HTML4 should be implemented, and a table will follow below. It's safe to assume that any HTML4 tag you need (and most HTML5 as well) will be there with the first letter upper-cased, all others lower-case.

=cut

=head2 Link

This follows the same convention as C<Meta()>, so to access the Nth <link/> tag call C<< $html->Link( 2 ) >>, named <link/> tags like C<< $html->link( rel => 'stylesheet' ) >>.

=cut

=head2 H1

This follows the same convention as C<Meta()>, so to access the Nth <h1/> tag call C<< $html->H1( 2 ) >>, named <h1/> tags like C<< $html->H1( class => 'foo' ) >>.

=cut

=head2 Span

=cut

=head1 AUTHOR

Jeff Goff, C<< <jgoff at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-jgoff-html-stringy at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=JGoff-HTML-Stringy>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JGoff::HTML::Stringy


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JGoff-HTML-Stringy>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JGoff-HTML-Stringy>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JGoff-HTML-Stringy>

=item * Search CPAN

L<http://search.cpan.org/dist/JGoff-HTML-Stringy/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Jeff Goff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of JGoff::HTML::Stringy
