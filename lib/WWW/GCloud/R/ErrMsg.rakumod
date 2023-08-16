use v6.e.PREVIEW;
# https://cloud.google.com/resource-manager/docs/core_errors, an entry of key "errors"
unit class WWW::GCloud::R::ErrMsg;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str:D $.domain is required;
has Str $.reason;
has Str $.message;
has Str $.locationType is mooish(:alias<location-type>);
has Str $.location;