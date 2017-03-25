## Make `IO::Path.Str` Return `$.abspath` [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/20)

**Current behaviour:**
- `.Str` method uses the value of `$!path` attribute and does NOT take the
object's `$!CWD` into consideration. Thus, creating a relative
`IO::Path` object, then `chdir`-ing somewhere, and then `.Str`-ing it will
give an incorrect path.

**Proposed behaviour:**

Use `$.abspath` instead. The `.Str`-ingified path will be always absolute.
The user still has `$.path` attribute along with `.relative` method to stringify
a path as a relative path, making it sensitive to `$*CWD`, if they so require.
