package LightPage::Form::User;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
use namespace::autoclean;

has '+item_class' => ( default => 'User' );

has_field 'username' =>
  ( type => 'Text', required => 1, minlength => 5, maxlength => 40 );
has_field 'first_name'    => ( type => 'Text' );
has_field 'last_name'     => ( type => 'Text' );
has_field 'email_address' => ( type => 'Email', required => 1 );
has_field 'active' => (
    type    => 'Select',
    options => [ { value => 0, label => 'No' }, { value => 1, label => 'Yes' } ]
);
( type => 'Integer', range_start => 0, range_end => 1, required => 1 );
has_field 'roles'  => ( type => 'Multiple', label_column => 'role' );
has_field 'submit' => ( type => 'Submit',   value        => 'Submit' );

__PACKAGE__->meta->make_immutable;
1;
