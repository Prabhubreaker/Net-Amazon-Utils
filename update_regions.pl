use strict;
use warnings FATAL => 'all';
use lib './lib';

use Net::Amazon::Utils;
use LWP::Simple;
use XML::Simple;
use Data::Dumper;

my $utils = Net::Amazon::Utils->new();

my $uri = $utils->_get_remote_regions_file_uri();

print STDERR "Will download $uri\n";

my $xml = LWP::Simple::get( $uri ) || die("Could not update regions.");

my $regions = XML::Simple::XMLin( $xml,
		KeyAttr => {Region => 'Name', Endpoint=>'ServiceName', Service => 'Name', }
);

print STDERR "Will try to write updated class file.\n";

mkdir 'lib/Net/Amazon/Utils';

# This should be a big file...
warn "Size of region file looks really suspicious." if ( length $xml < 10000 );

open ( LIB, '>lib/Net/Amazon/Utils/Regions.pm' ) || die("Could not open Regions module for writing.");

LIB->print( "package Net::Amazon::Utils::Regions;\n\n");
LIB->print( "use strict;\n\n");

LIB->print( "# Generated from L<$uri>\n\n");

$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;

LIB->print( "sub get_regions_data {\n");
LIB->print( "\tmy \$regions=" . Dumper( $regions ) . ";\n" );
LIB->print( "\treturn \$regions; \n" );
LIB->print( "}\n");
LIB->print( "return 1;\n");
LIB->close;

print STDERR "Class file updated.\n";

print STDERR "Will test new class file.\n";

my $new_regions;
eval {
	require Net::Amazon::Utils::Regions;
	$new_regions = Net::Amazon::Utils::Regions::get_regions_data();
};
die( $@ ) if ( $@ );

# Check for some format
# Check some regions and services that should exists unless all hell broke loose

print "Looks good\n." if (
	defined $new_regions->{Regions} &&
	defined $new_regions->{Regions}->{'us-east-1'} &&
	defined $new_regions->{Regions}->{'us-west-1'} &&
	defined $new_regions->{Regions}->{'us-west-2'} &&
	defined $new_regions->{Services} &&
	defined $new_regions->{Services}->{ec2} &&
	defined $new_regions->{Services}->{sqs} &&
	defined $new_regions->{Services}->{glacier}
);