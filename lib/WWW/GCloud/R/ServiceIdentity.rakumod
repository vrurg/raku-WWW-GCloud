use v6.e.PREVIEW;
unit class WWW::GCloud::R::ServiceIdentity;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.serviceAccountParent is mooish(:alias<service-account-parent>);
has Str $.displayName is mooish(:alias<display-name>);
has Str $.description;