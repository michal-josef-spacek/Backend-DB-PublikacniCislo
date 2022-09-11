package Backend::DB::PublikacniCislo::Transform;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Data::PublikacniCislo::HashType;
use Data::PublikacniCislo::Person;
use Data::PublikacniCislo::PersonRole;
use Data::PublikacniCislo::PublicationNumber;
use Data::PublikacniCislo::Role;
use Encode qw(is_utf8);
use Error::Pure qw(err);
use Scalar::Util qw(blessed);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Process parameters.
	set_params($self, @params);

	return $self;
}

sub hash_type_db2obj {
	my ($self, $hash_type_db) = @_;

	return Data::PublikacniCislo::HashType->new(
		'active' => $hash_type_db->active,
		'id' => $hash_type_db->hash_type_id,
		'name' => $hash_type_db->name,
	);
}

sub hash_type_obj2db {
	my ($self, $hash_type_obj) = @_;

	return {
		$self->_check_value('hash_type_id', $hash_type_obj, ['id']),
		'name' => $hash_type_obj->name,
		'active' => $hash_type_obj->active,
	};
}

sub person_db2obj {
	my ($self, $person_db) = @_;

	return Data::PublikacniCislo::Person->new(
		'id' => $person_db->person_id,
		'name' => $self->_decode_utf8($person_db->name),
		'email' => $person_db->email,
	);
}

sub person_obj2db {
	my ($self, $person_obj) = @_;

	return {
		$self->_check_value('person_id', $person_obj, ['id']),
		$self->_check_value('email', $person_obj, ['email']),
		$self->_check_value('name', $person_obj, ['name']),
	};
}

sub person_role_db2obj {
	my ($self, $person_role_db) = @_;

	return Data::PublikacniCislo::PersonRole->new(
		'competition' => $self->competition_db2obj($person_role_db->competition),
		'person' => $self->person_db2obj($person_role_db->person),
		'role' => $self->role_db2obj($person_role_db->role),
	);
}

sub person_role_obj2db {
	my ($self, $person_role_obj) = @_;

	return {
		$self->_check_value('competition_id', $person_role_obj, ['competition', 'id']),
		$self->_check_value('person_id', $person_role_obj, ['person', 'id']),
		$self->_check_value('role_id', $person_role_obj, ['role', 'id']),
	};
}

sub publication_number_db2obj {
	my ($self, $pn_db) = @_;

	return Data::PublikacniCislo::PublicationNumber->new(
		'created_by' => $self->person_db2obj($pn_db->created_by),
		'id' => $pn_db->publication_number_id,
		'publication_number' => $pn_db->publication_number,
	);
}

sub publication_number_obj2db {
	my ($self, $pn_obj) = @_;

	return {
		$self->_check_value('publication_number_id', $pn_obj, ['id']),
		$self->_check_value('publication_number', $pn_obj, ['publication_number']),
		$self->_check_value('created_by_id', $pn_obj, ['created_by', 'id']),
	};
}

sub role_db2obj {
	my ($self, $role_db) = @_;

	return Data::PublikacniCislo::Role->new(
		'id' => $role_db->role_id,
		'name' => $self->_decode_utf8($role_db->name),
		'description' => $self->_decode_utf8($role_db->description),
	);
}

sub role_obj2db {
	my ($self, $role_obj) = @_;

	return {
		$self->_check_value('role_id', $role_obj, ['id']),
		'name' => $role_obj->name,
		$self->_check_value('description', $role_obj, ['description']),
	};
}

sub _check_value {
	my ($self, $key, $obj, $method_ar) = @_;

	if (! defined $obj) {
		err 'Bad object',
			'Error', 'Object is not defined.',
		;
	}
	if (! blessed($obj)) {
		err 'Bad object.',
			'Error', 'Object in not a instance.',
		;
	}
	my $value = $obj;
	foreach my $method (@{$method_ar}) {
		$value = $value->$method;
		if (! defined $value) {
			return;
		}
	}
	return ($key => $value);
}

sub _decode_utf8 {
	my ($self, $value) = @_;

	if (defined $value) {
		if (is_utf8($value)) {
# XXX Pg is converting this automatically.
			return $value;
#			err "Value '$value' is decoded.";
		} else {
			return decode_utf8($value);
		}
	} else {
		return $value;
	}
}

1;

__END__
