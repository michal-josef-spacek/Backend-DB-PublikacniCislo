package Backend::DB::PublikacniCislo::Transform;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Data::PublikacniCislo::HashType;
use Data::PublikacniCislo::Link;
use Data::PublikacniCislo::LinkType;
use Data::PublikacniCislo::Person;
use Data::PublikacniCislo::PersonRole;
use Data::PublikacniCislo::PublicationNumber;
use Data::PublikacniCislo::PublicationNumberPrefix;
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

sub link_db2obj {
	my ($self, $link_db) = @_;

	return Data::PublikacniCislo::Link->new(
		'link' => $link_db->link,
		'link_type' => $self->link_type_db2obj($link_db->link_type),
		'created_by' => $self->person_db2obj($link_db->created_by),
	);
}

sub link_type_db2obj {
	my ($self, $link_type_db) = @_;

	return Data::PublikacniCislo::LinkType->new(
		'id' => $link_type_db->link_type_id,
		'created_by' => $self->person_db2obj($link_type_db->created_by),
		'name' => $link_type_db->link_type,
		'wd_property' => $link_type_db->wikidata_property,
	);
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

	my @links = map { $self->link_db2obj($_) } $pn_db->links;
	return Data::PublikacniCislo::PublicationNumber->new(
		'created_by' => $self->person_db2obj($pn_db->created_by),
		'id' => $pn_db->publication_number_id,
		'publication_number' => $pn_db->publication_number,
		'links' => \@links,
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

sub publication_number_prefix_db2obj {
	my ($self, $pnp_db) = @_;

	return Data::PublikacniCislo::PublicationNumberPrefix->new(
		'created_by' => $self->person_db2obj($pnp_db->created_by),
		'id' => $pnp_db->publication_number_prefix_id,
		'prefix' => $pnp_db->publication_number_prefix,
	);
}

sub publication_number_prefix_obj2db {
	my ($self, $pnp_obj) = @_;

	return {
		$self->_check_value('publication_number_prefix_id', $pnp_obj, ['id']),
		$self->_check_value('publication_number_prefix', $pnp_obj, ['prefix']),
		$self->_check_value('created_by_id', $pnp_obj, ['created_by', 'id']),
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
