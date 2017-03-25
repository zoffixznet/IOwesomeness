## Rename `IO::Handle.slurp-rest` to just `.slurp` [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/9)

- [✔️] docs
- [✔️] roast

**Current behaviour**:

There are thematically related routines: `comb` (all the characters),
`words` (all the words), `lines` (all the lines), and `slurp` (all the stuff).
All but the last are present as subroutines and as methods on `IO::Path`,
`IO::ArgFiles`, `IO::Path`, and `IO::Pipe`.

With respect to `&slurp`, there is sub `&slurp` and method `.slurp` on `IO::Path` and `IO::ArgFiles`. The `IO::Handle` and `IO::Pipe` name it
`.slurp-rest` instead. Since `IO::ArgFiles is IO::Handle`, it also has a
`.slurp-rest`, but it's broken and unusable.

**Proposed change**:

Rename `.slurp-rest` to just `.slurp` in 6.d language and make use of
`.slurp-rest` issue a deprecation warning.

I can surmise the alternate name in `IO::Handle` and its subclasses was meant to
be indicative that `.slurp-rest` only slurps **from the current file position**.
However, this caveat applies to every single read method in `IO::Handle`:
`.slurp`, `.lines`, `.words`, `.comb`, `.get`, `.getc`, `.getchars`. Yet, all
but `.slurp` do not have `-rest` in their name, as the behaviour is implied.
In fact, `Seq`-returning methods even interact with each other when called
on the same handle, as the file position being advanced by one iterator affects
what the next item in another `Seq` will be. Thus, knowledge about the effect of
file position on all of these methods is *essential,* and so requiring all users
to use a longer name as a reminder lest they forget about this behaviour
in slurps is antisocial.

The longer name is even more bizarre in `IO::Pipe`, on which `.seek` cannot be
used.
