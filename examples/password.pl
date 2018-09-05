#!../xperl -w

#use blib;

use strict;
use X11::Motif;

my $toplevel = X::Toolkit::initialize("Dialog");

my $form = give $toplevel -Form;

my $status = give $form -Label, -text => 'Not logged in';
my $login = give $form -Button, -text => 'Login', -command => \&do_login;
my $logout = give $form -Button, -text => 'Logout', -command => \&do_logout;

arrange $form -top => $status, -left => [ $login, $logout ];

handle $toplevel;

sub do_login {
    my $s = give $toplevel -DialogShell,
		-title => 'Login';

    my $f = give $s -Form,
		-managed => 0,
		-horizontalSpacing => 5,
		-verticalSpacing => 5;

    $f->set_inherited_resources('*prompt.width' => 150,
				'*prompt.alignment' => 'alignment_end',
				'*XmTextField.width' => 400,
				'*XmPushButton.width' => 100);

    my $u_label = give $f -Label,
		-name => 'prompt',
		-text => 'Metaphase Login: ';
    my $u_field = give $f -Field,
		-activateCallback => \&do_activate_login;

    my $p_label = give $f -Label,
		-name => 'prompt',
		-text => 'Password: ';
    my $p_field = give $f -Field,
		-secret => 1,
		-activateCallback => \&do_activate_password;

    my $sep = give $f -Separator;

    my $gap = give $f -Spacer;
    my $ok = give $f -Button, -text => 'OK', -command => \&do_ok;
    my $cancel = give $f -Button, -text => 'Cancel', -command => \&do_cancel;

    constrain $u_label -left => -form, -top => -form;
    constrain $u_field -left => $u_label, -top => -form, -right => -form;

    constrain $p_label -left => -form, -top => $u_field;
    constrain $p_field -left => $p_label, -top => $u_field, -right => -form;

    constrain $sep -left => -form, -top => $p_field, -bottom => $cancel, -right => -form;

    constrain $cancel -bottom => -form, -right => -form;
    constrain $ok -bottom => -form, -right => $cancel;
    constrain $gap -left => -form, -right => $ok, -bottom => -form;

    foreach my $w ($u_field, $p_field, $ok, $cancel) {
	X::Motif::XmAddTabGroup($w);
    }

    $f->Manage();
}

sub do_logout {
    change $status -text => 'Not logged in';
}

sub do_ok {
    change $status -text => 'Logged in';
}

sub do_cancel {
}

sub do_activate_login {
    my($w) = @_;
    X::Motif::XmProcessTraversal($w->Parent, X::Motif::XmTRAVERSE_NEXT_TAB_GROUP);
}

sub do_activate_password {
    my($w) = @_;
    print "password = '", (query $w -text), "'\n";
    print "         = '", (query $w -secret), "'\n";
    X::Motif::XmProcessTraversal($w->Parent, X::Motif::XmTRAVERSE_NEXT_TAB_GROUP);
}
