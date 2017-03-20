### Remove `:bin` parameter on `&spurt` / `IO::Path.spurt`

- [✔️] docs
- [✘] roast

**Current Behaviour:**
The argument is ignored. The binary mode is enabled based on whether or not
the spurted `$content` is a `Blob`.

**Proposed Change:**
Remove and un-document the argument.
