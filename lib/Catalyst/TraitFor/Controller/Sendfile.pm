package Catalyst::TraitFor::Controller::Sendfile;

use Moose::Role;
use MooseX::Types::Path::Class qw/ File /;
use MooseX::Types::Moose qw/ Str /;
use MIME::Types;
use Method::Signatures::Simple;
use namespace::autoclean;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

=head1 NAME

Catalyst::TraitFor::Controller::Sendfile - convenience method to send files with X-Sendfile, X-Accel-Redirect, ...

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
        $self->sendfile($c, file(qw/ path to file/));
    }

=head1 DESCRIPTION

If you want to deliver files using headers like 'X-Sendfile'
or 'X-Accel-Redirect' you can apply this trait and use its convenience method sendfile.

=cut

=head1 ATTRIBUTES

=head2 sendfile_header

name of the Sendfile header. Defaults to X-Sendfile (apache mod_sendfile and lighttpd),
or should be changed to 'X-Accel-Redirect' for nginx

=head2 sendfile

You call sendfile with $c and a Path::Class::File object. The file path can't be seen
by the client. Your webserver should check if the 'X-Sendfile' header is set and if so deliver the file.

=cut

has sendfile_header => (
    is       => 'ro',
    isa      => Str,
    default  => 'X-Sendfile',
);

has '_mime_types' => (
    is => 'ro',
    default => sub {
        my $mime = MIME::Types->new( only_complete => 1 );
        $mime->create_type_index;
        $mime;
    }
);

method set_content_type_for_file ($c, $file) {
    my ($ext) = $file->basename =~ /\.(.+?)$/;
    if (defined $ext) {
        $c->res->content_type($self->_mime_types->mimeTypeOf($ext));
    }
}

method sendfile ($c, $file) {

    die("No file supplied to sendfile with") unless($file);
    my $file_ob = to_File($file);
    die("Not supplied with a Path::Class::File or something that can be coerced to be one ($file)") unless $file = $file_ob;

    $self->set_content_type_for_file($c, $file);

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

=head1 AUTHORS

David Schmidt (davewood) C<< <davewood@gmx.at> >>

Florian Ragwitz C<< <rafl@debian.org> >>

Tomas Doran (t0m) C<< <bobtfish@bobtfish.net> >>

=head1 COPYRIGHT

Copyright (c) 2010, the above named authors.

=head1 LICENSE

This library is free software. You can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

