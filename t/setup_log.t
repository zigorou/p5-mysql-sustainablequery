use strict;
use warnings;

use Test::More;
use Test::Exception;
use MySQL::SustainableQuery;

subtest 'setup_log() default' => sub {
    my $query = MySQL::SustainableQuery->new;
    lives_and {
        isa_ok( $query->log, 'MySQL::SustainableQuery::Log' );
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
