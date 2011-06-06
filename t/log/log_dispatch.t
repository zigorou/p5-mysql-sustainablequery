use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Requires qw(
    Log::Dispatch
);
use Test::Output;

use Log::Dispatch;
use MySQL::SustainableQuery::Log;

my $logger = Log::Dispatch->new(
    outputs => [
        [ 'Screen', min_level => 'debug', stderr => 0, ],
    ],
);

my $log;

lives_and {
    $log = MySQL::SustainableQuery::Log->new( $logger );
    isa_ok( $log, 'MySQL::SustainableQuery::Log' );
    can_ok( $log, @MySQL::SustainableQuery::Log::LEVELS );

    for my $level (@MySQL::SustainableQuery::Log::LEVELS) {
        stdout_like( sub { $log->$level($level) },
            qr/$level/, sprintf( "%s() output", $level ) );
    }
} 'new() lives ok';

done_testing;

# Local Variables:
# mode: perl
# perl-indent-level: 4
# indent-tabs-mode: nil
# coding: utf-8-unix
# End:
#
# vim: expandtab shiftwidth=4:
