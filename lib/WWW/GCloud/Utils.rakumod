use v6.e.PREVIEW;
unit module WWW::GCloud::Utils;
use nqp;
use AttrX::Mooish;
use Crypt::Random::Extra;
use MIME::Types;

sub instance-or-type(Mu \obj) is export {
    (nqp::isconcrete(nqp::decont(obj)) ?? "an instance of" !! "type object") ~ " '" ~ obj.^name ~ "'"
}

our sub kebabify-name(Str:D $name is copy) is export(:kebabify) {
    $name ~~ s:g/<lower> <upper> | $<lower>="" _ $<upper>=""/$<lower>-$<upper>/
        ?? $name.lc
        !! Nil
}

our sub kebabify-attr(Attribute:D $attr) is export(:kebabify) {
    with kebabify-name($attr.name.substr(2)) {
        &trait_mod:<is>($attr, :mooish(:alias($_)))
            unless $attr.package.^can($_);
    }
}

sub gen-mime-boundary(Str:D $prefix="gcld") is export {
    "$prefix=_" ~ crypt_random_UUIDv4
}

sub maybe-nominalize(Mu \type --> Mu) is raw is export {
    type.HOW.archetypes.nominalizable ?? type.^nominalize !! type.WHAT
}

{
    my $pkg-cache = my Mu %;
    my $rlock = Lock.new;

    sub resolve-package(Str:D $pkg) is raw is export {
        my $cache := ⚛$pkg-cache;
        return $cache{$pkg} if $cache.EXISTS-KEY($pkg);

        my Mu $resolved;
        $rlock.protect: {
            $resolved := do require ::($pkg);
        }

        loop {
            # The symbol has been added by another thread already
            last if ($cache := ⚛$pkg-cache).EXISTS-KEY($pkg);
            # Otherwise create a copy of the old cache, place the symbol into the new copy and try atomically replace
            # the main package cache.
            my $new-cache = $cache.clone;
            $new-cache.BIND-KEY($pkg, $resolved);
            last if cas($pkg-cache, $cache, $new-cache) === $cache;
        }

        $resolved
    }
}

{
    my $mime-types;
    my Lock $mt-lock .= new;

    sub mime-type(IO:D() $file) is export {
        $mt-lock.protect: {
            ($mime-types //= MIME::Types.new).type($file.extension)
        }
    }
}