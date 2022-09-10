use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Backend::DB::PublikacniCislo', 'Backend::DB::PublikacniCislo is covered.');
