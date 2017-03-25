## `IO::Path` routines that involve a stat call [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/4)

**Affected Routines:**
- `.d`
- `.f`
- `.l`
- `.r`
- `.s`
- `.w`
- `.x`
- `.z`
- `.rw`
- `.rwx`
- `.modified`
- `.accessed`
- `.changed`
- `.mode`

**Current Behaviour:**

Each test goes out to VM to perform several `stat` calls (other than `.e` that
performs just one). For example, a single `.rwx` call performs 4 `stat` calls.
Based on IRC conversation, `stat` call is expensive and caching its results
can be beneficial.

**Proposed Change:**

Change `nqp::const::STAT*` constants to be powers of 2. Add
`nqp::stat_multi` op that will take bitwise-ORed `nqp::const::STAT*` constants
representing the pieces of stat information to be returned as a hash. This
will let us perform a single stat call to fetch all of the required information.

(related discussion: https://irclog.perlgeek.de/perl6-dev/2017-03-06#i_14213924)
