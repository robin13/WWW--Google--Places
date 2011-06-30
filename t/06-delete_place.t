#!perl

use strict; use warnings;
use WWW::Google::Places;
use Test::More tests => 1;

my ($api_key, $sensor, $google);
$api_key = 'Your_API_Key';
$sensor  = 'true';
$google  = WWW::Google::Places->new(api_key=>$api_key, sensor=>$sensor);

eval { $google->delete_place(); };
like($@, qr/0 parameters were passed to WWW\:\:Google\:\:Places\:\:delete_place but 1 was expected/);