use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;

use FindBin;
use lib "$FindBin::Bin/lib";

use Catalyst::Test 'TestApp';

{
    my $response = request(GET '/');
    ok( $response, 'Request' );
    ok( $response->is_success, 'Response Successful 2xx' );
    is( $response->header( 'X-Sendfile' ), '/path/to/file', 'Sendfile Header' );
}

done_testing;

