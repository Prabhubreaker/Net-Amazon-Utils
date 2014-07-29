package Net::Amazon::Utils;

use v5.10.0;
use strict;
use warnings;# FATAL => 'all';
use Carp;
use LWP::UserAgent;
use LWP::Protocol::https;


=head1 NAME

Net::Amazon::Utils - Implementation of a set of utilities to help in developing Amazon web service modules in Perl.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Loosely based in com.amazonaws.regions.Region at L<http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/regions/Region.html>

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Amazon::Utils;

    my $foo = Net::Amazon::Utils->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 new

=cut

sub new {
	my ( $class, $no_cache, $no_inet ) = @_;

	$no_inet = 1 unless defined $no_inet;
	$no_cache = 0 unless defined $no_cache;

	my $self = {
		remote_region_file => 'http://raw.githubusercontent.com/aws/aws-sdk-android-v2/master/src/com/amazonaws/regions/regions.xml',
		# do not cache regions between calls, does not affect Internet caching, defaults to false.
		no_cache => $no_cache,
		# do not load updated file from the Internet, defaults to true.
		no_inet => $no_inet,
		# be well behaved and tell who we are.
		# use more reasonable 21st century Internet timeout
		# do not accept redirects
		ua     => LWP::UserAgent->new(
			agent		=> __PACKAGE__ . '/' . $VERSION,
			timeout => 30,
			max_redirect => 0,
		),
	};
	
	bless $self, $class;
	$self->reset_known_protocols();
	
	return $self;
}

=head2 fetch_regions_update

Fetch regions file from the internet even if no_inet was specified when
intanciating the object.

=cut

sub fetch_region_update {
	my ( $self ) = @_;

	if ( $self->{no_cache} ) {
		# Cached regions will not be fetched
		carp 'Fetching updated region update is useless unless no_cache is false. Still I will comply to your orders in case you more intelligent.';
		$self->_load_regions( 1 );
	} else {
		# Backup and restore Internet connection selection.
		my $old_no_inet = $self->{no_inet};
		# Force loading
		$self->_load_regions( 1 );
		$self->{no_inet} = $old_no_inet;
	}
}

=head2 get_domain

=cut

sub get_domain {
	return 'amazonaws.com';
}

=head2 get_regions

=cut

sub get_regions {
	my ( $self ) = @_;
	my @regions;

	$self->_load_regions();

	return keys $self->{regions}->{Regions};

	$self->_unload_regions();
}

=head2 get_services

=cut

sub get_services {
	my ( $self ) = @_;

	$self->_load_regions();

	return keys $self->{regions}->{Services};

	$self->_unload_regions();
}

=head2 get_service_endpoints

Returns a list of the available services endpoints.

=cut

sub get_service_endpoints {
	my ( $self, $service ) = @_;

	$self->_load_regions();
	
	my @service_endpoints;
	
	unless ( defined $self->{regions}->{ServiceEndpoints} ) {
		foreach my $region ( keys $self->{regions}->{Regions} ) {
			push @service_endpoints, $self->{regions}->{Regions}->{$region}->{Endpoint}->{$service}->{Hostname}
				if (
					defined $self->{regions}->{Regions}->{$region}->{Endpoint}->{$service}
				);
		}
		$self->{regions}->{ServiceEndpoints} = \@service_endpoints;
	}
	
	return @{$self->{regions}->{ServiceEndpoints}};
	
	$self->_unload_regions();
}

=head2 get_http_support( $service, [ @regions ] )

Returns a list of the available http services endpoints for a service short name as returned by
get_services.
A region or list of regions can be specified to narrow down the results.

=cut

sub get_http_support {
	my ( $self, $service, @regions ) = @_;
	
	return $self->get_protocol_support( 'Http', $service, @regions );
}

=head2 get_https_support( $service, [ @regions ] )

Returns a list of the available https services endpoints for a service short name as returned by
get_services.
A region or list of regions can be specified to narrow down the results.

=cut

sub get_https_support {
	my ( $self, $service, @regions ) = @_;
	
	return $self->get_protocol_support( 'Https', $service, @regions );
}

=head2 get_protocol_support( $protocol, $service, [ @regions ] )

Returns a list of the available services endpoints for a service short name as returned by
get_services for a given protocol. Protocols should be cased according
A region or list of regions can be specified to narrow down the results.

=cut

sub get_protocol_support {	
	my ( $self, $protocol, $service, @regions ) = @_;
	
	croak 'A protocol must be specified' unless defined $protocol;
	croak 'A service must be specified' unless defined $service;
	
	$self->_load_regions();
	
	@regions = keys $self->{regions}->{Regions} unless ( @regions );
	
	my $regions_key = join('||', sort @regions);
	
	my @protocol_support;
	
	unless ( defined $self->{regions}->{$protocol . 'Support'}->{$service}->{$regions_key} ) {
		foreach my $region ( @regions ) {
			push @protocol_support, $self->{regions}->{Regions}->{$region}->{Endpoint}->{$service}->{Hostname}
				if (
					defined $self->{regions}->{Regions}->{$region}->{Endpoint}->{$service} &&
					$self->_is_true( 
						$self->{regions}->{Regions}->{$region}->{Endpoint}->{$service}->{$protocol}
					)
				);
		}
		$self->{regions}->{$protocol . 'Support'}->{$service}->{$regions_key} = \@protocol_support;
	}
	
	return @{$self->{regions}->{$protocol . 'Support'}->{$service}->{$regions_key}};

	$self->_unload_regions();
	
}

=head2 get_service_endpoint

=cut

sub get_service_endpoint {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 is_service_supported

=cut

sub is_service_supported {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 has_http_endpoint

=cut

sub has_http_endpoint {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 has_https_endpoint

=cut

sub has_https_endpoint {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 get_known_protocols

Returns a list of known endpoint protocols.

=cut

sub get_known_protocols {
	my ( $self ) = @_;
	
	return @{$self->{Protocols}};
}

=head2 set_known_protocols ( @protocols )

Sets the list of known protocols. Should not be used unless Net::Amazon::Utils::Regions is really
outdated or you are really brave and probably reckless.
Returns the newly set protocols.

=cut

sub set_known_protocols {
	my ( $self, @protocols) = @_;
	
	croak 'Protocols must be specified.' unless @protocols;
	
	$self->{Protocols} = \@protocols;
	
	return @protocols;
}

=head2 reset_known_protocols

Sets the list of known protocols to Net::Amazon::Utils::Regions defaults.
Should fix bad set_known_protocols.

=cut

sub reset_known_protocols {
	my ( $self) = @_;
	
	$self->set_known_protocols( 'Http', 'Https' );
}

=head1 Internal Functions

=head2 _load_regions

Loads regions from local cached file or the Internet.
If Internet fails local cached file is used.
If loading of new region definitions fail, old regions remain unaffected.

=cut

sub _load_regions {
	my ( $self, $force ) = @_;
	
	if ( $force || !defined $self->{regions} ) {
		my @xml_options = [ KeyAttr => {Region => 'Name', Endpoint=>'ServiceName', Service => 'Name' } ];
		my $new_regions;
		if ( $self->{no_inet} ) {
			eval {
				require Net::Amazon::Utils::Regions;
				$new_regions = Net::Amazon::Utils::Regions::get_regions_data();
			};
			if ( $@ ) {
				carp "Processing XML failed with error $@";
			}
		} else {
			my $error;
			my $response = $self->{ua}->get( $self->{remote_region_file} );
			if ( $response->is_success ) {
				# This should be a big file...
				carp "Size of region file looks really suspicious." if ( length $response->decoded_content < 10000 );
				eval {
					$new_regions = XML::Simple::XMLin( $response->decoded_content, @xml_options );
				};
				if ( $@ ) {
					carp "Processing XML failed with error $@";
					$error = 1;
				}
			} else {
				carp "Getting updated regions failed with " . $response->status_line;
				$error = 1;
			}
			# Retry locally on errors
			if ( $error ) {
				my $old_no_inet = $self->{no_inet};
				carp "Getting regions file from Internet failed will use local cache. Check your Internet connection...";
				$self->{no_inet} = 1;
				$self->_load_regions();
				$self->{no_inet} = $old_no_inet
			}
		}
		# Check that some "trustable" regions and services exist.
		if ( defined $new_regions &&
					defined $new_regions->{Regions} &&
					defined $new_regions->{Regions}->{Region}->{'us-east-1'} &&
					defined $new_regions->{Regions}->{Region}->{'us-west-1'} &&
					defined $new_regions->{Regions}->{Region}->{'us-west-2'} &&
					defined $new_regions->{Services} &&
					defined $new_regions->{Services}->{Service}->{ec2} &&
					defined $new_regions->{Services}->{Service}->{sqs} &&
					defined $new_regions->{Services}->{Service}->{glacier}
		) {
			$new_regions->{Regions} = $new_regions->{Regions}->{Region};
			$new_regions->{Services} = $new_regions->{Services}->{Service};
			
			$self->{regions} = $new_regions if ( defined $new_regions );
		} else {
			croak "Region file format cannot be trusted.";
		}
	}
}

=head2 _unload_regions

Unloads regions recovering memory unless object has been instantiated with
cache_regions set to any true value.

=cut

sub _unload_regions {
	my ( $self ) = @_;

	$self->{regions} = undef unless $self->{cache_regions};
}

=head2 _get_remote_regions_file_uri

Returns the uri of the remote regions.xml file.

=cut

sub _get_remote_regions_file_uri {
	my ( $self ) = @_;

	return $self->{remote_region_file};
}

=head2 get_regions_file_raw

=cut

sub _get_regions_file_raw {
	my ( $self ) = @_;

	$self->_load_regions();

	return $self->{regions};

	$self->_unload_regions();
}

=head2 _is_true

Returns a true value on strings that should be true in regions.xml parlance.

=cut

sub _is_true {
	my ( $self, $supposed_truth ) = @_;
	
	return $supposed_truth eq 'true';
}

=head1 AUTHOR

Gonzalo Barco, C<< <gbarco uy at gmail com, no spaces> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-amazon-utils at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Amazon-Utils>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Amazon::Utils

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Amazon-Utils>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Amazon-Utils>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Amazon-Utils>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Amazon-Utils/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Gonzalo Barco.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Net::Amazon::Utils
