use v6.e.PREVIEW;
unit class WWW::GCloud::R::Project;

use AttrX::Mooish;
use WWW::GCloud::R::ResourceId;
use WWW::GCloud::Record;

also is gc-record;

my Str enum LifecycleState is gc-enum is export(:types) (
    GCPSUnspecified => "LIFECYCLE_STATE_UNSPECIFIED",
    GCPSActive => "ACTIVE",
    GCPSDeleteRequested => "DELETE_REQUESTED",
    GCPSDeleteInProgress => "DELETE_IN_PROGRESS",
);

has Int(Str) $.projectNumber is mooish(:alias<project-number>);
has Str $.projectId is mooish(:alias<project-id>);
has LifecycleState(Str) $.lifecycleState is mooish(:alias<lifecycle-state>);
has Str $.name;
has DateTime(Str) $.createTime is mooish(:alias<create-time>);
has Str %.labels;
has WWW::GCloud::R::ResourceId $.parent;