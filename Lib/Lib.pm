package X11::Lib;

# Copyright 1997 by Ken Fox

use DynaLoader;

use strict;
use vars qw($VERSION @ISA);

BEGIN {
    $VERSION = 1.0;
    @ISA = qw(DynaLoader);

    use X11::LibCons;

    bootstrap X11::Lib;
}

sub beta_version { 2 };

sub alias_trimmed_pattern {
    my($pkg, $stab, $pattern) = @_;

    my $key;
    my $val;

    while (($key, $val) = each(%{$stab})) {
	local(*entry) = $val;
	if (defined &entry) {
	    if ($key =~ s/$pattern//) {
		no strict 'refs';
		*{$pkg.'::'.$key} = \&entry;
	    }
	}
    }
}

sub export_pattern {
    my($stab, $pattern, $pkg) = @_;

    my $key;
    my $val;

    ($pkg) = caller(1) if (!$pkg);

    while (($key, $val) = each(%{$stab})) {
	local(*entry) = $val;
	if (defined &entry) {
	    if ($key =~ /$pattern/) {
		no strict 'refs';
		*{$pkg.'::'.$key} = \&entry;
	    }
	}
    }
}

sub export_symbol {
    my($stab, $symbol, $pkg) = @_;

    my $val = $stab->{$symbol};

    ($pkg) = caller(1) if (!$pkg);

    if (defined $val) {
	local(*entry) = $val;
	if (defined &entry) {
	    no strict 'refs';
	    *{$pkg.'::'.$symbol} = \&entry;
	    return 1;
	}
    }
}

sub import {
    my $module = shift;
    my %done;

    foreach my $sym (@_) {
	next if ($done{$sym});

	if ($sym eq ':X') {
	    export_pattern(\%X::, '^X');
	}
	elsif ($sym eq ':private') {
	    export_symbol(\%X11::Lib::, 'export_pattern');
	    export_symbol(\%X11::Lib::, 'export_symbol');
	    export_symbol(\%X11::Lib::, 'alias_trimmed_pattern');
	}
	else {
	    export_symbol(\%X::, $sym);
	}

	$done{$sym} = 1;
    }
}

my $finished_standard_aliases = 0;

sub use_standard_aliases {
    if (!$finished_standard_aliases) {
	$finished_standard_aliases = 1;

	# What should be done about the Xrm functions?  These seem
	# kind of odd when aliased to X::rm.

	alias_trimmed_pattern("X", \%X::, '^X');
    }
}

package X;

sub True () { 1 };
sub False () { 0 };

sub cvt_to_Boolean ($) {
    return ($_[0] == 1 || $_[0] =~ /^-?true$/i) ? 1 : 0;
}

package X::Drawable;

# Windows and Pixmaps are both Drawables so any function
# taking a Drawable can take one of these.  (Perl checks
# the argument type while C does not.)

package X::Window;
    use vars qw(@ISA);
    @ISA = qw(X::Drawable);

package X::Pixmap;
    use vars qw(@ISA);
    @ISA = qw(X::Drawable);

package X::Event;

    sub synthetic {
	my $classname = shift;
	my $type = shift;

	my $event = X::Event::internal_new($type);
	my $window;
	my $screen;

	if (@_) {
	    if (ref($_[0]) eq 'X::Display') {
		my $dpy = shift;
		$event->set_display($dpy);
		$screen = X::DefaultScreenOfDisplay($dpy);
		$window = X::DefaultRootWindow($dpy);
	    }
	    elsif (ref($_[0]) eq 'X::Screen') {
		$screen = shift;
		$event->set_display(X::DisplayOfScreen($screen));
		$window = X::RootWindowOfScreen($screen);
	    }
	    elsif (ref($_[0])) {
		my $w = shift;
		$event->set_display($w->Display);
		$screen = $w->Screen;
		$window = $w->Window;
	    }

	    if (@_ && ref($_[0]) eq 'X::Window') {
		$window = shift;
	    }
	}

	if ($window) {
	    $event->set_window($window);
	}

	$event->complete($screen, $window, @_);
	$event;
    }

    sub complete {
	my($event, $screen, $window, @options) = @_;
    }

# Additional pure-virtual events are inserted into the event
# hierarchy to avoid duplicate definitions of all the member
# access functions.  Not sure why MIT didn't do this to begin
# with.

package X::Event::_XY;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

    sub complete {
	my($event, $screen, $window, $options) = @_;

	if (defined $screen) {
	    $event->set_root(X::RootWindowOfScreen($screen));
	}

	my $x = 1;
	my $y = 1;

	if (ref($options) eq 'ARRAY' && @{$options} > 2) {
	    $x = shift @{$options};
	    $y = shift @{$options};
	}

	$event->set_x($x);
	$event->set_y($y);

	$event->set_time(X::CurrentTime);
    }

package X::Event::MotionEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_XY);

package X::Event::ButtonEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_XY);

    sub complete {
	my($event, $screen, $window, @options) = @_;

	X::Event::_XY::complete($event, $screen, $window, \@options);

	my $state = 0;

	if (@options > 1) {
	    $state = shift(@options);
	}

	my $button = shift(@options) || X::Button1;

	$event->set_state($state);
	$event->set_button($button);
    }

package X::Event::ButtonPressedEvent;
    # This event class is identical to ButtonEvent. It is
    # only carried around as a separate class because some
    # Widget sets require ButtonPress events (and they
    # don't check the event type field because the function
    # prototypes require a ButtonPress object).

    use vars qw(@ISA);
    @ISA = qw(X::Event::ButtonEvent);

package X::Event::KeyEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_XY);

    sub complete {
	my($event, $screen, $window, @options) = @_;

	X::Event::_XY::complete($event, $screen, $window, \@options);

	my $state = 0;

	if (@options > 1) {
	    $state = shift(@options);
	}

	my $keycode = shift(@options) || 0x020;

	$event->set_state($state);
	$event->set_keycode($keycode);
    }

package X::Event::CrossingEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_XY);

package X::Event::_Expose;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ExposeEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_Expose);

package X::Event::GraphicsExposeEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event::_Expose);

package X::Event::NoExposeEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ColormapEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::FocusChangeEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::KeymapEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::PropertyEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ResizeRequestEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::CirculateEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ConfigureEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::CreateEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::DestroyEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::GravityEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::MapEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ReparentEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::UnmapEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::CirculateRequestEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ConfigureRequestEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::MapRequestEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::ClientMessageEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::MappingEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::SelectionClearEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::SelectionEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::SelectionRequestEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);

package X::Event::VisibilityEvent;
    use vars qw(@ISA);
    @ISA = qw(X::Event);


X11::Lib::use_standard_aliases();

1;
