use v6.e.PREVIEW;
unit class WWW::GCloud::Config;

use Method::Also;

use WWW::GCloud::Jsony;
use WWW::GCloud::HOW::RecordWrapper;
use WWW::GCloud::X;
use WWW::GCloud::Utils;

PROCESS::<$WWW-GCLOUD-CONFIG> = ::?CLASS;

has Mu %!type-map{Mu};

# Prevent circular dependency
my \RecordType = resolve-package("WWW::GCloud::Record");

proto method map-type(|) {*}
multi method map-type(::?CLASS:D: WWW::GCloud::Jsony:U \from, Mu:U \into --> Nil) {
    my \nominal-from = maybe-nominalize(from);
    unless into ~~ nominal-from {
        WWW::GCloud::X::Config::BadWrapType.new(
            :type(into),
            :what("a descendant of '" ~ nominal-from.^name ~ "'") ).throw
    }
    %!type-map{nominal-from} := into;
}
multi method map-type(::?CLASS:D: Mu:U \type --> Nil) is default {
    unless type.HOW ~~ WWW::GCloud::HOW::RecordWrapper {
        WWW::GCloud::X::Config::BadWrapType.new(:type(type), :what<gc-wrap>).throw
    }

    my Mu $wrapper := maybe-nominalize(type);
    my Mu $wrappee;

    WRAPEE:
    loop {
        $wrappee := $wrapper.^gc-wrappee;
        if $wrappee.HOW ~~ WWW::GCloud::HOW::RecordWrapper {
            $wrapper := $wrappee;
        }
        elsif $wrappee ~~ RecordType {
            last WRAPEE;
        }
        else {
            WWW::GCloud::X::Config::BadWrapType.new(
                :type($wrappee), :wrapper($wrapper), :what('a gc-wrap or a gc-record') ).throw
        }
    }

    self.map-type: $wrappee, $wrapper
}
multi method map-type(::?CLASS:D: Pair:D $mapping --> Nil) {
    self.map-type: $mapping.key.WHAT, $mapping.value.WHAT
}

method map-types(::?CLASS:D: *@mappings where .all ~~ Mu:U | Pair:D --> Nil) {
    for @mappings {
        $_ ~~ Pair:D
            ?? self.map-type(.key, .value)
            !! self.map-type($_)
    }
}

proto method type-from(|) {*}
multi method type-from(::?CLASS:D: WWW::GCloud::Jsony:U \from --> Mu:U) is raw {
    my Mu \nominal-from = maybe-nominalize(from);
    %!type-map{nominal-from}:exists ?? %!type-map{nominal-from} !! nominal-from
}
multi method type-from(::?CLASS:U: \from) is raw { maybe-nominalize(from) }

method gc-ctx(&code) is raw is also<gc-context> {
    my $*WWW-GCLOUD-CONFIG = self;
    &code()
}