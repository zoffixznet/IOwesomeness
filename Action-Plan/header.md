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
- `seek` — if neither a `.` nor `&` preceeds the name, the reference is to
    both subroutines and methods with that name
- `$*SPEC` — functionality common to `IO::Spec::*` types, is referred to using
`$*SPEC` variable and means all `IO::Spec::*` types that implement a method or
feature proposed for change.

## Legend

Some sections are marked as:

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

This indicates whether the **proposed change** affects something that
*is* (`[✔️]`) or *isn't* (`[✘]`) documented on [docs.perl6.org](https://docs.perl6.org),
tested in [master branch of roast](https://github.com/perl6/roast), or tested in
[6.c-errata branch of roast](https://github.com/perl6/roast/tree/6.c-errata).
Just `[✘] roast` means both `master` and `6.c-errata` branches.

To re-iterate: the indicators are only for the *proposed changes* (e.g. removed
argument); not *entire* routines.
