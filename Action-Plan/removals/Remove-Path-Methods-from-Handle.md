## Remove `IO::Path` Methods from `IO::Handle`

- [✘] roast
- [✘] docs (partial and inaccurate: only `.e`, `.d`, `.f`, `.s`, `.l`, `.r`, `.w`, `.x` are present and they all refer to "the invocant" rather than
`IO::Handle.path`, suggesting they're a verbatim copy-paste of `IO::Path` docs)

**Affected Routines:**
- `.watch`
- `.chmod`
- `.IO`
- `.e`
- `.d`
- `.f`
- `.s`
- `.l`
- `.r`
- `.w`
- `.x`
- `.modified`
- `.accessed`
- `.changed`
- `.mode`

**Current behaviour:**

The methods delegate to `IO::Handle`'s `$!path` attribute.

**Proposed behaviour:**

Remove all of these methods from `IO::Handle`.

Reasoning:
1) Most of these don't make any sense on subclasses of `IO::Handle`
(`IO::Pipe` and `IO::ArgFiles` or the proposed `IO::Cat`); `.d` doesn't
make sense even on an `IO::Handle` itself, as directories can't be `.open`ed;
`.chmod` affects whether an object is `.open`-able in the first place, so,
amusingly, it's possible to open a file for reading, then `.chmod` it to be
unreadable, and then continue reading from it.
2) The methods are unlikely to be oft-used and so the 5 characters of typing
that they save (see point (3) below) isn't a useful saving.
The usual progression goes from `Str` (a filename) to `IO::Path` (`Str.IO` call)
to `IO::Handle` (`IO::Path.open` call). The point at which the information is
gathered or actions are performed by the affected routines is generally at the
`IO::Path` level, not `IO::Handle` level.
3) All of these *and more* (`IO::Handle` does not provide `.rw`, `.rwx`, or
`.z` methods) are still available via `IO::Path.path` attribute that, for
`IO::Handle`, contains the path of the object the handle is opened on.
Subclasses of `IO::Handle` that don't deal with paths can simply override
*that* method instead of having to override the 15 affected routines.

The removal also cleans up the interface of the proposed `IO::Cat` type, in
which these method do not produce anything useful.
