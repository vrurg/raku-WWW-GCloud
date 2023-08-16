use v6.e.PREVIEW;
unit role WWW::GCloud::RR::Paginatable[::ITEM-TYPE, Str $items-alias?, Str :$json-name];

use AttrX::Mooish;
use JSON::Name;
use WWW::GCloud::Utils :kebabify;

has Str $.nextPageToken is mooish(:aliases<next-page-token page-token>);
has ITEM-TYPE:D @.items;

with $items-alias {
    # If there is an alias for @.items then:
    # - use the alias as its JSON key name
    # - install the alias itself
    # - install kebabified alias if the original is in camel case.
    my role PaginatingHOW[Mu \conc] {
        method compose_attributes(Mu \obj, |) {
            if  obj.^has_attribute('@!items') {
                my $attr := obj.^get_attribute_for_usage('@!items');
                my $my-items := conc.^get_attribute_for_usage('@!items');
                if $attr.original =:= $my-items.original {
                    &trait_mod:<is>($attr, :json-name($json-name // $items-alias));
                    my @aliases = $items-alias;
                    @aliases.push: $_ with kebabify-name($items-alias);
                    &trait_mod:<is>($attr, :mooish(:@aliases));
                }
            }
            nextsame;
        }
    }

    ::?CLASS.HOW does PaginatingHOW[$?CONCRETIZATION];
}