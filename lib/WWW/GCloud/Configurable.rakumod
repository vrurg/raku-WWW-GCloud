use v6.e.PREVIEW;
use WWW::GCloud::Config;
unit role WWW::GCloud::Configurable[::CFG-TYPE WWW::GCloud::Config $?];

use AttrX::Mooish;

has CFG-TYPE:D $.config
    handles<gc-ctx gc-ctx-wrap gc-context gc-context-wrap>
    = $*WWW-GCLOUD-CONFIG // $*JSON-CLASS-CONFIG // self.gc-new-config;

method gc-new-config(*%c) {
    CFG-TYPE.new(:!pretty, :!sorted-keys, :skip-null, :enums-as-value, |%c)
}

# BEGIN {
#     multi sub trait_mod:<is>(Method:D \meth, Bool:D :$gc-ctx!) is export {
#         meth.wrap: anon method (|) {
#             note "CTX WRAPPER FOR ", meth.name;
#             my $*JSON-CLASS-CONFIG :=
#             # my $*WWW-GCLOUD-CONFIG := self.config<>;
#             note "---> callsame?";
#             LEAVE note "WRAPPER IS DONE";
#             callsame
#         }
#     }
# }