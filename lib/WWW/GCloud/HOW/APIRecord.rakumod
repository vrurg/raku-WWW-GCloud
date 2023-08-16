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

        if $attr.type ~~ WWW::GCloud::Jsony {
            unless $attr ~~ JSON::Unmarshal::CustomUnmarshaller {
                &trait_mod:<is>($attr, :unmarshalled-by('from-json'));
            }
        }

        next if $attr ~~ AttrX::Mooish::Attribute;

        WWW::GCloud::Utils::kebabify-attr($attr);
    }
    nextsame
}