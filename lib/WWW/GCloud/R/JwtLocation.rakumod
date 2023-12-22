use v6.e.PREVIEW;
unit class WWW::GCloud::R::JwtLocation;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.valuePrefix;
has Str $.header;
has Str $.query;