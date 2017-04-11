#!/usr/bin/perl
# 2017 Copyright Frank Schütte <fschuett@gymhim.de>
# sync hosts with workstations file
# add missing hosts with oss_import_hosts.pl script
#

BEGIN{
    push @INC,"/usr/share/oss/lib/";
}

use strict;
use oss_base;
use oss_utils;
use Data::Dumper;

if( $> )
{
    die "Only root may start this programm!\n";
}

my $hosts = {};
my $connect  = {};
my $oss_base =  undef;

while(my $param = shift)
{
  if( $param =~ /text/i ) { $connect->{XML}=0; }
}
binmode STDIN, ':utf8';
while(<STDIN>)
{
	# Clean up the line!
	chomp; s/^\s+//; s/\s+$//;
	next if /^#/;

	my ( $key, $value ) = split / /,$_,2;

	next if( getConnect($connect,$key,$value));
	my @ar = split /;/,$_;
	#raum;rechner;gruppe;mac;;;;;benutzer;;linbo=1;
	my $host = {};
	$host->{'name'} = $ar[1];
	$host->{'hwaddress'} = $ar[3];
	$host->{'hwconf'} = $ar[2] if $ar[10] eq '1' and $ar[2] ne 'pc_group';
	$host->{'master'} = 'no';
	$host->{'room'} = $ar[0];
	$hosts->{$host} = $host;
}

# Make OSS Connection
if( defined $ENV{SUDO_USER} )
{
   if( ! defined $connect->{aDN} || ! defined $connect->{aPW} )
   {
       die "Using sudo you have to define the parameters aDN and aPW\n";
   }
}
$oss_base = oss_base->new($connect);
# get HW configurations
my $confs = $oss_base->get_HW_configurations(0);
my $hwconfs = {};
foreach my $key (@{$confs})
{
    $hwconfs->{$key->[1]} = $key->[0];
}

# create import file
my $importfile = "/tmp/import_workstations.add_hosts.$$.csv";
open(IMPORT,">$importfile");
print IMPORT "room;name;mac;hwconf;uid\n";
my $import_needed = 0;
foreach my $host (keys %$hosts) {
    my $data = $hosts->{$host};
    my $hwconf = $hwconfs->{$data->{'hwconf'}};
    if( ! defined $hwconf or $hwconf eq '' )
    {
	die "  > Host ".$data->{'name'}." has unknown hardware configuration ".$data->{'hwconf'};
    }
    next if defined $oss_base->get_host($data->{'name'});
    $import_needed = 1;
    my ($owner) = $host =~ /^(?:cpq|lap)(.+)$/;
    if( $owner ){
	$data->{'alternate'} = $host;
	$data->{'user'}=$owner if $owner ne $data->{'user'};
	print IMPORT $data->{'room'} . ";" . $data->{'alternate'} . ";" . $data->{'hwaddress'} . ";" . $hwconf
		  . ";" . $owner."\n";
    } else {
	print IMPORT $data->{'room'} . ";;" . $data->{'hwaddress'} . ";" . $hwconf . ";\n";    
    }
    print "  * Import new host " . $data->{'name'} . "/" . $data->{'alternate'} . " to ldap\n";
}

if($import_needed){
    # start the actual import
    system("oss_import_hosts.pl --addws --addma $importfile >$importfile.log");
} else {
    print "  * No new hosts to import.\n";
}
system("rm -f $importfile");
system("rm -f $importfile.log");

$oss_base->destroy();
