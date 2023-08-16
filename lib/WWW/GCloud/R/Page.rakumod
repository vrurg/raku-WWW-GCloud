use v6.e.PREVIEW;
unit class WWW::GCloud::R::Page;

use WWW::GCloud::Record;

also is gc-record;

has Str $.name;
has Str $.content;
has ::?CLASS:D @.subpages;