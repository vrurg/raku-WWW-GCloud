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
            my $marshaller;

            my proto sub is-jsony(|) {*}
            multi sub is-jsony(WWW::GCloud::Jsony --> True) is pure {}
            multi sub is-jsony(Positional \type) is pure { samewith(type.of) }
            multi sub is-jsony(Associative \type) is pure { samewith(type.of) || samewith(type.keyof) }
            multi sub is-jsony(Mu --> False) is pure {}

            my proto sub is-gc-enum(|) {*}
            multi sub is-gc-enum(Enumeration \type) is pure { type ~~ WWW::GCloud::Jsony }
            multi sub is-gc-enum(Positional \type)  is pure { samewith(type.of) }
            # For enumerations we only take into account hash values
            multi sub is-gc-enum(Associative \type) is pure { samewith(type.of) }
            multi sub is-gc-enum(Mu --> False) is pure {}

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
                    # Propagade upstream parameters. We don't need jsony-unmarshal here because no parameter is getting
                    # changed here.
                    my %params := %*WWW-GCLOUD-UNMARSHAL-PARAMS // %();
                    unmarshal(json, type, |%params)
                }
                multi sub of-unmarshal(\json, Associative \type) is raw {
                    if is-jsony(type) {
                        my \of-type = type.of;
                        my \key-type = type.keyof;
                        return (type.HOW ~~ Metamodel::ClassHOW ?? type.new !! Hash[of-type, key-type].new ) =
                                eager json.map({ of-unmarshal(.key, key-type) => of-unmarshal(.value, of-type)
                        })
                    }
                    my %params := %*WWW-GCLOUD-UNMARSHAL-PARAMS // %();
                    unmarshal(json, type, |%params)
                }
                multi sub of-unmarshal(\json, Mu) { json }

                $unmarshaller := -> \json { of-unmarshal(json, attr-type) };
            }

            if attr-type ~~ Enumeration & WWW::GCloud::Jsony {
                $marshaller := 'to-json';
            }
            elsif is-gc-enum(attr-type) {
                my proto sub of-marshal(|) {*}
                multi sub of-marshal(WWW::GCloud::Jsony:D $obj) {
                    $obj.to-json
                }
                multi sub of-marshal(@pos) is raw {
                    @pos.map({ of-marshal($_) }).Array
                }
                multi sub of-marshal(%assoc) is raw {
                    %assoc.map({ .key => of-marshal(.value) }).Hash
                }
                multi sub of-marshal(Mu $obj) is raw { $obj }

                $marshaller := &of-marshal;
            }

            &trait_mod:<is>($attr, :unmarshalled-by($_)) with $unmarshaller;
            &trait_mod:<is>($attr, :marshalled-by($_))   with $marshaller;
        }

        next if $attr ~~ AttrX::Mooish::Attribute;

        WWW::GCloud::Utils::kebabify-attr($attr);
    }
    nextsame
}