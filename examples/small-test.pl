#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;

print "Using X11::Motif version $X11::Motif::VERSION.\n";
print "This is beta #", X11::Motif::beta_version(), "\n" if (X11::Motif::beta_version());

my $toplevel = X::Toolkit::initialize("Example");

$toplevel->set_inherited_resources("*background" => "#ff0000",
				   "*foreground" => "#000000");

print "initialized Xt\n";

my $form = give $toplevel -Form;

my $menubar = give $form -MenuBar;
my $menu = give $menubar -Menu, -name => 'File';
    give $menu -Button, -name => 'Get Info', -command => \&do_get_info;
    give $menu -Button, -name => 'Exit', -command => sub { exit };

my $quit = give $form -Button,
		-background => 'yellow',
		-text => 'Exit',
		-command => sub { exit };

constrain $menubar -top => -form, -left => -form, -right => -form;
constrain $quit -top => $menubar, -bottom => -form, -left => -form, -right => -form;

handle $toplevel;

sub do_get_info {
    my($w) = @_;

    my $root;
    my $x;
    my $y;
    my $width;
    my $height;
    my $border_width;
    my $depth;

    X::GetGeometry($w->Display, $w->Window, $root,
		   $x, $y, $width, $height,
		   $border_width, $depth);

    print "AFTER:\n";
    print "root = ", $root->id, "\n";
    print "x = $x\n";
    print "y = $y\n";
    print "width = $width\n";
    print "height = $height\n";
    print "border_width = $border_width\n";
    print "depth = $depth\n";

    my $title;
    my $class = X::AllocClassHint;

    X::FetchName($w->Display, $toplevel->Window, $title);
    X::GetClassHint($w->Display, $toplevel->Window, $class);

    print "TITLE = $title\n";
    print "NAME = ", $class->name, "\n";
    print "CLASS = ", $class->class, "\n";

    my $parent;
    my $children;
    my $num;

    X::QueryTree($w->Display, $toplevel->Window, $root, $parent, $children, $num);

    print "root = ", $root->id, "\n";
    print "parent = ", $parent->id, "\n";
    print "children = $children\n";
    print "num children = $num\n";

    if (ref $children eq 'ARRAY') {
	foreach (@{$children}) {
	    print "  child = $_\n";
	}
    }
}
