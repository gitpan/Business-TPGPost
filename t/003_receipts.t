# -*- perl -*-

use Test::More tests => 2;

use Business::TPGPost;

my $tpg  = Business::TPGPost->new ();
my $cost = $tpg->calculate(
               country => 'DE',
               weight  => '250',
               register=> 1,
           );
is($cost, '7.70');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'DE',
               weight  => '250',
               register=> 1,
               receipt => 1,
           );
is($cost, '9.10');
