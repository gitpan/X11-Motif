#!/ford/thishost/unix/div/ap/bin/perl -w

#use blib;
use strict;

use X11::Motif;

my $toplevel = X::Toolkit::initialize('InfoBox');
my $rc = give $toplevel -RowColumn;

give $rc -Button,
	    -text => 'Create Message Dialog',
	    -command => [ \&do_create_dialog, \&X::Motif::XmCreateMessageDialog ];

give $rc -Button,
	    -text => 'Create Error Dialog',
	    -command => [ \&do_create_dialog, \&X::Motif::XmCreateErrorDialog ];

give $rc -Button,
	    -text => 'Create Question Dialog',
	    -command => [ \&do_create_dialog, \&X::Motif::XmCreateQuestionDialog ];

give $rc -Button,
	    -text => 'Create Information Dialog',
	    -command => [ \&do_create_dialog, \&X::Motif::XmCreateInformationDialog ];

give $rc -Button,
	    -text => 'Create File Selection Dialog',
	    -command => [ \&do_create_dialog, \&X::Motif::XmCreateFileSelectionDialog ];

give $rc -Button,
	    -text => 'Create Custom Form Dialog',
	    -command => \&do_create_form_dialog;

give $rc -Button,
	    -text => 'Create Custom Transient Dialog',
	    -command => \&do_create_transient_dialog;

handle $toplevel;

# The "built-in" Motif dialogs are pretty simple.  They are ok for
# the narrow purpose they were designed for, but don't try to do fancy
# things with them.  (Some people unmanage buttons and insert new
# widgets into these canned dialogs, but that requires a lot of
# detailed Motif knowledge.)

sub do_create_dialog {
    my($widget, $client, $call) = @_;

    my $shell = $widget->Shell;
    my $dialog = &$client($shell, 'name', -dialogTitle => 'Built-In Dialog Test');

    $dialog->Manage;
}

# The "flexible" Motif dialogs basically just give you a container
# widget (like a form or bulletin board) nested inside a generic
# Motif dialog.  You can do a lot of things with these widgets, but
# there are also some gotchas.  The worst is the stupid Motif default
# to dismiss the dialog when somebody pushes a button -- regardless
# of the callbacks you've defined.  You should read the Motif docs
# or a good Motif book before doing fancy things with Motif dialogs.
#
# These dialogs are a bit complex, but worth learning.

sub do_create_form_dialog {
    my($widget, $client, $call) = @_;

    my $form = X::Motif::XmCreateFormDialog($widget, 'name', -dialogTitle => 'Custom Form Dialog');

    my $label = give $form -Label, -text => 'Hello, world';
    my $button = give $form -Button, -text => 'OK';

    constrain $label  -top => -form, -bottom => $button, -left => -form, -right => -form;
    constrain $button -bottom => -form, -left => -form, -right => -form;

    $form->Manage;
}

# My favorite way to create dialogs is the generic X Toolkit way.
# Create a shell widget and then a single child, usually a container
# of some sort.  There aren't any gotchas or secret defaults here.
# When you're done, manage the child and popup the shell.
#
# One down-side to this technique is that the dialog is not
# automatically placed on the screen according to Motif rules.
# You can set '-x' and '-y' on the $shell if it's a problem.
#
# This technique works well for toplevel application windows too.
# (Those windows won't automatically iconify with the parent like
# transient dialogs do.)

sub do_create_transient_dialog {
    my($widget, $client, $call) = @_;

    my $shell = give $widget -Transient,
			-resizable => X::True,
			-title => 'Transient Dialog';

    my $form = give $shell -Form, -managed => X::False,
			-resizePolicy => X::Motif::XmRESIZE_GROW,
			-horizontalSpacing => 5,
			-verticalSpacing => 5;

    my $label = give $form -Label, -text => 'Hello, world';
    my $button = give $form -Button, -text => 'OK';

    constrain $label  -top => -form, -bottom => $button, -left => -form, -right => -form;
    constrain $button -bottom => -form, -left => -form, -right => -form;

    $form->Manage;
    $shell->Popup(X::Toolkit::GrabNonexclusive);
}
