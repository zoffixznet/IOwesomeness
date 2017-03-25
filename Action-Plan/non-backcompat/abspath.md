## Make `IO::Path.abspath` a private method [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/13)

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
