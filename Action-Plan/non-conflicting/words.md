## Make `&words` default to `$*ARGFILES` [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/8)

**Current behaviour:**

`&slurp`, `&lines`, `&get`, and `&getc`
(or, semantically, "whole thing", "all lines", "one line",
and "one char") default to using `$*ARGFILES`. `&words` (or "all words")
exceptionally doesn't and throws instead.

**Proposed behaviour:**

Make `&words` default to `$*ARGFILES`, just like the rest of the routines
in this family.
