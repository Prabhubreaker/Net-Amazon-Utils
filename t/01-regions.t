use strict;
use warnings;

use Test::More tests => 28;

use lib '../lib';

BEGIN {
	use_ok( 'Carp' );
	use_ok( 'XML::Simple' );
	use_ok( 'LWP::UserAgent' );
	use_ok( 'Net::Amazon::Utils' );
	use_ok( 'Net::Amazon::Utils::Regions' );
}

my $utils = Net::Amazon::Utils->new( 1, 1 );
my @methods = qw( get_regions fetch_region_update get_services get_service_endpoints get_http_support get_https_support get_service_endpoint is_service_supported has_http_endpoint has_https_endpoint );

isa_ok( $utils, 'Net::Amazon::Utils' );
can_ok( $utils, @methods );

# Test https://raw.githubusercontent.com/aws/aws-sdk-android-v2/master/src/com/amazonaws/regions/regions.xml

# Test Regions
my @regions = $utils->get_regions();
ok( scalar @regions > 0, 'Regions returns at least one region.' );
is( grep( /^us-east-1$/, @regions ), 1, 'Region us-east-1 shall always exist.');
is( grep( /^us-west-1$/, @regions ), 1, 'Region us-west-1 shall always exist.');
is( grep( /^us-west-2$/, @regions ), 1, 'Region us-west-2 shall always exist.');

# Test Services
my @services = $utils->get_services();
isnt( scalar @services, 0, 'Services returns at least one service.' );
ok( grep( /^ec2$/, @services ), 'Service ec2 shall always exist.');
ok( grep( /^s3$/, @services ), 'Service s3 shall always exist.');
ok( grep( /^sqs$/, @services ), 'Service sqs shall always exist.');
ok( grep( /^glacier$/, @services ), 'Service glacier shall always exist.');

ok( scalar $utils->get_service_endpoints('ec2') > 0, 'Service endpoints for ec2 exist.' );
ok( scalar $utils->get_service_endpoints('s3') > 0, 'Service endpoints for s3 exist.' );
ok( scalar $utils->get_service_endpoints('sqs') > 0, 'Service endpoints for sqs exist.' );
ok( scalar $utils->get_service_endpoints('glacier') > 0, 'Service endpoints for glacier exist.' );

# Test endpoint protocol support

ok( scalar $utils->get_http_support('sqs') > 0, 'There is at least one http endpoint' );
ok( scalar $utils->get_https_support('sqs') > 0, 'There is at least one https endpoint' );

# Test specific services

ok( $utils->is_service_supported( 'us-west-1', 'ec2' ), 'us-west-1->ec2 exists.' );
ok( $utils->is_service_supported( 'us-west-1', 's3' ), 'us-west-1->s3 exists.' );
ok( $utils->is_service_supported( 'us-west-1', 'sqs' ), 'us-west-1->sqs' );
ok( $utils->is_service_supported( 'us-west-1', 'glacier' ), 'us-west-1->glacier' );

# Test specific endpoints

ok( $utils->has_http_endpoint( 'us-west-1', 'glacier' ), 'us-west-1->glacier has http endpoint.' );
ok( $utils->has_https_endpoint( 'us-west-1', 'glacier' ), 'us-west-1->glacier has https endpoint.' );
