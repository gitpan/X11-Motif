package X11::Toolkit::Widget;

# Copyright 1997 by Ken Fox

use strict;
use vars qw($VERSION);

$VERSION = 1.0;

package X::Toolkit::Widget;

use Carp;

use vars qw(%class_registry %resource_registry %resource_alias
	    %constraint_resource_registry %constraint_resource_alias
	    %class_converter_to %type_converter_to %type_registry
	    %constraint_handlers %call_data_registry %resource_hints);

%class_registry = ();
%resource_registry = ();
%resource_alias = ();
%constraint_resource_registry = ();
%constraint_resource_alias = ();
%class_converter_to = ();
%type_converter_to = ();
%type_registry = ();
%constraint_handlers = ();
%call_data_registry = ();

$resource_alias{"Core"} = { 'bg' => 'background' };

# Resource Hints:
#
# 'u' -- Xt doesn't provide enough information to determine whether a
#        resource value is signed or unsigned.  In practice, this is
#        only a problem for short integers that should not be sign
#        extended.  Longer integers are always sign extended -- we
#        just hope that users don't use values that would make a
#        difference on a machine with 64-bit (or longer) integers!

%resource_hints = ( 'Dimension' => 'u', 'ShellHorizDim' => 'u', 'ShellVertDim' => 'u' );

# ================================================================================
# Utility functions

sub Realize { X::Toolkit::Widget::RealizeWidget($_[0]) }
sub Manage { X::Toolkit::Widget::ManageChild($_[0]) }
sub Unmanage { X::Toolkit::Widget::UnmanageChild($_[0]) }
sub ToApplicationContext { X::Toolkit::Widget::WidgetToApplicationContext($_[0]) }

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

    my $info = $registry->{$name};

    if ($info->[1] eq "Callback") {
	$callbacks->{$name} = $value if (defined $callbacks);
    }
    elsif ($info->[1] eq "String") {
	# Force the toolkit to use a string value instead of trying
	# to run a conversion sequence.  The rule of thumb is if you
	# use a C string to set the resource value, then the resource
	# should be set using this code.

	$resources->{$name} = X::Toolkit::InArg::new($value, $info->[1], $info->[2], 1);
    }
    else {
	if (X::is_string($value)) {
	    # first, try to run a perl class resource converter on the value

	    foreach my $proc (@{$class_converter_to{$info->[0]}}) {
		last if (&{$proc}(\$value));
	    }

	    if (X::is_string($value)) {
		# next, try to run a perl type resource converter on the value

		foreach my $proc (@{$type_converter_to{$info->[1]}}) {
		    last if (&{$proc}(\$value));
		}

		if (X::is_string($value)) {
		    # finally, let the toolkit converters do the conversion

		    $value = X::Toolkit::InArg::new($value, $info->[1], $info->[2], 0);
		}
	    }
	}

	$resources->{$name} = $value;
    }
}

sub build_resource_table {
    my $type_name = shift;
    my $parent_type_name = shift;
    my $resources = shift;
    my $callbacks = shift;
    my $pseudo_resources = shift;

    my $alias = $resource_alias{$type_name};
    my $registry = $resource_registry{$type_name};

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
	elsif ($res_name eq 'name') {
	    $pseudo_resources->{'name'} = $value
	}
	elsif ($res_name eq 'managed') {
	    $pseudo_resources->{managed} = X::cvt_to_Boolean($value);
	}
	elsif ($res_name eq 'mapped') {
	    $pseudo_resources->{mapped} = X::cvt_to_Boolean($value);
	}
	elsif ($res_name eq 'xy') {
	    my $pos = $value;
	    if (ref $pos) {
		if (defined $pos->[0]) {
		    set_resource('x' => $pos->[0], $registry, $resources, $callbacks);
		}
		if (defined $pos->[1]) {
		    set_resource('y' => $pos->[1], $registry, $resources, $callbacks);
		}
	    }
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

    my $alias = $resource_alias{$type_name};
    my $registry = $resource_registry{$type_name};

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
	else {
	    carp "resource $res_name not defined on widget class $type_name";
	}
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
	    if (ref $proc eq "ARRAY") {
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
    my %pseudo_resources = ();

    build_resource_table($type_name, $parent_type_name,
			 \%resources, \%callbacks, \%pseudo_resources, @_);

    if (exists $pseudo_resources{managed}) {
	if ($pseudo_resources{managed}) {
	    $self->Manage();
	}
	else {
	    $self->Unmanage();
	}
    }

    if (exists $pseudo_resources{mapped}) {
	if ($self->IsRealized()) {
	    my $dpy = Display($self);
	    my $win = Window($self);
	    if ($pseudo_resources{mapped}) {
		X::MapWindow($dpy, $win);
	    }
	    else {
		X::UnmapWindow($dpy, $win);
	    }
	}
	else {
	    if ($pseudo_resources{mapped}) {
		$resources{'mappedWhenManaged'} = X::True;
	    }
	    else {
		$resources{'mappedWhenManaged'} = X::False;
	    }
	}
    }

    $self->priv_XtSetValues(%resources) if (%resources);
    $self->add_callback_set($type_name, \%callbacks);
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
    my %pseudo_resources = ();

    build_resource_table($type_name, Class($parent)->name(),
			 \%resources, \%callbacks, \%pseudo_resources, @arg_list);

    my $name = $pseudo_resources{'name'};
    if (!defined $name) {
	$name = "an_".$type_name;
    }

    my $managed = $pseudo_resources{managed};
    if (!defined $managed) {
	$managed = 1;
    }

    my $child;

    if (exists($resource_registry{$type_name}{'allowShellResize'})) {
	$child = X::Toolkit::priv_XtCreatePopupShell($name, $type, $parent, %resources);

	if (!defined $child) {
	    carp "couldn't create $type_name popup $name";
	}
	else {
	    $child->add_callback_set($type_name, \%callbacks);
	}
    }
    else {
	$child = X::Toolkit::priv_XtCreateWidget($name, $type, $parent, %resources);

	if (!defined $child) {
	    carp "couldn't create $type_name widget $name";
	}
	else {
	    $child->add_callback_set($type_name, \%callbacks);
	    $child->Manage() if ($managed);
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

    build_resource_query_table($type_name, $parent_type_name, \@resources, @_);

    # also need to handle the pseudo resources like name and managed -- but
    # this is very tricky because the pseudo resource values must be inserted
    # into the returned value list in the proper location.  this can be done
    # with splice().  only do the special splice() code if there are pseudo
    # resources -- otherwise just do the simple return.

    $self->priv_XtGetValues(@resources) if (@resources);
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

    my $context = $self->ToApplicationContext();
    $context->AppMainLoop();
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
	$resource_registry{$type_name}{$cb_name}[1] eq "Callback")
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
