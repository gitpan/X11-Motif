#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;

my $toplevel = X::Toolkit::initialize("Example");

give $toplevel -Canvas,
		-width => 200,
		-height => 200,
		-bg => 'blue',
		-resizeCallback => \&resize,
		-exposeCallback => \&redraw;

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
	# no way to set the fields in a GCValues struct -- also
	# we don't have symbolic mask values yet (but if we do
	# the GCValues object properly we shouln't need to use
	# the mask values very often.)
	$gc = X::CreateGC($dpy, $win, 0, new X::GCValues);

	# no symbolic values yet.  FIXME
	X::SetLineAttributes($dpy, $gc, 5, 2, 2, 1);

	# this is a bizarre kludge, isn't it?  FIXME
	X::SetDashes($dpy, $gc, 0, chr(10).chr(10), 2);
    }

    my($w, $h) = query $wid -width, -height;
    my $ox = $w/2;
    my $oy = $h/2;

    X::DrawLine($dpy, $win, $gc, $ox, 0,   $ox, $h);
    X::DrawLine($dpy, $win, $gc, 0,   $oy, $w,  $oy);
}

handle $toplevel;
