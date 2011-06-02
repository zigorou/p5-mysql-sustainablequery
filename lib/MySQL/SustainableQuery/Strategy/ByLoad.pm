package MySQL::SustainableQuery::Strategy::ByLoad;

use strict;
use warnings;
use parent qw(MySQL::SustainableQuery::Strategy);

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/load/],
);
use List::Util qw(max);

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = $class->SUPER::new( @_ );
    $self->{load} ||= 0.5;
    $self;
}

sub wait_correction {
    my ( $self, $query, $elapsed, $i ) = @_;
    return ( max( $elapsed, 0 ) * ( 1 - $self->{load} ) / $self->{load} ) / $query->check_strategy_interval;
}

1;

__END__

=head1 NAME

MySQL::SustainableQuery::Strategy::ByLoad - write short description for MySQL::SustainableQuery::Strategy::ByLoad

=head1 SYNOPSIS

  use MySQL::SustainableQuery::Strategy::ByLoad;

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou@dena.jp<gt>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=head1 SEE ALSO

=cut

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8-unix
# End:
#
# vim: expandtab shiftwidth=4:
