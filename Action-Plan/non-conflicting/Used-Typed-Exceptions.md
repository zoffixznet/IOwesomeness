## Use typed exceptions instead of `X::AdHoc`

**Current Behaviour:**
- Some IO exceptions are generic, `X::AdHoc` type of exceptions.

**Proposed Change:**
- Use existing and create new, if needed, exceptions, all living in
`X::IO::*` namespace.
