use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Requires qw(
    Log::Log4perl
);

use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use MySQL::SustainableQuery::Log;

sub create_logger {
    my $logger = Log::Log4perl->get_logger('main');
    my $screen_appender = Log::Log4perl::Appender->new(
        "Log::Log4perl::Appender::Screen",
        name      => "screenlog",
        stderr    => 0
    );
    $screen_appender->layout(
        Log::Log4perl::Layout::PatternLayout->new("[%r] %F %L %m%n")
    );
    $logger->add_appender($screen_appender);
    $logger;
}

my $logger = create_logger;

note explain $logger;

my $log;
lives_and {
    $log = MySQL::SustainableQuery::Log->new( $logger );
    isa_ok( $log, 'MySQL::SustainableQuery::Log' );
    for my $level ( @MySQL::SustainableQuery::Log::LEVELS ) {
        can_ok( $log, $level, qq{can $level method} );
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
