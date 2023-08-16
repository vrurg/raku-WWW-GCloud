use v6.e.PREVIEW;
unit role WWW::GCloud::HOW::APIRegistry;

use WWW::GCloud::X;

has $!api-classes;

method register-API(Mu \obj, Mu:U \api-class, Str:D $name) {
    $!api-classes := %() without $!api-classes;

    warn "Re-registering Google Cloud '" ~ $name ~ "' API"  if $!api-classes{$name}:exists;

    $!api-classes{$name} := api-class;

    my &get-API-method = anon method { self.get-API-object($name) };
    &get-API-method.set_name($name);
    self.add_method(obj, $name, &get-API-method);
    self.compose(obj) if self.is_composed(obj);
}

method API-class(Mu \obj, Str:D $api-name --> Mu:U) is raw {
    WWW::GCloud::X::NoAPI.new(:$api-name).throw unless ($!api-classes andthen .{$api-name}:exists);
    $!api-classes{$api-name}
}