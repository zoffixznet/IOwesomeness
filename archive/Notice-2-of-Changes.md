# PART 2: Upgrade Information for Changes Due to IO Grant Work

We're making more changes! Do the core developers ever sleep? Nope! We keep making Perl 6 better 24/7!

## Why?

Not more than 24 hours ago, you may have read [Upgrade Information for Changes Due to IO Grant Work](http://rakudo.org/2017/04/02/upgrade-information-for-changes-due-to-io-grant-work/). All of that is still happening.

However, it turned out that I, (Zoffix), had an incomplete understanding of how changes in 6.d language will play along with 6.c stuff. My original assumption was we could remove or change existing methods, but that assumption was incorrect. Pretty much the only sane way to incompatibly change *a method in an object* in 6.d is to add a new method with a different name.

Thus, we have a bit of an in-flight course correction:

**ORIGINAL PLAN** was to minimize incompatibilities in 6.c code; leave everything potentially-breaking for 6.d

**NEW PLAN** is to add everything that does NOT break 6.c-errata specification right now, into 6.c language; leave everything else for 6.d. Note that current 6.c-errata specification for IO is sparse (the reason IO grant is running in the first place), so there's lots of wiggle room to make most of the changes in 6.c.

## When?

I (Zoffix) still hope to cram all the changes into 2017.04 release. Whether that's overly optimistic, given the time constraints… we'll find out on April 17th. If anything doesn't make it into 2017.04, all of it definitely will be in 2017.05.

## What?

Along with [the original list in first Upgrade Information Notice](http://rakudo.org/2017/04/02/upgrade-information-for-changes-due-to-io-grant-work/), the following changes may affect your code. I'm *excluding any non-conflicting changes.*

- `IO::Path.abspath` is being made private. Use `IO::Path.absolute` instead; it provides the same functionality + lets you optionally provide a different CWD as well.
- It was previously possible to use `IO::Path.child` to create unresolvable paths or paths are not the children of the invocant's path (e.g. `.child: "../../"`). This use now causes the method to `fail` instead, any time the path cannot be determined to be the child of the invocant. **This means the path will be fully resolved and the method will fail if it can't resolve it**. For original functionality, use the newly-added `.concat-with` method
- All IO routines now throw typed exception instead of `X::AdHoc`
- We're adding a generic version of `IO::ArgFiles` called `IO::Cat` which `is IO::Handle`. The `IO::ArgFiles` class will be kept for compatibility, but it'll be just an empty class that `is IO::Cat`. Note that this may modify what methods are available in `IO::ArgFiles`, however existing methods that aren't horribly broken should not be affected.
- This likely does not affect any code, but for FYI `IO::Path`'s methods `lines`, `words`, `split`, and `comb` previously captured most args and sent them all to `IO::Handle.open`. Now, only the arguments that make sense in read-only non-binary mode, namely `:$chomp`, `:$enc`, and `$nl-in`, will be forwarded. The rest will be ignored.

Potential changes:
- Currently `IO::Path.is-absolute` on Windows returns `True` if the path starts with a [back]slash (without any drive letters). There's some chance this is to be changed to return `False` instead. This is the only change in direct conflict with 6.c language specification, which is why the current behaviour might be kept unchanged, unless it's deemed incorrect.

Changes for 6.d language:
- `IO::Handle` and `IO::Pipe`'s `.slurp-rest` method is being renamed to just `.slurp`, which will be added in 6.c language. In 6.d language, `.slurp-rest` will be deprecated, to be removed in later language versions.
- `IO::Path.chdir` will be deprecated in 6.d language, to be removed in later language versions. It's a misnomer, as it doesn't change any dirs. It merely creates a new path. Its behaviour can be replaced with one or more of `.new`, `.concat-with`, `.d`, `.r`, `.w`, and `.x` methods.
- There's some chance `IO::Spec::*` classes will be deprecated in 6.d, to be removed in later language versions, because they're internal-ish. We'll first have a trial run with the proposed changes implemented in a module (to be named `FastIO`). If the module offers a lots of benefits, there will be a discussion on how to make it the default implementation for core IO.

## Help and More Info

If you need help or more information, please [join our IRC
channel](https://webchat.freenode.net/?channels=#perl6) and ask there. You can
also contact the person performing this work via
[Twitter @zoffix](https://twitter.com/zoffix) or by talking to user `Zoffix` in [our dev IRC channel](https://webchat.freenode.net/?channels=#perl6)
