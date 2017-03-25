## `:$test` parameter on multiple routines [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/10)

**Affected routines:**
- `IO::Path.chdir` / `&chdir`
- `&indir`
- `&homedir` *(proposed for removal)*
- `&tmpdir` *(proposed for removal)*

**Current behaviour:**

The affected routines take `:$test` parameter as a string (or
`Positional` that's later stringified) of tests to perform on a directory.
It's difficult to remember the correct order and currently it's very easy
to give an argument that will incorrectly report the directory as failing the
test: `chdir "/tmp/", :test<r w>` succeeds, while `:test<rw>` or `:test<w r`>
fail.

**Proposed behaviour:**

It is proposed the `:$test` parameter to be replaced with 4 boolean named
parameters `:$r, :$w, :$x, :$d`, with `:$d` (is it directory) test to be
enabled by default. Usage then becomes:

```perl6
    # BEFORE:
    indir :test<r w x>, '/tmp/foo', { dir.say } # Good
    indir :test<w r x>, '/tmp/foo', { dir.say } # Bad. Wrong order

    # AFTER:
    indir :r:w:x, '/tmp/foo', { dir.say } # Good
    indir :w:r:x, '/tmp/foo', { dir.say } # Still good
    indir :x:r:w, '/tmp/foo', { dir.say } # Still good
```

Note that as part of this change, it is proposed all of the aforementioned
*Affected Routines* default to only using the `:d` test. Doing so will also
resolve [RT#130460](https://rt.perl.org/Ticket/Display.html?id=130460).

To preserve backwards compatibility, the `:$test` parameter will remain for
6.c language and will be removed in 6.d language.
