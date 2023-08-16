use v6.e.PREVIEW;
# https://cloud.google.com/resource-manager/docs/core_errors
unit class WWW::GCloud::R::Error;

use WWW::GCloud::R::ErrMsg;
use WWW::GCloud::Record;

also is gc-record;


my class ErrRec is gc-record {
    has WWW::GCloud::R::ErrMsg:D @.errors;
    has Int $.code is required;
    has Str $.message is required;
    # This is just a name for $.code
    has Str $.status;
    has @.details;
}

has ErrRec:D $.error is required;