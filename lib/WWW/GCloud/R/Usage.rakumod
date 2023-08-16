use v6.e.PREVIEW;
unit class WWW::GCloud::R::Usage;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::UsageRule;
use WWW::GCloud::R::ServiceIdentity;

also is gc-record;

has Str:D @.requirements;
has WWW::GCloud::R::UsageRule:D @.rules;
has Str $.producerNotificationChannel is mooish(:alias<producer-notification-channel>);
has WWW::GCloud::R::ServiceIdentity $.serviceIdentity is mooish(:alias<service-identity>);