#!/ford/thishost/unix/div/ap/bin/perl -w

use blib;

use strict;
use X11::Motif;

my %listing = ();

foreach my $widget_class (keys %X::Toolkit::Widget::resource_registry) {
    my $registry = $X::Toolkit::Widget::resource_registry{$widget_class};
    foreach my $name (keys %{$registry}) {
	my $type = $registry->{$name}[1];
	if (!exists $listing{$type}) {
	    $listing{$type} = [ { $registry->{$name}[0] => 1 },  $registry->{$name}[2] ];
	}
	else {
	    $listing{$type}[0]{$registry->{$name}[0]} = 1;
	    if ($listing{$type}[1] != $registry->{$name}[2]) {
		print "warning: resource $name uses different size for same type\n";
	    }
	}
    }
}

foreach my $type (sort keys %listing) {
    print sprintf("%3d %-30s ", $listing{$type}[1], $type), join(", ", sort keys %{$listing{$type}[0]}), "\n";
}
