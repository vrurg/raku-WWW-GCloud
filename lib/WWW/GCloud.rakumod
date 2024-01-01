use v6.e.PREVIEW;
unit class WWW::GCloud:ver($?DISTRIBUTION.meta<ver>):auth($?DISTRIBUTION.meta<auth>):api($?DISTRIBUTION.meta<api>);

use AttrX::Mooish;
use Cro::HTTP::Client;
use Cro::Uri;
use File::Which;
use JSON::Class:auth<zef:vrurg>;
use Method::Also;

use WWW::GCloud::CPromise;
use WWW::GCloud::Config;
use WWW::GCloud::Configurable;
use WWW::GCloud::Utils;
use WWW::GCloud::X;

also does WWW::GCloud::Configurable;

PROCESS::<$WWW-GCLOUD-CONFIG> = ::?CLASS;

# Does the CORE Promise implements .andthen and .orelse?
our constant CORE-PROMISE-OK = $*RAKU.compiler.version >= v2023.06.99.gacd.8.cc.450;

our constant HTTPClient =
    CORE-PROMISE-OK
        ?? Cro::HTTP::Client
        !! Cro::HTTP::Client but role :: { method request(|) { callsame() but WWW::GCloud::CPromise }; };

has Str:D $.access-token is mooish(:lazy);

has Pair:D $.http-auth-header is mooish(:lazy);

has Mu:D %!APIs;
has $!API-lock = Lock.new;

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

method http-client { HTTPClient }

proto method new-record(|) {*}
multi method new-record(Str:D $short-name, |c) {
    resolve-package('WWW::GCloud::R::' ~ $short-name).new(|c)
}

my $api-classes = my %;
method register-api(Mu:U \api-class, Str:D $api-name --> Nil) {
    cas $api-classes, my sub ($_) {
        if .EXISTS-KEY($api-name) {
            unless .AT-KEY($api-name) === api-class {
                WWW::Cloud::X::DuplicateAPI.new(
                    :$api-name,
                    old-class => .AT-KEY($api-name),
                    new-class => api-class )
                .throw
            }
            return $_
        }

        (my $copy = .clone).{$api-name} := api-class;
        $copy
    }
}

method has-API(Str:D $api-name) { $api-classes.EXISTS-KEY($api-name) }

method get-API-object(::?CLASS:D: Str:D $api-name --> Mu:D) {
    $!API-lock.protect: {
        without %!APIs{$api-name} {
            WWW::GCloud::X::NoAPI.new(:$api-name).throw
                unless $api-classes.EXISTS-KEY($api-name);
            my Mu:U \api-class := $api-classes.AT-KEY($api-name);
            %!APIs{$api-name} := api-class.new(:gcloud(self), :$.config);
        }

        %!APIs{$api-name}
    }
}

BEGIN {
    ::?CLASS.^add_fallback(
        -> $obj, $name { $obj.has-API($name) },
        -> $obj, $name {
            my &get-API-method = anon method { self.get-API-object($name) };
            &get-API-method.set_name($name);
            ::?CLASS.^add_method($name, &get-API-method);
            ::?CLASS.^compose;
            &get-API-method
        }
    )
}

our sub META6 { $?DISTRIBUTION.meta }
