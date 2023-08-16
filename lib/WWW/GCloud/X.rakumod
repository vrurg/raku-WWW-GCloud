use v6.e.PREVIEW;
use AttrX::Mooish;
use Cro::HTTP::Response;
use WWW::GCloud::Utils;

module WWW::GCloud::X {

    role Base {
        has $.origin = Nil; # (Type)Object where the exception was originated in

        method message-origin {
            $!origin =:= Nil ?? "" !! instance-or-type($!origin)
        }

        method message-origin-type {
            $!origin =:= Nil ?? "" !! instance-or-type($!origin.WHAT)
        }
    }

    role Core does Base is Exception { }

    class AdHoc does Core {
        has Str:D $.message is required;
        multi method new(Str:D $message) { self.new: :$message }
    }

    class NoAPI does Core {
        has Str:D $.api-name is required;
        method message {
            "No API with name '$!api-name' is registered"
        }
    }

    class Cmd does Core {
        has Proc:D $.proc is required;
        method message {
            "Command '" ~ $!proc.command.join(" ") ~ "' ended with exit code " ~ $!proc.exitcode ~
                |(". The error message was:\n" ~ .slurp(:close).trim.split(/\n/).map("    | " ~ *).join("\n") with $!proc.err)
        }
    }

    class UnknownStdParam does Core {
        has Str:D $.what is required;
        has Str:D $.name is required;
        has Str:D $.method is required;

        method message {
            "Unknown $.what standard parameter '$.name' in WWW::GCloud::QueryParams definition of method $.method"
        }
    }

    class InvalidCotnext does Core {
        has Str:D $.operation is required;
        has Str $.expected;

        method message {
            "Invalid context for " ~ $.operation ~ |(': expected ' ~ $_ with $.expected)
        }
    }

    class NYI does Core {
        has Str:D $.feature is required;
        has Str $.explain;
        method message {
            "The following feature is not implemented yet: " ~ $.feature
                ~ ($.explain andthen ". " ~ $.explain orelse "")
        }
    }

    role Config does Core { }

    my class Config::BadWrapType does Config {
        has Mu $.type is required;
        has Mu $.wrapper is built(:bind);
        has Str:D $.what is required;

        method message {
            ($!wrapper<> =:= Mu
                ?? "Type object '" ~ $!type.^name ~ "'"
                !! "Wrappee type object '{$!type.^name}' of wrapper '" ~ $!wrapper.^name ~ "'")
            ~ " is not " ~ $.what
        }
    }

    role API does Core {
        has Str:D $.api-name is required;
        has Str $.resource;
        has Str $.method;

        method !message-where {
            |("method '" ~  |($_ ~ "." with $.resource) ~ $.method ~ "' of " with $.method)
            ~ "'" ~ $.api-name ~ "' API"
        }
    }

    class NoAlias does Core {
        has Str:D $.alias is required;

        method message {
            "No alias '" ~ $.alias ~ "' is registered by " ~ self.message-origin-type
        }
    }

    # Basically, this one is a replacement for X::Cro::HTTP::Error
    my class API::HTTP does API {
        has Cro::HTTP::Response:D $.response is required;
        has Cro::HTTP::Request $.request is mooish(:lazy);
        # Decoded body with error as in https://cloud.google.com/resource-manager/docs/core_errors.
        # Untyped because it has to be WWW::GCloud::R::Error, but using the module creates a circular dependency.
        has $.error is required;

        method build-request {
            $!response.request;
        }

        method message {
            my $error = $!error.error;
            "=== Google Cloud Error " ~ $error.code ~ " in " ~ self!message-where ~ " ===\n"
                ~ $error.message.indent(2)
                ~ |("\n" ~ $error.errors.map("- " ~ *.message).join("\n").indent(4) if $error.errors)
        }
    }

    my class API::ExtraArgs does API {
        has Str:D @.extra;
        method TWEAK {
            $!method //= "<no-method-name-fix-please>";
        }
        method message {
            my $sfx = @.extra.elems > 1 ?? "s" !! "";
            "Unexpected extra argument$sfx " ~ @.extra.map("'" ~ * ~ "'").join(", ") ~ " in a call to " ~ self!message-where
        }
    }
}

# It is problematic to declare a role named 'IO' within WWW::GCloud::X namespace because it would override the global
# IO:: and whatever the core defines under it (like IO::Path, IO::Handle, etc.) becomes inaccessible.
our role WWW::GCloud::X::IO does X::IO does WWW::GCloud::X::Base { }

my class WWW::GCloud::X::IO::Exists does WWW::GCloud::X::IO {
    has IO::Path:D $.path is required;
    has Str $.suggest;

    method message {
        "Cannot write into '" ~ $.path ~ "' because it already exists"
            ~ ($.suggest andthen '; ' ~ $_)
    }
}
