use v6.e.PREVIEW;
unit class WWW::GCloud::R::Endpoint;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.name;
has Str:D @.aliases;
has Str $.target;
has Bool $.allowCors;