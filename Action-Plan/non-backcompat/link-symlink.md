## Change order of arguments in `&link`/`&symlink`

*For `&link`:*
- [✘] docs
- [✘] roast

*For `&symlink`:*
- [✔️] docs (but confuses terminology for `"target"`)
- [✔️] roast (but confuses terminology for `"target"`)

**Current behaviour:**
Routines `&rename`, `&move`, `&copy`, as well as `*nix` command line untilities
`mv`, `cp`, **and `ln`** follow
the `command $existing-thing, $thing-we're-creating` format with respect to
their argument.

The `&link` and `&symlink` routines are an exception to this rule. And while
`&symlink` is documented and tested, both the docs and the tests use term
`"target"` to refer to the name of the link, rather to the actual target it
points to.

**Proposed behaviour:**

As there's [already some confusion](https://www.google.ca/#q=I+can+never+remember+the+argument+order+to+ln&*) with the order of arguments to `ln` tool, it would be beneficial
to maintain consistency both within `&rename`, `&move`, `&copy`, `&link`, and
`&symlink` routines and with `ln <-> &link/&symlink`.

It is proposed the order of the arguments for `&link` and `&symlink` to
be reversed:

- `link $existing-thing, $thing-we're-creating` (`link $target, $name`)
- `symlink $existing-thing, $thing-we're-creating` (`symlink $target, $name`)
