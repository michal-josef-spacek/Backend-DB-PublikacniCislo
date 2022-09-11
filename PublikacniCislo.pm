package Backend::DB::PublikacniCislo;

use strict;
use warnings;

use Class::Utils qw(set_params);
use Backend::DB::PublikacniCislo::Transform;
use English;
use Error::Pure qw(err);
use Unicode::UTF8 qw(decode_utf8);

our $VERSION = 0.01;

sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Database schema instance.
	$self->{'schema'} = undef;

	# Process parameters.
	set_params($self, @params);

	# Check schema.
	if (! defined $self->{'schema'}) {
		err "Parameter 'schema' is required.";
	}
	if (! $self->{'schema'}->isa('Schema::PublikacniCislo::0_1_0')) {
		err "Parameter 'schema' must be 'Schema::PublikacniCislo::0_1_0' instance.";
	}

	# Transform object.
	$self->{'_transform'} = Backend::DB::PublikacniCislo::Transform->new;

	return $self;
}

sub fetch_hash_type {
	my ($self, $hash_type_id) = @_;

	my $hash_type_db = $self->{'schema'}->resultset('HashType')->search({
		'hash_type_id' => $hash_type_id,
	})->single;

	return unless defined $hash_type_db;
	return $self->{'_transform'}->hash_type_db2obj($hash_type_db);
}

sub fetch_hash_type_name {
	my ($self, $hash_type_name) = @_;

	my $hash_type_db = $self->{'schema'}->resultset('HashType')->search({
		'name' => $hash_type_name,
	})->single;

	return unless defined $hash_type_db;
	return $self->{'_transform'}->hash_type_db2obj($hash_type_db);
}

sub fetch_link_type {
	my ($self, $cond_hr) = @_;

	my $link_type_db = $self->{'schema'}->resultset('LinkType')->search($cond_hr)
		->single;

	return unless defined $link_type_db;
	return $self->{'_transform'}->link_type_db2obj($link_type_db);
}

sub fetch_person {
	my ($self, $cond_hr) = @_;

	my $person_db = $self->{'schema'}->resultset('Person')->search($cond_hr)->single;

	return unless defined $person_db;
	return $self->{'_transform'}->person_db2obj($person_db);
}

sub fetch_person_login {
	my ($self, $login) = @_;

	my $person_login = $self->{'schema'}->resultset('PersonLogin')->search({
		'login' => $login,
	})->single;

	return unless defined $person_login;
	return $self->{'_transform'}->person_login_db2obj($person_login);
}

sub fetch_people {
	my ($self, $cond_hr, $attr_hr) = @_;

	return map {
		$self->{'_transform'}->person_db2obj($_);
	} $self->{'schema'}->resultset('Person')->search($cond_hr, $attr_hr);
}

sub fetch_publication_number {
	my ($self, $cond_hr) = @_;

	my $pn_db = $self->{'schema'}->resultset('PublicationNumber')->search($cond_hr)
		->single;

	return unless defined $pn_db;
	return $self->{'_transform'}->publication_number_db2obj($pn_db);
}

sub fetch_publication_number_prefix {
	my ($self, $cond_hr) = @_;

	my $pnp_db = $self->{'schema'}->resultset('PublicationNumberPrefix')->search($cond_hr)
		->single;

	return unless defined $pnp_db;
	return $self->{'_transform'}->publication_number_prefix_db2obj($pnp_db);
}

sub fetch_role {
	my ($self, $role_name) = @_;

	my $role_db = $self->{'schema'}->resultset('Role')->search({
		'name' => $role_name,
	})->single;

	return unless defined $role_db;
	return $self->{'_transform'}->role_db2obj($role_db);
}

sub save_hash_type {
	my ($self, $hash_type_obj) = @_;

	if (! $hash_type_obj->isa('Data::Commons::Vote::HashType')) {
		err "Hash type object must be a 'Data::Commons::Vote::HashType' instance.";
	}

	my $hash_type_db = eval {
		$self->{'schema'}->resultset('HashType')->create(
			$self->{'_transform'}->hash_type_obj2db($hash_type_obj),
		);
	};
	if ($EVAL_ERROR) {
		err "Cannot save hash type.",
			'Error', $EVAL_ERROR;
	}

	return unless defined $hash_type_db;
	return $self->{'_transform'}->hash_type_db2obj($hash_type_db);
}

sub save_person {
	my ($self, $person_obj) = @_;

	my $person_db = $self->{'schema'}->resultset('Person')->create(
		$self->{'_transform'}->person_obj2db($person_obj),
	);

	return unless defined $person_db;
	return $self->{'_transform'}->person_db2obj($person_db);
}

sub save_person_role {
	my ($self, $person_role_obj) = @_;

	my $person_role_db = $self->{'schema'}->resultset('PersonRole')->create(
		$self->{'_transform'}->person_role_obj2db($person_role_obj),
	);

	return unless defined $person_role_db;
	return $self->{'_transform'}->person_role_db2obj($person_role_db);
}

sub save_publication_number {
	my ($self, $pn_obj) = @_;

	my $pn_db = $self->{'schema'}->resultset('PublicationNumber')->create(
		$self->{'_transform'}->publication_number_obj2db($pn_obj),
	);

	return unless defined $pn_db;
	return $self->{'_transform'}->publication_number_db2obj($pn_db);
}

sub save_publication_number_prefix {
	my ($self, $pnp_obj) = @_;

	my $pnp_db = $self->{'schema'}->resultset('PublicationNumberPrefix')->create(
		$self->{'_transform'}->publication_number_obj2db($pnp_obj),
	);

	return unless defined $pnp_db;
	return $self->{'_transform'}->publication_number_prefix_db2obj($pnp_db);
}

1;

__END__
