# NAME

`WWW::GCloud` - Core of Google Cloud REST API framework

# SYNOPSIS

``` raku
use v6.e.PREVIEW;
use WWW::GCloud;
use WWW::GCloud::API::ResourceMgr;

my $gcloud = WWW::GCloud.new;

say "Available projects:";
react whenever $gcloud.resource-manager.projects.list -> $project {
    say "  * ", $project.project-id;
}

my $new-project-id = "my-unique-project-name";
await $gcloud.resource-manager.projects.create(
    $gcloud.resource-manager.new-project(
        "This is project description",
        id => $new-project-id,
        labels => { :label1('label_value'), :label2("another_value") } );
).andthen({
    say .result; # Would dump an instance of WWW::GCloud::R::Operation
})
.orelse({
    # Choose how to react to an error
    note "Can't create a new project '$new-project-id'";
    .cause.rethrow
});
```

# DESCRIPTION

This is going to be my worst documentation so far\! I apologize for this, but simply unable to write it yet. Will provide a few important notes though.

So far, best way to start with this module is to explore *examples/* and *t/* directories. Apparently, inspecting the sources in *lib/* would be the most helpful\!

## The Status

This is pre-alfa, pre-beta, pre-anything. It is incomplete, sometimes not well enough though out, etc., etc., etc. If you miss a method, an API, whatever – best is to submit a PR or implement a new missing API. It shouldn't be a big deal, a lot can be done by using the "By Example" textbook receipes\!

Do not hesitate to get in touch with me would you need any help. I know it could be annoying when a complex module has little to none docs. I'll do my best to fix the situation. But until then feel free to open an issue in the [GitHub repository](https://github.com/vrurg/raku-WWW-GCloud/issues), even if it's just a question.

## WWW::GCloud Object Structure

Google Cloud structures its API into themed APIs like Resource Manager, Storage, Vision, etc. Each particular API, in turns, provides *resources* where methods belong. `WWW::GCloud` tries to follow the same pattern. Say, in the SYNOPSIS `$gcloud.resource-manager` is `WWW::GCloud::API::ResourceMgr` instance implementing [Resource Manager API](https://cloud.google.com/resource-manager/reference/rest). Then, `$gcloud.resource-manager.projects` is the implementation of [`projects` resource](https://cloud.google.com/resource-manager/reference/rest#rest-resource:-v1.projects).

## Framework Namespacing

The framework is extensible. `WWW::GCloud` class by itself implements no APIs. New ones can be implemented any time. Basically, starting a new API module is as simple as doiing:

``` raku
use v6.e.PREVIEW;
unit class WWW::GCloud::API::NewOne;

use WWW::GCloud::API;

also does WWW::GCloud::API['new-one'];

has $.base-url = 'https://storage.googleapis.com/newone/v1';
```

Now, with `use WWW::GCloud::API::NewOne;` a method `new-one` becomes automatically available with any instance of `WWW::GCloud`.

As you can see, `WWW::GCloud::API::` namespace is used. Here is the list of standard namespaces:

  - **`WWW::GCloud::API::`**
    
    Apparently, any new API implementation must reside within this one.

  - **`WWW::GCloud::R::`**
    
    This is where record types are to be declared. For example, `WWW::GCloud::R::Operation` represents an [Operation](https://cloud.google.com/resource-manager/reference/rest/Shared.Types/Operation).
    
    The `R::` namespace itself is better be reserved for commonly used types of records. For an API-specific record it is recommended to use their own sub-spaces. `WWW::GCloud::API::Storage` is using `WWW::GCloud::R::Storage::`, for example.

  - **`WWW::GCloud::RR::`**
    
    `RR` stands for *Record Roles*. This is where roles, used by record classes, are to be located. Same API sub-naming rule applies.

## Type Mapping

Sometimes it is useful to map a core class into a user's child class. For example, an output from text recognition APIs could be "patched" so that records using vertexes (like actual symbols detected) can be represented with user classes where user's own coordinate system is used. So, that instead of re-building our class based on what's returned by the API we can use lazy approaches to simply construct the parts we need:

``` raku
use AttrX::Mooish;
class MyBoundingPoly is gc-wrap(WWW::GCloud::R::Vision::BoundingPoly) {
    has MyRect:D @.bounding-path;

    method build-bounding-path {
        self.vertices.map: { self.covert-point($^vertex) }
    }
}
```

See *examples/basic-usage.raku* and *t/050-type-map.rakutest*.

## Some API conventions

Most methods mapping into the actual REST calls return either a [`Promise`](https://docs.raku.org/type/Promise) or a [`Supply`](https://docs.raku.org/type/Supply). The latter is by default applies to methods which returns lists, especially when the list is paginated by the service. For example, method `list` of `projects` resource of `resource-manager` API returns a [`Supply`](https://docs.raku.org/type/Supply).

[`Promise`](https://docs.raku.org/type/Promise), apparently, would be broken in case of any error, including the errors reported by the Google Cloud.

For successfull calls the value of a kept [`Promise`](https://docs.raku.org/type/Promise) depends on the particular method. Sometimes it could be a plain [`Bool`](https://docs.raku.org/type/Bool), more often it would be an instance of a `WWW::GCloud::R::` record. On occasion a `Cro::HTTP::Response` itself can be produced in which case it is likely to get `WWW::GCloud::HTTP::Stream` mixin which allows to send response body into a file or any other kind of `IO::Handle`.

## A Couple Of Recommendations

Consider using traits for declarations. For example, a new record class is best declared as:

``` raku
use v6.e.PREVIEW;
unit class WWW::GCloud::R::NewAapi::ARec;

use WWW::GCloud::Record;

also is gc-record;

has Str $.someField;
has Int $.aCounter;
```

The trait would automatically mark all record attributes (except where explicit `is json-skip` is applied) as JSON-serializable as if `is json` has been applied to them manually.

Other useful traits are:

  - `gc-wrap` from `WWW::GCloud::Record`

  - `gc-params` from `WWW::GCloud::QueryParams` (find its usages in API modules and see *t/040-query-params.rakutest*)

  - `does` when used with `WWW::GCloud::API` automates registering of an API module with `WWW::GCloud`

# COPYRIGHT

(c) 2023, Vadim Belman <vrurg@cpan.org>

# LICENSE

Artistic License 2.0

See the [*LICENSE*](LICENSE) file in this distribution.
