use strict;
use warnings;

use Backend::DB::PublikacniCislo::Transform;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Backend::DB::PublikacniCislo::Transform::VERSION, 0.01, 'Version.');
