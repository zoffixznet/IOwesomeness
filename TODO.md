Check out IO::CatPath and IO::CatHandle in:
https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e
Should be very desirable.


--- Remove IO::Path.lines($limit). It's useless, people can just use [^$limit]

--- Fix all the broken .split, .words, etc routines. They take only SOME of the args and there's no guarantee the handle would get closed either.

--- Ensure all routines fail with `X::IO::*` exceptions, not AdHocs


--- Every new IO::Path gets `$*CWD` as IO::Path, which it then coerces to Str.
Can we keep it as IO::Path always instead?


--- .Str of an IO path does not consider its `$*CWD`, so
`my $p = "bar".IO; chdir ".."; $p.slurp.say` still works, but
`my $p = "bar".IO; chdir ".."; $p.Str.IO.slurp.say` doesn't.


--- Some sort of a bug when trying to read a sparsefile in bin mode:
`dd of=file bs=1 seek=100000000 count=0; perl6 -e '"file".IO.slurp(:bin)`


-- Document that .lines, .words, etc. on an `IO::Handle` move the current
position in the file and using more than one at the same time will end in tears.

--- Document `.Supply`'s read mode stays the same even if `.encoding` changes.


--- ugexe │ i think IO::Huh was meant to allow something like IO::File.new(uri => ...) to work, which intended to let you supply your own reader/writer

--- ugexe │ the other IO thing i'd really like to see is IO::Socket to be IO::Handle or at least an IO interface for dealing with a a file handle *or* socket data


--- old map: 205 routines; 107 unique names; new map
             220 routines; 112 unique names (+15; +5)
