use v6.e.PREVIEW;
unit class WWW::GCloud::R::Method;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::Option;
use WWW::GCloud::R::Syntax;

also is gc-record;

has Str $.name;
has Str $.request_type_url;
has Str $.request_streaming;
has Str $.response_type_url;
has Str $.response_streaming;
has WWW::GCloud::R::Option:D @.options;
has WWW::GCloud::R::Syntax(Str) $.syntax;