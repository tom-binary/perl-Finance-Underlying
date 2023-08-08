package Finance::Underlying::SubMarket::Registry;

use strict;
use warnings;

use File::ShareDir;

## VERSION

=head1 NAME

Finance::Underlying::SubMarket::Registry

=head1 SYNOPSYS

    my $registry = Finance::Underlying::SubMarket::Registry->instance;
    my $submarket = $registry->get('synthetic_index'); # By name

=head1 DESCRIPTION

This class parses a file describing submarkets and provides a singleton
lookup object to access this information. This is a singleton, you shouldn't
call I<new>, just get the object using I<instance> method.

=cut

use namespace::autoclean;
use MooseX::Singleton;

use Finance::Underlying::Market::Types;
use Finance::Underlying::SubMarket;

with 'MooseX::Role::Registry';

=head1 METHODS

=head2 config_file

The default location of the YML file describing known server roles.

=cut

sub config_file {
    return File::ShareDir::dist_file('Finance-Underlying', 'submarkets.yml');
}

=head2 build_registry_object

Builds a Finance::Underlying::SubMarket object from provided configuration.

=cut

sub build_registry_object {
    my $self   = shift;
    my $name   = shift;
    my $values = shift;

    return Finance::Underlying::SubMarket->new({
        name => $name,
        %$values
    });
}

=head2 find_by_market

=cut

sub find_by_market {
    my ($self, $market) = @_;
    die("Usage: find_by_market(market_name)") if not $market;
    my @result = (
        sort { $a->{display_order} <=> $b->{display_order} }
        grep { $_->{market}->name eq $market and $_->{offered} == 1 } ($self->all));
    return @result;
}

__PACKAGE__->meta->make_immutable;
1;
