# Upgrade Information for Changes Due to IO Grant Work

As [previously notified](http://rakudo.org/2017/02/26/advance-notice-of-significant-changes/), there are changes being made to IO routines. This notice is to provide details on changes that may affect currently-existing code.

## When?

Barring unforeseen delays, the work affecting version 6.c language is planned to be included in 2017.04 Rakudo Compiler release (planned for release on April 17, 2017) on which the next Rakudo Star release will be based.

Some or all of the work affecting 6.d language may also be included in that release and will be available if the user uses `use v6.d.PREVIEW` pragma. Any 6.d work that doesn't make it into 2017.04 release, will be included in 2017.05 release.

If you use development commits of the compiler (e.g. `rakudobrew`), you will
receive this work as-it-happens.

## Why?

If you only used documented features, the likelihood of you needing to change any of your code is low. The 6.c language changes due to IO Grant work affect either routines that are rarely used or undocumented routines that might have been used by users assuming they were part of the language.

## What?

This notice describes only **changes affecting existing code** and only for **6.c language**. It does **NOT** include any non-conflicting changes or changes slated for 6.d language. If you're interested in the full list of changes, you can find it in [the IO Grant Action Plan](https://github.com/rakudo/rakudo/blob/nom/docs/2017-IO-Grant--Action-Plan.md)

The changes that may affect existing code are:

- `role IO` together with its `IO.umask` method have been removed without any replacement
- Methods `.watch`, `.chmod`, `.IO`, `.e`, `.d`, `.f`, `.s`, `.l`, `.r`, `.w`, `.x`, `.modified`, `.accessed`, `.changed`, and `.mode` have been removed from `IO::Handle`. You can call these on the path returned by `IO::Handle.path` method to obtain the same behaviour
- `:test` parameter on `&chdir`, `IO::Path.chdir`, and `&indir` routines have been changed to issue a deprecation warning and will be removed in 6.d language. In addition, the default test performed by these routines has been changed to be only a test for whether the path is a directory. To upgrade your code for this change, simply use named parameters for the test. e.g replace `chdir :test<r w x> …` with `chdir :r:w:x …`
- binary mode in `IO::Handle.Supply` is now controlled by whether the handle
is in binary mode (e.g. opened with `.open(:bin …)`). The `:bin` argument to `.Supply` is now ignored.
- In 2017.03 release, `IO::Path.lines` was made non-lazy (slurps the whole file). This has now been reverted. To ensure the filehandle gets closed, you need to exhaust the returned Seq (simply iterate through it; `eager` it explicitly or implicitly (e.g. by assigning to array); or call `.sink` on it)
- The order of arguments to `&link` and `&symlink` has been reversed. It now follows `$existing-thing, $thing-we-are-creating` pattern adhered to by `ln` command line tool as well as `&move`, `&copy` and `&rename` routines.
- `IO::Handle.lock` no longer takes an `Int:D` argument, but a pair of named arguments instead. By default, it makes an exclusive, blocking lock. Use `:shared` named argument to make a shared lock instead and `:non-blocking` to make the method fail instead of waiting for lock.
- `IO::Path.new-from-absolute-path` is now a private method. Use `.IO` coercer or `IO::Path.new: $the-path` instead
- `&homedir` has been removed. Use `$*HOME` dynamic variable directly.
- `&tempdir` has been removed. Use `$*TMPDIR` dynamic variable directly.

### Help and More Info

If you need help or more information, please [join our IRC
channel](https://webchat.freenode.net/?channels=#perl6) and ask there. You can
also contact the person performing this work via
[Twitter @zoffix](https://twitter.com/zoffix) or by talking to user `Zoffix` in [our dev IRC channel](https://webchat.freenode.net/?channels=#perl6)
