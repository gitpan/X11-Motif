#!/ford/thishost/unix/div/ap/bin/perl -w

# use blib;
use Cwd;
use strict;
use X11::Motif qw(:Xt :Xm);

sub select_file {
    my($toplevel, $filter_string, $dialog_title, $dirname) = @_;

    my $button_ok;
    my $button_cancel;
    my $dir_list;
    my $file_list;
    my $button_filter;
    my $field_filter;
    my $field_dir;
    my $field_selection;
    my $file_form;
    my $selected_file;
    my $selection_finished;
    my $shell;
    
    ($button_ok, $button_cancel, $button_filter, $dir_list, $file_list, 
     $field_filter, $field_dir, $field_selection, $file_form, $shell) = 
    create_File_Selection_Dialog($toplevel, $dialog_title);

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
	my $dir_status = opendir(CONFIG_DIR, $selection);

	if($dir_status) {
		$selected_file = "NULL";
	}
	else {
		$selected_file = XmTextFieldGetString($field_selection);
	}
	
	$selection_finished = 1;
    };

    XtAddCallback($button_ok, XmNactivateCallback, $ok_callback, 0);
    XtAddCallback($field_selection, XmNactivateCallback, 
					sub {
	                                    my ($widget, $client, $call) = @_;
						my $selection = XmTextFieldGetString( $widget);
						if (-f $selection) {
							$selected_file = 
								XmTextFieldGetString($field_selection);
							$selection_finished = 1;
						}
						else {
							X::Bell($widget->Display(), 100);
						}
					} , 0);

    XtAddCallback($button_cancel, XmNactivateCallback,
					sub {
					    my ($widget, $client, $call) = @_;
					    $selection_finished = 1;
					    if ($selected_file eq "") {
						$selected_file = "NULL";
					    }
					}, 0);

    XtAddCallback($button_filter, XmNactivateCallback,
					sub {
					    my ($widget, $client, $call) = @_;
						my $filter_string = XmTextFieldGetString($field_filter);
                                                my $dirname = XmTextFieldGetString($field_dir);
						if ($dirname eq "/") {
							$dirname = $dirname;
						}
						else {
                                                	$dirname = $dirname . "/";
						}
                                                if (-d $dirname && -r $dirname) {
                                                        updateDirectoryList($dir_list, $file_list,
                                                                       $dirname, $filter_string);
							XmTextFieldSetString($field_selection, $dirname);
							XtSetValues($field_selection, 
								XmNcursorPosition, length($dirname) + 1);

							XtManageChild($file_form);
                                                }
                                                else {
                                                        X::Bell($widget->Display(), 100);
                                                }

					}, 0);

    XtAddCallback($file_list, XmNsingleSelectionCallback,
					sub {
					    my ($widget, $client, $call) = @_;
						my ($select_file) = $call->selected_items();
						my $filename = XmTextFieldGetString($field_dir);
                                                if (defined $select_file) {
							if ($select_file->plain eq "[NONE]") {
		                                                    X::Bell($widget->Display(), 100);
							}
							else {
							   if ($filename eq "/") {
							   	$filename = $filename . $select_file->plain;
							   }
							   else {
                                                                $filename = 
                                                                        $filename . "/" . $select_file->plain;
							   }
							   XmTextFieldSetString($field_selection, $filename);
							   XtSetValues($field_selection, 
								XmNcursorPosition, 
								       length($filename) + 1);
							}

						}
                                                else {
                                                    X::Bell($widget->Display(), 100);
                                                }
					}, 0);


    XtAddCallback($dir_list, XmNdefaultActionCallback,
					sub {
					    my ($widget, $client, $call) = @_;
						my($selected_dir) = $call->selected_items();
						my $dirname = XmTextFieldGetString($field_dir);
						my $filter_string = XmTextFieldGetString($field_filter);
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

						    updateDirectoryList($dir_list, $file_list, 
									$dirname, $filter_string);
						    if ($dirname eq "/") {
						    	XtSetValues($field_selection, XmNvalue, $dirname);
							XtSetValues($field_selection, XmNcursorPosition,
									length($dirname) + 1);
						    }
						    else {
                                                        XtSetValues($field_selection, XmNvalue, 
									$dirname . "/");
                                                        XtSetValues($field_selection, XmNcursorPosition,
								    length($dirname) + 1);
						    }
						    XtSetValues($field_dir, XmNvalue,
								$dirname);
                                                    XtSetValues($field_dir, XmNcursorPosition,
								length($dirname) + 1);
						}
						else {
						    X::Bell($widget->Display(), 100);
						}
					}, 0);


    XtAddCallback($field_dir, XmNactivateCallback,
					sub {
					    my ($widget, $client, $call) = @_;
						my $dirname = XmTextFieldGetString($widget);
						my $filter_string = XmTextFieldGetString($field_filter);
						if (-d $dirname && -r $dirname) {
						 	updateDirectoryList($dir_list, $file_list,
                                                                        $dirname, $filter_string);
						}
						else {
							X::Bell($widget->Display(), 100);
                                                }
					}, 0);

    XtAddCallback($field_filter, XmNactivateCallback,
						sub {
					    		my ($widget, $client, $call) = @_;
							my $filter_string = XmTextFieldGetString($widget);
	                                                my $dirname = XmTextFieldGetString($field_dir);
							$dirname = $dirname . "/";
                                                	if (-d $dirname && -r $dirname) {
        							updateDirectoryList($dir_list, $file_list,
                                                                        $dirname, $filter_string);
                                                	}
                                                	else {
                                                        	X::Bell($widget->Display(), 100);
                                                	}

					}, 0);

    XtSetValues($field_dir, XmNvalue, $dirname);
    XtSetValues($field_dir, XmNcursorPosition, length($dirname) + 1);
    XtSetValues($field_filter, XmNvalue, $filter_string);
    if ($dirname eq "/") {
    	XtSetValues($field_selection, XmNvalue, $dirname);
    }
    else {
        XtSetValues($field_selection, XmNvalue, $dirname . "/");
    }
    XtSetValues($field_selection, XmNcursorPosition, length($dirname) + 1);


    updateDirectoryList($dir_list, $file_list, $dirname, $filter_string);

    XtManageChild($file_form);

    my $app_context = $file_form->WidgetToApplicationContext();
    my $e;

    $selection_finished = 0;

    do {
	$e = $app_context->AppNextEvent();
	X::Toolkit::DispatchEvent($e);
    } while (!$selection_finished);

    XtDestroyWidget($shell);

    return $selected_file;
}

use vars qw($hide_dot_files);
$hide_dot_files = 1;

sub updateDirectoryList {
    my($dir_widget, $file_widget, $dirname, $filter_pattern) = @_;

    $filter_pattern =~ s|\.|\\.|g;
    $filter_pattern =~ s|\?|.|g;
    $filter_pattern =~ s|\*|.*|g;
    $filter_pattern = "^".$filter_pattern."\$";


    if (opendir(CONFIG_DIR, $dirname)) {
	my $filename;
	my $testname;
	my @dir_list = ();
	my @file_list = ();
	my @sorted_dir_list = ();
	my @sorted_file_list = ();
	my $dir_position = 1;
	my $file_position = 1;


	while (defined($filename = readdir(CONFIG_DIR))) {
	    next if ($filename eq "." || $filename eq ".." || ($filename =~ /^\./ && $hide_dot_files));

	    $testname = $dirname . "/" . $filename;

	    if(-d $testname && -r $testname) {
		push @dir_list, $filename;
	    }

	    if(-f $testname && -r $testname) {
		push @file_list, $filename;
	    }
	}

	closedir(CONFIG_DIR);

	XmListDeleteAllItems($dir_widget);
	XmListDeleteAllItems($file_widget);

	@sorted_dir_list = sort {$a cmp $b} @dir_list;
	unshift @sorted_dir_list, "..";

	@sorted_file_list = sort {$a cmp $b} @file_list;

	foreach $filename (@sorted_dir_list) {
	    XmListAddItem($dir_widget, XmStringCreateSimple($filename), $dir_position);
	    $dir_position++;
	}

	if ($dir_position == 1) {
	    XmListAddItem($dir_widget, XmStringCreateSimple("[NONE]"), $dir_position);
	}

	foreach $filename (@sorted_file_list) {
	    if ($filename =~ /$filter_pattern/) {
		XmListAddItem($file_widget, XmStringCreateSimple($filename), $file_position);
		$file_position++;
	    }
	    else {
		print "$filename doesn't match $filter_pattern\n";
	    }
	}

	if ($file_position == 1) {
	    XmListAddItem($file_widget, XmStringCreateSimple("[NONE]"), $file_position);
	}
    }
}
 
sub create_File_Selection_Dialog {
    my($toplevel, $dialog_title) = @_;

    my $shell = X::Toolkit::CreatePopupShell("dialog_shell", xmDialogShellWidgetClass, $toplevel,
						XmNwidth, 300,
						XmNheight, 400,
						XmNallowShellResize, 1,
						XmNtitle, $dialog_title);

    my $fileform = give $shell -Form, -managed => X::False, -width => 300, -height => 400,
			-dialogstyle => XmDIALOG_PRIMARY_APPLICATION_MODAL;

#-------------------------------------------------------------------------
#	Directory Filter Creation and Constraints
#-------------------------------------------------------------------------

    my $directory_filter_form = give $fileform -Form;

    my $directory_label = give $directory_filter_form -Label,
				-alignment => XmALIGNMENT_BEGINNING,
				-text => 'Directory Filter';

    my $directory_field = give $directory_filter_form -Field;


    constrain $directory_label  -top => -form, -left => -form, -right => -form;
    constrain $directory_field  -top => $directory_label, -bottom => -form, -left => -form, -right => -form;




#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------

    my $directory_list_form = give $fileform -Form;

    my $filter_label = give $directory_list_form -Label,
                                -alignment => XmALIGNMENT_BEGINNING,
				-text => 'File Filter';

    my $filter_field = give $directory_list_form -Field;


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

    constrain $filter_label  -top => -form, -left => -form, -right => -form;
    constrain $filter_field  -top => $filter_label, -left => -form, -right => -form;
    constrain $directories_label -top => $filter_field, -left => -form, -right => -form;
    constrain $dir_scrolled_window -top => $directories_label, -bottom => -form,
					-left => -form, -right => -form;





#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------

    my $file_list_form = give $fileform -Form;

    my $file_label = give $file_list_form -Label,
                                -alignment => XmALIGNMENT_BEGINNING,
                                -text => 'Files';

    my $file_scrolled_window = XtCreateManagedWidget("scrolledWindow", xmScrolledWindowWidgetClass,
                                                $file_list_form, XmNx, 200, XmNy, 100, XmNheight, 265);
    my $file_list = XtCreateManagedWidget("fileList", xmListWidgetClass, $file_scrolled_window,
						XmNlistSizePolicy, XmCONSTANT,
                                                XmNselectionPolicy, XmSINGLE_SELECT,
                                            	XmNscrollBarDisplayPolicy, XmSTATIC);

    constrain $file_label  -top => -form, -left => -form, -right => -form;
    constrain $file_scrolled_window  -top => $file_label, -bottom => -form, -left => -form, -right => -form;


#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------

    my $selection_form = give $fileform -Form;

    my $selection_label = give $selection_form -Label,
                                -alignment => XmALIGNMENT_BEGINNING,
				-text => 'Selection';

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

    my $filter_button = give $button_form -Button,
                                -text => 'Filter';

    my $cancel_button = give $button_form -Button,
                                -text => 'Cancel';

    change $button_form -fractionBase => 3;
    constrain $seperator  -top => -form, -bottom => 1, -left => -form, -right => -form;
    constrain $ok_button  -top => 1, -bottom => -form, -left => -form, -right => 1;
    constrain $filter_button  -top => 1, -bottom => -form, -left => 1, -right => 2;
    constrain $cancel_button  -top => 1, -bottom => -form, -left => 2, -right => -form;





#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------
 
    my @fill_sides = ( -right => -form, -left => -form );

    change $fileform -fractionBase => 10;
    constrain $directory_filter_form  -top => -form, -topoffset => 5, -leftoffset => 5,
				-rightoffset =>5, @fill_sides;
    constrain $directory_list_form  -top => $directory_filter_form, 
				-bottom => $selection_form , -leftoffset => 5,
				-left => -form, -right =>4;
    constrain $file_list_form  -top => $directory_filter_form, 
				-bottom => $selection_form, -left => 4, -right => -form, -rightoffset => 5;
    constrain $selection_form  -bottom => $button_form,  -leftoffset => 5, -rightoffset =>5, @fill_sides; 
    constrain $button_form -bottom => -form, -bottomoffset => 5,
				-leftoffset => 5, -rightoffset =>5, @fill_sides;

#-------------------------------------------------------------------------
#
#-------------------------------------------------------------------------


    return ($ok_button, $cancel_button, $filter_button, $directory_list, $file_list, $filter_field,
		$directory_field, $selection_field, $fileform, $shell);
}

# -------------------------------------------------------------------------------
my $toplevel = X::Toolkit::initialize("Example");
my $form = give $toplevel -Form;

sub do_File_Selection_Dialog {
    my($widget, $client, $call) = @_;

    my $filter_string = "*.*";
    my $dirname;
    my $dialog_title = "File Selection Dialog";

    my $selection = select_file($toplevel, $filter_string, $dialog_title, $dirname);
    print "\n",'$selection = ',$selection,"\n";

}
my $button = give $form -Button,
			-text => 'Manage File Selection Dialog',
			-command => \&do_File_Selection_Dialog;

handle $toplevel;
