package WWW::Google::Places;

use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;

use JSON;
use Readonly;
use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::Google::Places - Interface to Google Places API.

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';
Readonly my $BASE_URL => 'https://maps.googleapis.com/maps/api/place';
Readonly my $LANGUAGE =>
{
    'ar'    => 1,
    'eu'    => 1,
    'bg'    => 1,
    'bn'    => 1,
    'ca'    => 1,
    'cs'    => 1,
    'da'    => 1,
    'de'    => 1,
    'el'    => 1,
    'en'    => 1,
    'en-au' => 1,
    'en-gb' => 1,
    'es'    => 1,
    'eu'    => 1,
    'fa'    => 1,
    'fi'    => 1,
    'fi'    => 1,
    'fr'    => 1,
    'gl'    => 1,
    'gu'    => 1,
    'hi'    => 1,
    'hr'    => 1,
    'hu'    => 1,
    'id'    => 1,
    'it'    => 1,
    'iw'    => 1,
    'ja'    => 1,
    'kn'    => 1,
    'ko'    => 1,
    'lt'    => 1,
    'lv'    => 1,
    'ml'    => 1,
    'mr'    => 1,
    'nl'    => 1,
    'no'    => 1,
    'pl'    => 1,
    'pt'    => 1,
    'pt-br' => 1,
    'pt-pt' => 1,
    'ro'    => 1,
    'ru'    => 1,
    'sk'    => 1,
    'sl'    => 1,
    'sr'    => 1,
    'sv'    => 1,
    'tl'    => 1,
    'ta'    => 1,
    'te'    => 1,
    'th'    => 1,
    'tr'    => 1,
    'uk'    => 1,
    'vi'    => 1,
    'zh-cn' => 1,
    'zh-tw' => 1,
};
Readonly my $PLACE_TYPE =>
{
    'accounting'              => 1,
    'airport'                 => 1,
    'amusement_park'          => 1,
    'aquarium'                => 1,
    'art_gallery'             => 1,
    'atm'                     => 1,
    'bakery'                  => 1,
    'bank'                    => 1,
    'bar'                     => 1,
    'beauty_salon'            => 1,
    'bicycle_store'           => 1,
    'book_store'              => 1,
    'bowling_alley'           => 1,
    'bus_station'             => 1,
    'cafe'                    => 1,
    'campground'              => 1,
    'car_dealer'              => 1,
    'car_rental'              => 1,
    'car_repair'              => 1,
    'car_wash'                => 1,
    'casino'                  => 1,
    'cemetery'                => 1,
    'church'                  => 1,
    'city_hall'               => 1,
    'clothing_store'          => 1,
    'convenience_store'       => 1,
    'courthouse'              => 1,
    'dentist'                 => 1,
    'department_store'        => 1,
    'doctor'                  => 1,
    'electrician'             => 1,
    'electronics_store'       => 1,
    'embassy'                 => 1,
    'establishment'           => 1,
    'finance'                 => 1,
    'fire_station'            => 1,
    'florist'                 => 1,
    'food'                    => 1,
    'funeral_home'            => 1,
    'furniture_store'         => 1,
    'gas_station'             => 1,
    'general_contractor'      => 1,
    'geocode'                 => 1,
    'grocery_or_supermarket'  => 1,
    'gym'                     => 1,
    'hair_care'               => 1,
    'hardware_store'          => 1,
    'health'                  => 1,
    'hindu_temple'            => 1,
    'home_goods_store'        => 1,
    'hospital'                => 1,
    'insurance_agency'        => 1,
    'jewelry_store'           => 1,
    'laundry'                 => 1,
    'lawyer'                  => 1,
    'library'                 => 1,
    'liquor_store'            => 1,
    'local_government_office' => 1,
    'locksmith'               => 1,
    'lodging'                 => 1,
    'meal_delivery'           => 1,
    'meal_takeaway'           => 1,
    'mosque'                  => 1,
    'movie_rental'            => 1,
    'movie_theater'           => 1,
    'moving_company'          => 1,
    'museum'                  => 1,
    'night_club'              => 1,
    'painter'                 => 1,
    'park'                    => 1,
    'parking'                 => 1,
    'pet_store'               => 1,
    'pharmacy'                => 1,
    'physiotherapist'         => 1,
    'place_of_worship'        => 1,
    'plumber'                 => 1,
    'police'                  => 1,
    'post_office'             => 1,
    'real_estate_agency'      => 1,
    'restaurant'              => 1,
    'roofing_contractor'      => 1,
    'rv_park'                 => 1,
    'school'                  => 1,
    'shoe_store'              => 1,
    'shopping_mall'           => 1,
    'spa'                     => 1,
    'stadium'                 => 1,
    'storage'                 => 1,
    'store'                   => 1,
    'subway_station'          => 1,
    'synagogue'               => 1,
    'taxi_stand'              => 1,
    'train_station'           => 1,
    'travel_agency'           => 1,
    'university'              => 1,
    'veterinary_care'         => 1,
    'zoo'                     => 1,
};
Readonly my $MORE_PLACE_TYPE =>
{
    'administrative_area_level_1' => 1,
    'administrative_area_level_2' => 1,
    'administrative_area_level_3' => 1,
    'colloquial_area'             => 1,
    'country'                     => 1,
    'floor'                       => 1,
    'intersection'                => 1,
    'locality'                    => 1,
    'natural_feature'             => 1,
    'neighborhood'                => 1,
    'political'                   => 1,
    'point_of_interest'           => 1,
    'post_box'                    => 1,
    'postal_code'                 => 1,
    'postal_code_prefix'          => 1,
    'postal_town'                 => 1,
    'premise'                     => 1,
    'room'                        => 1,
    'route'                       => 1,
    'street_address'              => 1,
    'street_number'               => 1,
    'sublocality'                 => 1,
    'sublocality_level_4'         => 1,
    'sublocality_level_5'         => 1,
    'sublocality_level_3'         => 1,
    'sublocality_level_2'         => 1,
    'sublocality_level_1'         => 1,
    'subpremise'                  => 1,
    'transit_station'             => 1,
};
Readonly my $STATUS =>
{
    'OK'               => 'No errors occurred; the place was successfully detected and at least one result was returned.',
    'ZERO_RESULTS'     => 'Search was successful but returned no results.',
    'OVER_QUERY_LIMIT' => 'You are over your quota.',
    'REQUEST_DENIED'   => 'Your request was denied, generally because of lack of a sensor parameter.',
    'INVALID_REQUEST'  => 'A required query parameter (location or radius) is missing.',
    'UNKNOWN_ERROR'    => 'A server-side error; trying again may be successful.',
};

=head1 DESCRIPTION

The Google Places API is a service that returns information about Places,  defined within this
API as establishments, geographic location or prominent points of interest using HTTP request.
Place requests specify locations as latitude/longitude coordinates. Users with an API key  are
allowed 1,000 requests per 24 hour period. Currently it supports version v3.

=head1 PLACE TYPES

Supported types for Place Searches and Place adds.

    +-------------------------+
    | accounting              |
    | airport                 |
    | amusement_park          |
    | aquarium                |
    | art_gallery             |
    | atm                     |
    | bakery                  |
    | bank                    |
    | bar                     |
    | beauty_salon            |
    | bicycle_store           |
    | book_store              |
    | bowling_alley           |
    | bus_station             |
    | cafe                    |
    | campground              |
    | car_dealer              |
    | car_rental              |
    | car_repair              |
    | car_wash                |
    | casino                  |
    | cemetery                |
    | church                  |
    | city_hall               |
    | clothing_store          |
    | convenience_store       |
    | courthouse              |
    | dentist                 |
    | department_store        |
    | doctor                  |
    | electrician             |
    | electronics_store       |
    | embassy                 |
    | establishment           |
    | finance                 |
    | fire_station            |
    | florist                 |
    | food                    |
    | funeral_home            |
    | furniture_store         |
    | gas_station             |
    | general_contractor      |
    | geocode                 |
    | grocery_or_supermarket  |
    | gym                     |
    | hair_care               |
    | hardware_store          |
    | health                  |
    | hindu_temple            |
    | home_goods_store        |
    | hospital                |
    | insurance_agency        |
    | jewelry_store           |
    | laundry                 |
    | lawyer                  |
    | library                 |
    | liquor_store            |
    | local_government_office |
    | locksmith               |
    | lodging                 |
    | meal_delivery           |
    | meal_takeaway           |
    | mosque                  |
    | movie_rental            |
    | movie_theater           |
    | moving_company          |
    | museum                  |
    | night_club              |
    | painter                 |
    | park                    |
    | parking                 |
    | pet_store               |
    | pharmacy                |
    | physiotherapist         |
    | place_of_worship        |
    | plumber                 |
    | police                  |
    | post_office             |
    | real_estate_agency      |
    | restaurant              |
    | roofing_contractor      |
    | rv_park                 |
    | school                  |
    | shoe_store              |
    | shopping_mall           |
    | spa                     |
    | stadium                 |
    | storage                 |
    | store                   |
    | subway_station          |
    | synagogue               |
    | taxi_stand              |
    | train_station           |
    | travel_agency           |
    | university              |
    | veterinary_care         |
    | zoo                     |
    +-------------------------+

Additional types listed below can be used in Place Searches, but not when adding a Place.

    +-----------------------------+
    | administrative_area_level_1 |
    | administrative_area_level_2 |
    | administrative_area_level_3 |
    | colloquial_area             |
    | country                     |
    | floor                       |
    | intersection                |
    | locality                    |
    | natural_feature             |
    | neighborhood                |
    | political                   |
    | point_of_interest           |
    | post_box                    |
    | postal_code                 |
    | postal_code_prefix          |
    | postal_town                 |
    | premise                     |
    | room                        |
    | route                       |
    | street_address              |
    | street_number               |
    | sublocality                 |
    | sublocality_level_4         |
    | sublocality_level_5         |
    | sublocality_level_3         |
    | sublocality_level_2         |
    | sublocality_level_1         |
    | subpremise                  |
    | transit_station             |
    +-----------------------------+

=head1 LANGUAGES

    +-------+-------------------------+
    | Code  | Name                    |
    +-------+-------------------------+
    | ar    | ARABIC                  |
    | eu    | BASQUE                  |
    | bg    | BULGARIAN               |
    | bn    | BENGALI                 |
    | ca    | CATALAN                 |
    | cs    | CZECH                   |
    | da    | DANISH                  |
    | de    | GERMAN                  |
    | el    | GREEK                   |
    | en    | ENGLISH                 |
    | en-AU | ENGLISH (AUSTRALIAN)    |
    | en-GB | ENGLISH (GREAT BRITAIN) |
    | es    | SPANISH                 |
    | eu    | BASQUE                  |
    | fa    | FARSI                   |
    | fi    | FINNISH                 |
    | fil   | FILIPINO                |
    | fr    | FRENCH                  |
    | gl    | GALICIAN                |
    | gu    | GUJARATI                |
    | hi    | HINDI                   |
    | hr    | CROATIAN                |
    | hu    | HUNGARIAN               |
    | id    | INDONESIAN              |
    | it    | ITALIAN                 |
    | iw    | HEBREW                  |
    | ja    | JAPANESE                |
    | kn    | KANNADA                 |
    | ko    | KOREAN                  |
    | lt    | LITHUANIAN              |
    | lv    | LATVIAN                 |
    | ml    | MALAYALAM               |
    | mr    | MARATHI                 |
    | nl    | DUTCH                   |
    | no    | NORWEGIAN               |
    | pl    | POLISH                  |
    | pt    | PORTUGUESE              |
    | pt-BR | PORTUGUESE (BRAZIL)     |
    | pt-PT | PORTUGUESE (PORTUGAL)   |
    | ro    | ROMANIAN                |
    | ru    | RUSSIAN                 |
    | sk    | SLOVAK                  |
    | sl    | SLOVENIAN               |
    | sr    | SERBIAN                 |
    | sv    | SWEDISH                 |
    | tl    | TAGALOG                 |
    | ta    | TAMIL                   |
    | te    | TELUGU                  |
    | th    | THAI                    |
    | tr    | TURKISH                 |
    | uk    | UKRAINIAN               |
    | vi    | VIETNAMESE              |
    | zh-CN | CHINESE (SIMPLIFIED)    |
    | zh-TW | CHINESE (TRADITIONAL)   |
    +-------+-------------------------+

=cut

type 'Location'     => where { my ($lat, $lng);
                               ($_ =~ /\,/)
                               &&
                               ((($lat, $lng) = split/\,/,$_,2)
                                &&
                                (($lat =~ /^\-?\d+\.?\d+$/)
                                 &&
                                 ($lng =~ /^\-?\d+\.?\d+$/)))
                             };
type 'SearchPlace'  => where { my @types;
                               defined($_)
                               &&
                               (@types = split/\|/,$_)
                               &&
                               (map { exists($PLACE_TYPE->{lc($_)})
                                      ||
                                      exists($MORE_PLACE_TYPE->{lc($_)})
                                    } @types )
                             };
type 'AddPlace'     => where { my @types;
                               defined($_)
                               &&
                               (@types = split/\|/,$_)
                               &&
                               (map { exists($PLACE_TYPE->{lc($_)}) } @types )
                             };
type 'Place'        => where { my @types;
                               defined($_)
                               &&
                               (@types = split/\|/,$_)
                               &&
                               (map { exists($PLACE_TYPE->{lc($_)}) } @types )
                             };
type 'OutputFormat' => where { $_ =~ m(^\bjson\b|\bxml\b$)i };
type 'Language'     => where { exists($LANGUAGE->{lc($_)}) };
type 'TrueFalse'    => where { defined($_) && ($_ =~ m(^\btrue\b|\bfalse\b$)i) };
has  'api_key'      => (is => 'ro', isa => 'Str',       required => 1);
has  'sensor'       => (is => 'ro', isa => 'TrueFalse', required => 1);
has  'browser'      => (is => 'rw', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(); });
has  'output'       => (is => 'ro', isa => 'OutputFormat',   default => 'json');
has  'language'     => (is => 'ro', isa => 'Language',       default => 'en');

around BUILDARGS => sub
{
    my $orig  = shift;
    my $class = shift;

    if (@_ == 1 && ! ref $_[0])
    {
        return $class->$orig(api_key => $_[0]);
    }
    elsif (@_ == 2 && ! ref $_[0])
    {
        return $class->$orig(api_key => $_[0], sensor => $_[1]);
    }
    else
    {
        return $class->$orig(@_);
    }
};

=head1 CONSTRUCTOR

The constructor expects your application API Key and sensor at the least which you can  get it
for FREE from Google.

    +-----------+--------------------------------------------------------------------------------------+
    | Parameter | Meaning                                                                              |
    +-----------+--------------------------------------------------------------------------------------+
    | api_key   | Your application API key. You should supply a valid API key with all requests. Get a |
    |           | key from the Google APIs console. This must be provided.                             |
    | sensor    | Indicates whether or not the Place request came from a device using a location sensor|
    |           | (e.g. a GPS) to determine the location sent in this request. This value must be      |
    |           | either true or false. This must be provided.                                         |
    | language  | The language code, indicating in which language the results should be returned. The  |
    |           | default is en.                                                                       |
    | output    | Output format JSON or XML. Default is JSON.                                          |
    +-----------+--------------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $google);
    $api_key = 'Your_API_Key';
    $sensor  = 'true';

    $google  = WWW::Google::Places->new($api_key, $sensor);
    # or
    $google  = WWW::Google::Places->new({'api_key'=>$api_key, sensor=>$sensor});
    # or
    $google  = WWW::Google::Places->new({'api_key'=>$api_key, sensor=>$sensor, language=>'en', output=>'json'});

=head1 METHODS

=head2 search_place()

Searches place.

    +----------+--------------------------------------------------------------------------------+
    | Key      | Description                                                                    |
    +----------+--------------------------------------------------------------------------------+
    | location | The latitude/longitude around which to retrieve Place information. This must be|
    |          | provided as a google.maps.LatLng object. This must be provided.                |
    | radius   | The distance (in meters) within which to return Place results. The recommended |
    |          | best practice is to set radius based on the accuracy of the location signal as |
    |          | given by the location sensor. Note that setting a radius biases results to the |
    |          | indicated area, but may not fully restrict results to the specified area. This |
    |          | must be provided.                                                              |
    | types    | Restricts the results to Places matching at least one of the specified types.  |
    |          | Types should be separated with a pipe symbol.                                  |
    | name     | A term to be matched against the names of Places.                              |
    +----------+--------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $google, $places);
    $api_key = 'Your_API_Key';
    $sensor  = 'true';
    $google  = WWW::Google::Places->new($api_key, $sensor);
    $places  = $google->search_place(location=>'-33.8670522,151.1957362', radius=>500);

=cut

sub search_place
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'location' => { isa => 'Location',  required => 1 },
                'radius'   => { isa => 'Num',       required => 1 },
                'types'    => { isa => 'SearchPlace', default => undef},
                'name'     => { isa => 'Str',         default => undef},
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my ($browser, $url, $request, $response, $content);
    $browser = $self->browser;
    $url     = sprintf("%s/search/%s?key=%s", $BASE_URL, $self->output, $self->api_key);
    $url .= sprintf("&location=%s", $param{'location'});
    $url .= sprintf("&radius=%d",   $param{'radius'});
    $url .= sprintf("&sensor=%s",   $self->sensor);
    $url .= sprintf("&language=%s", $self->language);
    $url .= sprintf("&types=%s",    $param{'types'}) if defined($param{'types'});
    $url .= sprintf("&name=%s",     $param{'name'})  if defined($param{'name'});
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 place_detail()

A Place Details request returns more comprehensive information about the indicated place  such
as its complete address, phone number, user rating, etc.

    +-----------+--------------------------------------------------------------------------------+
    | Key       | Description                                                                    |
    +-----------+--------------------------------------------------------------------------------+
    | reference | A textual identifier that uniquely identifies a place, returned from a Place   |
    |           | search request. This must be provided.                                         |
    +-----------+--------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $reference, $google, $detail);
    $api_key   = 'Your_API_Key';
    $sensor    = 'true';
    $reference = 'Place_reference';
    $google    = WWW::Google::Places->new($api_key, $sensor);
    $detail    = $google->place_detail($reference);

=cut

sub place_detail
{
    my $self  = shift;
    my ($reference) = pos_validated_list(\@_,
                      { isa => 'Str', required => 1 },
                      MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my ($browser, $url, $request, $response, $content);
    $browser = $self->browser;
    $url     = sprintf("%s/details/%s?key=%s", $BASE_URL, $self->output, $self->api_key);
    $url .= sprintf("&reference=%s", $reference);
    $url .= sprintf("&sensor=%s",    $self->sensor);
    $url .= sprintf("&language=%s",  $self->language);
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 place_checkins()

It indicates that a user has checked in to that Place. Check-in activity from your application
is reflected in the Place search results that are returned - popular establishments are ranked
more highly making it easy for your users to find likely matches. As check-in activity changes
over time, so does the ranking of each Place.

    +-----------+--------------------------------------------------------------------------------+
    | Key       | Description                                                                    |
    +-----------+--------------------------------------------------------------------------------+
    | reference | A textual identifier that uniquely identifies a place, returned from a Place   |
    |           | search request. This must be provided.                                         |
    +-----------+--------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $reference, $google, $checkins);
    $api_key   = 'Your_API_Key';
    $sensor    = 'true';
    $reference = 'Place_reference';
    $google    = WWW::Google::Places->new($api_key, $sensor);
    $checkins  = $google->place_checkins($reference);

=cut

sub place_checkins
{
    my $self = shift;
    my ($reference) = pos_validated_list(\@_,
                      { isa => 'Str', required => 1 },
                      MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my ($browser, $url, $request, $response, $content);
    $browser  = $self->browser;
    $url      = sprintf("%s/check-in/%s?key=%s", $BASE_URL, $self->output, $self->api_key);
    $url .= sprintf("&reference=%s", $reference);
    $url .= sprintf("&sensor=%s",    $self->sensor);
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return from_json($content);
}

=head2 add_place()

Add a place to be available for any future search place request.

    +----------+--------------------------------------------------------------------------------+
    | Key      | Description                                                                    |
    +----------+--------------------------------------------------------------------------------+
    | location | The latitude/longitude around which to retrieve Place information. This must   |
    |          | be provided as a google.maps.LatLng object.                                    |
    | accuracy | The accuracy of the location signal on which this request is based, expressed  |
    |          | in meters. This must be provided.                                              |
    | name     | The full text name of the Place.                                               |
    | types    | Restricts the results to Places matching at least one of the specified types.  |
    |          | Types should be separated with a pipe symbol.                                  |
    +----------+--------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $google, $status);
    $api_key = 'Your_API_Key';
    $sensor  = 'true';
    $google  = WWW::Google::Places->new($api_key, $sensor);
    $stetus  = $google->add_place('location'=>'-33.8669710,151.1958750', accuracy=>40, name=>'Google Shoes!');

=cut

sub add_place
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'location' => { isa => 'Location', required => 1 },
                'accuracy' => { isa => 'Num',      required => 1 },
                'name'     => { isa => 'Str',      required => 1 },
                'types'    => { isa => 'AddPlace', default  => undef},
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my ($data, $lat, $lng);
    my ($browser, $url, $request, $response, $content);
    $browser = $self->browser;
    $url     = sprintf("%s/add/%s?key=%s&sensor=%s", $BASE_URL, $self->output, $self->api_key, $self->sensor);
    ($lat, $lng) = split /\,/,$param{'location'};

    $request  = HTTP::Request->new(POST => $url);
    $request->header('Host' => 'maps.googleapis.com');
    if ($self->output =~ /xml/i)
    {
        $data = '<?xml version="1.0" encoding="UTF-8"?>';
        $data.= '<PlaceAddRequest>';
        $data.= '<location><lat>' . $lat . '</lat><lng>' . $lng . '</lng></location>';
        $data.= '<accuracy>' . $param{'accuracy'} . '</accuracy>';
        $data.= '<name>'     . $param{'name'}     . '</name>';
        $data.= '<type>'     . $param{'types'}    . '</type>' if defined($param{'types'});
        $data.= '<language>' . $self->language    . '</language>';
        $data.= '</PlaceAddRequest>';
        $request->content($data);
    }
    else
    {
        # We handle number this way as JSON expects  number to be treated  as number and 
        # not number within single/double quotes. Spent one whole day to figure this out.
        $data = {'location' => {'lat' => _handle_number($lat), 'lng' => _handle_number($lng)},
                 'accuracy' => _handle_number($param{'accuracy'}),
                 'name'     => $param{'name'},
                 'language' => $self->language};
        $data->{'types'} = [$param{'types'}] if defined($param{'types'});
        $request->content(to_json($data));
    }

    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    
    return $content if ($self->output =~ /xml/i);
    return from_json($content);
}

=head2 delete_place()

Delete a place as given reference. Place can only be deleted by the same application  that has
added it in the first place.  Once  moderated  and added into the full Place Search results, a
Place  can  no longer  be deleted. Places that are not accepted by the moderation process will
continue to be visible to the application that submitted them.

    +-----------+--------------------------------------------------------------------------------+
    | Key       | Description                                                                    |
    +-----------+--------------------------------------------------------------------------------+
    | reference | A textual identifier that uniquely identifies a place, returned from a Place   |
    |           | search request. This must be provided.                                         |
    +-----------+--------------------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::Google::Places;

    my ($api_key, $sensor, $reference, $google, $status);
    $api_key   = 'Your_API_Key';
    $sensor    = 'true';
    $reference = 'Place_reference';
    $google    = WWW::Google::Places->new($api_key, $sensor);
    $status    = $google->delete_place($reference);

=cut

sub delete_place
{
    my $self = shift;
    my ($reference) = pos_validated_list(\@_,
                      { isa => 'Str', required => 1 },
                      MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my ($browser, $url, $request, $response, $content, $data);
    $browser  = $self->browser;
    $url      = sprintf("%s/delete/%s?key=%s&sensor=%s", $BASE_URL, $self->output, $self->api_key, $self->sensor);
    $request  = HTTP::Request->new(POST => $url);
    $request->header('Host' => 'maps.googleapis.com');

    if ($self->output =~ /xml/i)
    {
        $data = '<?xml version="1.0" encoding="UTF-8"?>';
        $data.= '<PlaceDeleteRequest>';
        $data.= '<reference>' . $reference . '</reference>';
        $data.= '</PlaceDeleteRequest>';
        $request->content($data);
    }
    else
    {
        $request->content(to_json({'reference' => $reference}));
    }
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    
    return $content if ($self->output =~ /xml/i);
    return from_json($content);
}

sub _handle_number
{
    my $number = shift;
    return ($number =~ m/^\-?[\d]+(\.[\d]+)?$/)?($number*1):$number;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs/feature requests to C<bug-www-google-places at rt.cpan.org>, or through
the  web  interface  at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Google-Places>. I
will be notified and then you will automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::Google::Places

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Google-Places>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-Google-Places>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-Google-Places>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-Google-Places/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Moose; # Keywords are removed from the WWW::Google::Moderator package

1; # End of WWW::Google::Places