# -*- perl -*-

use Test::More tests => 2;

use Business::TPGPost;

my $tpg  = Business::TPGPost->new ();
my $cost = $tpg->calculate(
               country => 'GB',
               weight  => '250',
           );
is($cost, '3.70');

# UK is not the ISO code, so it should take the same value as, say, Japan
$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'UK',
               weight  => '250',
           );
is($cost, '6.25');
