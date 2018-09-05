#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;

my $toplevel = X::Toolkit::initialize("Example");

my $canvas = give $toplevel -Canvas,
		-width => 200,
		-height => 200,
		-bg => 'blue',
		-resizeCallback => \&resize,
		-exposeCallback => \&redraw;

my @row = ();
my $data_A = [];
my $data_B = [];
my $data_C = [];

foreach (0 .. 99) {
    $row[$_] = $_;
}

foreach (0 .. 99) {
    push @{$data_A}, [ @row ];
}

# CreateGrayImage(widget, raw_data, max_value, num_colors, min_value)
my $image_A = X::Toolkit::CreateGrayImage($canvas, $data_A, 99, 32);

for my $x (0 .. 99) {
    for my $y (0 .. 99) {
	$data_B->[$x][$y] = $data_A->[$y][$x];
    }
}

my $image_B = X::Toolkit::CreateGrayImage($canvas, $data_B, 99, 32);

# once the raw_data has been loaded into an image, it isn't used
# anymore.  this means that we could over-write data_B instead
# of creating another raw_data array.  keeping everything around
# is easier for playing with the code.
for my $x (0 .. 99) {
    for my $y (0 .. 99) {
	$data_C->[$x][$y] = $data_A->[$x][$y] + $data_B->[$x][$y];
    }
}

my $image_C = X::Toolkit::CreateGrayImage($canvas, $data_C, 198, 32);

my $gc;

sub resize {
    my($wid) = @_;

    my $dpy = $wid->Display();
    my $win = $wid->Window();

    # X::ClearWindow doesn't trigger any exposures, so we
    # have to call this.
    X::ClearArea($dpy, $win, 0, 0, 0, 0, X::True);
}

sub redraw {
    my($wid) = @_;

    my $dpy = $wid->Display();
    my $win = $wid->Window();

    if (!defined($gc)) {

	my $root_win;
	my ($x, $y, $width, $height);
	my ($border_width, $depth);

	my $r = X::GetGeometry($dpy, $win, $root_win, $x, $y, $width, $height, $border_width, $depth);

	print "X::GetGeometry($dpy, $win [id = ", $win->id(), "]) -> $r\n";
	if ($r) {
	    print "  root_win = $root_win [id = ", $root_win->id(), "]\n";
	    print "  x = $x\n";
	    print "  y = $y\n";
	    print "  width = $width\n";
	    print "  height = $height\n";
	    print "  border_width = $border_width\n";
	    print "  depth = $depth\n";
	}

	# no way to set the fields in a GCValues struct -- also
	# we don't have symbolic mask values yet (but if we do
	# the GCValues object properly we shouln't need to use
	# the mask values very often.)
	$gc = X::CreateGC($dpy, $win, 0, new X::GCValues);

	# no symbolic values yet.  FIXME
	X::SetLineAttributes($dpy, $gc, 4, 2, 2, 1);

	# this is a bizarre kludge, isn't it?  FIXME
	X::SetDashes($dpy, $gc, 0, chr(10).chr(10), 2);
    }

    my($w, $h) = query $wid -width, -height;
    my $ox = $w/2;
    my $oy = $h/2;

    my $img_w = $ox - 10; if ($img_w < 5) { $img_w = 5 }
    my $img_h = $oy - 10; if ($img_h < 5) { $img_h = 5 }

    X::PutImage($dpy, $win, $gc, $image_A, 0, 0,       5,       5, $img_w, $img_h);
    X::PutImage($dpy, $win, $gc, $image_B, 0, 0, $ox + 5,       5, $img_w, $img_h);
    X::PutImage($dpy, $win, $gc, $image_C, 0, 0, $ox + 5, $oy + 5, $img_w, $img_h);

    X::DrawLine($dpy, $win, $gc, $ox, 0,   $ox, $h);
    X::DrawLine($dpy, $win, $gc, 0,   $oy, $w,  $oy);
}

handle $toplevel;
