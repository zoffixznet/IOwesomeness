## Make `:close` behaviour the default in `IO::Handle` and Its Subclasses

- [✘] docs (`:close` is mentioned only for `.comb` and only in signature and a example's comment, not prose)
- [✘] roast (`:close` is *used* in tests for `.words` and `.comb` but its functionality is not tested)

**Current behaviour:**

The routines `&slurp`, `IO::Path.slurp`, `&lines`, `IO::Path.lines`, `&comb`,
`IO::Path.comb`, `IO::Path.words`, `IO::Path.split`, and the
corresponding `IO::ArgFiles` routines **close the filehandle at the end**

Contrary to that pattern, `IO::Handle` and `IO::Pipe` routines `.slurp-rest`,
`.lines`, `.words`, `.comb`, and `.split` do *NOT* close the handle by default
(I would assume some sort of closage is done for pipes, but preliminary tests
showed omitting `:close` on `IO::Pipe.slurp-rest` in a 3000-iteration loop
causes a coredump on circa 2017.02 Rakudo)

**Proposed behaviour:**

- Remove `:close` parameter
- Add `:keep-open` `Bool` parameter that defaults to `False`. Close the
handle when the iterator is exhausted, unless `:keep-open` parameter is set
to `True`

First, no one seems to be using the `:close` parameter anyway. My guess would
be this is due to ignorance and these programs are leaking filehandles, rather
than the users explicitly closing the filehandle elsewhere in the program.
A March 22, 2017 ecosystem grep showed 1125 potential calls to the methods, yet
only one match came up for the `close` parameter on the same line: the
`perl6/doc` repository.

```bash
    $ grep -FR -e '.comb' -e '.lines' -e '.words' -e '.slurp-rest' | wc -l
    1125
    $ grep -FR -e '.comb' -e '.lines' -e '.words' -e '.slurp-rest' | grep close | wc -l
    1
```

Second, it's likely much more common to wish to close the filehandle at the end
in these methods than not to. The operations provide a the file as basically a
stream of chunks: whole (`.slurp-rest`), line-sized (`.lines`), word-sized
(`.words`), pattern- or character-sized (`.comb`), letting the user perform
most possible operations without needing to `.seek` to another file position
after exhausting the iterator (which would require the handle to be kept open).
