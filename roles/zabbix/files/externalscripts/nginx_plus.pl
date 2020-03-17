#!/usr/bin/perl -w

use strict;
use warnings;
use open qw/:std :utf8/;

# yum install perl-libwww-perl perl-JSON perl-JSON-XS zabbix-sender
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use Carp;

$SIG{__DIE__} = \&Carp::croak;
$SIG{__WARN__} = \&Carp::cluck;

$Data::Dumper::Indent = 1;

my $mode = shift @ARGV || '';

my $ua = LWP::UserAgent->new;
$ua->timeout(10);

my $response = $ua->get('http://127.0.0.1:8095/status/upstreams');

die $response->status_line if !$response->is_success;

my $json = from_json $response->decoded_content;  # or whatever

my @upstreams;

foreach my $upstream_name (keys %$json) {
  my $upstream = $json->{$upstream_name};
  foreach my $server (@{$upstream->{peers}}) {
    my $key = lc $upstream_name.'_'.$server->{server};
    $key =~ s/:/_/g;
    push @upstreams, {
      upstream => $upstream_name,
      server_port => $server->{server},
      key => $key,
      data => $server,
    };
  }
}

if ($mode eq 'upstreams') {
  print encode_json({
    data => [map { +{
                      '{#UPSTREAM}'       => $_->{key},
                      '{#UPSTREAM_NAME}'  => $_->{upstream},
                      '{#UPSTREAM_TIMEOUT}' => $_->{upstream} =~ /^(chat|liver|liner)$/ ? 3600 : 3,
                      '{#SERVER}'         => $_->{server_port},
                    } } @upstreams],
  });
  exit;
}

foreach my $u (@upstreams) {
  my $ukey = $u->{key};
  foreach my $k (keys %{$u->{data}}) {
    my $val = $u->{data}{$k};
    if (JSON::is_bool($val)) {
        print "- nginx_plus[$ukey,". lc($k). "] ". ($val eq 'true' ? 1 : 0). "\n";
    } elsif (ref $val) {
      foreach my $k2 (keys %$val) {
        my $val2 = $val->{$k2};
        print "- nginx_plus[$ukey,". lc($k.'_'.$k2). "] $val2\n";
      }
    } else {
      print "- nginx_plus[$ukey,". lc($k). "] $val\n";
      print "- nginx_plus[$ukey,responsesec] ". ($val/1000). "\n" if $k eq 'response_time';
    }
  }
}

# vim: set expandtab sw=2 ts=2 sts=2 bg=dark:
