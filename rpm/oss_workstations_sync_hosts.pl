#!/usr/bin/perl
# 2017 Copyright Frank Schütte <fschuett@gymhim.de>
# sync hosts with workstations file
# add missing hosts
#   $oss_host->add(      name => 'mediothek-pc01', 
#		      domain => 'schule.de',
#                      roomdn => 'cn=Room1,cn=172.16.0.0,cn=config1,cn=admin,ou=DHCP,dc=schule,dc=de',
#		   hwaddress => '00:04:23:CF:F8:2D',
#		   ipaddress => '172.16.5.10',
#		      hwconf => hwconf1,
#		      master => yes
#                );
#

BEGIN{
    push @INC,"/usr/share/oss/lib/";
}

use strict;
use oss_host;
use oss_utils;

if( $> )
{
    die "Only root may start this programm!\n";
}

my $hosts = {};
my $connect  = {};
my $oss_host =  undef;

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
	#raum;rechner;gruppe;mac;ip;;;;benutzer;;linbo=1;
	#Switche und Drucker im Servernetz einordnen
	my $host = {};
	$host->{'name'} = $ar[1];
	$host->{'hwaddress'} = $ar[3];
	$host->{'ipaddress'} = $ar[4];
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
$oss_host = oss_host->new($connect);

# create import file
my $importfile = "/tmp/import_workstations.add_hosts.$$.csv";
open(IMPORT,">$importfile");
print IMPORT "room;name;mac;hwconf;uid\n";
my $import_needed = 0;
foreach my $host (keys %$hosts) {
    my $data = $hosts->{$host};
    next if defined $oss_host->get_host($data->{'name'});
    $import_needed = 1;
    my ($owner) = $host =~ /^(?:cpq|lap)(.+)$/;
    if( $owner ){
	$data->{'alternate'} = $host;
	$data->{'user'}=$owner if $owner ne $data->{'user'};
	print IMPORT $data->{'room'} . ";" . $data->{'alternate'} . ";" . $data->{'hwaddress'} . ";" . $data->{'hwconf'}
		  . ";" . $owner;
    } else {
	print IMPORT $data->{'room'} . ";;" . $data->{'hwaddress'} . ";" . $data->{'hwconf'} . ";";    
    }
    print "  * Import new host " . $data->{'name'} . "/" . $data->{'alternate'} . " to ldap\n";
}
if($import_needed){
    # start the actual import
    system("oss_import_hosts.pl --debug --addws --addma $importfile");
} else {
    system("rm -f $importfile");
    print "  * No new hosts to import.\n";
}

$oss_host->destroy();
