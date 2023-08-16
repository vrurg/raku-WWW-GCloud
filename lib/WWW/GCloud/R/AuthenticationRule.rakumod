use v6.e.PREVIEW;
unit class WWW::GCloud::R::AuthenticationRule;

use WWW::GCloud::Record;
use WWW::GCloud::R::OAuthRequirements;
use WWW::GCloud::R::AuthRequirement;

also is gc-record;


has Str $.selector;
has WWW::GCloud::R::OAuthRequirements $.oauth;
has Bool $.allowWithoutCredential;
has WWW::GCloud::R::AuthRequirement:D @.requirements;