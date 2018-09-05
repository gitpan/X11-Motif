#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;
use Devel::Peek;

my $toplevel = X::Toolkit::initialize("SendEvent");

print "keycode for keysym XK_X is ", X::KeysymToKeycode($toplevel->Display, 0x058)->id, "\n";

my $form = give $toplevel -Form;

my $send = give $form -Button,
		-text => 'Send Event',
		-command => \&do_send_event;

constrain $send -top => -form, -bottom => -form, -left => -form, -right => -form;

$toplevel->debug_handle(\&trace_events);

sub do_send_event {
    my($w) = @_;

    my $e = synthetic X::Event (X::KeyPress, $w, X::KeysymToKeycode($w->Display, ord(' ')));

    print "\nSENDING event ", ref($e), "\n";
    print "  display = ", $e->display->id, "\n";
    print "  window = ", $e->window->id, "\n";
    print "  x = ", $e->x, "\n";
    print "  y = ", $e->y, "\n";
    print "  state = ", $e->state, "\n";
    print "  keycode = ", $e->keycode->id, "\n\n";

    X::SendEvent($w->Display, $w->Window, X::True, X::KeyPressMask, $e);

    $e = synthetic X::Event (X::KeyRelease, $w, X::KeysymToKeycode($w->Display, ord(' ')));
    X::SendEvent($w->Display, $w->Window, X::True, X::KeyReleaseMask, $e);
}

sub trace_events {
    my($e) = @_;

    print "event is ", ref($e), "\n";
    print "  type = ", $e->type, "\n";
    print "  display = ", $e->display->id, "\n";
    print "  window = ", $e->window->id, "\n";
    print "  send_event? = ", $e->send_event, "\n";

    if ($e->type == X::KeyPress) {
	print "  x = ", $e->x, "\n";
	print "  y = ", $e->y, "\n";
	print "  state = ", $e->state, "\n";
	print "  keycode = ", $e->keycode->id, "\n";
    }
}
