use strict;
use warnings;

use Test::More;
use Test::Warnings;
use Finance::Underlying;

subtest 'All symbols must have is_generated field' => sub {
    ok (defined $_->{is_generated}, "is_generated is not defined for $_->{symbol}") for Finance::Underlying->all_underlyings();
};

subtest 'Get all synthetic indices' => sub {
    my %expected_synthetics = map { $_ => 0 } qw/1HZ100V 1HZ200V 1HZ300V 1HZ10V 1HZ25V 1HZ50V 1HZ75V BOOM1000 BOOM500 CRASH1000 CRASH500 BOOM300N CRASH300N JD10 JD100 JD150 JD25 JD50 JD75 JD200 RB100 RB200 RDBEAR RDBULL R_10 R_100 R_25 R_50 R_75 WLDAUD WLDEUR WLDGBP WLDUSD WLDXAU stpAUDJPY stpAUDUSD stpEURCAD stpEURGBP stpEURUSD stpRNG stpUSDCAD stpUSDJPY/;

    my @syn_uls = map { $_->{symbol} } grep { $_->{is_generated} } Finance::Underlying->all_underlyings();
    $expected_synthetics{$_} = 1 for @syn_uls;
    is $expected_synthetics{$_}, 1, "$_ symbol should exist" for (keys %expected_synthetics);
    is @syn_uls, scalar keys %expected_synthetics, 'Number of generated symbols does not match the list';
};

done_testing;
