use v6.e.PREVIEW;
use WWW::GCloud::Config;
unit role WWW::GCloud::Configurable[::CFG-TYPE WWW::GCloud::Config $?];

use AttrX::Mooish;

has CFG-TYPE:D $.config = $*WWW-GCLOUD-CONFIG // CFG-TYPE.new;