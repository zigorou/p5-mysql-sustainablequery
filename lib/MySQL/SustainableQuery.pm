package MySQL::SustainableQuery;

use strict;
use warnings;
use Class::Accessor::Lite (
    new => 0,
    rw  => [
        qw/wait_interval check_strategy_interval strategy log exec_query terminate_condition/
    ],
);
use Class::Load qw(load_class);
use POSIX       ();
use Time::HiRes ();

use MySQL::SustainableQuery::Log;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{@_};
    %$args = (
        wait_interval           => 0.1,
        check_strategy_interval => 10,
        strategy                => +{
            class => 'ByLoad',
            args  => +{},
        },
        log                 => undef,
        exec_query          => sub { 1; },
        terminate_condition => sub { 1; },
        %$args,
    );

    my $self = bless $args => $class;
    $self->setup;
}

sub setup {
    my $self = shift;
    $self->setup_log;
    $self->setup_strategy;
    $self;
}

sub setup_log {
    my $self = shift;
    $self->{log} = MySQL::SustainableQuery::Log->new( $self->{log} );
}

sub setup_strategy {
    my $self = shift;

    my $config          = $self->{strategy};
    my $strategy_module = $config->{class};

    $strategy_module =
      index( $strategy_module, '+' ) == 0
      ? substr( $strategy_module, 1 )
      : 'MySQL::SustainableQuery::Strategy::' . $strategy_module;
    load_class($strategy_module);

    my $strategy = $strategy_module->new( $config->{args} );
    $self->{strategy} = $strategy;
}

sub run {
    my $self = shift;

    my $i             = 1;
    my $time_sum      = 0;
    my $time_total    = 0;
    my $wait_interval = $self->wait_interval;
    for ( ; ; ) {
        my $t0      = [Time::HiRes::gettimeofday];
        my $rv      = $self->exec_query->( $self, $i );
        my $elapsed = Time::HiRes::tv_interval( $t0, [Time::HiRes::gettimeofday] );
        $time_sum   += $elapsed;
        $time_total += $elapsed;

        if ( $self->terminate_condition->( $self, $rv, $i, $time_sum ) ) {
            $self->log->info(
                sprintf(
                    'finished, execute total time: %.3f sec (counter: %d)',
                    $time_total, $i
                )
            );
            last;
        }

        if ( $i % $self->check_strategy_interval == 0 ) {
            my $wait_time =
              $self->strategy->wait_correction( $self, $time_sum, $i );
            $wait_interval = $self->wait_interval + $wait_time;
            $time_sum      = 0;
        }

        if ( $wait_interval > 0 ) {
            $self->log->info(
                sprintf(
'execute elapsed: %.3f sec, wait interval %.3f sec (counter: %d)',
                    $elapsed, $wait_interval, $i
                )
            );
            Time::HiRes::sleep($wait_interval);
        }

        $i++;
    }

    my %result = ( executed => $i, time_total => $time_total );

    return wantarray ? %result : \%result;
}

1;

__END__

=head1 NAME

MySQL::SustainableQuery - Execute query sustainably by strategy

=head1 SYNOPSIS

  use DBI;
  use MySQL::SustainableQuery;

  my $dbh = DBI->connect( ... );

  my $query = MySQL::SustainableQuery->new(
    exec_query => sub {
      my ( $q, $i ) = @_;
      return $dbh->do('DELETE FROM large_table ORDER BY id ASC LIMIT 100');
    },
    terminate_condition => sub {
      my ( $q, $rv, $i, $ts ) = @_;
      $rv < 100 ? 1 : 0;
    }
  );

  my $rs = $query->run;
  printf("execute count: %d; total times: %.02f sec\n", $rs->{executed}, $rs->{time_total});

=head1 DESCRIPTION

MySQL::SustainableQuery executes query to care load time or replication behind times or other factor.

=head2 new( %args )

The details of args is below.

=over

=item wait_interval

Base interval time (seconds).

=item check_strategy_interval

The interval count calling strategy's wait_correction() method.

=item strategy

=over

=item class

Specify strategy class name. When the strategy class name is beggining of 'MySQL::SustainableQuery::Strategy::',
you can omit it likes 'ByLoad' or 'BalancedReplication'.

=item args

Arguments passed to strategy modules's new() method.

=back

=item log

Specify logger object or code reference.

=item exec_query

Specify code rederence to execute query.

=item terminate_condition

Specify code rederence to judge which it can terminate or not.

=back

=head2 run()

Execute query.

=head2 setup()

Internal uses.

=head2 setup_log()

Internal uses.

=head2 setup_strategy()

Internal uses.

=head1 AUTHOR

Toru Yamaguchi E<lt>zigorou at ecpan dot orgE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
