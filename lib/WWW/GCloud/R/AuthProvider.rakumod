use v6.e.PREVIEW;
unit class WWW::GCloud::R::AuthProvider;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::JwtLocation;

also is gc-record;


has Str $.id;
has Str $.issuer;
has Str $.jwksUri;
has Str $.audiences;
has Str $.authorizationUrl;
has WWW::GCloud::R::JwtLocation:D @.jwtLocations;