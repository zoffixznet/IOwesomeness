## Generalize `IO::ArgFiles` into `IO::Cat` [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/11)

**Current Behaviour:**
- `IO::CatPath` and `IO::CatHandle` [have been removed pre-Christmas](https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e) and `IO::ArgFiles` handles the `$*ARGFILES` stuff. Users wishing to read
from multipe files are left to their own devices.

**Proposed Change:**

All of the changes are proposed for 6.d.

We implement `IO::Cat`—a generalized version of what `IO::ArgFiles` currently does: an ability to seamlessly treat multiple filehandles as one, in read-only mode. The current `IO::ArgFiles` is obsoleted by `IO::Cat`, but since
6.d language is additive and to be a bit friedlier with existing code, it is
proposed for `IO::ArgFiles` to remain as simply `IO::ArgFiles is IO::Cat {}`
and for `$*ARGFILES` to contain an `IO::ArgFiles` instance.

An `IO::Cat` `is IO::Handle` and is created via a `.new` method,
that takes a list of `Str`, `IO::Path`, and `IO::Handle` (and
by extension its subclass, `IO::Pipe`) objects. Mixing of types is allowed.
`Str`s get turned into `IO::Path` at `IO::Cat`'s instantiation time.

Any attempt to use any of the write methods or attempting to call `.open`
in write, append, or exclusive modes throws. `.open` in read mode just
returns `self`. `.seek` throws just as on `IO::Pipe`. All of the read methods
operate the same as on a regular `IO::Handle`, going through the handles the
object was instantiated with, opening any `IO::Path`s when their turn arrives.

These are the broad strokes and since this is to be in 6.d, the implementation
can be refined once first draft of it is done.
