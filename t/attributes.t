#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Test::Most;
use Test::FailWarnings -allow_deps => 1;
use Finance::Underlying;

my @underlyings = Finance::Underlying->symbols;
cmp_ok scalar(@underlyings), ">", 100, "Finance::Underlying initialized, symbols are loaded";
my @mismatch = grep { $_ ne Finance::Underlying->by_symbol($_)->symbol } @underlyings;
is(scalar @mismatch, 0, 'No symbols differ from underlyings.yml keys.');
foreach my $key (@mismatch) {
    diag 'Mismatched key [' . $key . '] and symbol [' . Finance::Underlying->by_symbol($_)->symbol . ']';
}

my $sample_underlying = Finance::Underlying->by_symbol('OTC_FCHI');
my $sample_expected   = {
    'exchange_name'     => 'EURONEXT_OTC',
    'market_convention' => {
        'delta_premium_adjusted' => 0,
        'delta_style'            => 'spot_delta'
    },
    'is_generated'    => 0,
    'display_name'    => 'French Index',
    'instrument_type' => 'stockindex',
    'feed_license'    => 'realtime',
    'symbol'          => 'OTC_FCHI',
    'quoted_currency' => 'EUR',
    'providers'       => ['oz'],
    'asset'           => 'OTC_FCHI',
    'market'          => 'indices',
    'market_type'     => 'financial',
    'submarket'       => 'europe_OTC',
    'pip_size'        => '0.01'
};
eq_or_diff { %$sample_underlying }, $sample_expected, "correct data for sample underlying";

my $asset = Finance::Underlying->by_symbol('frxAUDUSD');
cmp_ok $asset->{pip_size}, '==', 0.00001, 'pip_size';

done_testing();

