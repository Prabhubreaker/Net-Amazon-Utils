use strict;
use warnings;

use Test::More tests => 3;
use Test::File;
use lib '../lib';

BEGIN {
	use_ok( 'Carp' );
	use_ok( 'XML::Simple' );
	use_ok( 'LWP::Useragent' );
	use_ok( 'Net::Amazon::Utils' );
}

my $utils = Net::Amazon::Utils->new( 1, 1);
my @methods = qw( get_regions fetch_region_update get_services get_service_endpoints get_http_support get_https_support get_service_endpoint is_service_supported has_http_endpoint has_https_endpoint );

isa_ok( $utils, 'Net::Amazon::Utils' );
can_ok( $utils, @methods );

file_exists_ok( 'regions.xml', 'Local regions file exists' );
# Test https://raw.githubusercontent.com/aws/aws-sdk-android-v2/master/src/com/amazonaws/regions/regions.xml
my @regions = $utils->get_regions();
isnt( scalar @regions, 0, 'Regions returns at least one region.' );

