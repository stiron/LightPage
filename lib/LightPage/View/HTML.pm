package LightPage::View::HTML;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die         => 1,
    ENCODING           => 'utf-8',
    WRAPPER            => 'html_wrapper.tt',
);

=head1 NAME

LightPage::View::HTML - TT View for LightPage

=head1 DESCRIPTION

TT View for LightPage.

=head1 SEE ALSO

L<LightPage>

=head1 AUTHOR

Tamas Molnar

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
