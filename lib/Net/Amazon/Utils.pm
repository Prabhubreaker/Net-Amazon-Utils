package Net::Amazon::Utils;

use v5.10.0;
use strict;
use warnings FATAL => 'all';
use Carp;
use LWP::UserAgent;
use XML::Simple;

=head1 NAME

Net::Amazon::Utils - Implementation of a set of utilities to help in developing Amazon web service modules in Perl.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

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
		remote_region_file => 'https://raw.githubusercontent.com/aws/aws-sdk-android-v2/master/src/com/amazonaws/regions/regions.xml',
		local_region_file => 'regions.xml',
		# do not cache regions between calls, does not affect Internet caching, defaults to false.
		no_cache => $no_cache,
		# do not load updated file from the Internet, defaults to true.
		no_inet => $no_inet,
		# be well behaved and tell who we are.
		ua     => LWP::UserAgent->new( agent=> __PACKAGE__ . '/' . $VERSION ),
	};
	return bless $self, $class;
}

=head2 fetch_regions_update

Fetch regions file from the internet even if no_inet was specified when
intanciating the object.

=cut

sub fetch_region_update {
	my ( $self ) = @_;

	if ( $self->{no_cache} ) {
		# Cached regions will net be fetched
		carp 'Fetching updated region update is useless unless no_cache is false. Still I will comply to your orders in case you more intelligent.';
	} else {
		# Backup and restore Internet connection selection.
		my $old_no_inet = $self->{no_inet};
		# Force loading
		$self->_load_regions( 1 );
		$self->{no_inet} = $old_no_inet;
	}
}

=head2 get_regions

=cut

sub get_regions {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 get_services

=cut

sub get_services {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 get_service_endpoints

=cut

sub get_service_endpoints {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 get_http_support

=cut

sub get_http_support {
	my ( $self ) = @_;

	$self->_load_regions();



	$self->_unload_regions();
}

=head2 get_https_support

=cut

sub get_https_support  {
	my ( $self ) = @_;

	$self->_load_regions();



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

=head1 Internal Functions

=head2 _load_regions

Loads regions from local cached file or the internet, non blocking until needed.

=cut

sub _load_regions {
	my ( $self, $force ) = @_;

	if ( $force || !defined $self->{regions} ) {
		if ( $self->{no_inet} ) {
			$self->{regions} = XML::Simple::XMLin( $self->{local_region_file} )
		} else {
			my $xml = LWP::Simple::get( $self->{remote_region_file} );
			$self->{regions} = XML::Simple::XMLin( $xml );
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
