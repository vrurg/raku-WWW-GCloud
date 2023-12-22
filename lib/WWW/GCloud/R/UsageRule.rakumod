use v6.e.PREVIEW;
unit class WWW::GCloud::R::UsageRule;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.selector;
has Bool $.allowUnregisteredCalls;
has Bool $.skipServiceControl;