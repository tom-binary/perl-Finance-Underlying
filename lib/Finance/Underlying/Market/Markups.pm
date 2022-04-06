package Finance::Underlying::Market::Markups;

use strict;
use warnings;

use Moose;

## VERSION

=head1 NAME

Finance::Underlying::Market::Markups

=head1 METHODS

=head2 market

Should we apply market specific markups like news_corrections.

=cut

has 'apply_traded_markets_markup' => (
    is  => 'ro',
    isa => 'Bool',
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
