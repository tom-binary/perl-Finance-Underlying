package Finance::Underlying::SubMarket;

use strict;
use warnings;

## VERSION

=head1 NAME

Finance::Underlying::SubMarket

=head1 DESCRIPTION

The representation of a sub market within our system

my $forex = Finance::Underlying::SubMarket->new({name => 'random_daily'});

=cut

use Moose;
use Finance::Underlying::Market::Types;

=head1 ATTRIBUTES

=head2 name

The name of the sub market

=head2 display_name

The name of the sub market to be displayed

=head2 display_order

The order in which this market has to be displayed within the market.

=head2 market

market it belongs to


=cut

has [qw (name display_name display_order)] => (
    is       => 'ro',
    required => 1,
);

has is_OTC => (
    is      => 'ro',
    default => 0,
);

=head2 providers

A list of feed providers for this submarket in the order of priority.

=cut

has 'providers' => (
    is      => 'ro',
    default => sub { undef },
);

=head2 volatility_surface_type

Type of surface this financial market should have.

=cut

has volatility_surface_type => (
    is      => 'ro',
    default => '',
);

has market => (
    is       => 'ro',
    isa      => 'financial_market',
    required => 1,
    coerce   => 1,
);

has offered => (
    is      => 'ro',
    default => 1,
);

=head2 explanation

explanation of what this submarket is.
=cut

has 'explanation' => (
    is => 'ro',
);

=head2 resets_at_open

Do underlyings on this (hopefully generated) sub-market get reset at their open?

=cut

has 'resets_at_open' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

=head2 intradays_must_be_same_day

Can this submarket be allowed to have intradays which cross days?

=cut

has intradays_must_be_same_day => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { return shift->market->intradays_must_be_same_day; },
);

=head2 asset_type

Represents the default asset_type for the market, can be (currency, index, asset).

=cut

has 'asset_type' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'asset',
);

=head2 max_suspend_trading_feed_delay

How long (in seconds) before we consider this feed down?

=cut

has max_suspend_trading_feed_delay => (
    is      => 'ro',
    isa     => 'time_interval',
    default => sub { return shift->market->max_suspend_trading_feed_delay; },
    coerce  => 1,
);

=head2 max_suspend_trading_feed_delay

How long (in seconds) before we consider to switch over to secondary feed provider?

=cut

has [qw(sod_blackout_start eod_blackout_start eod_blackout_expiry)] => (
    is         => 'ro',
    lazy_build => 1,
);

sub _build_sod_blackout_start {
    my $self = shift;
    return $self->market->sod_blackout_start;
}

sub _build_eod_blackout_start {
    my $self = shift;
    return $self->market->eod_blackout_start;
}

sub _build_eod_blackout_expiry {
    my $self = shift;
    return $self->market->eod_blackout_expiry;
}

has always_available => (
    is      => 'ro',
    default => 0,
);

has risk_profile => (
    is      => 'ro',
    default => undef,
);

=head2 is_rng

A boolean to indicate if feed generation relies on Random Number Generator (RNG)

=cut

has is_rng => (
    is      => 'ro',
    default => 0,
);

=head2 subgroup

Another layer between market and submarket.

=cut

has subgroup => (
    is      => 'ro',
    default => sub {
        return {
            name         => 'none',
            display_name => 'None',
        };
    });

no Moose;
__PACKAGE__->meta->make_immutable;

1;

