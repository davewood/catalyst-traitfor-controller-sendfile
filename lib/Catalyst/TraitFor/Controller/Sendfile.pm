package Catalyst::TraitFor::Controller::Sendfile;

use Moose::Role;
use namespace::autoclean;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

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
    __PACKAGE__->config(sendfile_header => 'X-Sendfile');

    sub some_action : Local {
        my ($self, $c) = @_;
        $c->sendfile($c, '/path/to/file');
    }

=head1 DESCRIPTION

If you want to deliver files using headers like 'X-Sendfile' or 'X-Accel-Redirect' you can apply this trait and use its convenience method sendfile.

=cut

=head2 sendfile_header

name of the Sendfile header. Probably 'X-Sendfile' or 'X-Accel-Redirect'. Default is 'X-Sendfile'

=cut

has sendfile_header => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'X-Sendfile',
);

use MIME::Types;
has '_mime_types' => (
  is => 'ro',
  default => sub {
    my $mime = MIME::Types->new( only_complete => 1 );
    $mime->create_type_index;
    $mime;
  }
);

use File::stat;
sub sendfile {
  my ($self, $c, $file) = @_;

  $c->res->header($self->sendfile_header, $file);
  my ($ext) = $file =~ /\.(.+?)$/;
  if (defined $ext) {
    $c->res->content_type( $self->_mime_types->mimeTypeOf($ext) );

    my $abs_file = $c->path_to('root', $file);
    warn $abs_file;
    my $file_stats = stat($abs_file);
    $c->res->content_length( $file_stats->size ) if $file_stats;
  }
  $c->res->status(200);
  #$c->res->body("foo"); # MASSIVE HACK: bypass RenderView
  $c->detach;
}

# Massive Hack II: Electric Boogaloo
#before finalize_headers => sub {
#  my ($c) = @_;
#  my $res = $c->res;
#
#  if (defined $res->header('X-SendFile')) {
#    $res->body('');
#  }
#};

1;

=head1 AUTHORS

David Schmidt (davewood) C<< <davewood@gmx.at> >>

Florian Ragwitz C<< <rafl@debian.org> >>

=head1 COPYRIGHT

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

