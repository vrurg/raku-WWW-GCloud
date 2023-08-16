use v6.e.PREVIEW;
unit role WWW::GCloud::Resource;
# A particular resource of an API

use WWW::GCloud::Object;
use WWW::GCloud::API;

also is WWW::GCloud::Object;

has WWW::GCloud::API $.api is required handles <gcloud>;

# method new(:$api, |c) {
#     note "NEW RESOURCE, with api: ", $api.WHICH, ", is API? ", $api ~~ WWW::GCloud::API;
#     nextsame
# }

# Provide support for exceptions of WWW::GCloud::X::API role
method throw(|c) {
    nextwith :api-name($.api.api-name), :resource(self.resource-name), |c
}

method resource-name { ::?CLASS.^shortname }