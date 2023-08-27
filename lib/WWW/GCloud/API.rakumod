use v6.e.PREVIEW;
unit role WWW::GCloud::API[Str:D $api-name, :%resources];

use experimental :will-complain;

use AttrX::Mooish;
use Cro::HTTP::Client;
use Cro::Uri;
use JSON::Fast;
use WWW::GCloud;
use WWW::GCloud::Configurable;
use WWW::GCloud::HTTP::Stream;
use WWW::GCloud::Object;
use WWW::GCloud::R::Error;
use WWW::GCloud::RR::Paginatable;
use WWW::GCloud::Record;
use WWW::GCloud::Utils;
use WWW::GCloud::X;

also is WWW::GCloud::Object;
also does WWW::GCloud::Configurable;

has WWW::GCloud:D $.gcloud is required;

has Cro::HTTP::Client:D $.http-client is mooish(:lazy);
has Cro::Uri:D $.api-url is mooish(:lazy);

method api-name { $api-name }

method base-url {...}

method build-api-url {
    my $url = self.base-url;
    $url ~= "/" unless $url.ends-with("/");
    Cro::Uri.parse: $url
}

method build-http-client {
    $.gcloud.http-client.new(:http<1.1>, base-uri => $.api-url)
}

method create(Mu \type, |c) {
    type.new: :$!gcloud, :api(self), |c
}

method gc-ctx-wrap(&code) {
    -> |c is raw {
        my $*WWW-GCLOUD-CONFIG = $.config;
        &code(|c)
    }
}

method gc-ctx(&code) is raw {
    my $*WWW-GCLOUD-CONFIG = $.config;
    &code()
}

method !on-HTTP-error(Promise:D $p) {
    my $cause = $p.cause;
    if $cause ~~ X::Cro::HTTP::Error
        && $cause.response.content-type.type-and-subtype eq 'application/json'
    {
        my $err-body = await $cause.response.body-text;
        if $*WWW-GCLOUD-DUMP-BODY {
            note "--- ERR BODY ---\n", $err-body, "\n--- ERR BODY ENDS ---";
        }
        self.throw:
            WWW::GCloud::X::API::HTTP,
            response => $cause.response,
            error => WWW::GCloud::R::Error.from-json($err-body),
            :$api-name
    }
    $cause.rethrow
}

method wrap-response(Promise:D $req-promise, ::AS :as($), Bool :$raw, Bool :json(:$json-body) = True) {
    $req-promise
        .andthen(
            self.gc-ctx-wrap: {
                if $raw {
                    .result
                }
                elsif $json-body {
                    my $body := await .result.body-text;
                    if $*WWW-GCLOUD-DUMP-BODY {
                        note "--- RESPONSE BODY ---\n", $body, "\n--- RESPONSE BODY ENDS ---";
                    }
                    AS =:= WWW::GCloud::Record ?? $body !! AS.from-json($body)
                }
                else {
                    .result does WWW::GCloud::HTTP::Stream
                }
            }
        )
        .orelse(self.gc-ctx-wrap: { self!on-HTTP-error($_) })
}

method get( ::?CLASS:D:
            Str:D $api-path,
            WWW::GCloud::Record :$as is raw,
            Bool :json(:$json-body) = True,
            Bool :$raw,
            :@headers,
            *%c
            --> Promise:D )
{
    self.wrap-response:
        :$json-body, :$raw, :$as,
        $.http-client.get( $api-path,
                        headers => [
                            $.gcloud.http-auth-header,
                            |@headers,
                        ],
                        |%c )
}

my subset POSTBody is export of Any
    will complain { "Body object for POST is expected to be either a hash or a WWW::GCloud::Record, not "
                    ~ instance-or-type($_) }
    where Hash | WWW::GCloud::Record;

method post( ::?CLASS:D:
             Str:D $api-path,
             POSTBody:D $body-object,
             # Return the response object as-is, no body deserializating. :as is ignored if $raw is True
             Bool :$raw,
             # What the response body must be deserialized as
             WWW::GCloud::Record :$as is raw,
             :@headers,
             *%c
             --> Promise:D )
{
    my $body =
        $body-object ~~ WWW::GCloud::Record
            ?? $body-object.to-json(:skip-null, :!pretty)
            !! to-json($body-object, :!pretty);
    self.wrap-response:
        :$raw, :$as, :json-body,
        $.http-client.post( $api-path,
                            content-type => 'application/json',
                            headers => [
                                $.gcloud.http-auth-header,
                                |@headers,
                            ],
                            :$body,
                            |%c )
}

method delete( ::?CLASS:D: Str:D $api-path, :@headers, *%c --> Promise:D ) {
    self.wrap-response:
        :raw,
        $.http-client.delete( $api-path,
                              headers => [
                                  $.gcloud.http-auth-header,
                                  |@headers,
                              ],
                              |%c )
}

proto method paginate(|) {*}

multi method paginate( ::?CLASS:D:
                       Str:D $method,
                       Str:D $api-path,
                       WWW::GCloud::RR::Paginatable :$as! is raw,
                       :%query,
                       Int :page-size(:$pageSize),
                       Bool :$paginate is copy,
                       *%c )
{
    if $pageSize {
        $paginate //= True;
        %query<pageSize> = $pageSize;
    }
    self.paginate: { self."$method"($api-path, :$as, :%query, |%c ) }, :$as, :%query, :$paginate
}

multi method paginate( ::?CLASS:D:
                       &promise-producer,
                       ::REC-TYPE WWW::GCloud::RR::Paginatable :as($)! is raw,
                       Hash :$query,
                       Bool :$paginate )
{
    my Str $pageToken;
    my Supplier::Preserving $supplier .= new;

    start repeat {
            with $query {
                $pageToken
                    andthen $query.ASSIGN-KEY('pageToken', $pageToken)
                    orelse  $query.DELETE-KEY('pageToken');
            }
            $pageToken =
                await promise-producer($pageToken)
                    .andthen(self.gc-ctx-wrap: {
                        my REC-TYPE $folio = .result;
                        if $paginate {
                            $supplier.emit: $folio.items;
                        }
                        else {
                            $supplier.emit($_) for $folio.items;
                        }

                        $folio.nextPageToken orelse do {
                            $supplier.done;
                            Nil
                        }
                    })
                    .orelse(self.gc-ctx-wrap: {
                        $supplier.quit: .cause;
                        Nil
                    });
        } while $pageToken.defined;

    $supplier.Supply
}

method register-API {
    WWW::GCloud.register-api(::?CLASS, $api-name);
}

BEGIN {
    my sub add_phaser(&phaser) {
        with $*W {
            my $unit-code-object;
            my $scopes = 0;
            while $*W.get_code_object(scopes => ++$scopes) -> \code-object {
                $unit-code-object = code-object;
            }
            $unit-code-object.add_phaser('LEAVE', &phaser);
        }
    }

    multi sub trait_mod:<does>(Mu:U \doee, WWW::GCloud::API:U \r) is export {
        add_phaser({ doee.register-API });
        nextsame
    }
}