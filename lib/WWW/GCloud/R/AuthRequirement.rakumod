use v6.e.PREVIEW;
unit class WWW::GCloud::R::AuthRequirement;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.providerId is mooish(:alias<provider-id>);
has Str $.audiences;

