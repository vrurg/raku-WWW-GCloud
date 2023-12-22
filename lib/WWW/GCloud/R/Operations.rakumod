use v6.e.PREVIEW;
unit class WWW::GCloud::R::Operations;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::Operation;

also is gc-record( :paginating(WWW::GCloud::R::Operation, "operations") );
