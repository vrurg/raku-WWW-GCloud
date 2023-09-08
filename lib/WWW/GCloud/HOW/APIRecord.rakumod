use v6.e.PREVIEW;
unit role WWW::GCloud::HOW::APIRecord;

use AttrX::Mooish;
use JSON::Marshal;
use JSON::OptIn;
use JSON::Unmarshal;
use AttrX::Mooish::Attribute;
use WWW::GCloud::Utils;
use WWW::GCloud::Jsony;

method compose_attributes(Mu \obj, |) {
    for self.attributes(obj, :local).grep({ .has_accessor || .is_built }) -> $attr is raw {
        next if $attr ~~ JSON::Marshal::JsonSkip;

        # Mark any non-skipped attribute as explicit `is json`
        &trait_mod:<is>($attr, :json) unless $attr ~~ JSON::OptIn::OptedInAttribute;


        unless $attr ~~ JSON::Unmarshal::CustomUnmarshaller {
            my Mu \attr-type = $attr.type;
            my $unmarshaller;

            my proto sub is-jsony(|) {*}
            multi sub is-jsony(WWW::GCloud::Jsony --> True) {}
            multi sub is-jsony(Positional \type) { samewith(type.of) }
            multi sub is-jsony(Associative \type) { samewith(type.of) || samewith(type.keyof) }
            multi sub is-jsony(Mu --> False) {}


            if attr-type ~~ WWW::GCloud::Jsony {
                $unmarshaller := 'from-json';
            }
            elsif is-jsony(attr-type) {
                my \of-type = attr-type.of;
                my proto sub of-unmarshal(|) {*}
                multi sub of-unmarshal(\json, WWW::GCloud::Jsony \type) {
                    type.from-json(json)
                }
                multi sub of-unmarshal(\json, Positional \type) is raw {
                    if is-jsony(type) {
                        my \of-type = type.of;
                        return (type.HOW ~~ Metamodel::ClassHOW ?? type.new !! Array[of-type].new) =
                                eager json.map({ of-unmarshal($_, of-type) })
                    }
                    unmarshal(json, type)
                }
                multi sub of-unmarshal(\json, Associative \type) is raw {
                    if is-jsony(type) {
                        my \of-type = type.of;
                        my \key-type = type.keyof;
                        return (type.HOW ~~ Metamodel::ClassHOW ?? type.new !! Hash[of-type, key-type].new ) =
                                eager json.map({ of-unmarshal(.key, key-type) => of-unmarshal(.value, of-type)
                        })
                    }
                    unmarshal(json, type)
                }
                multi sub of-unmarshal(\json, Mu) { json }

                $unmarshaller := -> \json { of-unmarshal(json, attr-type) };
            }

            &trait_mod:<is>($attr, :unmarshalled-by($_)) with $unmarshaller;
        }

        next if $attr ~~ AttrX::Mooish::Attribute;

        WWW::GCloud::Utils::kebabify-attr($attr);
    }
    nextsame
}