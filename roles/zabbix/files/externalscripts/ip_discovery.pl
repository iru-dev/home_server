#!/bin/perl -w

use strict;
use warnings;

my $hostname = `hostname -I` || die "Can't get ips";
chomp $hostname;

print '{"data":['.
	join(",\n", map { '{"{#IP}":"'.$_.'"}' }
		grep { /^\d+\.\d+\.\d+\.\d+$/ && !/^(127\.|10\.|172\.1[6-9]\.|172\.2[0-9]\.|172\.3[0-1]\.|192\.168\.)/ }
		split /\s+/, $hostname
	). "]}\n";
