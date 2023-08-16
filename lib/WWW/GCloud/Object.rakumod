use v6.e.PREVIEW;
unit class WWW::GCloud::Object;

use WWW::GCloud::X;

proto method throw(|) {*}
multi method throw(WWW::GCloud::X::Base:U \ex, |ex-args) {
    ex.new(|ex-args, :origin(self)).throw
}
multi method throw(WWW::GCloud::X::Base:D \ex, |ex-args) {
    ex.clone(|ex-args, :origin(self)).throw
}

method die(*@pos) {
    self.throw: WWW::GCloud::X::AdHoc, message => @pos.map(*.gist).join
}