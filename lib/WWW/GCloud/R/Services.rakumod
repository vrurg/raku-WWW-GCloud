use v6.e.PREVIEW;
unit class WWW::GCloud::R::Services;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::Service;

also is gc-record( :paginating(WWW::GCloud::R::Service, "services") );
