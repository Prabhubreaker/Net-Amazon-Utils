package Net::Amazon::Utils;

use v5.10.0;
use strict;
use warnings FATAL => 'all';
use Carp;
use LWP::Simple;
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
	my ( $class, $cache_regions ) = @_;

	my $self = {
		# be well behaved and tell who we are
		cache_regions => $cache_regions,
		ua     => LWP::Simple->new( agent=> __PACKAGE__ . '/' . $VERSION ),
	};
	return bless $self, $class;
}

=head2 get_regions

=cut

sub get_regions {
	my ( $self ) = @_;

	$self->_load_regions() unless defined $self->{regions}

	$self->_unload_regions();
}



=head1 Internal Functions

=head2 _load_regions

=cut

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
