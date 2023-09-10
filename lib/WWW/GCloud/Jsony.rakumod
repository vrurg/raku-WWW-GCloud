use v6.e.PREVIEW;
unit role WWW::GCloud::Jsony;

use JSON::Marshal;
use JSON::Unmarshal;

method from-json(|) {...}
method to-json(|) {...}

# jsony-unmarshal and json-marshal are here to implement propagation of de-/serialization arguments.

sub jsony-unmarshal($json, Mu \dest-type, *%params) is raw is export {
    with %*WWW-GCLOUD-UNMARSHAL-PARAMS {
        for .kv -> $key, $argv {
            %params{$key} //= $argv;
        }
    }
    {
        my %*WWW-GCLOUD-UNMARSHAL-PARAMS := %params;
        # Re-inject :$warn and :$throw to be used as defaults because if omitted from arguments they wouldn't be in
        # the %params capture.
        return unmarshal($json, dest-type, |%params)
    }
}

sub jsony-marshal(Mu \obj, *%params ) is raw is export {
    with %*WWW-GCLOUD-MARSHAL-PARAMS {
        for .kv -> $key, $argv {
            %params{$key} //= $argv;
        }
    }
    {
        my %*WWW-GCLOUD-MARSHAL-PARAMS := %params;
        # Re-inject parameters to be used as defaults because if omitted from arguments they wouldn't be in
        # the %params capture.
        return marshal(obj, |%params)
    }
}