## Make `IO::Path.Str` Return `$.abspath`

**Current behaviour:**
- `.Str` method uses the value of `$!path` attriubte and does NOT take the
object's `$!CWD` into consideration. Thus, creating a relative
`IO::Path` object, then `chdir`-ing somewhere, and then `.Str`-ing it will
give an incorrect path.

**Proposed behaviour:**

Use `$.abspath` instead. The `.Str`-ingified path will be always absolute.
