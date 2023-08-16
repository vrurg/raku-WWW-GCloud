use v6.e.PREVIEW;
unit class WWW::GCloud::R::MonitoringDestination;

use WWW::GCloud::Record;

also is gc-record;


has Str $.monitoredResource;
has Str:D @.metrics;