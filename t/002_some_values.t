# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 5;

use Business::TPGPost;

my $tpg  = Business::TPGPost->new ();
my $cost = $tpg->calculate(
               country => 'DE',
               weight  => '1234',
               priority=> 1
           );
is($cost, '10.25');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'NL',
               weight  => '234',
               priority=> 0,
               register=> 1,
               machine => 1 
           );
is($cost, '5.55');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'MX',
               weight  => '666',
               priority=> 1,
               register=> 0,
               machine => 0 
           );
is($cost, '19.30');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'CH',
               weight  => '6666',
               priority=> 1,
               register=> 1,
               machine => 0 
           );
is($cost, undef);
is($Business::TPGPost::ERROR, '4666 grams too heavy (max: 2000 gr.)');
