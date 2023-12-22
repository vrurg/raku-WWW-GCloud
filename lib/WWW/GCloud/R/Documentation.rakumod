use v6.e.PREVIEW;
unit class WWW::GCloud::R::Documentation;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::Page;
use WWW::GCloud::R::DocumentationRule;

also is gc-record;

has Str $.summary;
has WWW::GCloud::R::Page:D @.pages;
has WWW::GCloud::R::DocumentationRule @.rules;
has Str $.documentationRootUrl;
has Str $.serviceRootUrl;
has Str $.overview;