use strict;
use warnings FATAL => 'all';
use lib './lib';

use Net::Amazon::Utils;
use Data::Dumper;

my $utils = Net::Amazon::Utils->new(0,0);

my $uri = $utils->_get_remote_regions_file_uri();

print STDERR "Will download $uri\n";

my $regions = $utils->_get_regions_file_raw();

print STDERR "Will try to write updated class file.\n";

mkdir 'lib/Net/Amazon/Utils';

open ( LIB, '>lib/Net/Amazon/Utils/Regions.pm' ) || die("Could not open Regions module for writing." );

LIB->print( "package Net::Amazon::Utils::Regions;\n\n" );
LIB->print( "use strict;\n\n" );

LIB->print( "=head1 NAME\n\n" );

LIB->print( "Net::Amazon::Utils::Regions - Data for Net::Amazon::Utils::Regions." );

LIB->print( "# Generated from L<$uri>\n\n" );

LIB->print( "=head1 VERSION\n\n" );

LIB->print( "Version 0.01\n\n" );

LIB->print( "=head2 get_regions_datan\n\n" );

LIB->print( "Returns the structure of regions.xml.\n\n" );

LIB->print( "=cut\n\n" );

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

print "Looks good\n.";