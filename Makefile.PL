use strict;
use warnings;
use inc::Module::Install 0.99;

name 'Catalyst-TraitFor-Controller-Sendfile';
all_from 'lib/Catalyst/TraitFor/Controller/Sendfile.pm';

requires 'Catalyst::Runtime' => '5.80';
requires 'Moose';
requires 'MooseX::Types::Path::Class';
requires 'namespace::autoclean';

test_requires 'Test::More' => '0.88';
test_requires 'HTTP::Request::Common';

system("pod2text lib/Catalyst/TraitFor/Controller/Sendfile.pm > README")
    if $Module::Install::AUTHOR;

WriteAll;
