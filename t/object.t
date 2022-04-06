use strict;
use warnings;

use Test::Most tests => 1;
use Test::Exception;
use Test::FailWarnings;

use Finance::Underlying::Market;
use Finance::Underlying::Market::Registry;

throws_ok { Finance::Underlying::Market->new() } qr/Attribute \(name\) is required/, 'Name is Required';
