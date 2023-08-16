use v6.e.PREVIEW;
use WWW::GCloud;
use WWW::GCloud::API::ResourceMgr;
use WWW::GCloud::API::ServiceUsage;
use WWW::GCloud::R::Project;
use WWW::GCloud::R::Documentation;
use WWW::GCloud::Record;

class MyDoc is WWW::GCloud::R::Documentation {}
class MyProj is gc-wrap(WWW::GCloud::R::Project) {}

sub MAIN(Str :$project is copy, Str :$create-project) {
    my $gcloud = WWW::GCloud.new;

    # See if overriding a core Record works.
    $gcloud.config.map-types: WWW::GCloud::R::Documentation => MyDoc, MyProj;

    say "--- all projects";
    my $rm = $gcloud.resource-manager;
    my @projects;
    react {
        whenever $rm.projects.list {
            say "    * ", .project-id;
            @projects.push: .project-id;
            QUIT {
                default {
                    note "QUIT while listing projects: " .WHICH, "\n", .gist;
                }
                done
            }
        }
    }

    without $project {
        say "??? No project specified on the command line, choosing one randomly";
        $project = @projects.pick;
    }

    say "--- Project `$project` details:\n    ", my $project-details = await $rm.projects.get($project);

    say "--- paginate all";
    for  $rm.projects.list(:page-size(3)) {
        say "    * [{.elems}] ", .map(*.project-id).join(", ");
    }

    say "--- services by num";
    for $gcloud.service-usage.services.list(parent => 'projects/' ~ $project-details.project-number) {
        say "    * ", $_,
            (.config andthen .documentation andthen "\n      documentation class: " ~ .^name orelse "");
    }

    # say "--- services by ID";
    # for $gcloud.service-usage.services.list(parent => 'projects/' ~ $project, :page-size(10), :!paginate) {
    #     say "srv>>> ", $_;
    # }

    if $create-project {
        my $resp = $gcloud.resource-manager.projects.create:
            $gcloud.resource-manager.new-project(
                "Created with API",
                id => $create-project,
                labels => { "label1" => "value1", "label2" => "value2" } );

        try await $resp;

        if $resp.status == Broken {
            say $resp.cause;
        }
        else {
            say $resp.result;
        }

        say "--- filter by name";
        for  $gcloud.resource-manager.projects(:filter<name:Created*>) {
            say ">>> ", $_;
        }
    }
}