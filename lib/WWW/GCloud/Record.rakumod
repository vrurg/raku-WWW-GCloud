use v6.e.PREVIEW;
unit role WWW::GCloud::Record;

use AttrX::Mooish;
use JSON::Class:auth<zef:vrurg>:api<1.0.4>;
use JSON::Class::HOW::Jsonish:auth<zef:vrurg>:api<1.0.4>;

use WWW::GCloud::Config;
use WWW::GCloud::HOW::APIRecord;
use WWW::GCloud::Object;
use WWW::GCloud::RR::Paginatable;
use WWW::GCloud::Utils;
use WWW::GCloud::X;

also is WWW::GCloud::Object;
also is json;

multi method COERCE(%profile) {
    self.WHAT.new: |%profile
}

BEGIN {
    my proto sub setup-pagination(|) {*}
    multi sub setup-pagination(Mu \type, Mu:U \precord) {
        type.^add_role(WWW::GCloud::RR::Paginatable[precord]);
    }
    multi sub setup-pagination(Mu \type, Mu:U \precord, Str $item-alias?, Str :$json-name) {
        type.^add_role(WWW::GCloud::RR::Paginatable[precord, $item-alias, :$json-name]);
    }

    my proto sub make-a-record(|) {*}
    multi sub make-a-record(Mu:U \type, Bool:D $gc-record) {
        make-a-record(type) if $gc-record;
    }
    multi sub make-a-record(Mu:U \type, |c (Mu :$paginating is raw, *%for-json)) {
        unless type.HOW ~~ WWW::GCloud::HOW::APIRecord {
            unless type.HOW ~~ JSON::Class::HOW::Jsonish {
                my %config = :enums-as-value, (|.Hash with %for-json<config>);
                &trait_mod:<is>( type,
                                 json => (:implicit, :lazy, :skip-null, |%for-json, :%config) );
            }
            type.HOW does WWW::GCloud::HOW::APIRecord;
            type.^add_role(::?ROLE);
            if c.Hash<paginating>:exists {
                setup-pagination(type, |$paginating.List.Capture);
            }
        }
    }
    multi sub make-a-record(Mu:U \type, |c) {
        WWW::GCloud::X::AdHoc.new("Trait 'gc-record' can't be used with these arguments: " ~ c.raku).throw
    }

    multi sub trait_mod:<is>(Mu:U \type, Pair:D :$gc-record! is raw) is export {
        make-a-record(type, |($gc-record,).Capture)
    }
    multi sub trait_mod:<is>(Mu:U \type, :@gc-record! is raw) is export {
        make-a-record(type, |@gc-record.Capture)
    }
    multi sub trait_mod:<is>(Mu:U \type, Mu :$gc-record! is raw) is export {
        make-a-record(type, |$gc-record.List.Capture)
    }

    multi sub trait_mod:<is>(Mu:U \type, Mu :gc-wrap($json-wrap) is raw) is export {
        &trait_mod:<is>(type, :$json-wrap);
    }

    multi sub trait_mod:<is>(Mu \type, Bool :gc-enum($)!) is export {
        warn "Non-functional gc-enum trait is used with " ~ type.^name;
    }
}

method json-config-class { WWW::GCloud::Config }