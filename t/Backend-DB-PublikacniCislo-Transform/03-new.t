use strict;
use warnings;

use Backend::DB::PublikacniCislo::Transform;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
my $obj = Backend::DB::PublikacniCislo::Transform->new;
isa_ok($obj, 'Backend::DB::PublikacniCislo::Transform');
