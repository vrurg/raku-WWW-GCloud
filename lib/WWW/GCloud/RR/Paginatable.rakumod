use v6.e.PREVIEW;
unit role WWW::GCloud::RR::Paginatable[::ITEM-TYPE, Str $items-alias?, Str :$json-name];

use AttrX::Mooish;
use JSON::Class:auth<zef:vrurg>:api<1.0.4>;
use JSON::Class::Attr:auth<zef:vrurg>:api<1.0.4>;
use WWW::GCloud::Utils :kebabify;

also is json(:implicit);

my class PgItems is json( :sequence(ITEM-TYPE:D) ) {}

has Str $.nextPageToken;
has @.items is PgItems;

with $items-alias {
    # If there is an alias for @.items then:
    # - use the alias as its JSON key name
    # - install the alias itself
    # - install kebabified alias if the original is in camel case.
    my role PaginatingHOW[Mu \conc, Attribute:D $role-attr is raw] {
        method add_attribute(Mu \obj, \attr) {
            if attr.name eq '@!items' && attr.original =:= $role-attr {
                with $items-alias {
                    my @aliases = $items-alias;
                    @aliases.push($_) with kebabify-name($items-alias);
                    attr.set-options: :@aliases;
                }
            }
            nextsame
        }
        method json-attr-register(Mu \obj, JSON::Class::Attr:D $json-attr --> Nil) {
            with $json-name // $items-alias {
                if $json-attr.name eq '@!items' {
                    nextwith(obj, $json-attr.clone(:json-name($_)));
                }
            }
            nextsame
        }
    }

    ::?CLASS.HOW does PaginatingHOW[$?CONCRETIZATION, ::?ROLE.^get_attribute_for_usage('@!items')];
}