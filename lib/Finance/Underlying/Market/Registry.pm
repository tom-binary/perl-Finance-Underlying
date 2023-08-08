package Finance::Underlying::Market::Registry;

use strict;
use warnings;

use File::ShareDir;

## VERSION

=head1 NAME

Finance::Underlying::Market::Registry

=head1 SYNOPSYS

    my $registry = Finance::Underlying::Market::Registry->instance;
    my $host = $registry->get('synthetic_index'); # By name

=head1 DESCRIPTION

This class parses a file describing markets and provides a singleton
lookup object to access this information. This is a singleton, you shouldn't
call I<new>, just get the object using I<instance> method.

=cut

use namespace::autoclean;
use MooseX::Singleton;

use Finance::Underlying::Market::Types;
use Finance::Underlying::Market;

with 'MooseX::Role::Registry';

=head1 METHODS

=head2 config_file

The default location of the YML file describing known server roles.

=cut

sub config_file {
    return File::ShareDir::dist_file('Finance-Underlying', 'financial_markets.yml');
}

=head2 build_registry_object

Builds a Finance::Underlying::Market object from provided configuration.

=cut

sub build_registry_object {
    my $self   = shift;
    my $name   = shift;
    my $values = shift;

    return Finance::Underlying::Market->new({
        name => $name,
        %$values
    });
}

=head2 display_markets

=cut

sub display_markets {
    my $self = shift;

    my @display_markets =
        sort { $a->display_order <=> $b->display_order }
        grep { $_->display_order } $self->all;
    return @display_markets;
}

=head2 all_market_names

=cut

sub all_market_names {
    my $self  = shift;
    my @names = grep { $_ ne 'config' } map { $_->name } $self->display_markets;
    return @names;
}

__PACKAGE__->meta->make_immutable;

1;
