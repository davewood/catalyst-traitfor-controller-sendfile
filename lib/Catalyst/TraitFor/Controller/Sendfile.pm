package Catalyst::TraitFor::Controller::Sendfile;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Catalyst::TraitFor::Controller::Sendfile - convenience method to send files with X-Sendfile, X-Accel-Redirect, ...

=head1 SYNOPSIS

    package MyApp::Controller::Foo;
    use Moose;
    use namespace::clean;
    BEGIN {
        extends 'Catalyst::Controller';
        with 'Catalyst::TraitFor::Controller::Sendfile';
    }

    sub some_action : Local {
        my ($self, $c) = @_;
        $c->sendfile('/path/to/file');
    }

=cut


has '_mime_types' => (
  is => 'ro',
  default => sub {
    my $mime = MIME::Types->new( only_complete => 1 );
    $mime->create_type_index;
    $mime;
  }
);

sub sendfile {
  my ($self, $c, $file) = @_;

  $c->res->header("X-Sendfile", $file);
  my ($ext) = $file =~ /\.(.+?)$/;
  if (defined $ext) {
    $c->res->content_type( $c->_mime_types->mimeTypeOf($ext) );
  }
  $c->res->status(200);
  $c->res->body("foo"); # MASSIVE HACK: bypass RenderView
  $c->detach;
}

# Massive Hack II: Electric Boogaloo                                                                                                                                                     
before finalize_headers => sub {
  my ($c) = @_;
  my $res = $c->res;

  if (defined $res->header('X-SendFile')) {
    $res->body('');
  }
};

1;

=head1 AUTHOR

David Schmidt E<lt>davewood@gmx.atE<gt>

Florian Ragwitz E<lt>rafl@debian.orgE<gt>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

