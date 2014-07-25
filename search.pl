#!/usr/bin/env perl

use strict;
use warnings;

use JSON;
use Sphinx::Search;

my ( $start, $size, $query ) = ( 0, 100, 'inbred' );

my $sph = Sphinx::Search->new();
$sph->SetMatchMode(SPH_MATCH_EXTENDED);
$sph->SetSortMode(SPH_SORT_RELEVANCE);
$sph->SetLimits( $start, $size );
my $results = $sph->Query( $query, 'ss_idx' );
print JSON->new->pretty->encode($results);

# vim:ts=2:sw=2:sts=2:et:ft=perl

