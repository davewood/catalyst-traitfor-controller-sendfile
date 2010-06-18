package TestApp::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN {
    extends 'Catalyst::Controller';
    with 'Catalyst::TraitFor::Controller::Sendfile';
}

__PACKAGE__->config(namespace => '');

sub default : Path {
    my ($self, $c) = @_;
    $self->sendfile($c, '/static/image.png');
}

__PACKAGE__->meta->make_immutable;

1;
