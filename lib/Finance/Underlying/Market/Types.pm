package Finance::Underlying::Market::Types;

use strict;
use warnings;

use Moose;

use MooseX::Types::Moose qw(Int Num Str);
use MooseX::Types -declare => [qw(
        financial_market
        submarket
        market_markups
        date_object
        time_interval
        )];

use Moose::Util::TypeConstraints;
use Time::Duration::Concise;

## VERSION

=head1 NAME

Finance::Underlying::Market::Types

=cut

subtype 'time_interval', as 'Time::Duration::Concise';
coerce 'time_interval', from 'Str', via { Time::Duration::Concise->new(interval => $_) };

subtype 'date_object', as 'Date::Utility';
coerce 'date_object', from 'Str', via { Date::Utility->new($_) };

subtype 'financial_market', as 'Finance::Underlying::Market';
coerce 'financial_market', from 'Str', via { return Finance::Underlying::Market::Registry->instance->get($_); };

subtype 'submarket', as 'Finance::Underlying::SubMarket';
coerce 'submarket', from 'Str', via { return Finance::Underlying::SubMarket::Registry->instance->get($_); };

subtype 'market_markups', as 'Finance::Underlying::Market::Markups';
coerce 'market_markups', from 'HashRef' => via { Finance::Underlying::Market::Markups->new($_); };

no Moose;
no Moose::Util::TypeConstraints;
__PACKAGE__->meta->make_immutable;

1;
