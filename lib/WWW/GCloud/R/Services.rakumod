use v6.e.PREVIEW;
unit class WWW::GCloud::R::Services;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::RR::Paginatable;
use WWW::GCloud::R::Service;

also is gc-record;
also does WWW::GCloud::RR::Paginatable[WWW::GCloud::R::Service, "services"];
