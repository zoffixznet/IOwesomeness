### `IO.umask`

**Current Behaviour:**
- shell out to `umask` and parse output as octal string. On OSes without
`umask` this produces output that `umask` isn't a recognized command and then
returns a `Failure` with `X::Str::Numeric` exception.

**Proposed Change:**
- Use proper detection for whether running `umask` succeeded and returning
an appropriate Failure in cases where it doesn't. Only then attempt to
decode the output.
