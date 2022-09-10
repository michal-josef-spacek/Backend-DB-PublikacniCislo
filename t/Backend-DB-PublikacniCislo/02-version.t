use strict;
use warnings;

use Backend::DB::PublikacniCislo;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Backend::DB::PublikacniCislo::VERSION, 0.01, 'Version.');
