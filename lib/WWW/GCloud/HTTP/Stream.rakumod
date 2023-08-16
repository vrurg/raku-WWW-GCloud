use v6.e.PREVIEW;
unit role WWW::GCloud::HTTP::Stream;

use AttrX::Mooish;
use WWW::GCloud::X;

method header(|) {...}
method body-byte-stream {...}

has UInt $.length is mooish(:lazy, :alias<size Size>);

method build-length {
    self.header('Content-Length')
        andthen .Int
        orelse Nil
}

my class SendMsg {
    has $.response is required;
    has Int:D $.total-sent is required;
    has Int:D $.total-received is required;
    has Int:D $.last-buf-size is required;
}

proto method send-to(|) {*}

multi method send-to(IO() $path, Bool :$overwrite, |c) {
    if $path.e && !$overwrite {
        WWW::GCloud::X::IO::Exists.new(
                    :$path,
                    :suggest('consider removing it first or use :overwrite if this is what you want') ).throw
    }
    self.send-to: $path.open(:mode<wo>, :create), |c
}

multi method send-to( ::?CLASS:D:
                      IO::Handle:D $dest,
                      UInt:D :$out-buffer = 65536,
                      UInt:D :$report-every = 1024,
                      Bool:D :$close = False )
{
    my Supplier $ev-supplier .= new;
    my Buf[uint8] $buffer .= new;
    my Int $total-sent = 0;
    my Int $total-received = 0;
    my Int $last-buf-size = 0;
    my Int $last-reported = 0;

    my sub emit-msg {
        # Prevent double-reporting when stream ends.
        return if $total-received > 0 && $last-reported == $total-received;
        $ev-supplier.emit: SendMsg.new(:response(self), :$total-sent, :$total-received, :$last-buf-size);
        $last-reported = $total-received;
    }


    (start {
        emit-msg;
        react whenever self.body-byte-stream {
            my $buf-size = $buffer.append($_).bytes;

            $total-received += .bytes;

            my sub flush-buf(:$last) {
                $dest.write($buffer);
                $total-sent += ($last-buf-size = $buf-size);

                if $last {
                    emit-msg;
                    $buffer = Nil;
                    $dest.close if $close;
                    $ev-supplier.done;
                }
                else {
                    $buffer .= new;
                }
            }

            flush-buf if $buf-size >= $out-buffer;
            emit-msg  if ($total-received - $last-reported) >= $report-every;

            CATCH {
                default { $ev-supplier.quit($_); done }
            }
            QUIT { $ev-supplier.quit($_) }
            LAST flush-buf(:last);
        }
    }).orelse({ $ev-supplier.quit(.cause) }); # Last resort for any accidentally lost exception

    $ev-supplier.Supply
}

method Supply { self.body-byte-stream }