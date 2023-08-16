use v6.e.PREVIEW;
unit class WWW::GCloud::R::Type;

use WWW::GCloud::Record;
use WWW::GCloud::R::Option;
use WWW::GCloud::R::Field;
use WWW::GCloud::R::SourceContext;
use WWW::GCloud::R::Syntax;

also is gc-record;


has Str $.name;
has WWW::GCloud::R::Field:D @.fields;
has Str $.oneofs;
has WWW::GCloud::R::Option:D @.options;
has WWW::GCloud::R::SourceContext $.source_context;
has WWW::GCloud::R::Syntax(Str) $.syntax;