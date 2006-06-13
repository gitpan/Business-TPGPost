# -*- perl -*-

use Test::More tests => 4;

use Business::TPGPost;

my $tpg  = Business::TPGPost->new ();
my $cost = $tpg->calculate(
               country => 'PL',
               weight  => '345',
               register=> 1
           );
is($cost, '8.10');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'NL',
               weight  => '11337',
               priority=> 1,
               large   => 1 
           );
is($cost, undef);
is($Business::TPGPost::ERROR, '1337 grams too heavy (max: 10000 gr.)');

$tpg  = Business::TPGPost->new ();
$cost = $tpg->calculate(
               country => 'NL',
               weight  => '1337',
               priority=> 1,
               large   => 1 
           );
is($cost, '6.20');
