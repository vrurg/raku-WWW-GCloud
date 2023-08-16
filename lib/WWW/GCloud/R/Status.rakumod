use v6.e.PREVIEW;
unit class WWW::GCloud::R::Status;

use WWW::GCloud::Record;

also is gc-record;

has Int(Str) $.code;
has Str $.message;
has Hash:D @.details;