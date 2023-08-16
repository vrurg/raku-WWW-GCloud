use v6.e.PREVIEW;
unit class WWW::GCloud::API::ServiceUsage;

use AttrX::Mooish;
use WWW::GCloud::API;
use WWW::GCloud::Resource;
use WWW::GCloud::R::Operations;
use WWW::GCloud::R::Services;

class Operations {...}

also does WWW::GCloud::API['service-usage', resources => %( operations-a => Operations, )];

### API Resource Classes ###

class Operations does WWW::GCloud::Resource {
    method list( ::?CLASS:D: Str:D :$users, Str :$filter, *%c --> Supply:D ) {
        my $api-path = $users ~ "/" ~ 'operations';
        my %query = |(:$filter with $filter);
        $.api.paginate: "get", $api-path, |%c, as => WWW::GCloud::R::Operations, :%query
    }
}

class Services does WWW::GCloud::Resource {
    method list( ::?CLASS:D: Str:D :$parent, Str :$filter, *%c --> Supply:D ) {
        my $api-path = |($_ ~ "/" with $parent) ~ "services";
        my %query = |(:$filter with $filter);
        $.api.paginate: "get", $api-path, |%c, as => WWW::GCloud::R::Services, :%query
    }
}

### Attributes And Methods ###

has Str:D $.base-url = 'https://serviceusage.googleapis.com/v1';

has Operations:D $.operations is mooish(:lazy);
has Services:D   $.services   is mooish(:lazy);

method build-operations {
    Operations.new: api => self
}

method build-services {
    Services.new: api => self
}