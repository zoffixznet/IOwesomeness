## Make `IO::Path.is-absolute` Give False for `/` path on Windows

- [✔️] docs (but not the information that `/` is absolute on Windows)
- [✔️] roast

**Current behaviour:**
`'/'.IO.is-absolute.say` returns `True`, despite the path lacking a drive.

Currently, this behaviour is explicitly tested by 6.c-errata roast.

**Proposed behaviour:**

Make `IO::Path.is-absolute` return `False` for `/` (and `\\`) on Windows, as
the path is still dependent on the CWD associated with the path. Moreover,
calling `.absolute` on such a path prepends the drive letter, which is an
odd thing to do for a path that was already claimed to be absolute
by the `.is-absolute` method.
