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

-- IO::Pipe.t causes a segfault:

--- - check that .close flushes

-----------------------------------------------------------------

Pre-Flight:

- Sort out typing on IO::Path's $!CWD, $!path and IO::Handle's $!path

--- Figure out a better way to pass flags to IO::Handle.lock() https://github.com/MoarVM/MoarVM/blob/a8448142d8b49a742a6b167907736d0ebbae9779/src/io/syncfile.c#L303-L358
