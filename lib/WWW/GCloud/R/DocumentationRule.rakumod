use v6.e.PREVIEW;
unit class WWW::GCloud::R::DocumentationRule;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.selector;
has Str $.description;
has Str $.deprecationDescription is mooish(:alias<deprecation-description>);