#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;
use Cwd;

use strict;
use X11::Motif qw(:Xt :Xm);

sub select_directory {
    my($toplevel, $filter_string, $dialog_title, $dirname) = @_;

    my $button_ok;
    my $button_cancel;
    my $dir_list;
    my $field_selection;
    my $file_form;
    my $selected_directory;
    my $selection_finished;
    my $shell;
    
    ($button_ok, $button_cancel, $dir_list, $field_selection, $file_form, $shell) =
    					create_Directory_Selection_Dialog($toplevel, $dialog_title);

    if ($dirname eq "" || $dirname eq ".") {
               $dirname = getcwd();
    }

    if ($dirname eq "..") {
               $dirname = getcwd();
               $dirname =~ s|/[^/]*$||;
               $dirname = '/' if ($dirname eq "");
    }

    my $ok_callback = sub {
	my ($widget, $client, $call) = @_;
	my $selection = XmTextFieldGetString($field_selection);

	if (-d $selection) {
		$selected_directory = XmTextFieldGetString($field_selection);
	}
	else {
		$selected_directory = "NULL";
	}
	$selection_finished = 1;
    };

    XtAddCallback($button_ok, XmNactivateCallback, $ok_callback, 0);
    XtAddCallback($field_selection, XmNactivateCallback, 
					sub {
                                            my ($widget, $client, $call) = @_;
						my $dirname = XmTextFieldGetString($widget);
						if(-d $dirname) {
                                                	updateDirectoryList($dir_list, $dirname);
						}
						else {
                                                    X::Bell($widget->Display(), 100);
						}
					},
					 0);

    XtAddCallback($button_cancel, XmNactivateCallback,
					sub {
					    my ($widget, $client, $call) = @_;
					    $selection_finished = 1;
					}, 0);

    XtAddCallback($dir_list, XmNdefaultActionCallback,
                                        sub {
                                            my ($widget, $client, $call) = @_;
                                                my($selected_dir) = $call->selected_items();
                                                my $dirname = XmTextFieldGetString($field_selection);
                                                if (defined $selected_dir) {
                                                    $selected_dir = $selected_dir->plain;
                                                    if ($selected_dir eq "..") {
                                                        $dirname =~ s|/[^/]*$||;
                                                        $dirname = '/' if ($dirname eq "");
                                                    }
                                                    else {
							if ($dirname eq "/") {
                                                        	$dirname = $dirname . $selected_dir;
							}
							else {
                                                                $dirname = $dirname . "/" . $selected_dir;
							}
                                                    }
 
                                                    updateDirectoryList($dir_list, $dirname);
                                                    XtSetValues($field_selection, XmNvalue,
                                                                $dirname);
                                                    XtSetValues($field_selection, XmNcursorPosition,
                                                                length $dirname);

                                                }
                                                else {
                                                    X::Bell($widget->Display(), 100);
                                                }
                                        }, 0);
 
 
    XtSetValues($field_selection, XmNvalue, $dirname);
    XtSetValues($field_selection, XmNcursorPosition, length $dirname);

    if(-d $dirname) {
    	updateDirectoryList($dir_list, $dirname);
    }
    else {
        X::Bell($shell->Display(), 100);
    }

    XtManageChild($file_form);

    my $app_context = $file_form->WidgetToApplicationContext();
    my $e;

    $selection_finished = 0;

    do {
	$e = $app_context->AppNextEvent();
	X::Toolkit::DispatchEvent($e);
    } while (!$selection_finished);

    XtDestroyWidget($shell);

    return $selected_directory;
}

use vars qw($hide_dot_files);
$hide_dot_files = 1;
 

sub updateDirectoryList {
    my($dir_widget, $dirname) = @_;

    if (opendir(CONFIG_DIR, $dirname)) {
	my $filename;
	my $testname;
	my @dir_list = ();
	my @sorted_dir_list = ();
	my $dir_position = 1;


	while (defined($filename = readdir(CONFIG_DIR))) {
            next if ($filename eq "." || $filename eq ".." || ($filename =~ /^\./ && $hide_dot_files));

	    $testname = $dirname . "/" . $filename;

	    if(-d $testname && -r $testname) {
		push @dir_list, $filename;
	    }

	}

	closedir(CONFIG_DIR);

	XmListDeleteAllItems($dir_widget);

	@sorted_dir_list = sort {$a cmp $b} @dir_list;
	unshift @sorted_dir_list, "..";


	foreach $filename (@sorted_dir_list) {
	    XmListAddItem($dir_widget, XmStringCreateSimple($filename), $dir_position);
	    $dir_position++;
	}

	if ($dir_position == 1) {
	    XmListAddItem($dir_widget, XmStringCreateSimple("[NONE]"), $dir_position);
	}

    }
}
 
sub create_Directory_Selection_Dialog {
    my($toplevel, $dialog_title) = @_;

    my $shell = X::Toolkit::CreatePopupShell("dialog_shell", xmDialogShellWidgetClass, $toplevel,
						XmNwidth, 300,
						XmNheight, 400,
						XmNallowShellResize, 1,
						XmNtitle, $dialog_title);

    my $fileform = give $shell -Form, -managed => X::False, -width => 300, -height => 400,
                        -dialogstyle => XmDIALOG_PRIMARY_APPLICATION_MODAL;


#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------

    my $directory_list_form = give $fileform -Form;

    my $directories_label = give $directory_list_form -Label,
                                -alignment => XmALIGNMENT_BEGINNING,
                                -text => 'Directories';

    my $dir_scrolled_window = XtCreateManagedWidget("scrolledWindow", xmScrolledWindowWidgetClass,
						$directory_list_form, XmNx, 0, XmNy, 165, XmNheight, 200);

    my $directory_list = XtCreateManagedWidget("directoryList", xmListWidgetClass, 
						$dir_scrolled_window,
						XmNscrollBarDisplayPolicy, XmSTATIC,
						XmNselectionPolicy, XmBROWSE_SELECT,
						XmNlistSizePolicy, XmCONSTANT);

    constrain $directories_label -top => -form, -left => -form, -right => -form;
    constrain $dir_scrolled_window -top => $directories_label, -bottom => -form,
					-left => -form, -right => -form;





#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------

    my $selection_form = give $fileform -Form;

    my $selection_label = give $selection_form -Label,
                                -alignment => XmALIGNMENT_BEGINNING,
				-text => 'Selected Directory';

    my $selection_field = give $selection_form -Field;

    constrain $selection_label  -top => -form, -left => -form, -right => -form;
    constrain $selection_field  -top => $selection_label, -bottom => -form, -left => -form, -right => -form;



#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------


    my $button_form = give $fileform -Form;

    my $seperator = give $button_form -Separator;

    my $ok_button = give $button_form -Button,
				-text => 'OK';

    my $cancel_button = give $button_form -Button,
                                -text => 'Cancel';

    change $button_form -fractionBase => 2;
    constrain $seperator  -top => -form, -bottom => 1, -left => -form, -right => -form;
    constrain $ok_button  -top => 1, -bottom => -form, -left => -form, -right => 1;
    constrain $cancel_button  -top => 1, -bottom => -form, -left => 1, -right => -form;





#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
 
    my @fill_sides = ( -right => -form, -left => -form );

    change $fileform -fractionBase => 10;
    constrain $directory_list_form  -top => -form,
				-bottom => $selection_form , -leftoffset => 5,
				-left => -form, -right => -form, -rightoffset =>5;
    constrain $selection_form  -bottom => $button_form,  -leftoffset => 5, -rightoffset =>5, @fill_sides; 
    constrain $button_form -bottom => -form, -bottomoffset => 5,
				-leftoffset => 5, -rightoffset =>5, @fill_sides;

#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------


    return ($ok_button, $cancel_button, $directory_list, $selection_field, $fileform, $shell);
}

# -------------------------------------------------------------------------------
my $toplevel = X::Toolkit::initialize("Example");
my $form = give $toplevel -Form;

sub do_Directory_Selection_Dialog {
    my($widget, $client, $call) = @_;

    my $filter_string = "*.*";
    my $dirname = "..";
    my $dialog_title = "Directory Selection Dialog";

    my $selection = select_directory($toplevel, $filter_string, $dialog_title, $dirname);

    print "*** selected file $selection\n";
}

my $button = give $form -Button,
			-text => 'Manage Directory Selection Dialog',
			-command => \&do_Directory_Selection_Dialog;

handle $toplevel;
