use v6.e.PREVIEW;
unit class WWW::GCloud::Config;
use WWW::GCloud::Jsony;
use WWW::GCloud::HOW::RecordWrapper;
use WWW::GCloud::X;
use WWW::GCloud::Utils;

INIT PROCESS::<$WWW-GCLOUD-CONFIG> = ::?CLASS;

has Mu %!type-map{Mu};

# Prevent circular dependency
my \RecordType = resolve-package("WWW::GCloud::Record");

proto method map-type(|) {*}
multi method map-type(::?CLASS:D: WWW::GCloud::Jsony:U \from, Mu:U \into --> Nil) {
    unless into ~~ from {
        WWW::GCloud::X::Config::BadWrapType.new(:type(into), :what("a descendant of '" ~ from.^name ~ "'")).throw
    }
    %!type-map{from} := into;
}
multi method map-type(::?CLASS:D: Mu:U \type --> Nil) is default {
    unless type.HOW ~~ WWW::GCloud::HOW::RecordWrapper {
        WWW::GCloud::X::Config::BadWrapType.new(:type(type), :what<gc-wrap>).throw
    }

    my Mu $wrapper := type.WHAT;
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
    %!type-map{from}:exists ?? %!type-map{from} !! from
}
multi method type-from(::?CLASS:U: \from) is raw { from }