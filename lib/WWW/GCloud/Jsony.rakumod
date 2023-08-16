use v6.e.PREVIEW;
unit role WWW::GCloud::Jsony;

use JSON::Marshal;
use JSON::Unmarshal:ver<0.15>:auth<zef:raku-community-modules>;

method from-json($json, Bool :$warn = True, Bool :die(:$throw) = False --> ::?CLASS) {
    my \dest-type = $*WWW-GCLOUD-CONFIG.type-from(self.WHAT);
    unmarshal $json, dest-type, :$warn, :$throw, :opt-in
}

method to-json(Bool:D :$skip-null = True, Bool:D :$sorted-keys = False, Bool:D :$pretty = False --> Str) {
    marshal(self, :$skip-null, :$sorted-keys, :$pretty, :opt-in)
}