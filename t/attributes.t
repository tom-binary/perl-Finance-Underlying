#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Test::Most;
use Test::FailWarnings -allow_deps => 1;
use Finance::Underlying;

subtest 'general' => sub {
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
        'is_micro'        => 0,
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
        'pip_size'        => '0.01',
        inverted          => 0,
    };
    eq_or_diff { %$sample_underlying }, $sample_expected, "correct data for sample underlying";

    my $asset = Finance::Underlying->by_symbol('frxAUDUSD');
    cmp_ok $asset->{pip_size}, '==', 0.00001, 'pip_size';
};

subtest 'inverted' => sub {
    my $u               = Finance::Underlying->by_symbol('frxJPYAUD');
    my $expected_config = {
        'asset'             => 'JPY',
        'display_name'      => 'AUD/JPY inverted',
        'exchange_name'     => 'FOREX',
        'feed_license'      => 'realtime',
        'forward_feed'      => 1,
        'instrument_type'   => 'forex',
        'inverted'          => 1,
        'is_generated'      => 0,
        'is_micro'          => 0,
        'market'            => 'forex',
        'market_convention' => {
            'atm_setting'            => 'atm_delta_neutral_straddle',
            'bf'                     => '2_vol',
            'delta_premium_adjusted' => 1,
            'delta_style'            => 'spot_delta',
            'rr'                     => 'call-put'
        },
        'market_type'                  => 'financial',
        'pip_size'                     => 0.001,
        'quanto_only'                  => 0,
        'quoted_currency'              => 'AUD',
        'spot_spread_size'             => 45,
        'submarket'                    => 'major_pairs',
        'symbol'                       => 'frxJPYAUD',
        'uses_dst_shifted_seasonality' => 0
    };
    eq_or_diff($u->as_hashref, $expected_config, "correct data for sample underlying");
};

done_testing();

