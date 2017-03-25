## Changes to `.Supply` [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/12)

- [✘] docs
- [✔️] roast ([1 test](https://github.com/perl6/roast/blob/4dcbbb9097a728b7e46feb582acbaff19b81014d/S16-io/supply.t#L30-L31))

**Current behaviour:**
- Among the IO routines, the method is implemented only in `IO::Handle` (and is
inherited by `IO::Pipe`).
- `.Supply` takes `:bin` parameter that specifies whether it'll read in binary
mode. Note that `open("foo", :bin).Supply` will **NOT** read in binary mode!

**Proposed behaviour:**
- Remove `.Supply(:bin)` parameter. Instead, Use `IO::Handle`'s `$!encoding`
attribute's value to decide whether to use binary mode. Currently, there's
[one roast test](https://github.com/perl6/roast/blob/4dcbbb9097a728b7e46feb582acbaff19b81014d/S16-io/supply.t#L30-L31) that would be impacted, however its opening
in non-binary mode and then reading in binary feels like a thinko.
