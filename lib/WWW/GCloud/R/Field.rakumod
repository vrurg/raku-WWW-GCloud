use v6.e.PREVIEW;
unit class WWW::GCloud::R::Field;

use WWW::GCloud::Record;
use WWW::GCloud::R::Option;

also is gc-record;


has Str $.name;
has Str $.kind;
has Str $.cardinality;
has Str $.type_url;
has Int(Str) $.oneof_index;
has Bool $.packed;
has Str $.json_name;
has Str $.default_value;
has WWW::GCloud::R::Option @.options;
has Int(Str) $.number;
