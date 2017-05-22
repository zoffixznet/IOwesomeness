    method spurt(IO::Path:D: $data, :$enc = 'utf8', :$append, :$createonly) {
        self.open(
            :$enc,     :bin(nqp::istype($data, Blob)),
            :mode<wo>, :create, :exclusive($createonly), :$append,
        ).spurt($data, :close);
    }


    proto sub spurt(|) { * }
    multi sub spurt(IO() $path, |c) { $path.spurt(|c) }



    proto method spurt(|) { * }
    multi method spurt(IO::Handle:D: Blob $contents, :$close) {
        LEAVE self.close if $close;
        self.write($contents);
    }
    multi method spurt(IO::Handle:D: Cool $contents, :$close) {
        LEAVE self.close if $close;
        self.print($contents);
    }






    method spurt(IO::Path:D:
        $contents, :$enc, :$bin, :$append, :$createonly, |c
    ) {
        self.open(
            |(:$enc if $enc), :$bin,
            |($createonly ?? :x !! $append ?? :a !! :w), |c
        ).spurt($contents, :close);
    }


CatHandle all methods and attributes:

$.path;
$.chomp is rw = Bool::True;
$.nl-in = ["\x0A", "\r\n"];
$.nl-out is rw = "\n";
$.encoding = 'utf8';

close
comb
DESTROY
encoding
eof
flush
get
getc
gist
IO
lines
lock
native-descriptor
nl-in
open
opened
path
print
printf
print-nl
put
read
readchars
seek
slurp
slurp-rest
split
Str
Supply
t
tell
unlock
words
write
