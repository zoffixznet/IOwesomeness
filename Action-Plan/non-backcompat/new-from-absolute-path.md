## Make `IO::Path.new-from-absolute-path` a private method [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/19)

- [✘] docs
- [✘] roast

**Current behaviour:**
`.new-from-absolute-path` is a public method that, for optimization purposes,
assumes the given path is most definitely an absolute path, and so it by-passes
calls to `.absolute` and `.is-absolute` methods and fills up their cache
directly with what was given to it.

**Proposed behaviour:**

Make this method a private method. Since no checks are performed on the
path, use of this method is dangerous as it gives wildly inaccurate **and
exploitable** results when the path is not infact absolute:
`.is-absolute` always returns `True`; `.absolute` always returns the string
the method was called with; `.perl` does not include `CWD`, so round-tripped
value is **no longer an absolute path** and points to a relative resource,
depending on the `CWD` set at the time of the `EVAL`; and while `.resolve`
resolves to an absolute path, `.cleanup` ends up returning a path
*relative to the `CWD` used at the time of path's creation*:

```bash
$ perl6 -e 'dd IO::Path.new-from-absolute-path("foo").is-absolute'
Bool::True

$ perl6 -e 'dd IO::Path.new-from-absolute-path("foo").absolute'
Str $path = "foo"

$ perl6 -e 'dd IO::Path.new-from-absolute-path("foo")'
"foo".IO(:SPEC(IO::Spec::Unix))

$ perl6 -e 'dd IO::Path.new-from-absolute-path("foo").resolve'
"/foo".IO(:SPEC(IO::Spec::Unix))

$ perl6 -e 'my $p = IO::Path.new-from-absolute-path("foo"); chdir "/tmp"; dd $p.cleanup'
"foo".IO(:SPEC(IO::Spec::Unix),:CWD("/home/zoffix"))
```
