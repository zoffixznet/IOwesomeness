## Remove `role IO {}` Along With Its Only `IO.umask` Method [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/22)

- [✘] docs (partial and inaccurate)
- [✘] roast ([1 indirect test](https://github.com/perl6/roast/blob/4dcbbb9097a728b7e46feb582acbaff19b81014d/S06-multi/type-based.t#L43) that tests multi-dispatch by dispatching `$*ERR`
to `IO` type candidate)

**Documentation:**

While the documentation website does mention `role IO`, it's mainly to list
the IO subroutines. The role itself is described as
*"Input/output related object"*, which isn't entirely true, as `IO::Path` does
not do `IO`, despite being related.

The role is also described as providing no functionality, despite it currently
containing the `.umask` method. The 5-to-6 documentation does reference
the `IO.umask` as the replacement for Perl 5's `&umask` subroutine.

**Current Behaviour:**
- `role IO` is done by `IO::Handle` and `IO::Socket`
- `.umask` is implemented by shelling out to `umask` command (not available
    on Windows).

**Proposed Change:**

Remove the role, together with its `.umask` method.

While `.umask` could be re-implemented with C and adding another nqp op,
functionally the method is a bit of an outlier, compared to all the other
methods currently available on the `IO::*` types. So while we might expand
the core offerings in this area in the future, I believe the current
implementation should be removed.

With the `.umask` method gone, the `role IO` becomes empty, serving no purpose,
and so it should be removed as well.
