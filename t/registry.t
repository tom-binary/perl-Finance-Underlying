#!/etc/rmg/bin/perl

use strict;
use warnings;

use Test::Most;
use Test::FailWarnings;

use Finance::Underlying::Market::Registry;

subtest 'Build Registry' => sub {
    plan tests => 2;
    my $registry;

    lives_ok {
        $registry = Finance::Underlying::Market::Registry->instance;
    }
    'Able to load registry';

    ok $registry->get('forex'), 'We get forex';
};

subtest 'display_markets' => sub {
    plan tests => 1;
    my $registry = Finance::Underlying::Market::Registry->instance;

    eq_or_diff [sort map { $_->name } $registry->display_markets],
        [sort 'forex', 'cryptocurrency', 'indices', 'commodities', 'stocks', 'synthetic_index'], "correct list of financial markets";
};

subtest 'Market builds or configs test' => sub {
    subtest 'config' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $config = $registry->get('config');

        isa_ok $config, 'Finance::Underlying::Market';
        ok !$config->display_name, 'Display Name';
        ok !$config->equity;
        ok !$config->reduced_display_decimals, 'Reduced Display Decimals';
        is $config->asset_type,         'asset';
        is $config->deep_otm_threshold, 0.10;
        ok !$config->markups->apply_traded_markets_markup, 'Market Markup';
        ok !$config->foreign_bs_probability;
        ok !$config->absolute_barrier_multiplier;
        ok !$config->display_order;

        ok !$config->providers->[0];
        is $config->license, 'realtime';
        ok !$config->integer_barrier, 'non integer barrier';
    };

    subtest 'forex' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $forex = $registry->get('forex');

        isa_ok $forex, 'Finance::Underlying::Market';
        is $forex->display_name, 'Forex', 'Correct display name';
        is $forex->display_order, 1;
        ok !$forex->equity;
        ok $forex->reduced_display_decimals;
        is $forex->asset_type,         'currency';
        is $forex->deep_otm_threshold, 0.05;

        ok $forex->markups->apply_traded_markets_markup, 'Market Markup';
        ok $forex->foreign_bs_probability;
        ok $forex->absolute_barrier_multiplier;

        cmp_deeply($forex->providers, [qw(idata bloomberg oz)]);

        is $forex->license, 'realtime';
        ok !$forex->integer_barrier, 'non integer barrier';
    };

    subtest 'commodities' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $commodities = $registry->get('commodities');

        isa_ok $commodities, 'Finance::Underlying::Market';
        is $commodities->display_name,  'Commodities';
        is $commodities->display_order, 3;
        ok !$commodities->equity;
        ok $commodities->reduced_display_decimals;
        is $commodities->deep_otm_threshold, 0.10;
        is $commodities->asset_type,         'currency';

        ok $commodities->markups->apply_traded_markets_markup, 'Market Markup';
        ok !$commodities->foreign_bs_probability;
        ok $commodities->absolute_barrier_multiplier;

        cmp_deeply($commodities->providers, ['bloomberg', 'idata', 'oz'],);
        is $commodities->license, 'realtime';
        ok !$commodities->integer_barrier, 'non integer barrier';
    };

    subtest 'indices' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $indices = $registry->get('indices');

        isa_ok $indices, 'Finance::Underlying::Market';
        is $indices->display_name,  'Stock Indices';
        is $indices->display_order, 2;
        ok $indices->equity;
        ok !$indices->reduced_display_decimals;
        is $indices->deep_otm_threshold, 0.10;
        is $indices->asset_type,         'index';

        ok $indices->markups->apply_traded_markets_markup, 'Market Markup';
        ok !$indices->foreign_bs_probability;
        ok !$indices->absolute_barrier_multiplier;

        cmp_deeply($indices->providers, ['oz']);

        is $indices->license, 'daily';
        ok $indices->integer_barrier, 'Integer barrier';
    };

    subtest 'random' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $random = $registry->get('synthetic_index');

        isa_ok $random, 'Finance::Underlying::Market';
        is $random->display_name,  'Synthetic Indices';
        is $random->display_order, 4;
        ok !$random->equity;
        ok $random->reduced_display_decimals;
        is $random->deep_otm_threshold, 0.025;
        is $random->asset_type,         'synthetic';
        ok !$random->markups->apply_traded_markets_markup, 'Market Markup';
        ok !$random->foreign_bs_probability;
        ok $random->absolute_barrier_multiplier;

        cmp_deeply($random->providers, ['random',]);
        is $random->license, 'realtime';
        ok !$random->integer_barrier, 'non integer barrier';
    };

    subtest 'cryptocurrency' => sub {
        my $registry = Finance::Underlying::Market::Registry->instance;

        my $crypto = $registry->get('cryptocurrency');

        isa_ok $crypto, 'Finance::Underlying::Market';
        is $crypto->display_name, 'Cryptocurrencies';
        is $crypto->display_order, 5, 'display order is 5';
        ok !$crypto->equity;
        ok $crypto->reduced_display_decimals;
        is $crypto->deep_otm_threshold, 0.05;
        is $crypto->asset_type,         'digital';
        ok !$crypto->markups->apply_traded_markets_markup, 'Market Markup';
        ok !$crypto->foreign_bs_probability;
        ok !$crypto->absolute_barrier_multiplier;
        is $crypto->risk_profile, 'extreme_risk', 'risk_profile is extreme risk';

        cmp_deeply($crypto->providers, ['oz']);
        is $crypto->license, 'realtime';
        ok !$crypto->integer_barrier, 'non integer barrier';
    };
};

done_testing;
