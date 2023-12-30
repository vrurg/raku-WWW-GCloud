use v6.e.PREVIEW;
unit class WWW::GCloud::Config;

use Method::Also;
use JSON::Class::Config:auth<zef:vrurg>;

use WWW::GCloud::X;
use WWW::GCloud::Utils;

also is JSON::Class::Config;

method new(|c) { nextwith(:enums-as-value, |c) }

method gc-ctx(&code) is raw is also<gc-context> {
    my $*JSON-CLASS-CONFIG :=
    my $*WWW-GCLOUD-CONFIG := self;
    &code()
}

method gc-ctx-wrap(&code) is also<gc-context-wrap> is raw {
    -> |c is raw {
        my $*JSON-CLASS-CONFIG :=
        my $*WWW-GCLOUD-CONFIG := self;
        &code(|c)
    }
}