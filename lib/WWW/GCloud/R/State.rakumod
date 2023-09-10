use v6.e.PREVIEW;

use WWW::GCloud::Record;

enum WWW::GCloud::R::State is gc-enum (
    GCStateUnspecified => "STATE_UNSPECIFIED",
    GCStateDisable => "DISABLED",
    GCStateEnabled => "ENABLED",
);