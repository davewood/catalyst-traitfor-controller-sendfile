package TestApp::Controller::Root;
use Moose;
use namespace::autoclean;
    BEGIN {
        extends 'Catalyst::Controller';
        with 'Catalyst::TraitFor::Controller::Sendfile';
    }

    sub some_action : Local {
        my ($self, $c) = @_;
        $c->sendfile('/path/to/file');
    }

__PACKAGE__->meta->make_immutable;
