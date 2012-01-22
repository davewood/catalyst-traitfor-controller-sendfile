use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;
use FindBin;
use lib "$FindBin::Bin/lib";
use Path::Class;
use Catalyst::Test 'TestApp';

BEGIN { use_ok('TestApp'); }

my $testapp = new_ok ( 'TestApp' );

{
    my $controller = $testapp->controller('Root');
    can_ok ( $controller, 'sendfile' );
}

{
    local $ENV{CATALYST_ENGINE} = 'FastCGI';
    my $response = request(GET '/');
    ok( $response, 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->header( 'X-Sendfile' ), Path::Class::File->new("$FindBin::Bin/lib/image.png"), 'Sendfile Header' );
    is( $response->header( 'Content-Type' ), 'image/png', 'Content Type' );
    is ( $response->content, '', 'No response content' );
}

{
    local $ENV{CATALYST_ENGINE} = 'HTTP';
    my $response = request(GET '/');
    ok( $response, 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->header( 'Content-Length' ), 81, 'Content Length' );
    is( $response->header( 'Content-Type' ), 'image/png', 'Content Type' );
    ok length($response->content), 'Response has content';
}

done_testing;
