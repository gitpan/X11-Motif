#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Lib;

my $indent = 0;
my $display = X::OpenDisplay($ENV{'DISPLAY'});

die "can't open display" if (!defined $display);

show_tree(X::DefaultRootWindow($display));
exit 0;

sub show_tree {
    my ($w) = @_;
    my ($root, $parent, $children, $num);

    show_info($w);

    ++$indent;

    X::QueryTree($display, $w, $root, $parent, $children, $num);
    foreach (@{$children}) {
	show_tree($_);
    }

    --$indent;
}

sub show_info {
    my ($w) = @_;

    my ($root, $x, $y, $width, $height, $border, $depth);

    X::GetGeometry($display, $w, $root,
		   $x, $y, $width, $height,
		   $border, $depth);

    my $title;
    my $class = X::AllocClassHint;

    X::FetchName($display, $w, $title);
    X::GetClassHint($display, $w, $class);

    my $name = (defined $title) ? "'$title' " : '';

    if (defined $class->name) {
	$name .= $class->name . '.' . $class->class . ' ';
    }

    my $geom = "${width}x${height}";

    $geom .= (($x >= 0) ? '+' : '') . $x;
    $geom .= (($y >= 0) ? '+' : '') . $y;

    print ' ' x ($indent * 4), sprintf("0x%08x ", $w->id), "$name$geom\n";
}
