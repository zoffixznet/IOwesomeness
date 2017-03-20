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
- `$*SPEC` — functionality common to `IO::Spec::*` types, is referred to using
`$*SPEC` variable and means all `IO::Spec::*` types that implement a method or
feature are proposed for change.

## Legend

Some sections are marked as, e.g.:

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

This indicates whether the **proposed change** affects something that
is (`[✔️]`) or isn't (`[✘]`) documented on [docs.perl6.org](https://docs.perl6.org),
tested in [master branch of roast](https://github.com/perl6/roast), or tested in
[6.c-errata branch of roast](https://github.com/perl6/roast/tree/6.c-errata).
Just `[✘] roast` means both `master` and `6.c-errata` branches.

To re-iterate: the indicators are only for the proposed changes (e.g. removed
argument); not entire routines.


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

## Make `IO::Path.abspath` a private method

- [✔️] docs
- [✘] roast

**Current behaviour:**
`.abspath` is a public method that simply caches `$*SPEC.rel2abs` into the
private `$!abspath` attribute.

Also exists, `IO::Path.absolute`. That has exact same functionality, except it
also takes an optional `$CWD` parameter.

**Proposed behaviour:**

Make `.abspath` a private method, to avoid duplicate functionality and confusion
about which version takes the `$CWD` argument.


------------------------------

## Make `IO::Path.child` fail for non-child paths / Add `IO::Path.concat-with`

- [✔️] docs (but no description of ability to use nested paths or parent paths)
- [✔️] roast (but no tests of ability to use nested paths or parent paths)

**Current behaviour:**
`.child` can accept any path part, so
`"/tmp/files/".IO.child("../../my/secrets")` is a valid operation and based
on the argument given to `.child`, the resulting path may be something that
is **not** a child of the original path.

**Proposed behaviour:**

The proposed change is two-part: rename current method and add another behaviour
under the name `.child`:

1) Make the current behaviour of `.child` available via `.concat-with` method.
    The goal of the name change is to make it indicative that the user can
    provide any type of path fragment—not necessarily a child one or singular—
    and that giving what looks like an absolute path as the argument will merely
    concatenate it to the original path:

    ```perl6
        # non-child path is OK
        "/tmp/files/".IO.concat-with("../../my/secrets").say;
        # OUTPUT: "/tmp/files/../../my/secrets".IO

        # "absolute" path gets tacked on to original
        "/tmp/files/".IO.concat-with("/my/secrets").say;
        # OUTPUT: "/tmp/files//my/secrets".IO

        # child file is OK
        "/tmp/files/".IO.concat-with("foo.txt").say;
        # OUTPUT: "/tmp/files/foo.txt".IO
    ```

2) Make `.child` fully resolve the resultant path and `fail` if it's not the
    child of the original path. The last part of the path does not have to
    actually
    exist in order to pass the check. The idea behind the new behaviour is to
    make it possible to *securely* use code like this and not worry that
    `$user-input` would contain any path that would be able to read from
    or write to outside the original path (in the example, that is
    `/tmp/files/`):

    ```perl6
        my $stuff = "/tmp/files/".IO;

        if $stuff.child($user-input) -> $_ {
            when :!e {
                .spurt: "Stuff started on {DateTime.now}";
                say "Started new file for your stuff!";
            }
            say "The content of your stuff is:\n{.slurp}";
        }
        else -> $file {
            die "Cannot use $file as a valid file to read/write from";
        }
    ```


------------------------------

## Changes to behaviour of `.lines`, `.words`, `.split`, `.comb`

- [✘] docs
- [✘] roast

**Affected Routines**
- `&lines`, `IO::Path.lines`, `IO::Handle.lines`
- `&words`, `IO::Path.words`, `IO::Handle.words`
- `&split`, `IO::Path.split`, `IO::Handle.split`
- `&comb`, `IO::Path.comb`, `IO::Handle.comb`

**Current behaviour:**

- The subroutine forms delegate work to `IO::Path` methods
- `IO::Path` methods delegate to `IO::Handle`'s methods; they do so by picking
    out a few args to forward, but the rest they `Capture` and give to
    `IO::Path.open`
- `IO::Handle` methods do the work and take an optional `:close` parameter,
    which will cause the handle to be closed when the iterator is exhausted.

**Problems:**

*`#1` Argument handling*
- `IO::Handle`'s method differ in functionality with their `Str.`
counter-parts (e.g. `.split` does not offer `:skip-empty`).
- Several of the arguments accepted and forwarded to `open` aren't needed for
*reading* mode these routines use

*`#2` Possibility of filehandle leak*
- If the user does not exhaust the `Seq` returned by the methods, the
filehandle won't get closed until it gets GCed:

```perl6
    $ perl6 -e 'for ^3000 { $ = "lines".IO.lines[1] }'
    Failed to open file /tmp/tmp.XRqP7tH5zR/lines: too many open files…
```

**Discussion:**

lizmat++ identified the issue and proposed and partially (`.lines` only)
implemented a solution for file handle leak by **`(a)`** making `IO::Path` slurp the
files (so the file handle
gets closed right at the call) and **`(b)`** removing `:close` argument from
`IO::Handle` methods, since we can't guarantee the handle's closing.

While **`(a)`** does address the handle leak problem, I think it creates a much bigger problem in its wake. [The measurements](https://twitter.com/zoffix/status/843600777457340416) show
a slurped file needs about 4.8x its size of RAM. So slurping files, especially
ones with no pre-defined (by programmer) format, can very easily nom all the
available RAM that on many servers is limited as it is.

So by introducing this behaviour, we'll be essentially instating a "best
practice" to never use `IO::Path` methods due to their slurping
behaviour, and programmer's lack of full control over the environment and
the files the program will work in and operate on.

In addition, since the subroutine forms of these routines simply forward to
`IO::Path`, this
means Perl 6 one liners will be commonly afflicted with both high RAM usage
and performance issues (e.g. "print first line of a 4GB file" will require
19GB of RAM and a lot of processing time, rather than being nearly instant).

I think situation **`(b)`** is a caveat that simply needs to be documented.
Forcing the user to keep the filehandle around in a variable, just to be
able to close it is a bit antisocial, and the problem becomes worse if the
user wants to both lazily read a file and pass the, say `.lines` `Seq` around
the program, as along with the `Seq` the filehandle will need to be passed
as well.

Thus, combined with critique of **`(a)`**, the recommended way to get the first
5 lines from a file becomes rather involved:

```perl6
    my @stuff = with "foo".IO.open {
        LEAVE .close;
        .lines[^5];
    }
```

And despite the removal of convenience `:close` parameter, it's quite easy
for user to erroneously make a mistake and might even make it more likely the
users will make it more often that (we [had a user who did just that](https://irclog.perlgeek.de/perl6/2017-03-11#i_14243167)):

```perl6
    my $fh = open "foo";
    my $lines = $fh.lines;
    $fh.close;
    say $lines[0]; # Dies with "Reading from filehandle failed"
```

**Proposed behaviour:**

*`#1` Argument handling*
- Do not take args to open as a `Capture`, take them as normal args and
`Capture` the args for the routines we're delegating to instead. For the
`open`, take only these parameters: `:$chomp`, `:$enc`, `$nl-in`, and
`:$nl-out`. The rest of `open`'s arguments aren't applicable. This will
also make it easier to ensure we're not missing any of the routines'
args when forwarding them.
- Make the routines take the same args and behave the same as their `Str`
counterparts.

*`#2` Possibility of filehandle leak*
- Leave `:$close` parameter in place for all 4 routines in `IO::Handle`
- Add `$limit` parameter to all 4 routines in `IO::Handle` (`.lines` already
    has it, although it's not implemented in a way that avoids the leak)
    - When `$limit` is given, close the filehandle when it's reached or when
        the iterator has been exhausted.
    - When `:$close`is `True`, close the filehandle when the iterator has been
        exhausted
    - `+Inf` and `Whatever` `$limit` is permitted, to maintain consistency with
        `Str.lines($limit)` parameter. When set to such a value, the effect is the
        same as setting `:close` to `True`.
    - Specifying both `$limit` and `:$close` is a fatal exception.
- Clearly document the filehandle leak issue along with plentiful examples
of using `$limit` instead of `[^whatever]` on the returned `Seq`, or to
exhaust the partially-consumed Seq by sinking it, when you're done with it.


------------------------------

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

## Make `IO::Path.resolve` fail if it can't resolve path

**Current behaviour:**
`.resolve` will attempt to access the filesystem and resolve all the links,
but will stop resolving as soon as it hits a non-existent path; all further
parts will be merely cleaned up (e.g. `foo///../` will have duplicated slashes
removed, but the `../` part will remain).

**Proposed behaviour:**
Add `Bool :$completely` parameter that, when specified as `True`, will cause
`.resolve` to `fail` if cannot fully resolve the path.


------------------------------
------------------------------

## Changes Needing Attention

I'm not 100% sure whether the changes in this section actually need to be made,
as they appear to be deliberately introduced behaviours; I'm just unsure of
the reasoning behind them.


------------------------------

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


------------------------------
------------------------------

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


#### Other Issues

- `IO::Path.resolve` is not portable and produces wrong results on Windows.
