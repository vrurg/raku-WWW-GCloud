use v6.e.PREVIEW;
unit class WWW::GCloud::R::QuotaLimit;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.name;
has Str $.description;
has Str $.defaultLimit;
has Str $.maxLimit;
has Str $.freeTier;
has Str $.duration;
has Str $.metric;
has Str $.unit;
has Str $.displayName;
has %.values;