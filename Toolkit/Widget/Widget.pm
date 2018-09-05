package X11::Toolkit::Widget;

# Copyright 1997 by Ken Fox

use strict;
use vars qw($VERSION);

$VERSION = 1.0;

package X::Toolkit::Widget;

use Carp;

use vars qw(%class_registry %resource_registry %resource_alias
	    %constraint_resource_registry %constraint_resource_alias
	    %resource_conversion_mandatory %resource_conversion_prohibited
	    %class_converter_to %type_converter_to %type_registry
	    %constraint_handlers %call_data_registry %resource_hints
	    %synthetic_resource_registry);

%class_registry = ();
%resource_registry = ();
%resource_alias = ();
%constraint_resource_registry = ();
%constraint_resource_alias = ();
%resource_conversion_mandatory = ();
%resource_conversion_prohibited = ( 'String' => 1 );
%class_converter_to = ();
%type_converter_to = ();
%type_registry = ();
%constraint_handlers = ();
%call_data_registry = ();
%synthetic_resource_registry = ();

$resource_alias{'Core'} = { 'bg' => 'background', 'fg' => 'foreground' };
$synthetic_resource_registry{'Core'}{'name'} = [ undef, \&synth_get_name ];
$synthetic_resource_registry{'Core'}{'parent'} = [ undef, \&synth_get_parent ];
$synthetic_resource_registry{'Core'}{'managed'} = [ \&synth_set_managed, \&synth_get_managed ];
$synthetic_resource_registry{'Core'}{'mapped'} = [ \&synth_set_mapped, \&synth_get_mapped ];

# Resource Hints:
#
# 'u' -- Xt doesn't provide enough information to determine whether a
#        resource value is signed or unsigned.  In practice, this is
#        only a problem for short integers that should not be sign
#        extended.  Longer integers are always sign extended -- we
#        just hope that users don't use values that would make a
#        difference on a machine with 64-bit (or longer) integers!

%resource_hints = ( 'Dimension' => 'u', 'ShellHorizDim' => 'u', 'ShellVertDim' => 'u' );

my $event_loop_nesting = 0;

# ================================================================================
# Utility functions

sub Realize { XtRealizeWidget($_[0]) }
sub Manage { XtManageChild($_[0]) }
sub Unmanage { XtUnmanageChild($_[0]) }
sub GetContext { XtWidgetToApplicationContext($_[0]) }

sub FullName {
    my $w = shift;
    my @name = ();
    while ($w) {
	unshift @name, XtName($w);
	$w = XtParent($w);
    }
    join('.', @name);
}

sub constraint_resource_info {
    my($self, $res_name) = @_;
    my $parent = Parent($self);
    my @output = ();

    if (defined $parent) {
        my $type_name = Class($parent)->name();

	push @output, $res_name;

	my $alias = $constraint_resource_alias{$type_name}{$res_name};
	if (defined $alias) {
	    $output[0] .= " ($alias)";
	    $res_name = $alias;
	}

	my $info = $constraint_resource_registry{$type_name}{$res_name};
	if (defined $info) {
	    push @output, @{$info};
	}
    }

    @output;
}

sub resource_info {
    my($self, $res_name) = @_;
    my $type_name = Class($self)->name();
    my @output = ();

    $res_name =~ s|^-||;
    push @output, $res_name;

    my $alias = $resource_alias{$type_name}{$res_name};
    if (defined $alias) {
	$output[0] .= " ($alias)";
	$res_name = $alias;
    }

    my $info = $resource_registry{$type_name}{$res_name};
    if (defined $info) {
	push @output, @{$info};
    }
    else {
	return constraint_resource_info($self, $res_name);
    }

    @output;
}

sub conversion_is_mandatory {
    my($res_type) = @_;

    $resource_conversion_mandatory{$res_type}++;
}

sub conversion_is_prohibited {
    my($res_type) = @_;

    $resource_conversion_prohibited{$res_type}++;
}

sub register_converter {
    my($res_type, $to) = @_;

    unshift @{$type_converter_to{$res_type}}, $to;
}

sub register_class_converter {
    my($res_class, $to) = @_;

    unshift @{$class_converter_to{$res_class}}, $to;
}

sub set_resource {
    my($name, $value, $registry, $resources, $callbacks) = @_;

    if (ref $name) {
	my $num = scalar @{$name};
	my $i = 1;

	while ($i < $num) {
	    set_resource($name->[$i] => $name->[$i + 1],
			 $registry, $resources, $callbacks);
	    $i += 2;
	}
	$name = $name->[0];
    }

    # $info->[0] = resource class
    # $info->[1] = resource type
    # $info->[2] = resource size

    my $info = $registry->{$name};

    if ($info->[1] eq 'Callback') {

	# Callbacks aren't treated as normal resources since they
	# must be set using the special XtAddCallback() interface.

	$callbacks->{$name} = $value if (defined $callbacks);
    }
    elsif (defined $resource_conversion_prohibited{$info->[1]}) {

	# Force the toolkit to use a string value instead of trying
	# to run a conversion sequence.  The rule of thumb is if you
	# use a C string to set the resource value, then the resource
	# should be set using this code.

	$resources->{$name} = X::Toolkit::InArg::new($value, $info->[1], $info->[2], 1);
    }
    elsif (defined $resource_conversion_mandatory{$info->[1]}) {

	# If resource conversion is mandatory, then the class and type
	# converters will always be run -- regardless of what the input
	# resource value is.

	foreach my $proc (@{$class_converter_to{$info->[0]}}) {
	    &{$proc}(\$value);
	}

	foreach my $proc (@{$type_converter_to{$info->[1]}}) {
	    &{$proc}(\$value);
	}

	$resources->{$name} = $value;
    }
    elsif (X::is_string($value)) {

	# If the input value is a string, try running through the resource
	# converters until one of them returns a non-string value.

	# First, try to run a class-based resource converter on the value.

	foreach my $proc (@{$class_converter_to{$info->[0]}}) {
	    last if (&{$proc}(\$value));
	}

	if (X::is_string($value)) {

	    # Next, try to run a type-based resource converter on the value.

	    foreach my $proc (@{$type_converter_to{$info->[1]}}) {
		last if (&{$proc}(\$value));
	    }

	    if (X::is_string($value) && !X::is_numeric($value)) {

		# Finally, let the toolkit converters do the conversion if
		# the value is still a string (and does not have an alternate
		# integer value).  This could generate a toolkit warning if
		# the widget set does not provide a conversion from string
		# format.  Most resources have these converters though because
		# they are used for converting app-defaults files.
		#
		# The reason why we don't run potential numbers through the
		# toolkit conversion is because a number is almost always
		# an enumeration value.  Most converters don't handle the
		# numeric value, but rather the symbolic name.  If we ran
		# numbers through the toolkit conversion there's a good chance
		# the conversion would fail.  Besides, if the value is already
		# an integer it skips the relatively slow toolkit conversion
		# process.

		$value = X::Toolkit::InArg::new($value, $info->[1], $info->[2], 0);
	    }
	}

	$resources->{$name} = $value;
    }
    else {

	# Lastly, if the attribute is not a string and does not require
	# conversion, the resource is just set directly.  This allows
	# objects (i.e. blessed refs) returned from other X11 routines
	# to be used directly.

	$resources->{$name} = $value;
    }
}

sub build_resource_table {
    my $type_name = shift;
    my $parent_type_name = shift;
    my $resources = shift;
    my $callbacks = shift;
    my $synthetic_resources = shift;

    my $alias = $resource_alias{$type_name};
    my $registry = $resource_registry{$type_name};
    my $synthetic_registry = $synthetic_resource_registry{$type_name};
    my $core_synthetic_registry = $synthetic_resource_registry{'Core'};

    my $constraint_alias;
    my $constraint_registry;

    if (defined $parent_type_name) {
	$constraint_alias = $constraint_resource_alias{$parent_type_name};
	$constraint_registry = $constraint_resource_registry{$parent_type_name};
    }

    my($res_name, $value);
    my $num = scalar @_;
    my $i = 0;

    while ($i < $num) {
	$res_name = $_[$i++];
	$res_name =~ s|^-||;

	$value = $_[$i++];

	if (defined $alias->{$res_name}) {
	    set_resource($alias->{$res_name} => $value,
			 $registry, $resources, $callbacks);
	}
	elsif (defined $registry->{$res_name}) {
	    set_resource($res_name => $value,
			 $registry, $resources, $callbacks);
	}
	elsif (defined $constraint_alias && defined $constraint_alias->{$res_name}) {
	    set_resource($constraint_alias->{$res_name} => $value,
			 $constraint_registry, $resources, $callbacks);
	}
	elsif (defined $constraint_registry && defined $constraint_registry->{$res_name}) {
	    set_resource($res_name => $value,
			 $constraint_registry, $resources, $callbacks);
	}
	elsif (defined $synthetic_registry->{$res_name}) {
	    $synthetic_resources->{$res_name} = $value;
	}
	elsif (defined $core_synthetic_registry->{$res_name}) {
	    $synthetic_registry->{$res_name} = $core_synthetic_registry->{$res_name};
	    $synthetic_resources->{$res_name} = $value;
	}
	else {
	    carp "resource $res_name not defined on widget class $type_name";
	}
    }
}

sub build_strict_resource_table {
    my $type_name = shift;
    my $parent_type_name = shift;
    my $resources = shift;
    my $callbacks = shift;

    my $registry = $resource_registry{$type_name};
    my $constraint_registry;

    if (defined $parent_type_name) {
	$constraint_registry = $constraint_resource_registry{$parent_type_name};
    }

    my($res_name, $value);
    my $num = scalar @_;
    my $i = 0;

    while ($i < $num) {
	$res_name = $_[$i++];
	$res_name =~ s|^-||;

	$value = $_[$i++];

	if (defined $registry->{$res_name}) {
	    set_resource($res_name => $value,
			 $registry, $resources, $callbacks);
	}
	elsif (defined $constraint_registry && defined $constraint_registry->{$res_name}) {
	    set_resource($res_name => $value,
			 $constraint_registry, $resources, $callbacks);
	}
	else {
	    carp "resource $res_name not defined on widget class $type_name";
	}
    }
}

sub build_resource_query_table {
    my $type_name = shift;
    my $parent_type_name = shift;
    my $resources = shift;
    my $synthetic_resources = shift;

    my $alias = $resource_alias{$type_name};
    my $registry = $resource_registry{$type_name};
    my $synthetic_registry = $synthetic_resource_registry{$type_name};
    my $core_synthetic_registry = $synthetic_resource_registry{'Core'};

    my $constraint_alias;
    my $constraint_registry;

    if (defined $parent_type_name) {
	$constraint_alias = $constraint_resource_alias{$parent_type_name};
	$constraint_registry = $constraint_resource_registry{$parent_type_name};
    }

    my $res_name;
    my $num = scalar @_;
    my $i = 0;
    my $info;
    my $hints;
    my $res_pos = 0;

    while ($i < $num) {
	$res_name = $_[$i++];
	$res_name =~ s|^-||;

	undef $info;

	if (defined $alias->{$res_name}) {
	    if (ref $alias->{$res_name}) {
		$res_name = $alias->{$res_name}[0];
	    }
	    else {
		$res_name = $alias->{$res_name};
	    }
	    $info = $registry->{$res_name};
	}
	elsif (defined $registry->{$res_name}) {
	    $info = $registry->{$res_name};
	}
	elsif (defined $constraint_alias && defined $constraint_alias->{$res_name}) {
	    if (ref $constraint_alias->{$res_name}) {
		$res_name = $constraint_alias->{$res_name}[0];
	    }
	    else {
		$res_name = $constraint_alias->{$res_name};
	    }
	    $info = $constraint_registry->{$res_name};
	}
	elsif (defined $constraint_registry && defined $constraint_registry->{$res_name}) {
	    $info = $constraint_registry->{$res_name};
	}

	if (defined $info) {
	    $hints = $resource_hints{$info->[2]} || '';
	    push @{$resources}, X::Toolkit::OutArg::new($res_name, $info->[0],
							$info->[1], $info->[2],
							$hints);
	}
	elsif (defined $synthetic_registry->{$res_name}) {
	    push @{$synthetic_resources}, $res_name, $res_pos;
	}
	elsif (defined $core_synthetic_registry->{$res_name}) {
	    $synthetic_registry->{$res_name} = $core_synthetic_registry->{$res_name};
	    push @{$synthetic_resources}, $res_name, $res_pos;
	}
	else {
	    carp "resource $res_name not defined on widget class $type_name";
	}

	++$res_pos;
    }
}

sub build_strict_resource_query_table {
    my $type_name = shift;
    my $parent_type_name = shift;
    my $resources = shift;

    my $registry = $resource_registry{$type_name};
    my $constraint_registry;

    if (defined $parent_type_name) {
	$constraint_registry = $constraint_resource_registry{$parent_type_name};
    }

    my $res_name;
    my $num = scalar @_;
    my $i = 0;
    my $info;
    my $hints;

    while ($i < $num) {
	$res_name = $_[$i++];
	$res_name =~ s|^-||;

	undef $info;

	if (defined $registry->{$res_name}) {
	    $info = $registry->{$res_name};
	}
	elsif (defined $constraint_registry && defined $constraint_registry->{$res_name}) {
	    $info = $constraint_registry->{$res_name};
	}

	if (defined $info) {
	    $hints = $resource_hints{$info->[2]} || '';
	    push @{$resources}, X::Toolkit::OutArg::new($res_name, $info->[0],
							$info->[1], $info->[2],
							$hints);
	}
	else {
	    carp "resource $res_name not defined on widget class $type_name";
	}
    }
}

sub add_callback_set {
    my($self, $type_name, $callbacks) = @_;

    if (defined $callbacks && defined %{$callbacks}) {
	my($cb_name, $proc);
	while (($cb_name, $proc) = each %{$callbacks}) {
	    if (ref $proc eq 'ARRAY') {
		$self->priv_XtAddCallback($cb_name, $proc->[0],
					  $call_data_registry{$type_name.','.$cb_name},
					  $proc->[1]);
	    }
	    else {
		$self->priv_XtAddCallback($cb_name, $proc,
					  $call_data_registry{$type_name.','.$cb_name});
	    }
	}
    }
}

# ================================================================================
# Tk-like object interface
#
# The methods implemented here provide a completely different (and
# hopefully better) interface to the X Toolkit.  The Tk indirect
# object style is used, i.e. [verb] [noun] [indirect object].  For
# example, instead of saying:
#
#   $widget->manage();
#
# you say:
#
#   manage $widget;
#
# Actually either syntax is acceptable but the methods are written
# to make sense when read in the second syntax.

# --------------------------------------------------------------------------------
# change $widget resource => value, ...
#
# change the value of one or more of a widget's resources

sub change {
    my $self = shift;
    my $parent = Parent($self);

    my $type_name = Class($self)->name();
    my $parent_type_name;

    # shells don't have parents
    if (defined $parent) {
	$parent_type_name = Class($parent)->name();
    }

    my %resources = ();
    my %callbacks;
    my %synthetic_resources = ();

    build_resource_table($type_name, $parent_type_name,
			 \%resources, \%callbacks, \%synthetic_resources, @_);

    $self->priv_XtSetValues(%resources) if (%resources);
    $self->add_callback_set($type_name, \%callbacks);

    my $key; my $value;
    my $synthetic_registry = $synthetic_resource_registry{$type_name};

    while (($key, $value) = each %synthetic_resources) {
	my $setter = $synthetic_registry->{$key}[0];
	if (defined $setter) {
	    &{$setter}($self, $value);
	}
    }
}

sub synth_get_name {
    my($self) = @_;

    XtName($self);
}

sub synth_get_parent {
    my($self) = @_;

    XtParent($self);
}

sub synth_set_managed {
    my($self, $v) = @_;

    if (X::cvt_to_Boolean($v)) {
	$self->Manage();
    }
    else {
	$self->Unmanage();
    }
}

sub synth_get_managed {
    my($self) = @_;

    XtIsManaged($self);
}

sub synth_set_mapped {
    my($self, $v) = @_;

    if ($self->IsRealized()) {
	my $dpy = Display($self);
	my $win = Window($self);
	if ($v) {
	    X::MapWindow($dpy, $win);
	}
	else {
	    X::UnmapWindow($dpy, $win);
	}
    }
    else {
	$self->priv_XtSetValues('mappedWhenManaged', ($v) ? X::True : X::False);
    }
}

# This is a tricky request because Xt doesn't keep the information.  It
# actually requires a round trip to the X server.  FIXME

sub synth_get_mapped {
    my($self) = @_;

    1;
}

# --------------------------------------------------------------------------------
# child = give $widget class, resource => value, ...
#
# give a parent widget a new child widget of the given class with the
# given default resource values

sub give {
    my $parent = shift;
    my $type = shift;

    my $type_name;
    my @arg_list = ();

    if (!ref $type) {
	$type_name = lc $type;
	$type_name =~ s|^-||;
	$type = $class_registry{$type_name};
	if (ref $type) {
	    if (ref $type eq 'ARRAY') {
		($type, @arg_list) = @{$type};
		if (ref $arg_list[0] eq 'CODE') {
		    my $proc = shift @arg_list;
		    return &{$proc}($parent, $type, @arg_list, @_);
		}
	    }
	}
	else {
	    croak "$type_name is not a registered widget class";
	}
    }

    $type_name = $type->name();
    push @arg_list, @_;

    my %resources = ();
    my %callbacks;
    my %synthetic_resources = ();

    build_resource_table($type_name, Class($parent)->name(),
			 \%resources, \%callbacks, \%synthetic_resources, @arg_list);

    my $name = $synthetic_resources{'name'};
    if (!defined $name) {
	$name = 'an_'.$type_name;
    }

    # Don't use the normal synthetic resource setter for handling
    # managed widgets during widget creation.  Widget creation is
    # already *way* too expensive -- calling a synthetic set managed
    # function every time is too much.

    my $should_manage = $synthetic_resources{'managed'};
    if (!defined $should_manage) {
	$should_manage = 1;
    }
    else {
	$should_manage = X::cvt_to_Boolean($should_manage);
	delete $synthetic_resources{'managed'};
    }

    # Take the widget name out of the synthetic resource list since
    # the name can only be set at creation time.  (This special cast
    # stuff bothers me.  Perhaps there should be create/set/get
    # routines instead of just set/get?  FIXME)

    delete $synthetic_resources{'name'};

    my $child;

    if (exists($resource_registry{$type_name}{'allowShellResize'})) {
	$child = X::Toolkit::priv_XtCreatePopupShell($name, $type, $parent, %resources);

	if (defined $child) {
	    $child->add_callback_set($type_name, \%callbacks);
	}
	else {
	    carp "couldn't create $type_name popup $name";
	}
    }
    else {
	$child = X::Toolkit::priv_XtCreateWidget($name, $type, $parent, %resources);

	if (defined $child) {
	    $child->add_callback_set($type_name, \%callbacks);
	    $child->Manage() if ($should_manage);
	}
	else {
	    carp "couldn't create $type_name widget $name";
	}
    }

    if (defined $child) {
	my $key; my $value;
	my $synthetic_registry = $synthetic_resource_registry{$type_name};

	while (($key, $value) = each %synthetic_resources) {
	    my $setter = $synthetic_registry->{$key}[0];
	    if (defined $setter) {
		&{$setter}($child, $key, $value);
	    }
	}
    }

    $child;
}

# --------------------------------------------------------------------------------
# constrain $widget resource => value, ...
#
# constrain the location and size of a widget by defining the constraint
# resources of the child (the change method will also do this, but this
# routine will prohibit non-constraint resources from being changed)

sub constrain {
    my $self = shift;
    my $parent = Parent($self);

    if (defined $parent)
    {
	my $parent_type_name = Class($parent)->name();

	my $alias = $constraint_resource_alias{$parent_type_name};
	my $registry = $constraint_resource_registry{$parent_type_name};

	my $custom_handler = $constraint_handlers{$parent_type_name};

	my %resources = ();

	my($res_name, $value);
	my $num = scalar @_;
	my $i = 0;

	while ($i < $num) {
	    $res_name = $_[$i++];
	    $res_name =~ s|^-||;

	    $value = $_[$i++];

	    if (defined $alias->{$res_name}) {
		set_resource($alias->{$res_name} => $value, $registry, \%resources);
	    }
	    elsif (defined $registry->{$res_name}) {
		set_resource($res_name => $value, $registry, \%resources);
	    }
	    elsif (defined $custom_handler && &$custom_handler($res_name, $value, $registry, \%resources))
	    {
	    }
	    else {
		carp "resource $res_name not defined on widget class $parent_type_name";
	    }
	}

	$self->priv_XtSetValues(%resources) if (%resources);
    }
}

# --------------------------------------------------------------------------------
# (value, ...) = query $widget resource, ...
#
# query the widget for the current values of the given resources.  the
# values are returned as a list in the same order that the resource
# names are given.

sub query {
    my $self = shift;
    my $parent = Parent($self);

    my $type_name = Class($self)->name();
    my $parent_type_name;

    # shells don't have parents
    if (defined $parent) {
	$parent_type_name = Class($parent)->name();
    }

    my @resources = ();
    my @synthetic_resources = ();

    build_resource_query_table($type_name, $parent_type_name, \@resources,
			       \@synthetic_resources, @_);

    my @values = ();

    if (@resources) {
	@values = $self->priv_XtGetValues(@resources);
    }

    if (@synthetic_resources) {
	my $i = 0;
	my $res_name;
	my $res_pos;
	my $synthetic_registry = $synthetic_resource_registry{$type_name};

	while ($i < @synthetic_resources) {
	    $res_name = $synthetic_resources[$i++];
	    $res_pos = $synthetic_resources[$i++];

	    my $getter = $synthetic_registry->{$res_name}[1];
	    splice @values, $res_pos, 0, defined($getter) ? &{$getter}($self) : undef;
	}
    }

    if (wantarray) {
	return @values;
    }
    else {
	$values[0];
    }
}

# --------------------------------------------------------------------------------
# handle $widget
#
# tell the widget to display itself and then start handling all input
# events.

sub handle {
    my $self = shift;

    if (!$self->IsRealized()) {
	$self->Realize();
    }

    my $context = $self->GetContext();
    my $nesting_on_entry = $event_loop_nesting;

    ++$event_loop_nesting;

    while ($event_loop_nesting > $nesting_on_entry) {
	X::Toolkit::DispatchEvent($context->AppNextEvent);
    }
}

sub debug_handle {
    my $self = shift;
    my $trace = shift;

    if (!$self->IsRealized()) {
	$self->Realize();
    }

    my $context = $self->GetContext();
    my $nesting_on_entry = $event_loop_nesting;
    my $event;

    ++$event_loop_nesting;

    while ($event_loop_nesting > $nesting_on_entry) {
	$event = $context->AppNextEvent;
	&{$trace}($event) if (ref $trace eq 'CODE');
	X::Toolkit::DispatchEvent($event);
    }
}

sub return_from_handler () {
    --$event_loop_nesting;
}

# --------------------------------------------------------------------------------
# $widget->set_inherited_resources(name => value, ...)
#
# This is totally different from the other set values functions.
# set_inherited_resources will create an entry in the resource database
# that applies below the current widget.  This only makes sense for
# manager widgets, i.e. widgets with children.
#
# For example, this:
#
#   $form->set_inherited_resources('*foreground', 'white');
#
# will set the foreground of all the children of the form to white.
#
# NOTE:  Resources set with this routine only affect widgets at creation
#        time.  Existing widgets will not be affected.

sub set_inherited_resources {
    my $w = shift;
    my $db = X::Toolkit::Database($w->Display());

    my($res, $val);

    my $fullname = $w->FullName();

    while (@_) {
	$res = shift;
	$val = shift;

	if (defined($res) && defined($val)) {
	    $res = $fullname.$res;
	    X::XrmPutStringResource($db, $res, $val);
	}
    }
}


# ================================================================================
# X Toolkit compatibility functions
#
# The intention is to support the Xt interface as faithfully as
# possible.  Where an obvious C limitation can be easily removed,
# in creating ArgLists for example, the Xt interface is *slightly*
# improved.

sub XtAddCallback {
    my($self, $cb_name, $proc, $client_data) = @_;
    my $type_name = Class($self)->name();

    if (exists $resource_registry{$type_name}{$cb_name} &&
	$resource_registry{$type_name}{$cb_name}[1] eq 'Callback')
    {
	$self->priv_XtAddCallback($cb_name, $proc,
				  $call_data_registry{$type_name.','.$cb_name},
				  $client_data);
    }
}

sub XtSetValues {
    my $self = shift;
    my $parent = Parent($self);

    my $type_name = Class($self)->name();
    my $parent_type_name;

    # shells don't have parents
    if (defined $parent) {
	$parent_type_name = Class($parent)->name();
    }

    my %resources = ();
    my %callbacks;

    build_strict_resource_table($type_name, $parent_type_name,
				\%resources, \%callbacks, @_);

    $self->priv_XtSetValues(%resources);
}

sub XtGetValues {
    my $self = shift;
    my $parent = Parent($self);

    my $type_name = Class($self)->name();
    my $parent_type_name;

    # shells don't have parents
    if (defined $parent) {
	$parent_type_name = Class($parent)->name();
    }

    my @resources = ();

    build_strict_resource_query_table($type_name, $parent_type_name, \@resources, @_);

    $self->priv_XtGetValues(@resources) if (@resources);
}

1;
