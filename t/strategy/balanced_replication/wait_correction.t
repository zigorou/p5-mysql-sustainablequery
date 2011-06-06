use strict;
use warnings;

use Test::More;
use Test::Requires 'DBD::Mock';

use DBI;
use MySQL::SustainableQuery;

sub create_query_and_strategy {
    my $query = MySQL::SustainableQuery->new(@_);
    $query->setup;
    my $strategy = $query->strategy;

    return ( $query, $strategy );
}

subtest 'check_strategy_interval: 1, capable_behind_seconds: 5; on_error_scale_factor: 5; Seconds_Behind_Master: 10' => sub {
    my $dbh = DBI->connect('dbi:Mock:', '', '');
    $dbh->{mock_add_resultset} = +{
        sql => 'SHOW SLAVE STATUS',
        results => [
            [ qw/Seconds_Behind_Master/ ],
            [ 10 ]
        ],
    };

    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 1,
        strategy => +{
            class => 'BalancedReplication',
            args => +{
                dbh => $dbh,
                capable_behind_seconds => 5,
                on_error_scale_factor => 5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 5, 'elapsed: 10, wait_time: 5' );
    is( $strategy->wait_correction( $query, 3, 1 ), 5, 'elapsed: 3, wait_time: 5' );
};

subtest 'check_strategy_interval: 10, capable_behind_seconds: 5; on_error_scale_factor: 5; Seconds_Behind_Master: 10' => sub {
    my $dbh = DBI->connect('dbi:Mock:', '', '');
    $dbh->{mock_add_resultset} = +{
        sql => 'SHOW SLAVE STATUS',
        results => [
            [ qw/Seconds_Behind_Master/ ],
            [ 10 ]
        ],
    };

    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 10,
        strategy => +{
            class => 'BalancedReplication',
            args => +{
                dbh => $dbh,
                capable_behind_seconds => 5,
                on_error_scale_factor => 5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 0.5, 'elapsed: 10, wait_time: 0.5' );
    is( $strategy->wait_correction( $query, 3, 1 ), 0.5, 'elapsed: 3, wait_time: 0.5' );
};

subtest 'check_strategy_interval: 10, capable_behind_seconds: 15; on_error_scale_factor: 5; Seconds_Behind_Master: 10' => sub {
    my $dbh = DBI->connect('dbi:Mock:', '', '');
    $dbh->{mock_add_resultset} = +{
        sql => 'SHOW SLAVE STATUS',
        results => [
            [ qw/Seconds_Behind_Master/ ],
            [ 10 ]
        ],
    };

    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 10,
        strategy => +{
            class => 'BalancedReplication',
            args => +{
                dbh => $dbh,
                capable_behind_seconds => 15,
                on_error_scale_factor => 5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 0, 'elapsed: 10, wait_time: 0' );
    is( $strategy->wait_correction( $query, 3, 1 ), 0, 'elapsed: 3, wait_time: 0' );
};

subtest 'check_strategy_interval: 10, capable_behind_seconds: 10; on_error_scale_factor: 5; Seconds_Behind_Master: undef' => sub {
    my $dbh = DBI->connect('dbi:Mock:', '', '');
    $dbh->{mock_add_resultset} = +{
        sql => 'SHOW SLAVE STATUS',
        results => [
            [ qw/Seconds_Behind_Master/ ],
            [ undef ]
        ],
    };

    my ( $query, $strategy ) = create_query_and_strategy(
        check_strategy_interval => 10,
        strategy => +{
            class => 'BalancedReplication',
            args => +{
                dbh => $dbh,
                capable_behind_seconds => 10,
                on_error_scale_factor => 5,
            },
        },
    );

    is( $strategy->wait_correction( $query, 10, 1 ), 4, 'elapsed: 10, wait_time: 0' );
    is( $strategy->wait_correction( $query, 3, 1 ), 4, 'elapsed: 3, wait_time: 0' );
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
