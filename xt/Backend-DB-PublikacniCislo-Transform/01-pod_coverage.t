use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Backend::DB::PublikacniCislo::Transform', 'Backend::DB::PublikacniCislo::Transform is covered.');
