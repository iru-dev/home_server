#!/usr/bin/perl -w

use strict;
use warnings;

my $devices_fn = '/sys/devices/platform';

opendir my $dirh, $devices_fn or die;
my @cores = grep { /coretemp.\d+/ } readdir $dirh;
closedir $dirh;

my @sensors;
foreach my $core (@cores) {
  my $device_name = $core;
  $device_name =~ s/\.(\d+)$/-isa-000$1/;
  my $core_dir = $devices_fn.'/'.$core;
  opendir my $dirh, $core_dir or die;
  my @temps = sort grep { /temp\d_/ } readdir $dirh;
  closedir $dirh;
  if (!@temps && -d "$core_dir/hwmon") {
    opendir my $dirh, "$core_dir/hwmon" or die;
    my @hwmons = sort grep { /hwmon\d/ } readdir $dirh;
    closedir $dirh;
    if (@hwmons) {
      $core_dir .= "/hwmon/". $hwmons[0];
      opendir my $dirh, $core_dir or die;
      @temps = sort grep { /temp\d_/ } readdir $dirh;
      closedir $dirh;
    }
  }
  if (@temps) {
    my $file = $temps[0];
    my $dat = $file;
    $dat =~ s/_.*//;
    my $file_prefix = $core_dir.'/'.$dat;

    my %data;
    $data{device} = $device_name;
    $data{sensor} = $dat;
    $data{label} = read_file($file_prefix.'_label') || $dat;
    foreach (qw/max crit/) {
      $data{$_} = read_file($file_prefix.'_'.$_);
      $data{$_} /= 1000 if $data{$_};
    }
    push @sensors, '{'. join(',', map { defined($data{$_}) ? '"{#'. uc($_). '}":"'. $data{$_}. '"' : () } keys %data). '}';
  }
}

print '{"data": ['. join(",\n", @sensors). ']}';

sub read_file {
  open my $fh, shift or return undef;
  #local $/;
  my $res = <$fh>;
  close $fh;
  chomp $res;
  return $res;
}
