#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

package FileSelector;

use Cwd;
use Net::Domain qw(hostname);
use Net::FTP;
use File::Listing;
use X11::Motif;

use strict;
use vars qw($VERSION @ISA $after @matches);

$VERSION = 1.0;
@ISA = qw();

sub new {
    my $self = shift;
    my $class = ref($self) || $self;
    my($dirname, $pattern) = @_;

    $self = {
	'hide_dots' => 1,
	'hide_emacs' => 1,
	'storage' => 'file',
	'all_dirs' => [],
	'all_files' => [],
	'displayed_dirs' => [],
	'displayed_files' => [],
	'dialog_shell' => undef,
	'done' => 0
    };

    bless $self, $class;

    $self->switch_to($dirname);
    $self->filter($pattern);

    return $self;
}

sub popup {
    my $self = shift;
    my $shell = $self->{'dialog_shell'};

    if (!defined($shell)) {
	my($toplevel, $dialog_title);
	my $arg;

	while (defined($arg = shift)) {
	    if (X::Toolkit::Widget::IsWidget($arg)) {
		$toplevel = $arg;
	    }
	    else {
		$dialog_title = $arg;
	    }
	}

	$toplevel = X::Toolkit::toplevel() if (!defined($toplevel));
	$dialog_title = "Choose a File" if (!defined($dialog_title));

	my $dialog = $self->create_dialog($toplevel, $dialog_title);

	$dialog->ManageChild();
	$shell = $dialog->Parent();
    }

    $shell->Popup(X::Toolkit::GrabNonexclusive);
    $self->filter();
}

sub choose {
    my $self = shift;

    $self->popup(@_);

    my $shell = $self->{'dialog_shell'};
    my $context = $shell->WidgetToApplicationContext();
    my $event;

    $self->{'done'} = 0;

    X::Motif::XmProcessTraversal($self->{'dialog_choice'}, X::Motif::XmTRAVERSE_CURRENT);

    while (!$self->{'done'}) {
	$event = $context->AppNextEvent();
	X::Toolkit::DispatchEvent($event);
    }

    $self->popdown();

    if ($self->{'storage'} eq 'file') {
	return $self->{'selection'};
    }
    else {
	return $self->{'storage'} . '://' . $self->{'host'} . $self->{'selection'};
    }
}

sub popdown {
    my $self = shift;
    my $shell = $self->{'dialog_shell'};

    if (defined($shell)) {
	$shell->Popdown();
    }

    $self->{'done'} = 1;
}

sub destroy {
    my $self = shift;
    my $shell = $self->{'dialog_shell'};

    if (defined($shell)) {
	$shell->DestroyWidget();
	$self->{'dialog_shell'} = undef;
    }

    $self->{'done'} = 1;
}

sub ftp_switch_hosts {
    my $self = shift;
    my $ftp = $self->{'ftp'};

    if (defined $ftp) {
	$ftp->quit;
	$self->{'ftp'} = undef;
    }
}

sub metaphase_switch_hosts {
}

my %special_switch_hosts = (
    'ftp' => \&ftp_switch_hosts,
    'metaphase' => \&metaphase_switch_hosts
);

sub csh_style_expand {
    my($filename) = @_;
    my $user;

    if ($filename =~ s|^~([^/]*)||) {
	if ($1 ne '') {
	    $user = (getpwnam $1)[7];
	}
	else {
	    $user = $ENV{HOME};
	}
    }

    $filename =~ s|\${([^\}]+)}|$ENV{$1}|eg;
    $filename =~ s|\$(\w+)|$ENV{$1}|eg;

    if (defined $user) {
	if ($filename =~ m|^/|) {
	    $filename = $user . $filename;
	}
	else {
	    $filename = $user . '/' . $filename;
	}
    }

    $filename;
}

sub switch_to {
    my $self = shift;
    my($new_dir, $new_host) = @_;

    my $dir = $self->{'dir'};

    if (defined $new_dir) {
	$dir = '' if (!defined $dir);
	$new_dir = csh_style_expand($new_dir);
	if ($new_dir !~ m|^/|) {
	    $new_dir = $dir . '/' . $new_dir;
	}
    }
    elsif (!defined $dir) {
	$new_dir = getcwd();
    }

    my $field;

    if (defined $new_dir) {
	my @history = ();
	foreach my $dir (split('/', $new_dir)) {
	    if ($dir eq '..') {
		pop @history;
	    }
	    elsif ($dir ne '' && $dir ne '.') {
		push @history, $dir;
	    }
	}

	$self->{'dir'} = '/'.join('/', @history);
	$self->{'history'} = [@history];
    }

    $field = $self->{'dialog_computer'};

    if (defined $field) {
	if (!defined $new_host) {
	    $new_host = X::Motif::XmTextFieldGetString($field);
	}
	else {
	    X::Motif::XmTextFieldSetString($field, $new_host);
	}
    }

    my $host = $self->{'host'};

    if (!defined $new_host && !defined $host) {
	$new_host = hostname();
    }

    if (defined $new_host) {
	$self->{'host'} = $new_host;
	my $proc = $special_switch_hosts{$self->{'storage'}};
	if (defined $proc) {
	    &$proc($self);
	}
    }

    $self->scan_directory();
}

my %saved_storage_settings = ();

sub switch_storage {
    my $self = shift;
    my($new_storage) = @_;
    my $storage = $self->{'storage'};

    if ($storage ne $new_storage) {
	$self->{'storage'} = $new_storage;

	$saved_storage_settings{$storage} = [ $self->{'dir'}, $self->{'host'} ];

	my $settings = $saved_storage_settings{$new_storage};
	if (defined $settings) {
	    $self->switch_to($settings->[0], $settings->[1]);
	}
	else {
	    $self->switch_to("/");
	}
    }
}

sub file_filter {
    my $self = shift;

    my $dir_list = $self->{'dialog_dir_list'};
    my $file_list = $self->{'dialog_file_list'};
    my $filter_regex = $self->{'filter_regex'};

    $dir_list->Unmanage();
    $file_list->Unmanage();

    X::Motif::XmListDeleteAllItems($dir_list);
    X::Motif::XmListDeleteAllItems($file_list);

    my $row;
    my $item;
    my $pad;
    my $visible_row;
    my @displayed;

    $row = 1;
    X::Motif::XmListAddItemUnselected($dir_list, '/', $row);
    foreach $item (@{$self->{'history'}}) {
	X::Motif::XmListAddItemUnselected($dir_list, (' ' x $row) . $item . '/     ', $row + 1);
	++$row;
    }

    X::Motif::XmListSelectPos($dir_list, $row, X::False);

    $visible_row = ($row == 1) ? $row : $row - 1;
    $pad = ' ' x ($row + 2);
    ++$row;
    @displayed = ();

    foreach $item (@{$self->{'all_dirs'}}) {
	next if ($self->{'hide_dots'} && $item =~ /^\./);

	X::Motif::XmListAddItemUnselected($dir_list, $pad . $item . '/     ', $row);
	push @displayed, $item;

	++$row;
    }

    @{$self->{'displayed_dirs'}} = @displayed;
    my $last_row = $visible_row + query $dir_list -visibleItemCount;

    while ($row < $last_row) {
	X::Motif::XmListAddItemUnselected($dir_list, "", $row);
	++$row;
    }

    X::Motif::XmListSetPos($dir_list, $visible_row);

    $row = 1;
    @displayed = ();

    foreach $item (@{$self->{'all_files'}}) {
	next if ($self->{'hide_emacs'} && ($item =~ /^\#/ || $item =~ /~$/));
	next if ($self->{'hide_dots'} && $item =~ /^\./);

	next if (!&$filter_regex($item));

	X::Motif::XmListAddItemUnselected($file_list, $item, $row);
	push @displayed, $item;

	++$row;
    }

    X::Motif::XmListSetPos($file_list, 1);
    @{$self->{'displayed_files'}} = @displayed;

    $dir_list->Manage();
    $file_list->Manage();
}

sub http_filter {
    my $self = shift;
}

sub metaphase_filter {
    my $self = shift;
}

my %special_storage_filters = (
    'file' => \&file_filter,
    'ftp' => \&file_filter,
    'http' => \&http_filter,
    'metaphase' => \&metaphase_filter
);

sub filter {
    my $self = shift;
    my($pattern) = @_;

    my $field = $self->{'dialog_filter'};
    if (defined $field) {
	if (!defined $pattern) {
	    $pattern = X::Motif::XmTextFieldGetString($field);
	}
	else {
	    X::Motif::XmTextFieldSetString($field, $pattern);
	}
    }

    $pattern = '*' if (!defined($pattern));

    $self->{'filter'} = $pattern;
    $self->{'filter_regex'} = cvt_glob_to_regex($pattern);

    if (defined $field) {
	X::Motif::XmTextFieldSetString($self->{'dialog_choice'}, "");
	my $proc = $special_storage_filters{$self->{'storage'}};
	if (defined $proc) {
	    &$proc($self);
	}
    }
}

sub complete_partial_name {
    my $self = shift;
    my($partial, $w) = @_;

    my $item;

    if ($partial =~ m|(.*)/([^.]*)|) {
	$item = ($1 eq '') ? '/' : $1;
	$partial = $2;
	$self->switch_to($item);
    }
    elsif ($partial eq '..' || $partial =~ m|^~|) {
	$self->switch_to($partial);
	return;
    }

    return if ($partial eq '');

    my $dir_list = $self->{'dialog_dir_list'};
    my $file_list = $self->{'dialog_file_list'};
    my @matches = ();
    my $row;
    my $dir_row;
    my $file_row;

    $row = scalar(@{$self->{'history'}}) + 2;
    foreach $item (@{$self->{'displayed_dirs'}}) {
	if ($item =~ /^\Q$partial\E/i) {
	    push @matches, $item;
	    if (!defined $dir_row) {
		$dir_row = $row;
	    }
	}
	++$row;
    }

    $row = 1;
    foreach $item (@{$self->{'displayed_files'}}) {
	if ($item =~ /^\Q$partial\E/i) {
	    push @matches, $item;
	    if (!defined $file_row) {
		$file_row = $row;
	    }
	}
	++$row;
    }

    $w ||= $self->{'dialog_choice'};
    if (defined $w) {
	if (@matches == 0) {
	    X::Bell($w->Display(), 100);
	}
	elsif (@matches == 1) {
	    $partial = $matches[0];
	    if (defined $dir_row) {
		$partial .= '/';
	    }
	}
	else {
	    my $start = length($partial);
	    my $test_start = $start;
	    my $test_match = pop @matches;
	    my $test_prefix;

	    undef $partial;

	    do {
		$test_prefix = substr($test_match, $test_start, 1);
		foreach (@matches) {
		    if (substr($_, $test_start, 1) ne $test_prefix) {
			$partial = substr($test_match, 0, $test_start);
			last;
		    }
		}
		++$test_start;
	    }
	    while (!defined $partial);
	}

	if (defined $file_row) {
	    X::Motif::XmListSetPos($file_list, $file_row);
	}

	if (defined $dir_row) {
	    X::Motif::XmListSetPos($dir_list, $dir_row);
	}

	X::Motif::XmTextFieldSetString($w, $partial);
	my $len = X::Motif::XmTextFieldGetLastPosition($w);
	X::Motif::XmTextFieldSetInsertionPosition($w, $len);
    }
}

sub file_scanner {
    my $self = shift;
    my $dir = $self->{'dir'};
    my $host = $self->{'host'};
    my @file_contents = ();
    my @dir_contents = ();

    if (opendir(FILE_DIALOG_DIR, $dir)) {
	my $entry;
	my $fullpath;

	while (defined($entry = readdir(FILE_DIALOG_DIR))) {
	    next if ($entry eq '.' || $entry eq '..');

	    $fullpath = $dir . '/' . $entry;

	    if (-d $fullpath) {
		push @dir_contents, $entry;
	    }
	    else {
		push @file_contents, $entry;
	    }
	}
	closedir(FILE_DIALOG_DIR);
    }

    @{$self->{'all_dirs'}} = sort @dir_contents;
    @{$self->{'all_files'}} = sort @file_contents;
}

sub ftp_scanner {
    my $self = shift;
    my $dir = $self->{'dir'};
    my $host = $self->{'host'};
    my $ftp = $self->{'ftp'};
    my @file_contents = ();
    my @dir_contents = ();

    if (!defined $ftp) {
	$ftp = Net::FTP->new($host);
	if (defined $ftp && $ftp->login()) {
	    $self->{'ftp'} = $ftp;
	}
	else {
	    undef $ftp;
	}
    }

    if (defined $ftp && $ftp->cwd($dir)) {
	my $entry;
	my $name;
	my $type;

	foreach $entry (parse_dir($ftp->dir)) {
	    ($name, $type) = @{$entry};
	    if ($type eq 'd') {
		push @dir_contents, $name;
	    }
	    else {
		push @file_contents, $name;
	    }
	}
    }

    @{$self->{'all_dirs'}} = sort @dir_contents;
    @{$self->{'all_files'}} = sort @file_contents;
}

sub http_scanner {
    my $self = shift;
}

sub metaphase_scanner {
    my $self = shift;
}

my %special_storage_scanners = (
    'file' => \&file_scanner,
    'ftp' => \&ftp_scanner,
    'http' => \&http_scanner,
    'metaphase' => \&metaphase_scanner
);

sub scan_directory {
    my $self = shift;

    my $label = $self->{'dialog_current_folder'};

    if (defined $label) {
	change $label -text => $self->{'dir'};
    }

    my $proc = $special_storage_scanners{$self->{'storage'}};
    if (defined $proc) {
	&$proc($self);
    }

    $self->filter();
}

my %remembered_patterns = ();

sub cvt_glob_to_regex {
    my($pattern) = @_;

    $pattern = '' if (!defined($pattern));
    my $regex = $remembered_patterns{$pattern};

    if (!defined $regex) {
	$pattern =~ s|\\||g;
	$pattern =~ s|^\s+||;
	$pattern =~ s|\s+$||;
	$pattern .= '*' if ($pattern !~ m|\*|);

	$pattern =~ s|(\W)|\\$1|g;
	$pattern =~ s|\s+|\\s+|g;

	$pattern =~ s|\\\001|.|g;
	$pattern =~ s|\\\?|.|g;
	$pattern =~ s|\\\*|.*|g;

	$pattern = "^".$pattern."\$";

	$regex = eval "sub { \$_[0] =~ m\001".$pattern."\001i }";
	$remembered_patterns{$pattern} = $regex;
    }

    return $regex;
}

sub do_change_storage_to_local {
    my($w, $user, $call) = @_;
    my $field = $user->{'dialog_computer'};
    change $field -sensitive => X::False;
    $user->switch_storage('file');
}

sub do_change_storage_to_ftp {
    my($w, $user, $call) = @_;
    my $field = $user->{'dialog_computer'};
    change $field -sensitive => X::True;
    $user->switch_storage('ftp');
}

sub do_change_storage_to_web {
    my($w, $user, $call) = @_;
    my $field = $user->{'dialog_computer'};
    change $field -sensitive => X::True;
    $user->switch_storage('http');
}

sub do_change_storage_to_metaphase {
    my($w, $user, $call) = @_;
    my $field = $user->{'dialog_computer'};
    change $field -sensitive => X::True;
    $user->switch_storage('metaphase');
}

sub do_change_host {
    my($w, $user, $call) = @_;
    $user->switch_to();
}

sub do_filter {
    my($w, $user, $call) = @_;
    $user->filter();
}

sub do_complete_choice {
    my($w, $user, $call) = @_;

    my $change = $call->text;

    if (defined $change && $change eq ' ' && ref($call->event) eq 'X::Event::KeyEvent') {
	$call->deny_change;
	$user->complete_partial_name(X::Motif::XmTextFieldGetString($w), $w);
    }
}

sub do_ok {
    my($w, $user, $call) = @_;

    my $choice = X::Motif::XmTextFieldGetString($user->{'dialog_choice'});
    my $dir = $user->{'dir'};

    if ($choice =~ m|^/|) {
	$user->{'selection'} = $choice;
    }
    elsif ($dir =~ m|/$|) {
	$user->{'selection'} = $dir . $choice;
    }
    else {
	$user->{'selection'} = $dir . '/' . $choice;
    }

    $user->{'done'} = 1;
}

sub do_cancel {
    my($w, $user, $call) = @_;

    $user->{'selection'} = undef;
    $user->{'done'} = 1;
}

sub do_choose_folder {
    my($w, $user, $call) = @_;

    my $pos = $call->item_position() - 1;
    my $history = $user->{'history'};
    my $history_len = scalar(@{$history});

    if ($pos != $history_len) {
	if ($pos < $history_len) {
	    splice(@{$history}, $pos);
	}
	else {
	    my $subdir = $user->{'displayed_dirs'}[$pos - 1 - $history_len];
	    return if (!defined $subdir);
	    push @{$history}, $subdir;
	}

	$user->{'dir'} = '/'.join('/', @{$history});
	$user->scan_directory();
    }
}

sub do_choose_file {
    my($w, $user, $call) = @_;

    my $file = $call->item()->plain();
    X::Motif::XmTextFieldSetString($user->{'dialog_choice'}, $file);
    do_ok($w, $user);
}

sub do_maybe_choose_file {
    my($w, $user, $call) = @_;

    my $file = $call->item()->plain();
    X::Motif::XmTextFieldSetString($user->{'dialog_choice'}, $file);
}

sub create_dialog {
    my $self = shift;
    my($parent, $dialog_title) = @_;

    my $shell = give $parent -Transient,
			-resizable => X::True,
			-title => $dialog_title;

    my $form = give $shell -Form, -managed => X::False, -name => 'top_form',
			-resizePolicy => X::Motif::XmRESIZE_GROW,
			-horizontalSpacing => 5,
			-verticalSpacing => 5;

    my($storage_system, $menu) = give $form -OptionMenu,
			-traversalOn => X::False,
			-label => 'Storage System: ';
	give $menu -Button, -text => 'Local Disk', -command => [\&do_change_storage_to_local, $self];
        give $menu -Button, -text => 'FTP', -command => [\&do_change_storage_to_ftp, $self];
        give $menu -Button, -text => 'Web', -command => [\&do_change_storage_to_web, $self];
        give $menu -Button, -text => 'Metaphase', -command => [\&do_change_storage_to_metaphase, $self];
    my $spacer_1 = give $form -Spacer;

    my $folder_form = give $form -Form, -name => 'folder_form',
			-resizePolicy => X::Motif::XmRESIZE_GROW,
			-verticalSpacing => 5;
	my $computer_label = give $folder_form -Label, -text => 'Computer:';
	my $computer = give $folder_form -Field, -text => $self->{'host'},
			-sensitive => X::False,
			-command => [\&do_change_host, $self];
	my $folder_list_label = give $folder_form -Label, -text => 'Folders:';
	my $folder_view = give $folder_form -ScrolledWindow;
	my $folder_list = give $folder_view -List,
			-traversalOn => X::False,
			-visibleItemCount => 7,
			-scrollBarDisplayPolicy => X::Motif::XmSTATIC,
			-selectionPolicy => X::Motif::XmBROWSE_SELECT,
			-listSizePolicy => X::Motif::XmVARIABLE;
	$folder_list->AddCallback(X::Motif::XmNdefaultActionCallback, \&do_choose_folder, $self);

	constrain $computer_label -top => -form, -left => -form, -right => -form;
	constrain $computer -top => $computer_label, -left => -form, -right => -form;
	constrain $folder_list_label -top => $computer, -left => -form, -right => -form;
	constrain $folder_view -top => $folder_list_label, -left => -form, -right => -form, -bottom => -form;

    my $file_form = give $form -Form, -name => 'file_form',
			-resizePolicy => X::Motif::XmRESIZE_GROW,
			-verticalSpacing => 5;
	my $filter_label = give $file_form -Label, -text => 'Show Files Like:';
	my $filter = give $file_form -Field, -text => $self->{'filter'};
	$filter->AddCallback(X::Motif::XmNvalueChangedCallback, \&do_filter, $self);
	my $file_list_label = give $file_form -Label, -text => 'Files:';
	my $file_view = give $file_form -ScrolledWindow;
	my $file_list = give $file_view -List,
			-visibleItemCount => 7,
			-scrollBarDisplayPolicy => X::Motif::XmSTATIC,
			-selectionPolicy => X::Motif::XmBROWSE_SELECT,
			-listSizePolicy => X::Motif::XmVARIABLE;
	$file_list->AddCallback(X::Motif::XmNdefaultActionCallback, \&do_choose_file, $self);
	$file_list->AddCallback(X::Motif::XmNbrowseSelectionCallback, \&do_maybe_choose_file, $self);

	constrain $filter_label -top => -form, -left => -form, -right => -form;
	constrain $filter -top => $filter_label, -left => -form, -right => -form;
	constrain $file_list_label -top => $filter, -left => -form, -right => -form;
	constrain $file_view -top => $file_list_label, -left => -form, -right => -form, -bottom => -form;

    my $current_folder_label = give $form -Label, -text => 'Folder: ',
			-alignment => X::Motif::XmALIGNMENT_END;
    my $current_folder = give $form -Label, -text => $self->{'dir'},
			-resizable => X::False;
    my $choice_label = give $form -Label, -text => 'File: ',
			-alignment => X::Motif::XmALIGNMENT_END,
			-width => (query $current_folder_label -width);
    my $choice = give $form -Field, -verifyBell => X::False;
    $choice->AddCallback(X::Motif::XmNmodifyVerifyCallback, \&do_complete_choice, $self);
    $choice->AddCallback(X::Motif::XmNactivateCallback, \&do_ok, $self);

    my $spacer_3 = give $form -Spacer;
    my $ok = give $form -Button, -text => 'OK', -command => [\&do_ok, $self];
    my $cancel = give $form -Button, -text => 'Cancel', -command => [\&do_cancel, $self];

    constrain $storage_system -top => -form, -left => -form;
    constrain $spacer_1 -left => $storage_system, -right => -form;
    constrain $folder_form -top => $storage_system, -left => -form, -bottom => $current_folder;
    constrain $file_form -top => $storage_system, -left => $folder_form, -right => -form, -bottom => $current_folder;
    constrain $current_folder_label -left => -form, -bottom => $choice;
    constrain $current_folder -left => $current_folder_label, -right => -form, -bottom => $choice;
    constrain $choice_label -left => -form, -bottom => $cancel;
    constrain $choice -left => $choice_label, -right => -form, -bottom => $cancel;
    constrain $cancel -right => -form, -bottom => -form;
    constrain $ok -right => $cancel, -bottom => -form;
    constrain $spacer_3 -left => -form, -right => $ok;

    $self->{'dialog_shell'} = $shell;
    $self->{'dialog_form'} = $form;
    $self->{'dialog_current_folder'} = $current_folder;
    $self->{'dialog_choice'} = $choice;
    $self->{'dialog_computer'} = $computer;
    $self->{'dialog_filter'} = $filter;
    $self->{'dialog_dir_list'} = $folder_list;
    $self->{'dialog_file_list'} = $file_list;

    foreach my $w ($choice, $filter, $file_list) {
	X::Motif::XmAddTabGroup($w);
    }

    return $form;
}

package main;

# -------------------------------------------------------------------------------

my $toplevel = X::Toolkit::initialize("Example");

my $chooser = new FileSelector;
print "FILE #1 = ", $chooser->choose(), "\n";
$chooser->switch_to("/tmp");
print "FILE #2 = ", $chooser->choose(), "\n";

#handle $toplevel;
