Check out IO::CatPath and IO::CatHandle in:
https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e
Should be very desirable.


--- Remove IO::Path.lines($limit). It's useless, people can just use [^$limit]

--- Fix all the broken .split, .words, etc routines. They take only SOME of the args and there's no guarantee the handle would get closed either.


perl6.vip
