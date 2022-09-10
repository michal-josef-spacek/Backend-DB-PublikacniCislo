use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('Backend::DB::PublikacniCislo::Transform');
}

# Test.
require_ok('Backend::DB::PublikacniCislo::Transform');
