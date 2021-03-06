package MySQL::SustainableQuery::Log;

use strict;
use warnings;
use Scalar::Util ();

our $VERSION = '0.01';
our @LEVELS = qw(debug info notice warning error alert emergency);
our %LOGGER_DISPATCH_METHODS = (
    'Log::Dispatch' => [ qw/debug info notice warning error critical alert emergency/ ],
    'Log::Log4perl::Logger' => [ qw/debug info info warn error fatal fatal fatal/ ],
);

sub new {
    my ( $class, $logger ) = @_;

    my $attrs = +{};
    if ( defined $logger && Scalar::Util::blessed($logger) ) {
        my $is_supported_logger = 0;
        for my $supported_logger_class ( keys %LOGGER_DISPATCH_METHODS ) {
            if ( UNIVERSAL::isa($logger, $supported_logger_class) ) {
                $is_supported_logger = 1;
                my $dispatch_methods = $LOGGER_DISPATCH_METHODS{$supported_logger_class};
                my $i = 0;
                for my $level ( @LEVELS ) {
                    my $method = $dispatch_methods->[$i++];
                    $attrs->{$level} = sub {
                        my @messages = @_;
                        $logger->$method(@messages);
                    };
                }
                last;
            }
        }
        unless ( $is_supported_logger ) {
            $logger = undef;
        }
    }

    if (!defined $logger || ref $logger eq 'CODE') {
        require POSIX;
        $logger ||= sub {
            my ( $level, @messages ) = @_;
            for ( @messages ) {
                print STDERR sprintf("[%s %s] %s\n", $level, POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime), $_);
            };
        };

        for my $level ( @LEVELS ) {
            $attrs->{$level} = sub {
                my @messages = @_;
                $logger->( $level, @messages );
            };
        }
    }

    bless $attrs => $class;
}

do {
    no strict 'refs';
    for my $level ( @LEVELS ) {
        *{$level} = sub {
            my ( $self, @messages ) = @_;
            $self->{$level}->(@messages);
        };
    }
};

1;

__END__

=head1 NAME

MySQL::SustainableQuery::Log - Logger for MySQL::SustainableQuery

=head1 SYNOPSIS

  use MySQL::SustainableQuery::Log;

=head1 DESCRIPTION

=head1 METHODS

=head2 new( $logger )

=head2 debug( @msg )

=head2 info( @msg )

=head2 notice( @msg )

=head2 warning( @msg )

=head2 error( @msg )

=head2 alert( @msg )

=head2 emergency( @msg )

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

Log::Dispatch

debug
info
notice
warning
error
critical
alert
emergency

Log::Log4perl

trace
debug
info
warn
error
fatal

Sys::Syslog

* LOG_EMERG - system is unusable
* LOG_ALERT - action must be taken immediately
* LOG_CRIT - critical conditions
* LOG_ERR - error conditions
* LOG_WARNING - warning conditions
* LOG_NOTICE - normal, but significant, condition
* LOG_INFO - informational message
* LOG_DEBUG - debug-level message
