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

=head2 user_list

=cut

sub user_list : Local : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash( user_list => [ $c->model('DB::User')->all ] );
    $c->stash( template  => 'admin_page/user_list.tt' );
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
