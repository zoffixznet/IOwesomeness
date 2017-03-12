# IO Action Plan

This document is a deliverable of [TPF Standardization, Test Coverage, and
Documentation of Perl 6 I/O Routines
grant](http://news.perlfoundation.org/2017/01/grant-proposal-standardization.html)
and describes the proposed changes to the implementations of Rakudo's IO
routines.

**Each topic has an `[Issue for discussion]` link in the title that points to
a GitHub Issue where the topic can be discussed.**

---------------

## Terms and Conventions

- `routines` — means both subroutines and methods (as both are `Routine` types)
- `IO::Handle.seek` / `.seek` — all method names are referenced with a `.`
before their name, which is optionally preceded by the type.
- `&seek` — all subroutine names are referenced with a `&` before their name.

## Legend

Some sections are marked as, e.g.:

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

This indicates whether the proposed change affects something that is (`[✔️]`) or
isn't (`[✘]`) documented on [docs.perl6.org](https://docs.perl6.org),
tested in [master branch of roast](https://github.com/perl6/roast), or tested in
[6.c-errata branch of roast](https://github.com/perl6/roast/tree/6.c-errata).
Just `[✘] roast` means both `master` and `6.c-errata` branches.


------------------------------
------------------------------

## Removals

The changes in this section propose the immediate removal of routines, with
no deprecation period.


------------------------------

### `&homedir`

- [✘] docs
- [✘] roast

Saves typing half a single line of code and is rarely needed.
The user will set `$*HOME` variable directly, using `my ...` to
localize the effects, and using `.= chdir` if any directory tests need to be
done.


------------------------------

### `&tmpdir`

- [✘] docs
- [✘] roast
- [✘] routine is broken and never worked since Christmas

Saves typing half a single line of code and is rarely needed.
The user will set `$*TMPDIR` variable directly, using `my ...` to
localize the effects, and using `.= chdir` if any directory tests need to be
done.


------------------------------
------------------------------

## Changes with No Backwards-Compatible Support

The changes in this section propose for an immediate change of behaviour,
without providing any backwards compatible support.


------------------------------

## Make all routines that return paths return an `IO::Path` instead of `Str`

**Affected routines:**
- `IO::Path.absolute`

**Current behaviour:**
The routine returns a `Str`

**Proposed behaviour:**
Return an `IO::Path` instead. Currently some IO routines return an `IO::Path`
and some `Str`. Lack of consistency makes it tricky to remember which returns
which, and leads to superstitious `.IO` methods tacked on by users.

It is proposed all routines that return "a path" return an `IO::Path` object
instead of `Str`. Since `IO::Path` is `Cool`, it will still stringify and
maintain the old `Str` behaviour. The only backwards-compatibility issue this
change would present is in explicit type check (e.g.
`my Str $x = ".".IO.absolute` would now throw). If this is unacceptable, then it
is to be implemented under 6.d.PREVIEW pragma. If any changes break 6.c-errata
tests, the changes will be made in 6.d language instead.


------------------------------
------------------------------

## Changes with Backwards-Compatible Support

The changes proposed in this section allow for retention of old behaviour.
It is proposed the use of old behaviour is made to issue a deprecation warning
(in 6.c language) and for it to be removed entirely in 6.d language.

Note: since our current infrastructure for 6.d language is **additive,** the
behaviour proposed for removal in 6.d might not end up actually being removed
from the code, but instead marked as deprecated with warnings/exceptions issued
on use (and appropriately documented as being obsolete).


------------------------------

### `IO::Handle.seek` seek reference [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/1)

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

**Current behaviour**:
- The seek reference is taken as an enum which is globally available and is
somewhat long to type: `SeekFromBeginning`, `SeekFromCurrent`, `SeekFromEnd`.
`.seek` is nearly unique in using such a calling convention.

**Proposed change**:
- Use mutually exclusive named arguments instead: `:from-start`,
`:from-current`, and `:from-end`. The old enums will be kept in 6.c language and
will be removed in 6.d.


------------------------------

### `:$test` parameter on multiple routines

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


------------------------------
------------------------------

## Non-Conflicting Improvements

The changes proposed in this section do not change current behaviour and merely
enhance it or add new, non-conflicting features.


------------------------------

### `IO::Handle`'s Closed status

**Current Behaviour:**
- When a IO::Handle is closed, its $!PIO atribute is set to nqp::null. This
causes calls to many methods on a closed file handle to return LTA error,
such as `foo requires an object with REPR MVMOSHandle`.

**Proposed Change:**
- On handle close, mixin a role that overrides all the relevant methods
to throw/fail with an error. This will give the same behaviour as adding
`if nqp::isnull($!PIO) { ... throw ... }` to all the methods, without a
performance impact to open handles (it was ~5% when such check was added to
`.lines` iterator)


------------------------------

### `IO::Path` routines that involve a stat call

**Routine List:**

`.d`, `.f`, `.l`, `.r`, `.s`, `.w`, `.x`, `.z`, `.rw`, `.rwx`, `.modified`, `.accessed`, `.changed`, `.mode`

**Current Behaviour:**
Each test goes out to VM to perform several `stat` calls (other than `.e` that
performs just one). For example, a single `.rwx` call performs 4 `stat` calls.
Based on IRC conversation, `stat` call is expensive and caching its results
can be beneficial.

**Proposed Change:**
Change `nqp::const::STAT*` constants to be powers of 2. Add
`nqp::stat_multi` op that will take bitwise-ORed `nqp::const::STAT*` constants
representing the pieces of stat information to be returned as a hash. This
will let us perform a single stat call to fetch all of the required information.

(related discussion: https://irclog.perlgeek.de/perl6-dev/2017-03-06#i_14213924)


------------------------------

### `IO::Path.extension`

It's not uncommon to see users asking on IRC how to
obtain or modify an extension of a path. Depending on what is needed, the answer
is usually a gnarly-looking `.subst` or `.split`+`.join` invocation. In
addition, often the desired extension for files like `foo.tar.gz` would be
`tar.gz`, yet the current `.extension` does not offer a means to obtain it.

The following changes are proposed:

- Add `:$parts = 1` named parameter that specifies how many parts (the
    `.whatever` segments, counting from end) to consider as the extension.
    That is `'foo.tar.gz'.IO.extension` returns `'gz'`,
    `'foo.tar.gz'.IO.extension: :2parts` returns `'tar.gz'`, and
    `'foo.tar.gz'.IO.extension: :3parts` returns `''` (signaling there is no
        [3-part] extension on the file).

    In the future we can extend this to take a `Range` or `Junction` of values,
    but for now, just a single `UInt` should be sufficient. The default value
    of `1` preserves the current behaviour of the routine. Value of `0` always
    makes routine return an empty string.
- Add a candidate that accepts a positional `$replacement` argument. This
    candidate will return a new `IO::Path` object, with the extension
    changed to the the `$replacement`. The user can set the `:parts` argument
    to `0` if they want to *append* an extra extension. The operation is
    equivalent to:

    ```perl6
        my $new-ext = 'txt';
        say (.substr(0, .chars - .extension.chars) ~ $new-ext).IO
            with 'foo.tar.gz'.IO
        # OUTPUT: «"foo.tar.txt".IO␤»
    ```

    Note: since `.extension` returns the extension without the leading dot,
    the replacement string does not have it either. However, since the users
    may be inclined to include it, we should warn if it is included.


------------------------------

### `IO.umask`

**Current Behaviour:**
- shell out to `umask` and parse output as octal string. On OSes without
`umask` this produces output that `umask` isn't a recognized command and then
returns a `Failure` with `X::Str::Numeric` exception.

**Proposed Change:**
- Use proper detection for whether running `umask` succeeded and returning
an appropriate Failure in cases where it doesn't. Only then attempt to
decode the output.


------------------------------
------------------------------

----------------

## Bug Fixes

Along with implementation of API changes in this proposal, an attempt to
resolve the following tickets will be made under the [IO grant](http://news.perlfoundation.org/2017/01/grant-proposal-standardization.html).

#### RT Tickets

- [RT#128047: Rakudo may crash if you use get() when -n is used (perl6 -ne 'say get' <<< 'hello')](https://rt.perl.org/Ticket/Display.html?id=128047)
- [RT#125757: shell().exitcode is always 0 when :out is used](https://rt.perl.org/Ticket/Display.html?id=125757)
- [RT#128214: Decide if `.resolve` should work like POSIX `realname`](https://rt.perl.org/Ticket/Display.html?id=128214)
- [RT#130715: IO::Handle::close shouldn't decide what's a failure](https://rt.perl.org/Ticket/Display.html?id=130715)
- [RT#127407: (1) add method IO::Path.stemname; (2) expand method IO::Path.parts](https://rt.perl.org/Ticket/Display.html?id=127407)
- [RT#127682: (OSX) writing more than 8192 bytes to IO::Handle causes it to hang forever](https://rt.perl.org/Ticket/Display.html?id=127682)
- [RT#130900: nul in pathname](https://rt.perl.org/Ticket/Display.html?id=130900)
- [RT#125463: $non-existent-file.IO.unlink returns True](https://rt.perl.org/Ticket/Display.html?id=125463)
- [RT#129845: `.dir` returns corrupted `IO::Path`s under concurrent load](https://rt.perl.org/Ticket/Display.html?id=129845)
- [RT#128062: (MoarVM) chdir does not respect group reading privilege](https://rt.perl.org/Ticket/Display.html?id=128062)
- [RT#130781: Using both :out and :err in run() reports the wrong exit code](https://rt.perl.org/Ticket/Display.html?id=130781)
- [RT#127566: run hangs on slurp-rest with :out and :err if command runs background process](https://rt.perl.org/Ticket/Display.html?id=127566)
- [RT#130898: IO::Spec confused by diacritics](https://rt.perl.org/Ticket/Display.html?id=130898)
- [RT#127772: mkdir($file) succeeds if $file exists and is a regular file](https://rt.perl.org/Ticket/Display.html?id=127772)
- [RT#123838: IO::Handle::tell return 0, no matter what](https://rt.perl.org/Ticket/Display.html?id=123838)

#### GitHub Issues

- [roast/Add tests to make sure that file names roundtrip correctly when they should](https://github.com/perl6/roast/issues/221)
- [doc/IO::Handle "replace" deprecated method ins with kv](https://github.com/perl6/doc/issues/401)
