use strict;
use warnings;

use Test::More;
use Test::Exception;
use MySQL::SustainableQuery;

subtest 'Setup MySQL::SustainableQuery::Strategy::Byload' => sub {
    my $query = MySQL::SustainableQuery->new(+{
        strategy => +{
            class => 'ByLoad',
            args => +{},
        },
    });

    lives_and {
        isa_ok( $query->strategy, 'MySQL::SustainableQuery::Strategy::ByLoad' );
        can_ok( $query->strategy, 'wait_correction' );
    } 'setup_strategy() lives ok';
};

subtest 'Setup MySQL::SustainableQuery::Strategy::BalancedReplication' => sub {
    my $query = MySQL::SustainableQuery->new(+{
        strategy => +{
            class => 'BalancedReplication',
            args => +{},
        },
    });

    lives_and {
        isa_ok( $query->strategy, 'MySQL::SustainableQuery::Strategy::BalancedReplication' );
        can_ok( $query->strategy, 'wait_correction' );
    } 'setup_strategy() lives ok';
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
