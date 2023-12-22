use v6.e.PREVIEW;
unit role WWW::GCloud::HOW::APIRecord;

use WWW::GCloud::Utils :kebabify;

use AttrX::Mooish;
use AttrX::Mooish::Attribute;
use JSON::Class:auth<zef:vrurg>;

method jsonify-attribute(Mu \obj, Attribute:D $attr is raw, :alias(:$aliases), |c) {
    with kebabify-name($attr.name.substr(2)) {
        # Only add alias when there is no existing method with the same name.
        unless self.declares_method(obj, $_) {
            my @aliases = ($aliases andthen |$_), $_;
            nextwith obj, $attr, :@aliases, |c;
        }
    }
    nextsame
}