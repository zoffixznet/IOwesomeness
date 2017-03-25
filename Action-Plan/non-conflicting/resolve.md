## Make `IO::Path.resolve` fail if it can't resolve path [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/7)

**Current behaviour:**

`.resolve` will attempt to access the filesystem and resolve all the links,
but will stop resolving as soon as it hits a non-existent path; all further
parts will be merely cleaned up (e.g. `foo///../` will have duplicated slashes
removed, but the `../` part will remain).

**Proposed behaviour:**

Add `Bool :$completely` parameter that, when specified as `True`, will cause
`.resolve` to `fail` if cannot fully resolve the path.
