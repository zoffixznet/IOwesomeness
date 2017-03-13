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
