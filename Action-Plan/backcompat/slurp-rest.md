## Rename `IO::Handle.slurp-rest` to just `.slurp`

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

I can surmise the name change in `IO::Handle` and its subclasses was meant to
be indicative that `.slurp-rest` only slurps **from the current file position**.
However, this caveat applies to every single read method in `IO::Handle`:
`.slurp`, `.lines`, `.words`, `.comb`, `.get`, `.getc`, `.getchars`. Yet, all
but `.slurp` do not have `-rest` in their name, as the behaviour is implied.

The longer name is even more absurd in `IO::Pipe`, on which `.seek` cannot be
used.
