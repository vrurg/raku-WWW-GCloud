use v6.e.PREVIEW;
unit class WWW::GCloud::R::Projects;

use WWW::GCloud::Record;
use WWW::GCloud::R::Project;

also is gc-record(:paginating(WWW::GCloud::R::Project, "projects"));