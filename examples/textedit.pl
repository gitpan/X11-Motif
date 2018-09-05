
use blib;
use strict;
use X11::Motif qw(:Xt :Xm);

my $toplevel = X::Toolkit::initialize("Baraha");
my $form = give $toplevel -Form;
my $tex = give $form -Text,
	-columns => 30,
	-rows => 20,
	-editMode => XmMULTI_LINE_EDIT;

constrain $tex
	 -top => -form,
	-bottom => -form,
	-left => -form,
	-right => -form;

XtAddCallback($tex, XmNmodifyVerifyCallback, \&TranslitText, 0);

handle $toplevel;

sub TranslitText {
    my($w, $client, $call) = @_;

    if (defined($call)) {
	print "Ok\n";
    } else {
	print "Why??\n";
    }
}
