use v6.e.PREVIEW;
unit class WWW::GCloud::API::ResourceMgr;

use AttrX::Mooish;
use WWW::GCloud;
use WWW::GCloud::API;
use WWW::GCloud::Resource;
use WWW::GCloud::R::Projects;
use WWW::GCloud::R::Project :types;
use WWW::GCloud::R::ResourceId;
use WWW::GCloud::R::Operation;

also does WWW::GCloud::API['resource-manager'];

### Resource Classes ###

class Projects does WWW::GCloud::Resource {
    # https://cloud.google.com/resource-manager/reference/rest/v3/projects/list
    method list( ::?CLASS:D:
                 Int :page-size(:$pageSize),
                 Str :$filter,
                 Bool :$paginate is copy
                 --> Supply:D )
    {
        my %query = |(:$filter with $filter);
        with $pageSize {
            $paginate = True;
            %query<pageSize> = $pageSize;
        }
        $.api.paginate: "get", "projects", as => WWW::GCloud::R::Projects, :%query, :$paginate
    }

    # https://cloud.google.com/resource-manager/reference/rest/v3/projects/create
    method create( ::?CLASS:D: WWW::GCloud::R::Project:D $project ) {
        $.api.post: "projects", $project, as => WWW::GCloud::R::Operation
    }

    # https://cloud.google.com/resource-manager/reference/rest/v3/projects/get
    method get( ::?CLASS:D: Str:D $id ) {
        $.api.get: 'projects/' ~ $id, as => WWW::GCloud::R::Project
    }
}

### Attributes And Methods ###

has Str:D $.base-url = 'https://cloudresourcemanager.googleapis.com/v1';

has Projects:D $.projects is mooish(:lazy);

method build-projects {
    Projects.new: api => self
}

# Create a new project record
method new-project( Str:D $name,
                    Int :number(:$projectNumber),
                    Str :id(:$projectId),
                    LifecycleState(Str) :state(:$lifecycleState),
                    DateTime(Str) :create-time(:$createTime),
                    :%labels,
                    WWW::GCloud::R::ResourceId(Hash) :$parent )
{
    WWW::GCloud::R::Project.new:
        :$name, :$projectNumber, :$projectId, :$lifecycleState,
        :$createTime, :%labels, :$parent
}