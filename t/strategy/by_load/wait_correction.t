use strict;
use warnings;

use Test::More;

use MySQL::SustainableQuery;

sub create_query_and_strategy {
    my $query = MySQL::SustainableQuery->new(@_);
    my $strategy = $query->strategy;

    return ( $query, $strategy );
}

subtest 'check_strategy_interval: 1; load: 0.1' => sub {
    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 1,
        strategy => +{
            class => 'ByLoad',
            args => +{
                load => 0.1,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 90, 'elapsed: 10, wait_time: 90' );
    is( $strategy->wait_correction( $query, 3, 1 ), 27, 'elapsed: 3, wait_time: 27' );
};

subtest 'check_strategy_interval: 10; load: 0.1' => sub {
    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 10,
        strategy => +{
            class => 'ByLoad',
            args => +{
                load => 0.1,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 9, 'elapsed: 10, wait_time: 9' );
    is( $strategy->wait_correction( $query, 3, 1 ), 2.7, 'elapsed: 3, wait_time: 2.7' );
};

subtest 'check_strategy_interval: 1; load: 0.5' => sub {
    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 1,
        strategy => +{
            class => 'ByLoad',
            args => +{
                load => 0.5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 10, 'elapsed: 10, wait_time: 10' );
    is( $strategy->wait_correction( $query, 3, 1 ), 3, 'elapsed: 3, wait_time: 3' );
};

subtest 'check_strategy_interval: 10; load: 0.5' => sub {
    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 10,
        strategy => +{
            class => 'ByLoad',
            args => +{
                load => 0.5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 1, 'elapsed: 10, wait_time: 1' );
    is( $strategy->wait_correction( $query, 3, 1 ), 0.3, 'elapsed: 3, wait_time: 0.3' );
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
