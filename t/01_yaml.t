#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib';
use Test::More;
use Test::Exception;
use Test::FailWarnings -allow_deps => 1;
use Finance::Underlying;

lives_ok { my $underlying = Finance::Underlying->by_symbol('frxAUDUSD') } 'YAML loaded';

done_testing();
