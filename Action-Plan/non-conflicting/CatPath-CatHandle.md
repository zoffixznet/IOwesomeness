### `IO::CatPath` and `IO::CatHandle`

**Current Behaviour:**
- `IO::CatPath` and `IO::CatHandle` [have been removed pre-Christmas](https://github.com/rakudo/rakudo/commit/a28270f009e15baa04ce76e) and `IO::ArgFiles` handles the `$*ARGFILES` stuff

**Proposed Change:**
All of the changes are proposed for 6.d. We bring back the two classes as
a generalized version of what `IO::ArgFiles` currently does. If the idea
is approved, more detailed design plan will be drafted first.
