use strict;
use warnings;

use Test::More;
use Test::Exception;

use Time::HiRes ();
use MySQL::SustainableQuery;

sub create_query {
    my $query = MySQL::SustainableQuery->new(@_);
    $query->setup;
    $query;
}

subtest 'strategy: ByLoad' => sub {
    my $j = 0;
    my $query = create_query(
        wait_interval => 0.1,
        check_strategy_interval => 3,
        strategy => +{
            class => 'ByLoad',
            args  => +{ load => 0.3 },
        },
        exec_query => sub {
            my ( $query, $i ) = @_;
            Time::HiRes::sleep( ++$j * 0.05 );
            return $j;
        },
        terminate_condition => sub {
            my ( $query, $rv, $i, $time_sum ) = @_;
            ( $rv == 15 ) ? 1 : 0;
        }
    );

    lives_and {
        my $rv = $query->run;
        is( $rv->{executed}, 15, 'executed count' );
        cmp_ok( $rv->{time_total}, '>', 6, 'time total' );
    };
};

done_testing;

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8-unix
# End:
#
# vim: expandtab shiftwidth=4:
