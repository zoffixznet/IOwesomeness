- Several routines have been identified which in other languages return useful information:
    number of bytes actually written or current file position, whereas in Perl 6 they just
    return a Bool (`.print`, `.say`, `.write`) or a Mu type object (`.seek`). Inconsistently,
    `.printf` does appear to return the number of bytes written. It should be possible
    to make other routines similarly useful, although I suspect some of it may have to
    wait until 6.d language release.
- The `.seek` routine takes the seek location as one of three Enum values. Not only are they
    quite lengthy to type, they're globally available for no good reason and `.seek` is virtually
    unique in using this calling convention. I will seek to standardize this routine to take
    mutually-exclusive named arguments instead, preferably with much shorter names, but those
    are yet to be bikeshed.
- `link`'s implementation and documentation confuses what a "target" is. Luckily (or sadly?)
    there are exactly zero tests for this routine in the Perl 6 Specification, so we can
    change it to match the behaviour of `ln` Linux command and the `foo $existing-thing, $new-thing`
    argument order of `move`, `rename`, and other similar routines.
- When using `run(:out, 'some-non-existant-command').out.slurp-rest`
    it will silently succeed and return an empty string. If possible, this
    should be changed to return the failure or throw at some point.
- `chdir`'s `:test` parameter for directory permissions test is taken as a
    single string parameter. This makes it extremely easy to mistakenly write
    broken code: for example, `"/".IO.chdir: "tmp", :test<r w>` succeeds, while
    `"/".IO.chdir: "tmp", :test<w r>` fails with a misleading error message
    saying the directory is not readable/writable. I will propose for `:test`
    parameter to be deprecated in favour of using multiple named arguments to
    indicate desired tests. By extension, similar change will be applied to
    `indir`, `tmpdir`, and `homedir` routines (if they remain in the language).
- *Documentation:* several inaccuracies in the documentation were found. I won't be identifying these in my reports/Action Plan, but will simply ensure the documentation matches the implementation once the Action Plan is fully implemented.


## Discovered Bugs

The hunt for 6-legged friends has these finds so far:

#### Will (attempt to) fix as part of the grant

- indir() has a race condition where the actual dir it runs in ends up being wrong.
    Using `indir '/tmp/useless', { qx/rm -fr */ }` in one thread and backing
    up your precious data in another has the potential to result in some spectacular failurage.
- `perl6 -ne '@ = lines'` crashes after first iteration, crying about `MVMOSHandle REPR`. I suspect
    the code is failing to follow iterator protocol somewhere and is attempting to read
    on an already closed handle. I expect to be able to resolve this and the related
    [RT#128047](https://rt.perl.org/Ticket/Display.html?id=128047) as part of the grant.
- `.tell` incorrectly always returns `0` on files opened in append mode
- `link` mixes up target and link name in its error message


#### Don't think I will be able to fix these as part of the grant

- `seek()` with `SeekFromCurrent` as location fails to seek correctly if called
    after `.readchars`, but only on MoarVM. This appears to occur due to some sort of buffering.
    I filed this as [RT#130843](https://rt.perl.org/Ticket/Display.html?id=130843).
- On JVM, `.readchars` incorrectly assumes all chars are 2 bytes long. This appears to be
    just a naive substitute for nqp::readcharsfh op. I filed this as
    [RT#130840](https://rt.perl.org/Ticket/Display.html?id=130840).


#### Already Fixed

- While making the Routine Map, I discovered `.WHICH` and `.Str` methods on `IO::Special` were `only`
    methods defined only for the `:D` subtype, resulting in a crash when using, say, `infix:<eqv>`
    operator on the type object, instead `Mu.WHICH`/`.Str` candidates getting invoked.
    This bug was easy and I already commited fix in
    [radudo/dd4dfb14d3](https://github.com/rakudo/rakudo/commit/dd4dfb14d3ccfe50dbd4b425778a005d3303edb9)
    and tests to cover it in
    [roast/63370fe054](https://github.com/perl6/roast/commit/63370fe0546eded34cbaa695f6d928aa3db42395)

#### Auxiliary Bugs

While doing the work for this grant, I also discovered some non-IO related bugs (some of which I fixed):

- `.Bool`, `.so`, `.not`, `.has`h, and `.elems` on `Baggy:U` crash
    ([fixed in e8af8553](https://github.com/rakudo/rakudo/commit/e8af8553eae9abfe4f5cd02dcf4114c5c4877c51))
- `.sort` on reified empty arrays crashes ([reported as RT#130866](https://rt.perl.org/Ticket/Display.html?id=130866))
- SEGV with Scalar type object in unique() ([reported as RT#130852](https://rt.perl.org/Ticket/Display.html?id=130852))
- `.Bool`, `.so`, `.not` and possibly others crash on `Seq:U`; need to evaluate entire codebase to see where `only`
    methods are used instead of `multi`, preventing dispatch to `Mu.*` candidates. ([reported as RT#130867
    ](https://rt.perl.org/Ticket/Display.html?id=130867))
- Incorrect line number reported for wrong routine call when unpacking/heredocs are used ([reported
    as RT#130862](https://rt.perl.org/Ticket/Display.html?id=130862#ticket-history))
- Warnings produced by core code marked as "shouldn't happen" ([reported as
    RT#130857](https://rt.perl.org/Ticket/Display.html?id=130857#ticket-history))
