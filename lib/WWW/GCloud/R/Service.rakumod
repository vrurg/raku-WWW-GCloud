use v6.e.PREVIEW;
unit class WWW::GCloud::R::Service;

use WWW::GCloud::Record;
use WWW::GCloud::R::ServiceConfig;
use WWW::GCloud::R::State;

also is gc-record;

has Str $.name;
has Str $.parent;
has WWW::GCloud::R::ServiceConfig $.config;
has WWW::GCloud::R::State(Str) $.state;