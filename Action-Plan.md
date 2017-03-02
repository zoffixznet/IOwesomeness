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

---------------

## Removals

- `&homedir` ­/ `&tempdir` — these routines save typing half a single line of code and are rarely needed. The user will set `$*TMPDIR` / `$*HOMEDIR` variables
directly.


---------------

## Changes with Backwards-Compatible Support

### `IO::Handle.seek` seek reference [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/1)

**Current behaviour**:
- The seek reference is taken as an enum which is globally available and is
somewhat long to type: `SeekFromBeginning`, `SeekFromCurrent`, `SeekFromEnd`.
`.seek` is nearly unique in using such a calling convention.

**Proposed change**:
- Use mutually exclusive named arguments instead: `:from-start`,
`:from-current`, and `:from-end`. The old enums will be kept and will still
work in 6.c language and will be removed in 6.d.

### `:$test` parameter on multiple routines

**Affected routines**
- `IO::Path.chdir` / `&chdir`
- `&indir`
- `&homedir` *(proposed for removal)*
- `&tmpdir` *(proposed for removal)*
**Current behaviour**:
`IO::Path.chdir`,

---------------

## Non-Conflicting Improvements

### `IO.umask`

**Current behaviour**:
- shell out to `umask` and parse output as octal string. On OSes without
`umask` this produces output that `umask` isn't a recognized command and then
returns a `Failure` with `X::Str::Numeric` exception.

**Proposed change**:
- Use proper detection for whether running `umask` succeeded and returning
an appropriate Failure in cases where it doesn't. Only then attempt to
decode the output.

### `IO::Handle`'s Closed status

**Current behaviour**:
- When a IO::Handle is closed, its $!PIO atribute is set to nqp::null. This
causes calls to many methods on a closed file handle to return LTA error,
such as `foo requires an object with REPR MVMOSHandle`.

**Proposed change**:
- On handle close, mixin a role that overrides all the relevant methods
to throw/fail with an error. This will give the same behaviour as adding
`if nqp::isnull($!PIO) { ... throw ... }` to all the methods, without a
performance impact (it was ~5% when such check was added to `.lines`
terator)


---------------

## Bug Fixes
