use strict;
use warnings;

use Test::More (tests => 1);
use Test::Exception;
use Test::FailWarnings;

use Date::Utility;
use Finance::Underlying::Market::Registry;
use Finance::Underlying::SubMarket;

subtest 'SubMarket' => sub {
    plan tests => 5;
    my $submarket = new_ok(
        'Finance::Underlying::SubMarket',
        [{
                name          => 'forex_minor',
                display_name  => 'Forex Minor Market',
                display_order => 1,
                market        => 'forex',
            }]);

    is($submarket->name,          'forex_minor',        'name');
    is($submarket->display_name,  'Forex Minor Market', 'display name');
    is($submarket->display_order, 1,                    'display order');
    is($submarket->market->name,  'forex',              'market');
};
