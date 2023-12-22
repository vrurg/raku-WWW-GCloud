use v6.e.PREVIEW;
unit class WWW::GCloud::R::Api;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::Method;
use WWW::GCloud::R::Option;
use WWW::GCloud::R::SourceContext;
use WWW::GCloud::R::Mixin;
use WWW::GCloud::R::Syntax;

also is gc-record;


has Str $.name;
has WWW::GCloud::R::Method:D @.methods;
has WWW::GCloud::R::Option @.options;
has Str $.version;
has WWW::GCloud::R::SourceContext $.source_context;
has WWW::GCloud::R::Mixin:D @.mixins;
has WWW::GCloud::R::Syntax $.syntax;