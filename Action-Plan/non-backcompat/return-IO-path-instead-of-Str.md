## Make all routines that return paths return an `IO::Path` instead of `Str`

**Affected routines:**
- `IO::Path.absolute`
- `IO::Path.relative`

**Current behaviour:**
The routines return a `Str`

**Proposed behaviour:**
Return an `IO::Path` instead, with its `.Str` producing the same `Str` as
currently returned by the routines.

Currently some IO routines return an `IO::Path` and some `Str`. Lack of consistency makes it tricky to remember which returns
which, and leads to superstitious `.IO` methods tacked on by users.

It is proposed all routines that return "a path" return an `IO::Path` object
instead of `Str`. The only exceptions are `$.CWD` and `$.path` attributes of
`IO::Path` (n.b.: `$.CWD` should likely be an `IO::Path`).

Since `IO::Path` is `Cool`, it will still stringify and
maintain the old `Str` behaviour. The only backwards-compatibility issue this
change would present is in explicit type check (e.g.
`my Str $x = ".".IO.absolute` would now throw). If this is unacceptable, then it
is to be implemented under 6.d.PREVIEW pragma. If any changes break 6.c-errata
tests, the changes will be made in 6.d language instead.

**Additional notes for individual routines:**

- `IO::Path.relative` and `$*SPEC.abs2rel` return a `Str` that only works for
the `CWD` used when the `Str` was generated. Any later `&chdir` calls will make
its value wrong, whereas if an `IO::Path` object were returned, it wouldn't be
affected.
