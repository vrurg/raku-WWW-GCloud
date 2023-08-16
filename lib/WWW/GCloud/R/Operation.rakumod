use v6.e.PREVIEW;
# https://cloud.google.com/resource-manager/reference/rest/Shared.Types/Operation
unit class WWW::GCloud::R::Operation;

use WWW::GCloud::Record;
use WWW::GCloud::R::Status;

also is gc-record;

has Str $.name;
has %.metadata;
has Bool $.done;
has WWW::GCloud::R::Status $.error;
has %.response;