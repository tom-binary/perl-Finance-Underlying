package Finance::Underlying;
# ABSTRACT: Represents an underlying financial asset
use strict;
use warnings;
use feature 'state';

our $VERSION = '0.005';

=head1 NAME

Finance::Underlying - Object representation of a financial asset

=head1 VERSION

version 0.005

=head1 SYNOPSIS

    use Finance::Underlying;

    my $underlying = Finance::Underlying->by_symbol('frxEURUSD');
    print $underlying->pip_size, "\n";

=head1 DESCRIPTION

Provides metadata on financial assets such as forex pairs.

=cut

use Moo;
use YAML::XS qw(LoadFile);
use Scalar::Util qw(looks_like_number);
use File::ShareDir ();
use POSIX;
use Format::Util::Numbers qw(roundcommon);
use Finance::Underlying::SubMarket::Registry;
use Finance::Underlying::Market::Registry;

my (%underlyings, %inverted_underlyings);

=head1 CLASS METHODS

=head2 pipsized_value

Return a string pipsized to the correct number of decimal point

->pipsized_value(100);

=head2 all_underlyings

Returns a list of all underlyings, ordered by symbol.

=head2 display_decimals

Returns the number of digits of the underlying pip size or a custom pip size

=cut

sub pipsized_value {
    my ($self, $value, $custom) = @_;

    my $pip_size = $custom || $self->pip_size;

    if (defined $value and looks_like_number($value)) {
        $value = roundcommon($pip_size, $value);
    }
    return $value;
}

=head2 all_underlyings

Returns all the underlyings as sorted list.

=cut

sub all_underlyings {
    my ($self) = @_;
    map { $underlyings{$_} } sort keys %underlyings;
}

sub display_decimals {
    my ($self, $custom) = @_;
    my $the_pip_size = $custom ? $custom : $self->pip_size;
    return POSIX::log10(1 / $the_pip_size);
}

=head2 symbols

Return sorted list of all symbols.

=cut

sub symbols {
    return sort keys %underlyings;
}

=head2 by_symbol

Look up the underlying for the given symbol, returning a L<Finance::Underlying> instance.

=cut

sub by_symbol {
    my (undef, $symbol) = @_;

    $symbol =~ s/^FRX/frx/i;
    $symbol =~ s/^CRY/cry/i;
    $symbol =~ s/^RAN/ran/i;
    $symbol =~ s/^STP/stp/i;
    return $underlyings{$symbol} // $inverted_underlyings{$symbol} // die "unknown underlying $symbol";
}

=head2 cached_underlyings

To be used in L<Quant::Framework::Underlying>. 

=cut

sub cached_underlyings {
    state $cached_values = {};

    return $cached_values;
}

=head1 ATTRIBUTES

=head2 asset

The asset being quoted, for example C<USD> for the C<frxUSDJPY> underlying.

=cut

has asset => (
    is       => 'ro',
    required => 1,
);

has generation_interval => (
    is => 'ro',
);

=head2 display_name

User-friendly English name used for display purposes.

=cut

has display_name => (
    is => 'ro',
);

=head2 exchange_name

The symbol of the exchange this underlying is traded on.

See C<Finance::Exchange>. for more details.

=cut

has exchange_name => (
    is => 'ro',
);

=head2 instrument_type

Categorises the underlying, available values are:

=over 4

=item * commodities

=item * forex

=item * future

=item * forex_basket

=item * commodity_basket

=item * stockindex

=item * synthetic

=back

=cut

has instrument_type => (
    is => 'ro',
);

=head2 market

The type of market for this underlying, for example C<forex> for foreign exchange.

This will be one of the following:

=over 4

=item * commodities

=item * forex

=item * futures

=item * indices

=item * synthetic_index

=item * basket_index

=back

=cut

has market => (
    is => 'ro',
);

=head2 market_convention

These should mirror Bloomberg's Composite vol data conventions.

For further information, see C<Foreign Exchange option pricing>, by Iain J Clark, pages
47 onwards.

Types of volatility conventions available:

=head3 atm_setting

There are three types:

=over 4

=item * B<atm_delta_neutral_straddle> - strike so that call delta = -put delta

=item * B<atm_forward> - strike = forward price

=item * B<atm_spot> - strike = spot

=back

=head3 delta_premium_adjusted

There are two types:

=over 4

=item * 1 for premium adjusted . Premium adjusted means the actual hedge
quantity must be adjusted by the premium received if the premium is
paid in foreign currency.

=item * 0 for no premium adjusted - for futher explanation please refer to Wystup C<FX Volatility Smile Construction> April 2010 paper, pg 5 and 6.

=back

=head3 delta_style

There are two delta convention available:

=over 4

=item * B<spot_delta> - with a hedge in the spot market.

=item * B<forward_delta> - with a hedge in FX forward market

=back

=head3 rr

Risk reversal:

=over 4

=item * call-put

=item * put-call

=back

=head3 bf

There are three types of butterfly available in Bloomberg setting:

=over 4

=item * B<(call+put)/2-atm>  (which is quoted 1 vol strangle for Composite
sources and 2 vol (a.k.a smile strangle) for BGN sources)

=item * B<Base currency strangle> - ATM (which is (base currency call + base
currency put)- ATM)

=item * B<Foreign currency strangle> - ATM (which is (foreign currency call +
foreign currency put)- ATM)

=back

=cut

has market_convention => (
    is => 'ro',
);

=head2 pip_size

How large the spot pip is.

=cut

has pip_size => (
    is => 'ro',
);

=head2 quoted_currency

The second half of a forex pair - indicates the currency that this underlying is quoted in,
or the currency in which a stock index is quoted.

=cut

has quoted_currency => (
    is => 'ro',
);

=head2 submarket

Classification for the underlying, see also L</market>.

=cut

has submarket => (
    is => 'ro',
);

=head2 symbol

The symbol of the underlying, for example C<frxUSDJPY> or C<WLDAUD>.

=cut

has symbol => (
    is => 'ro',
);

=head2 market_type

financial or non_financial. Defaults to financial

=cut

has market_type => (
    is      => 'ro',
    default => 'financial'
);

=head2 is_generated

Whether this symbol is generated or it's coming from other sources

=cut

has is_generated => (
    is      => 'ro',
    default => 0
);

has uses_dst_shifted_seasonality => (
    is => 'ro',
);

has forward_feed => (
    is => 'ro',
);

has quanto_only => (
    is => 'ro',
);

has spot_spread_size => (
    is => 'ro',
);

has providers => (
    is => 'ro',
    is => 'lazy',
);

=head2 _build_providers

Return providers from SubMarket or Market

=cut

sub _build_providers {
    my ($self) = @_;

    my $providers = Finance::Underlying::SubMarket::Registry->get($self->submarket)->providers;
    return $providers if defined $providers;

    $providers = Finance::Underlying::Market::Registry->get($self->market)->providers;
    return $providers || die "No provider is defined for " . $self->symbol;
}

has flat_smile => (
    is => 'ro',
);

has forward_inefficient_periods => (
    is => 'ro',
);

has feed_license => (
    is => 'ro',
);

has feed_failover => (
    is      => 'ro',
    default => 60,
);

has inefficient_periods => (
    is => 'ro',
);

=head2 inverted

Boolean which indicates if a symbol is inverted.

=cut

has inverted => (
    is      => 'ro',
    default => 0,
);

=head2 is_micro

Boolean which indicates if this is a micro symbol. Only applicable to forex.

=cut

has is_micro => (
    is      => 'ro',
    default => 0,
);

=head2 as_hashref

Returns a hash reference of symbol config

=cut

sub as_hashref {
    my $self = shift;

    my %hash = $self->%*;

    return \%hash;
}

{
    my $param = LoadFile(File::ShareDir::dist_file('Finance-Underlying', 'underlyings.yml'));

    foreach my $symbol (keys $param->%*) {
        my $obj = __PACKAGE__->new($param->{$symbol});
        # straight up initialise the potential inverted symbols for cleaner caller code.
        if (not $obj->is_micro and ($obj->market eq 'forex' or $obj->market eq 'cryptocurrency' or $obj->market eq 'commodities')) {
            my %inverted_params = $param->{$symbol}->%*;
            $inverted_params{inverted}        = 1;
            $inverted_params{asset}           = $obj->quoted_currency;
            $inverted_params{quoted_currency} = $obj->asset;
            my $symbol_prefix = $obj->market eq 'cryptocurrency' ? 'cry' : 'frx';
            $inverted_params{symbol} = $symbol_prefix . $inverted_params{asset} . $inverted_params{quoted_currency};
            $inverted_params{display_name} .= ' inverted';
            $inverted_underlyings{$inverted_params{symbol}} = __PACKAGE__->new(\%inverted_params);
        }

        $underlyings{$symbol} = $obj;
    }

}

1;

=head1 SEE ALSO

=over 4

=item * L<Finance::Contract> - represents a financial contract

=back

=head1 AUTHOR

binary.com

=cut
