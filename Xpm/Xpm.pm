package X11::Xpm;

# Copyright 1997, 1998 by Ken Fox

use DynaLoader;

use strict;
use vars qw($VERSION @ISA);

BEGIN {
    $VERSION = 1.0;
    @ISA = qw(DynaLoader);

    bootstrap X11::Xpm;
}

sub beta_version { 3 };

package X::Xpm;

sub CreatePixmap {
    my($widget, $source => $data) = @_;

    my $dpy = $widget->Display;
    my $win = X::RootWindowOfScreen($widget->Screen);

    my($visual, $colormap, $depth);

    if (X::Toolkit::toplevel_has_custom_visual()) {
	my $shell = $widget->Shell;
	($visual, $colormap, $depth) = query $shell -visual, -colormap, -depth;
    }

    if ($source eq '-file') {
	return ReadFileToPixmap($dpy, $win, $data,
				$visual, $colormap, $depth);
    }
    else {
	return CreatePixmapFromData($dpy, $win, $data,
				    $visual, $colormap, $depth);
    }
}

sub CreatePixmapFromData {
    my($dpy, $d, $data, $visual, $colormap, $depth) = @_;

    if (! ref $data) {
	$data = [ split(/\n/, $data) ];
    }

    return CreatePixmapFromData_array($dpy, $d, $data,
				      $visual, $colormap, $depth);
}

1;
