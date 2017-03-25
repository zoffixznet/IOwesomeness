## Restructure `spurt` [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/3)

- [✔️] docs (with several inaccuracies)
- [✘] roast

**Current Behaviour:**
- `IO::Path` implements `.spurt` which is the only writing method that's
present in `IO::Path` but is not present in `IO::Handle`
- `:bin` parameter on `&spurt` / `IO::Path.spurt` is taken and documented, but
is ignored. The binary mode is enabled based on whether or not the spurted
`$content` is a `Blob`.
- The docs lie about `&spurt` being able to take an `IO::Handle`

**Proposed Change:**
- Move `IO::Path.spurt` implementation to `IO::Handle`. Remove all of its
parameters, except for a single positional `Cool:D` parameter.
    - the bin/non-bin mode is selected based on whether the handle is in
        bin/non-bin mode    
- Make `IO::Path.spurt` delegate to `IO::Handle`
    - Remove `:bin` argument and ascertain the spurt mode based on the type
        of the content to be spurted
    - The rest of the arguments are to be used in the `IO::Handle.open` call,
        with the `:createonly` argument being an alias for `:x` open mode.
