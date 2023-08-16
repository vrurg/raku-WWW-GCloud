use v6.e.PREVIEW;
unit class WWW::GCloud::R::ServiceConfig;

use WWW::GCloud::Record;
use WWW::GCloud::R::Api;
use WWW::GCloud::R::Documentation;
use WWW::GCloud::R::Quota;
use WWW::GCloud::R::Authentication;
use WWW::GCloud::R::Usage;
use WWW::GCloud::R::Endpoint;
use WWW::GCloud::R::Monitoring;
use WWW::GCloud::R::MonitoredResourceDescriptor;
use WWW::GCloud::R::Type;

also is gc-record;


has Str $.name;
has Str $.title;
has Str $.producerProjectId;
has Str $.id;
has WWW::GCloud::R::Type:D @.types;
has WWW::GCloud::R::Api @.apis;
has WWW::GCloud::R::Documentation $.documentation;
has WWW::GCloud::R::Quota $.quota;
has WWW::GCloud::R::Authentication $.authentication;
has WWW::GCloud::R::Usage $.usage;
has WWW::GCloud::R::Endpoint:D @.endpoints;
has WWW::GCloud::R::Monitoring $.monitoring;
has WWW::GCloud::R::MonitoredResourceDescriptor:D @.monitoredResources;