use v6.e.PREVIEW;
unit class WWW::GCloud::R::QuotaLimit;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.name;
has Str $.description;
has Str $.defaultLimit is mooish(:alias<default-limit>);
has Str $.maxLimit is mooish(:alias<max-limit>);
has Str $.freeTier is mooish(:alias<free-tier>);
has Str $.duration;
has Str $.metric;
has Str $.unit;
has Str $.displayName is mooish(:alias<display-name>);
has %.values;