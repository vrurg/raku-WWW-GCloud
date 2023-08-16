use v6.e.PREVIEW;
unit class WWW::GCloud::R::Monitoring;

use WWW::GCloud::Record;
use WWW::GCloud::R::MonitoringDestination;

also is gc-record;


has WWW::GCloud::R::MonitoringDestination:D @.producerDestinations;
has WWW::GCloud::R::MonitoringDestination:D @.consumerDestinations;