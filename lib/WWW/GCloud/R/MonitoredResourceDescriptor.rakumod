use v6.e.PREVIEW;
# https://cloud.google.com/service-infrastructure/docs/service-management/reference/rest/v1/services.configs#monitoredresourcedescriptor
unit class WWW::GCloud::R::MonitoredResourceDescriptor;

use WWW::GCloud::Record;
use WWW::GCloud::R::LabelDescriptor;

also is gc-record;


has Str $.name;
has Str $.type;
has Str $.displayName;
has Str $.description;
has WWW::GCloud::R::LabelDescriptor:D @.labels;
has Str $.launchStage;