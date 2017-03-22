### `IO::CatPath` and `IO::CatHandle`

**Current Behaviour:**
- `IO::CatPath` and `IO::CatHandle` [have been removed pre-Christmas](https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e) and `IO::ArgFiles` handles the `$*ARGFILES` stuff

**Proposed Change:**
All of the changes are proposed for 6.d. We bring back a generalized version of
what `IO::ArgFiles` currently does: an ability to seamlessly treat multiple
handles as one.

If the idea is approved, more detailed design plan will be drafted first.
Speaking in broad strokes, [in the past implementation](https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e), `IO::CatPath` looks superflous—the implemented methods merely delegate
to `IO::CatHandle` and the unimplemented methods that `IO::Path` has don't
make much sense in `IO::CatPath`—and the fact that `IO::CatHandle` overrides
half of the `IO::Handle` methods to simply throw, suggests there may be
a better design to be discovered.
