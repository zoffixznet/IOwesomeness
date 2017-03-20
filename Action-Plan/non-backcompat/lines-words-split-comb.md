## Changes to behaviour of `.lines`, `.words`, `.split`, `.comb`

- [✘] `IO::Path` docs
- [✘] `IO::Path` roast

**Affected Routines**
- `&lines`, `IO::Path.lines`, `IO::Handle.lines`
- `&words`, `IO::Path.words`, `IO::Handle.words`
- `&split`, `IO::Path.split`, `IO::Handle.split`
- `&comb`, `IO::Path.comb`, `IO::Handle.comb`

**Current behaviour:**

- The subroutine forms delegate work to `IO::Path` methods
- `IO::Path` methods delegate to `IO::Handle`'s methods; they do so by picking
    out a few args to forward, but the rest they `Capture` and give to
    `IO::Path.open`
- `IO::Handle` methods do the work and take an optional `:close` parameter,
    which will cause the handle to be closed when the iterator is exhausted.

**Problems:**

*`#1` Argument handling*
- `IO::Handle`'s method differ in functionality with their `Str.`
counter-parts (e.g. `.split` does not offer `:skip-empty`).
- Several of the arguments accepted and forwarded to `open` aren't needed for
*reading* mode these routines use

*`#2` Possibility of filehandle leak*
- If the user does not exhaust the `Seq` returned by the methods, the
filehandle won't get closed until it gets GCed:

```perl6
    $ perl6 -e 'for ^3000 { $ = "lines".IO.lines[1] }'
    Failed to open file /tmp/tmp.XRqP7tH5zR/lines: too many open files…
```

**Discussion:**

lizmat++ proposed and partially (`.lines` only) implemented a solution for
file handle leak by (a) making `IO::Path` slurp the files (so the file handle
gets closed right at the call) and (b) removing `:close` argument from
`IO::Handle` methods, since we can't guarantee the handle's closing.

While `(a)` does address the handle leak problem, I think it creates a much bigger problem in its wake. [The measurements](https://twitter.com/zoffix/status/843600777457340416) show
a slurped file needs about 4.8x its size of RAM. So slurping files, especially
ones with no pre-defined (by programmer) format, can very easily nom all the
available RAM that on many servers is limited as it is.

So by introducing this behaviour, we'll be essentially instating a "best
practice" to never use `IO::Path` methods due to their slurping
behaviour, and programmer's lack of full control over the environment and
the files the program will work in and operate on.

I think situation in `#2` is a caveat that simply needs to be documented.
Forcing the user to keep the filehandle around in a variable, just to be
able to close it is a bit antisocial, and the problem becomes worse if the
user wants to both lazily read a file and pass the, say `.lines` `Seq` around
the program, as along with the `Seq` the filehandle will need to be passed
as well.

Thus, combined with critique of `#1`, the recommended way to get the first
5 lines from a file becomes rather involved:

```perl6
    my @stuff = with "foo".IO.open {
        LEAVE .close;
        .lines[^5];
    }
```

**Proposed behaviour:**

*`#1` Argument handling*
- Do not take args to open as a `Capture`, take them as normal args and
`Capture` the args for the routines we're delegating to instead. For the
`open`, take only these parameters: `:$chomp`, `:$enc`, `$nl-in`, and
`:$nl-out`. The rest of `open`'s arguments aren't applicable.
