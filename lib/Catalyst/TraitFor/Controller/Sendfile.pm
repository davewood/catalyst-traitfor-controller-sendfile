package Catalyst::TraitFor::Controller::Sendfile;

use Moose::Role;
use MooseX::Types::Path::Class qw/ File /;
use MooseX::Types::Moose qw/ Str /;
use MIME::Types;
use Method::Signatures::Simple;
use namespace::autoclean;

# ABSTRACT: convenience method to send files with X-Sendfile, X-Accel-Redirect, ...

=head1 SYNOPSIS

    package MyApp::Controller::Foo;
    use Moose;
    use Path::Class qw/ file /;
    use namespace::autoclean;

    BEGIN { extends 'Catalyst::Controller' }
    with 'Catalyst::TraitFor::Controller::Sendfile';

    __PACKAGE__->config(sendfile_header => 'X-Sendfile');

    sub some_action : Local {
        my ($self, $c) = @_;
        $self->sendfile($c, file(qw/ path to file/), 'image/jpeg');
    }

=head1 DESCRIPTION

If you want to deliver files using headers like 'X-Sendfile'
or 'X-Accel-Redirect' you can apply this trait and use its convenience method sendfile.

=head1 ATTRIBUTES

=head2 sendfile_header

name of the Sendfile header. Defaults to X-Sendfile (apache mod_sendfile and lighttpd),
or should be changed to 'X-Accel-Redirect' for nginx

=cut

has sendfile_header => (
    is       => 'ro',
    isa      => Str,
    default  => 'X-Sendfile',
);

=head2 _mime_types

data structure used to look up the mime type for file extensions

=cut

has '_mime_types' => (
    is => 'ro',
    default => sub {
        my $mime = MIME::Types->new( only_complete => 1 );
        $mime->create_type_index;
        $mime;
    }
);

=head1 METHODS

=head2 set_content_type_for_file

=cut

method set_content_type_for_file ($c, $file, $content_type) {
    if (!$content_type) {
        my ($ext) = $file->basename =~ /\.(.+?)$/;

        die "Could not find file extension. (" . $file->basename . ")"
            unless defined $ext;

        $content_type = $self->_mime_types->mimeTypeOf($ext);

        die "No content-type found for '$ext'"
            unless defined $content_type;
    }

    die "No content-type found. (" . $file->basename . ")"
        unless defined $content_type;

    $c->res->content_type($content_type);
}

=head2 sendfile

You call sendfile with $c, Path::Class::File object and an optional content_type.
The file path can't be seen by the client.
Your webserver should check if the 'X-Sendfile' header is set and if so deliver the file.
If you do not define a content_type it will be guessed by the file extension.

=cut

method sendfile ($c, $file, $content_type) {
    die "No file supplied to sendfile with" unless $file;
    my $file_ob = to_File($file);
    die "Not supplied with a Path::Class::File or something that can be coerced to be one ($file)"
        unless $file = $file_ob;

    $content_type = $self->set_content_type_for_file($c, $file, $content_type);

    my $engine = $ENV{CATALYST_ENGINE} || 'HTTP';

    # Catalyst development server
    if ( $engine =~ /^HTTP/ ) {
        if ( $file->stat && -f _ && -r _ ) {
            $c->res->body( $file->openr );
            $c->res->content_length( $file->stat->size );
        }
    }

    # Deployment with FastCGI
    elsif ( $engine eq 'FastCGI' ) {
        $c->res->header($self->sendfile_header, $file);
        $c->res->body( '' );
    }

    # unknown engine
    else {
        die "Unknown engine: " . $engine;
    }

    $c->res->status(200);
    $c->detach;
}

1;
