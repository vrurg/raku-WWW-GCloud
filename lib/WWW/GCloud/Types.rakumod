use v6.e.PREVIEW;
unit module WWW::GCloud::Types;

use Cro::Uri;

subset UriStr is export of Str where Str:U | /^ <[A..Za..z]> <[A..Za..z0..9+.-]>* '://' <?before \w> /;

class GCUri is Cro::Uri is export {
    multi method COERCE(Str:D $from) { self.parse: $from }
    multi method COERCE(Cro::Uri:D $from) { self.parse: ~$from }
    method to-json(::?CLASS:D:) { self.Str }
    method from-json($v) {
        my $self-type := self.WHAT;
        if $self-type.^archetypes.nominalizable {
            $self-type := $self-type.^nominalize;
        }
        $self-type.parse: $v
    }
}

subset UriStrOrObj is export of Any where Any:U | UriStr | GCUri;