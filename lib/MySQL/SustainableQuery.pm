package MySQL::SustainableQuery;

use strict;
use warnings;
use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/wait_interval check_strategy_interval strategy log exec_query terminate_condition/],
);
use Class::Load qw(load_class);
use POSIX ();
use Time::HiRes ();

use MySQL::SustainableQuery::Log;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{ @_ };
    %$args = (
        wait_interval => 0.1,
        check_strategy_interval => 10,
        strategy => +{
            class => 'ByLoad',
            args  => +{},
        },
        log => undef,
        exec_query => sub { 1; },
        terminate_condition => sub { 1; },
        %$args,
    );

    bless $args => $class;
}

sub setup {
    my $self = shift;
    $self->setup_log;
    $self->setup_strategy;
}

sub setup_log {
    my $self = shift;
    $self->{log} = MySQL::SustainableQuery::Log->new( $self->{log} );
}

sub setup_strategy {
    my $self = shift;

    my $config = $self->{strategy};
    my $strategy_module = $config->{class};

    $strategy_module = index($strategy_module, '+') == 0 ?
        substr($strategy_module, 1) : 'MySQL::SustainableQuery::Strategy::' . $strategy_module;
    load_class( $strategy_module );

    my $strategy = $strategy_module->new( $config->{args} );
    $self->{strategy} = $strategy;
}

sub run {
    my $self = shift;

    my $i = 1;
    my $time_sum = 0;
    my $time_total = 0;
    my $wait_interval = $self->wait_interval;
    for (;;) {
        my $t0 = [ Time::HiRes::gettimeofday ];
        my $rv = $self->exec_query->( $self, $i );
        my $elapsed = tv_interval ( $t0, [ Time::HiRes::gettimeofday ]);
        $time_sum += $elapsed;
        $time_total += $elapsed;

        if ( $self->terminate_condition->( $self, $rv, $i, $time_sum ) ) {
            $self->log->info( sprintf('finished, execute total time: %.3f sec (counter: %d)', $time_total, $i) );
            last;
        }

        if ( $i % $self->check_strategy_interval == 0 ) {
            my $wait_time = $self->strategy->wait_correction( $self, $time_sum, $i );
            $wait_interval = $self->wait_interval + $wait_time;
            $time_sum = 0;
        }

        if ( $wait_interval > 0 ) {
            $self->log->info( sprintf('execute elapsed: %.3f sec, wait interval %.3f sec (counter: %d)', $elapsed, $wait_interval, $i) );
            Time::HiRes::sleep( $wait_interval );
        }

        $i++;
    }
}

1;

__END__

=head1 NAME

MySQL::SustainableQuery -

=head1 SYNOPSIS

  use MySQL::SustainableQuery;

=head1 DESCRIPTION

MySQL::SustainableQuery is

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou at ecpan dot orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
