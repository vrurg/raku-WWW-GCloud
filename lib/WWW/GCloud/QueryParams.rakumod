use v6.e.PREVIEW;
unit role WWW::GCloud::QueryParams;

use MONKEY-SEE-NO-EVAL;

use AttrX::Mooish;
use WWW::GCloud::X;
use WWW::GCloud::Utils :kebabify;

my constant @storage-std-params =
    'Str :$alt', 'Str :$fields', 'Str :quota-user(:$quotaUser)', 'Str :user-project(:$userProject)';
my constant @storage-std-pvars = <$alt $fields $quotaUser $userProject>;

my constant %std-header-params =
    x-allowed-resources => [ 'X-Goog-Allowed-Resources', Str ],
    x-content-length-range => [ 'X-Goog-Content-Length-Range', Str ],
    x-encryption-algorithm => [ 'X-Goog-Encryption-Algorithm', Str ],
    x-encryption-key => [ 'X-Goog-Encryption-Key', Str ],
    x-encryption-key-sha256 => [ 'X-Goog-Encryption-Key-Sha256', Str ],
    x-copy-source-encryption-algorithm => [ 'X-Goog-Copy-Source-Encryption-Algorithm', Str ],
    x-copy-source-encryption-key => [ 'X-Goog-Copy-Source-Encryption-Key', Str ],
    x-copy-source-encryption-key-sha256 => [ 'X-Goog-Copy-Source-Encryption-Key-Sha256', Str ],
    x-stored-content-encoding => [ 'X-Goog-Stored-Content-Encoding', Str ],
    x-stored-content-length => [ 'X-Goog-Stored-Content-Length', Int ],
    x-user-project => [ 'X-Goog-User-Project', Str ];

my sub make-param(Mu \type, Str:D $pname) {
    type.raku
        ~ ' '
        ~ (kebabify-name($pname)
            andthen ':' ~ $_ ~ '(:$' ~ $pname ~ ')'
            orelse ':$' ~ $pname)
}

my role GCApiMethod {
    has %.query-params;
    has %.header-params;
    has &.validator is mooish(:lazy);

    method gcapi-set-params(%!query-params, %!header-params) {}

    method build-validator {
        my @params;
        my @results;

        # Prepare %query
        my $qbody = '';
        if %!query-params -> %qparams {
            my @qset;

            for %qparams.pairs -> (:$key, Mu :value($type)) {
                my sub qv-set($var) {
                    '|(:' ~ $var ~ ' with ' ~ $var ~ ')'
                }

                if $key eq 'STD-PARAMS' {
                    # note "QUERY STD-PARAMS is ", %qparams<STD-PARAMS>;
                    if %qparams<STD-PARAMS> {
                        @params.push: |@storage-std-params;
                        @qset.push: |@storage-std-pvars.map(&qv-set);
                    }
                }
                else {
                    # note "QUERY PARAM: ", $key;
                    @qset.push: qv-set('$' ~ $key);
                    @params.push: make-param($type, $key)
                }
            }

            if @qset {
                $qbody = ' my %query := %(' ~ @qset.join(", ") ~ ',);';
                @results.push: ':%query';
            }
        }

        # Prepare @headers
        my $hbody = '';
        if %!header-params -> %hparams {
            my @hset;
            my @hdefs = %hparams.keys.map({
                if $^key eq 'STD-PARAMS' {
                    (my $std = %hparams<STD-PARAMS>) === True
                        ?? |%std-header-params.pairs
                        !! |( $std.List.map({
                                WWW::GCloud::X::UnknownStdParam.new(:what<header>, :name($^std-key), :method($*GCAPI-CALLER-NAME)).throw
                                    unless %std-header-params.EXISTS-KEY($std-key);
                                %std-header-params{$std-key}:p
                            }) )
                }
                else {
                    %hparams{$key}:p
                }
            });

            for @hdefs -> (:$key, :value(@spec)) {
                @hset.push: '(' ~ @spec[0] ~ ' => $_ with $' ~ $key ~ ')';
                @params.push: make-param(@spec[1], $key);
            }

            if @hset {
                $hbody = ' my @headers := (' ~ @hset.join(", ") ~ ',);';
                @results.push: ':@headers';
            }
        }

        # Ready to finalize method code
        my $code-src =
            'anon method (&code, ' ~ @params.join(", ") ~ ', *%extra ) is raw {' ~ "\n"
            ~ ' if %extra { self.throw: WWW::GCloud::X::API::ExtraArgs, :method<' ~ $*GCAPI-CALLER-NAME ~ '>, :extra(%extra.keys) };' ~ "\n"
            ~ $qbody ~ "\n"
            ~ $hbody ~ "\n"
            ~ ' &code(' ~ @results.join(", ") ~ ")\n"
            ~ "}";

        EVAL($code-src, context => $*GCAPI-CALLER-LEXICAL)<>
    }
}

method gc-validate-args(&code, *%c) {
    my $level = 1;
    my $ctx = CALLER::;
    my $cf;

    while $cf = callframe($level) {
        last if $cf.code ~~ GCApiMethod;
        $ctx = $ctx<CALLER>.WHO;
        ++$level;
    }

    WWW::GCloud::X::InvalidCotnext.new(
        :operation<gc-validate-args>, :expected('a method with gc-params trait applied')).throw without $cf;

    my $*GCAPI-CALLER-LEXICAL := $ctx<LEXICAL>.WHO;
    my $*GCAPI-CALLER-NAME := $cf.code.name;

    $cf.code.validator.(self, &code, |%c)
}

BEGIN {
    multi sub trait_mod:<is>( Method:D \meth,
                              Hash:D() :gc-params($)! (Hash() :$query = %(), Hash() :headers(:$header) = %())
                            ) is export
    {
        meth does GCApiMethod unless meth ~~ GCApiMethod;

        meth.gcapi-set-params: $query, $header
    }
}