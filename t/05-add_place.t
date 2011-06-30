#!perl

use strict; use warnings;
use WWW::Google::Places;
use Test::More tests => 4;

my ($api_key, $sensor, $google);
$api_key = 'Your_API_Key';
$sensor  = 'true';
$google  = WWW::Google::Places->new(api_key=>$api_key, sensor=>$sensor);

eval { $google->add_place(); };
like($@, qr/Mandatory parameters 'location', 'name', 'accuracy' missing in call to WWW\:\:Google\:\:Places\:\:add_place/);

eval { $google->add_place('location'=>'-33.8669710,151.1958750'); };
like($@, qr/Mandatory parameters 'name', 'accuracy' missing in call to WWW\:\:Google\:\:Places\:\:add_place/);

eval { $google->add_place('accuracy'=>50); };
like($@, qr/Mandatory parameters 'location', 'name' missing in call to WWW\:\:Google\:\:Places\:\:add_place/);

eval { $google->add_place('name'=>'Google Shoes!'); };
like($@, qr/Mandatory parameters 'location', 'accuracy' missing in call to WWW\:\:Google\:\:Places\:\:add_place/);