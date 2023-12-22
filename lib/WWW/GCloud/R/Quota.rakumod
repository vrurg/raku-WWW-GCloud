use v6.e.PREVIEW;
unit class WWW::GCloud::R::Quota;

use AttrX::Mooish;
use WWW::GCloud::Record;
use WWW::GCloud::R::QuotaLimit;
use WWW::GCloud::R::MetricRule;

also is gc-record;

has WWW::GCloud::R::QuotaLimit:D @.limits;
has WWW::GCloud::R::MetricRule:D @.metricRules;