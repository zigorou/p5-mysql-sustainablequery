use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Requires qw(
  Log::Log4perl
  Log::Log4perl::Layout
  Log::Log4perl::Level
);
use Test::Output;

use Log::Log4perl;
use Log::Log4perl::Layout;
use Log::Log4perl::Level;
use MySQL::SustainableQuery::Log;

sub create_logger {
    my $logger          = Log::Log4perl->get_logger('main');
    my $screen_appender = Log::Log4perl::Appender->new(
        "Log::Log4perl::Appender::Screen",
        name   => "screenlog",
        stderr => 0,
    );
    $screen_appender->layout( Log::Log4perl::Layout::PatternLayout->new("%m") );
    $logger->add_appender($screen_appender);
    $logger->level($DEBUG);
    $logger;
}

my $logger = create_logger;

my $log;
lives_and {
    $log = MySQL::SustainableQuery::Log->new($logger);

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
