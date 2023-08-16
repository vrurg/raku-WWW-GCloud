use v6.e.PREVIEW;
unit class WWW::GCloud::R::SourceContext;

use AttrX::Mooish;
use WWW::GCloud::Record;

also is gc-record;

has Str $.file_name is mooish(:alias<file-name>);