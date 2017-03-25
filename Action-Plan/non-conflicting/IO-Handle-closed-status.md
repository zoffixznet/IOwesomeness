## `IO::Handle`'s Closed status

**Current Behaviour:**
- When a IO::Handle is closed, its $!PIO atribute is set to nqp::null. This
causes calls to many methods on a closed file handle to return LTA error,
such as `foo requires an object with REPR MVMOSHandle`.

**Proposed Change:**
- On handle close, mixin a role that overrides all the relevant methods
to throw/fail with an error. This will give the same behaviour as adding
`if nqp::isnull($!PIO) { ... throw ... }` to all the methods, without a
performance impact to open handles (it was ~5% when such check was added to
`.lines` iterator)
