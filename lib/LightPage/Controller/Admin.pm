package LightPage::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

LightPage::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Controller for the Admin page

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( template => 'admin_page/admin_index.tt' );
}

=head2 base

Base for a chained action

=cut

sub base : Chained('/') : PathPart('admin') : CaptureArgs(0) {
    my ( $self, $c ) = @_;
    $c->stash( resultset => $c->model('DB::User') );
}

=head2 base -> user_list

Get the list of the users

=cut

sub user_list : Chained('base') : PathPart('user_list') : Args(0) {
    my ( $self, $c ) = @_;
    my $user_list = [ $c->model('DB::User')->all ];
    $c->stash(
        user_list => $user_list,
        template  => 'admin_page/user_list.tt'
    );
}

=head2 base -> user_object

Get a user object id, stash it

=cut

sub user_object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash( user_object => $c->stash->{resultset}->find($id) );
    die "User ID $id not found!" if !$c->stash->{user_object};
}

=head2 base -> create_user_form

Form for creating a new user

=cut

sub create_user_form : Chained('base') : PathPart('create_user_form') : Args(0)
{
    my ( $self, $c ) = @_;
    $c->stash( template => "admin_page/create_user_form.tt" );
}

=head2 base -> create_user_do

Action for creating a new user

=cut

sub create_user_do : Chained('base') : PathPart('create_user_do') : Args(0) {
    my ( $self, $c ) = @_;

    # Data from the form
    my $username      = $c->request->params->{'username'};
    my $first_name    = $c->request->params->{'first_name'};
    my $last_name     = $c->request->params->{'last_name'};
    my $email_address = $c->request->params->{'email_address'};
    my $password      = $c->request->params->{'password'};
    my $active        = 1;
    my $role_id       = 1;

    # Creating the user
    my $user = $c->model('DB::User')->create(
        {
            username      => $username,
            first_name    => $first_name,
            last_name     => $last_name,
            email_address => $email_address,
            password      => $password,
            active        => $active,
        }
    );

    # Adding to the roles
    # $user->create_related( 'user_roles', { role_id => $role_id } );
    $user->add_to_user_roles( { role_id => $role_id } );

    # Return to the user list
    $c->response->redirect( $c->uri_for( $self->action_for('user_list') ) );
}

=head2 base -> user_object -> user_delete

Delete a user

=cut

sub user_delete : Chained('user_object') : PathPart('user_delete') : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{user_object}->delete;
    $c->response->redirect( $c->uri_for( $self->action_for('user_list') ) );
}

=head2 base -> user_object -> modify_user_form

Form for modifying a user

=cut

sub modify_user_form : Chained('user_object') : PathPart('modify_user_form') :
  Args(0) {
    my ( $self, $c ) = @_;
    $c->stash(
        user_data => $c->stash->{user_object},
        template  => "admin_page/modify_user_form.tt"
    );
}

=head2 base -> user_object -> modify_user_do

Action for modifying a user

=cut

sub modify_user_do : Chained('user_object') : PathPart('modify_user_do') :
  Args(0) {
    my ( $self, $c ) = @_;

    # Data from the form
    my $username      = $c->request->params->{'username'};
    my $first_name    = $c->request->params->{'first_name'};
    my $last_name     = $c->request->params->{'last_name'};
    my $email_address = $c->request->params->{'email_address'};
    my $role_id       = $c->request->params->{'role_id'};

    # Updating user data
    my $user = $c->stash->{'user_object'}->update(
        {
            username      => $username,
            first_name    => $first_name,
            last_name     => $last_name,
            email_address => $email_address,
        }
    );

    # Updating the many_to_many relationship
    $user->update_or_create_related( 'user_roles', { role_id => $role_id } );

    # Redirecting to user list
    $c->response->redirect( $c->uri_for( $self->action_for('user_list') ) );
}

=head2 auto
 
Check if there is an admin user and, if not, forward to login page
 
=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    # The admin page is only reachable for admin users
    if ( $c->check_user_roles(qw(admin)) != 1 ) {
        $c->response->redirect( $c->uri_for('/permission_denied') );
        return 0;
    }
    return 1;
}

=encoding utf8

=head1 AUTHOR

Tamas Molnar

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
