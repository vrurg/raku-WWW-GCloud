use v6.e.PREVIEW;
unit role WWW::GCloud::Aliasing;

use WWW::GCloud::X;

::?CLASS.HOW does my role AliasingHOW {
    has $!aliases;

    method add-alias(Mu, Str:D $alias, Str:D $orig) {
        $!aliases //= %();
        $!aliases{$alias} := $orig;
    }

    method add-aliases(Mu, Iterable:D \aliases) {
        $!aliases //= %();
        for aliases -> Pair:D $alias {
            $!aliases{$alias.key} := $alias.value;
        }
    }

    method unalias(Mu, Str:D $alias) {
        $!aliases andthen .{$alias} orelse Nil
    }
}

method throw(WWW::GCloud::X::Base, |) {...}

method add-aliases(Iterable:D \aliases) { self.^add-aliases(aliases) }

proto method add-alias(|) {*}
multi method add-alias(Pair:D $ (Str:D :key($alias), Str:D :value($orig))) { self.^add-alias($alias, $orig) }
multi method add-alias(Str:D $alias, Str:D $orig) { self.^add-alias($alias, $orig) }
multi method add-alias(*%aliases) { self.^add-aliases(%aliases) }

method unalias(Str:D $alias, Bool :$strict) {
    my $orig = ::?CLASS.^unalias($alias);
    $orig // do {
        self.throw: WWW::GCloud::X::NoAlias, :$alias if $strict;
        $alias
    }
}