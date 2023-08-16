use v6.e.PREVIEW;
unit class WWW::GCloud::R::Authentication;

use WWW::GCloud::Record;
use WWW::GCloud::R::AuthenticationRule;
use WWW::GCloud::R::AuthProvider;

also is gc-record;


has WWW::GCloud::R::AuthenticationRule:D @.rules;
has WWW::GCloud::R::AuthProvider:D @.providers;