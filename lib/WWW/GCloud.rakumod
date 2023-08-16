use v6.e.PREVIEW;
unit class WWW::GCloud:ver($?DISTRIBUTION.meta<ver>):auth($?DISTRIBUTION.meta<auth>):api($?DISTRIBUTION.meta<api>);

use AttrX::Mooish;
use Cro::HTTP::Client;
use Cro::Uri;
use File::Which;
use Method::Also;
use WWW::GCloud::CPromise;
use WWW::GCloud::Config;
use WWW::GCloud::Configurable;
use WWW::GCloud::Utils;
use WWW::GCloud::X;

also does WWW::GCloud::Configurable;

# Does the CORE Promise implement .andthen and .orelse?
our constant CORE-PROMISE-OK = $*RAKU.compiler.version >= v2023.06.99.gacd.8.cc.450;

our constant HTTPClient =
    CORE-PROMISE-OK
        ?? Cro::HTTP::Client
        !! Cro::HTTP::Client but role :: { method request(|) { callsame() but WWW::GCloud::CPromise }; };

BEGIN {
    use WWW::GCloud::HOW::APIRegistry;
    ::?CLASS.HOW does WWW::GCloud::HOW::APIRegistry;
}

has Str:D $.access-token is mooish(:lazy);

has Pair:D $.http-auth-header is mooish(:lazy);

has Mu:D %!APIs;

method build-access-token {
    my $gcloud = which('gcloud');
    my $proc = run $gcloud, 'auth', 'application-default', 'print-access-token', :out, :err;
    WWW::GCloud::X::Cmd.new(:$proc).throw unless $proc.exitcode == 0;
    $proc.out.slurp(:close).trim
}

method build-http-auth-header {
    "Authorization" => "Bearer " ~ $.access-token;
}

method create(Mu \type, |c) {
    type.new: :gcloud(self), |c
}

method get-API-object(::?CLASS:D: Str:D $api-name --> Mu:D) {
    without %!APIs{$api-name} {
        my Mu:U \api-class := self.^API-class($api-name);
        %!APIs{$api-name} := api-class.new(:gcloud(self), :$.config);
    }

    %!APIs{$api-name}
}

method http-client { HTTPClient }

proto method new-record(|) {*}
multi method new-record(Str:D $short-name, |c) {
    resolve-package('WWW::GCloud::R::' ~ $short-name).new(|c)
}

method gc-ctx(&code, WWW::GCloud::Config :$config --> Mu) is also<gc-context> is raw {
    my $*WWW-GCLOUD-CONFIG = $config // $.config;
    &code()
}

method gc-ctx-wrap(&code, WWW::GCloud::Config :$config) is also<gc-context-wrap> is raw {
    -> |c is raw {
        my $*WWW-GCLOUD-CONFIG = $config // $.config;
        &code(|c)
    }
}

our sub META6 { $?DISTRIBUTION.meta }