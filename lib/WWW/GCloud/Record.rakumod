use v6.e.PREVIEW;
unit role WWW::GCloud::Record;

use AttrX::Mooish;
use JSON::Marshal;
use JSON::Unmarshal:ver<0.15>:auth<zef:raku-community-modules>;

use WWW::GCloud::Jsony;
use WWW::GCloud::Object;
use WWW::GCloud::HOW::APIRecord;
use WWW::GCloud::HOW::RecordWrapper;
use WWW::GCloud::RR::Paginatable;
use WWW::GCloud::Utils;

also is WWW::GCloud::Object;
also does WWW::GCloud::Jsony;

multi method COERCE(%profile) {
    self.WHAT.new: |%profile
}

method from-json( $json,
                  *%params ( Bool:D :$warn = False,
                             Bool:D :die(:$throw) = False,
                             Bool:D :$opt-in = True )
                  --> ::?CLASS )
{
    return Nil without $json;
    my \dest-type = $*WWW-GCLOUD-CONFIG.type-from(self.WHAT);
    jsony-unmarshal $json, dest-type, :$warn, :$throw, :$opt-in, |%params
}

method to-json( *%params ( Bool:D :$skip-null= True,
                           Bool:D :$sorted-keys = False,
                           Bool:D :$pretty = False,
                           Bool:D :$opt-in = True )
                --> Str )
{
    jsony-marshal self, :$skip-null, :$sorted-keys, :$pretty, :$opt-in, |%params
}

BEGIN {
    multi sub trait_mod:<is>(Attribute $attr is raw, Bool:D :kebabish(:$raku-aliased)!) is export {
        WWW::GCloud::Utils::kebabify-attr($attr);
    }

    multi sub trait_mod:<is>(Mu:U \type, Bool:D :$gc-record) is export {
        unless type.HOW ~~ WWW::GCloud::HOW::APIRecord {
            type.HOW does WWW::GCloud::HOW::APIRecord;
            type.^add_role(::?ROLE);
        }
    }

    multi sub trait_mod:<is>( Mu:U \type,
                              List(Mu:D) :gc-record($)! ( :paginating($)
                                                            (::?ROLE:U \precord, Str $item-alias?, Str :$json-name)) )
    {
        unless type.HOW ~~ WWW::GCloud::HOW::APIRecord {
            type.HOW does WWW::GCloud::HOW::APIRecord;
            type.^add_role(::?ROLE);
            type.^add_role(WWW::GCloud::RR::Paginatable[precord, $item-alias, :$json-name]);
        }
    }

    multi sub trait_mod:<is>(Mu:U \type, Mu :$gc-wrap is raw) {
        type.HOW does WWW::GCloud::HOW::RecordWrapper unless type.HOW ~~ WWW::GCloud::HOW::RecordWrapper;
        type.^gc-set-wrappee($gc-wrap.WHAT);
    }

    my role GCEnumeration does WWW::GCloud::Jsony {
        proto method from-json(|) {*}
        multi method from-json(::?CLASS:_: Mu:U $) { Nil }
        multi method from-json(::?CLASS:_: Str:D $json) {
            maybe-nominalize(self).($json)
        }
        method to-json(::?CLASS:D:) {
            self.value
        }
    }

    multi sub trait_mod:<is>(Mu \type, Bool :gc-enum($)!) {
        type.^add_role: GCEnumeration;
    }
}