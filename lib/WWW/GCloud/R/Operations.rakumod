use v6.e.PREVIEW;
unit class WWW::GCloud::R::Operations;

use AttrX::Mooish;
use WWW::GCloud::RR::Paginatable;
use WWW::GCloud::Record;
use WWW::GCloud::R::Operation;

also is gc-record;
also does WWW::GCloud::RR::Paginatable[WWW::GCloud::R::Operation, "operations"];
