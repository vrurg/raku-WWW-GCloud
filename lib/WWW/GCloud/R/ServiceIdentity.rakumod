use v6.e.PREVIEW;
unit class WWW::GCloud::R::ServiceIdentity;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.serviceAccountParent;
has Str $.displayName;
has Str $.description;