# Final Note on Changes Due to IO Grant Work

The IO grant work is at its wrap up. This note lists some of the last-minute changes to the plans
delineated in earlier communications.

- We implemented [`IO::Path.sibling`](https://docs.perl6.org/routine/sibling)
- The promised `IO::Path.concat-with` was instead added as the much shorter
  [`IO::Path.add`](https://docs.perl6.org/routine/add). Due to large ecosystem usage,
  `IO::Path.child` was left as is
  for now. The secure version is already written and `.child` will be swapped
  to use it later on; possibly around 6.d time. This will allow more time for
  users to update to the `.add` routine, where the secureness isn't needed.
- `&mkdir` multi candidate that takes a list of directories has been removed.
    IO::Path.mkdir has been changed to return the invocant on success, to
    mirror the subroutine form's behaviour
- The changes to `&symlink` and `&link` affected `IO::Path.symlink` and
  `IO::Path.link` as well. The new order of arguments is
    `$existing-thing.symlink: $the-new-thing-we're-creating` (same for `.link`)
- `role IO` was promised to be removed. Essentially it was, none of the types
    that did it do it anymore. However, the role was brought back, to be done
    by `IO::Path` and `IO::Special`. The role provides no methods, but when
    we'll make our coercers type-check the results of the coercion, we'll
    need `IO::Path` to be of type `IO`, or all of our shiny `IO()` coercers
    will explode. As `IO::Special` is meant to be a fake-IO::Path-lite, it
    does `IO` role as well.
- Many of the IO routines were changed from taking `Str` arguments to taking
    `IO()` arguments. When paths are given as `IO::Path`s, this avoids needless
    waste of cycles to convert the `IO::Path` to `Str` and then to `IO::Path`
    again. More importantly, since `IO::Path.Str` doesn't consider `$.CWD`
    into account, this fixes all potential bugs where the `IO::Path` given
    as arg was created with `$.CWD` other than current `$*CWD`

## Help and More Info

If you need help or more information, please [join our IRC
channel](https://webchat.freenode.net/?channels=#perl6) and ask there. You can
also contact the person performing this work via
[Twitter @zoffix](https://twitter.com/zoffix) or by talking to user `Zoffix` in [our dev IRC channel](https://webchat.freenode.net/?channels=#perl6)
