package MySQL::SustainableQuery::Strategy::BalancedReplication;

use strict;
use warnings;
use parent qw(MySQL::SustainableQuery::Strategy);

use Carp;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/dbh capable_behind_seconds on_error_scale_factor/],
);
use List::Util qw(max);
use Try::Tiny;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    unless ( exists $self->{capable_behind_seconds} ) {
        $self->{capable_behind_seconds} = 5;
    }
    unless ( exists $self->{on_error_scale_factor} ) {
        $self->{on_error_scale_factor} = 5;
    }
    $self;
}

sub wait_correction {
    my ( $self, $query, $elapsed, $i ) = @_;

    my $second_behind_master; ;

    try {
        my $dbh = $self->{dbh};
        my $status = $dbh->selectrow_hashref('SHOW SLAVE STATUS') or croak($dbh->errstr);
        if ( defined $status->{Seconds_Behind_Master} ) {
            $second_behind_master = $status->{Seconds_Behind_Master};
        }
    }
    catch {
        my $e = $_;
        $query->log->error( $e );
    };

    unless ( defined $second_behind_master ) {
        $second_behind_master = max($self->{capable_behind_seconds}, 5) * $self->{on_error_scale_factor};
    }

    return max( ( $second_behind_master - $self->{capable_behind_seconds} ) / $query->check_strategy_interval, 0 );
}

1;

__END__

=head1 NAME

MySQL::SustainableQuery::Strategy::BalancedReplication - write short description for MySQL::SustainableQuery::Strategy::BalancedReplication

=head1 SYNOPSIS

  use MySQL::SustainableQuery::Strategy::BalancedReplication;

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
