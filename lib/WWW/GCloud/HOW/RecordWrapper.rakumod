use v6.e.PREVIEW;
unit role WWW::GCloud::HOW::RecordWrapper;

has Mu $!wrappee;

method gc-set-wrappee(Mu \obj, Mu:U $!wrappee --> Nil) {
    self.add_parent(obj, $!wrappee);
}
method gc-wrappee(Mu \obj) is raw { $!wrappee }