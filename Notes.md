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
