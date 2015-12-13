package LightPage::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use LightPage::Form::User;

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
        template  => 'admin_page/user_list.tt',
    );
}

=head2 base -> user_create
 
Create a new user
 
=cut

sub user_create : Chained('base') : PathPart('user_create') : Args(0) {
    my ( $self, $c ) = @_;
    my $user = $c->model('DB::User')->new_result( {} );
    return $self->form( $c, $user );
}

=head2 base -> user_object

Get a user object id, stash it

=cut

sub user_object : Chained('base') : PathPart('id') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    $c->stash( user_object => $c->stash->{resultset}->find($id) );
    die "User ID $id not found!" if !$c->stash->{user_object};
}

=head2 base -> user_object -> user_edit
 
Edit an existing user
 
=cut

sub user_edit : Chained('user_object') : PathPart('user_edit') : Args(0) {
    my ( $self, $c ) = @_;
    return $self->form( $c, $c->stash->{'user_object'} );
}

=head2 base -> user_object -> user_delete

Delete a user

=cut

sub user_delete : Chained('user_object') : PathPart('user_delete') : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{user_object}->delete;
    $c->response->redirect( $c->uri_for( $self->action_for('user_list') ) );
}

=head2 form
 
Process the FormHandler user form
 
=cut

sub form {
    my ( $self, $c, $user ) = @_;

    my $form = LightPage::Form::User->new;

    # Set the template
    $c->stash( template => 'admin_page/c_user.tt', form => $form );
    $form->process( item => $user, params => $c->req->params );
    return unless $form->validated;

    # Return to books list
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
