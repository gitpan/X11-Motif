
sub dump_scope {
    my($stab) = @_;

    my $key;
    my $val;

    while (($key, $val) = each(%{$stab})) {
	local(*entry) = $val;
	if (defined &entry) {
	    print "$key\n";
	}
    }
}
