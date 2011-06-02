package MySQL::SustainableQuery::Strategy;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $args = ref $_[0] ? $_[0] : +{ @_ };
    bless $args => $class;
}

sub wait_correction { 1; }

1;

__END__

=head1 NAME

MySQL::SustainableQuery::Strategy - write short description for MySQL::SustainableQuery::Strategy

=head1 SYNOPSIS

  use MySQL::SustainableQuery::Strategy;

=head1 DESCRIPTION

=head1 METHODS

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
