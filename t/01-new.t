#!perl

use strict; use warnings;
use WWW::Google::Places;
use Test::More tests => 7;

my ($api_key, $sensor, $google);
$api_key = 'Your_API_Key';
$sensor  = 'true';

eval { $google = WWW::Google::Places->new($api_key); };
like($@, qr/Attribute \(sensor\) is required/);

eval { $google = WWW::Google::Places->new({'api_key'=>$api_key}); };
like($@, qr/Attribute \(sensor\) is required/);

eval { $google = WWW::Google::Places->new({'sensor'=>$sensor}); };
like($@, qr/Attribute \(api_key\) is required/);

eval { $google = WWW::Google::Places->new({api_key=>$api_key, language=>'en', sensor=>'falsee'}); };
like($@, qr/Attribute \(sensor\) does not pass the type constraint/);

eval { $google = WWW::Google::Places->new({api_key=>$api_key, sensor=>'false', output=>'jsoon'}); };
like($@, qr/Attribute \(output\) does not pass the type constraint/);

eval { $google = WWW::Google::Places->new({api_key=>$api_key, sensor=>'false', language=>'enn'}); };
like($@, qr/Attribute \(language\) does not pass the type constraint/);

eval { $google = WWW::Google::Places->new({api_key=>$api_key, sensor=>'false', language=>'en-AUX'}); };
like($@, qr/Attribute \(language\) does not pass the type constraint/);