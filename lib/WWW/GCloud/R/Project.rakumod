use v6.e.PREVIEW;
unit class WWW::GCloud::R::Project;

use AttrX::Mooish;
use WWW::GCloud::R::ResourceId;
use WWW::GCloud::Record;

also is gc-record;

my Str enum LifecycleState is export(:types) (
    GCPSUnspecified => "LIFECYCLE_STATE_UNSPECIFIED",
    GCPSActive => "ACTIVE",
    GCPSDeleteRequested => "DELETE_REQUESTED",
    GCPSDeleteInProgress => "DELETE_IN_PROGRESS",
);

has Int(Str) $.projectNumber;
has Str $.projectId;
has LifecycleState(Str) $.lifecycleState;
has Str $.name;
has DateTime(Str) $.createTime;
has Str %.labels;
has WWW::GCloud::R::ResourceId $.parent;