package Finance::Underlying::Market;

use strict;
use warnings;

## VERSION

=head1 NAME

Finance::Underlying::Market

=head1 DESCRIPTION

The representation of a market within our system

my $forex = Finance::Underlying::Market->new({name => 'forex'});

=cut

use Moose;

use Finance::Underlying::Market::Markups;
use Finance::Underlying::Market::Types;

has 'name' => (
    is       => 'ro',
    required => 1,
);

has suspicious_move => (
    is => 'ro',
);

=head2 integer_barrier

Only allow integer barrier for this market. Default to false.

=cut

has integer_barrier => (
    is      => 'ro',
    default => 0,
);

=head2 display_current_spot

A Boolean that determines if we are allowed to show current spot of this market to user

=cut

has display_current_spot => (
    is      => 'ro',
    default => 0,
);

has 'display_name' => (
    is => 'ro',
);

has 'explanation' => (
    is => 'ro',
);

has volatility_surface_type => (
    is      => 'ro',
    default => '',
);

=head2 markups

All the markups used for this market as I<Finance::Underlying::Market::Markups> object.

=cut

has 'markups' => (
    is      => 'ro',
    isa     => 'market_markups',
    coerce  => 1,
    default => sub { Finance::Underlying::Market::Markups->new(); });

=head2 reduced_display_decimals

Has display decimals reduced by 1

=cut

has 'reduced_display_decimals' => (
    is  => 'ro',
    isa => 'Bool',
);

=head2 asset_type

Represents the default asset_type for the market, can be (currency, index, asset).

=cut

has 'asset_type' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'asset',
);

=head2 foreign_bs_probability

Should foreign_bs_probability be used on this market

=cut

has 'foreign_bs_probability' => (
    is  => 'ro',
    isa => 'Bool',
);

=head2 absolute_barrier_multiplier

Should barrier multiplier be applied for absolute barried on this market

=cut

has 'absolute_barrier_multiplier' => (
    is  => 'ro',
    isa => 'Bool',
);

=head2 equity

Is this an equity

=cut

has 'equity' => (
    is  => 'ro',
    isa => 'Bool',
);

=head2 eod_blackout_expiry

How close is too close to close for bet expiry?

=head2 eod_blackout_start

How close is too close to close for bet start?

=head2 sod_blackout_start

How close is too close to open for bet start?

=cut

has [qw(eod_blackout_expiry eod_blackout_start sod_blackout_start)] => (
    is      => 'ro',
    default => undef,
);

=head2 intradays_must_be_same_day

Can any submarket of this be allowed to have intradays which cross days?

=cut

has intradays_must_be_same_day => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

=head2 max_suspend_trading_feed_delay

How long before we think the feed is down?

=cut

has max_suspend_trading_feed_delay => (
    is      => 'ro',
    isa     => 'time_interval',
    default => '5m',
    coerce  => 1,
);

=head2 display_order

The order with which this market has to be displayed

=cut

has 'display_order' => (
    is  => 'ro',
    isa => 'Int',
);

=head2 deep_otm_threshold

Threshold for ask price value to which deep_otm contracts will be
pushed. For deep_itm contracts with ask price greater than
1 - deep_otm_threshold, it will be pushed to full payout

=cut

has deep_otm_threshold => (
    is      => 'ro',
    isa     => 'Num',
    default => 0.10,
);

=head2 providers

A list of feed providers for this market in the order of priority.

=cut

has 'providers' => (
    is      => 'ro',
    default => sub { [] },
);

=head2 feed_parity

maximum acceptable deviation from mean, how close must recent ticks be to consider status as good

=cut

has 'feed_parity' => (
    is   => 'ro',
    isa     => 'Num',
    default => 0.01,
);

=head2 license

The license we have for this feed.

=cut

has 'license' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'daily',
);

# if you did not define this, I assume you don't offer it.
has risk_profile => (
    is      => 'ro',
    default => 'no_business',
);

=head2 expected_tick_frequency

Expected tick frequency in seconds. Feed generated internally (volatility indces), has 2-second interval.
Everything else is marked at 1-second interval

=cut

has expected_tick_frequency => (
    is      => 'ro',
    default => 1
);

=head2 generation_interval

How often we generate ticks, if a generated feed.

=cut

has generation_interval => (
    is      => 'ro',
    isa     => 'time_interval',
    coerce  => 1,
    default => 0,
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;

