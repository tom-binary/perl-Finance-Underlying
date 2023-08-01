use strict;
use warnings;

use Test::More tests => 1;
use Test::FailWarnings;
use Finance::Underlying::Market::Registry;
use Finance::Underlying::SubMarket::Registry;
use Finance::Underlying::SubMarket;

subtest 'Finance::Underlying::SubMarket::Registry' => sub {
    plan tests => 20;

    my $random_daily = Finance::Underlying::SubMarket::Registry->instance->get('random_daily');
    is($random_daily->name,         'random_daily',        'name');
    is($random_daily->display_name, 'Daily Reset Indices', 'display name');
    is($random_daily->market->name, 'synthetic_index',     'market');

    my $invalid = Finance::Underlying::SubMarket::Registry->instance->get('forex_test');
    is($invalid, undef, 'invalid Sub Market');

    my %markets = (
        forex           => 2,
        synthetic_index => 11,
        indices         => 7,
        commodities     => 2,
    );

    foreach my $market (keys %markets) {
        my @found_submarkets = Finance::Underlying::SubMarket::Registry->find_by_market($market);
        is(scalar @found_submarkets, $markets{$market}, 'found proper number of sub markets for ' . $market);
        my $first_example = $found_submarkets[0];
        isa_ok($first_example, 'Finance::Underlying::SubMarket', 'Properly returning SubMarket Objects');
        is($first_example->display_order, 1,       'First out is first in order');
        is($first_example->market->name,  $market, 'And on the correct market');
    }

};

