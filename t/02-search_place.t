#!perl

use strict; use warnings;
use WWW::Google::Places;
use Test::More tests => 6;

my ($api_key, $sensor, $google);
$api_key = 'Your_API_Key';
$sensor  = 'true';
$google  = WWW::Google::Places->new(api_key=>$api_key, sensor=>$sensor);

eval { $google->search_place(location=>'-33.8670522,151.1957362'); };
like($@, qr/Mandatory parameter 'radius' missing in call to WWW\:\:Google\:\:Places\:\:search_place/);

eval { $google->search_place(location=>'-33.8670522,151.1957362'); };
like($@, qr/Mandatory parameter 'radius' missing in call to WWW\:\:Google\:\:Places\:\:search_place/);

eval { $google->search_place(location=>'abcde,151.1957362', radius=>500); };
like($@, qr/The 'location' parameter \("abcde,151.1957362"\) to WWW\:\:Google\:\:Places\:\:search_place did not pass/);

eval { $google->search_place(location=>'151.1957362', radius=>500); };
like($@, qr/The 'location' parameter \("151.1957362"\) to WWW\:\:Google\:\:Places\:\:search_place did not pass/);

eval { $google->search_place(location=>'151.1957362,abcde', radius=>500); };
like($@, qr/The 'location' parameter \("151.1957362,abcde"\) to WWW\:\:Google\:\:Places\:\:search_place did not pass/);

eval { $google->search_place(location=>'151.1957362,123.4567,123.45678', radius=>500); };
like($@, qr/The 'location' parameter \("151.1957362,123.4567,123.45678"\) to WWW\:\:Google\:\:Places\:\:search_place did not pass/);