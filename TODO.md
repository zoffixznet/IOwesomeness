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


--- cpan@perlbuild2~/CPANPRC/rakudo (nom)$ ./perl6 -e 'shell(:out, "yes 2>/dev/null | head -n 10000").out.IO::Handle::lines; say now - INIT now'                                                                                                                   
Cannot seek this kind of handle
  in block <unit> at -e line 1


cpan@perlbuild2~/CPANPRC/rakudo (nom)$ ./perl6 -e '$ = shell(:out, "yes 2>/dev/null | head -n 100000").out.lines; say now - INIT now'
0.0066377
head: error writing ‘standard output’: Connection reset by peer
cpan@perlbuild2~/CPANPRC/rakudo (nom)$ ./perl6 -e '$ = shell(:out, "yes 2>/dev/null | head -n 100000").out.IO::Handle.lines; say now - INIT now'
No concretization found for IO
  in block <unit> at -e line 1

head: error writing ‘standard output’: Connection reset by peer
cpan@perlbuild2~/CPANPRC/rakudo (nom)$
