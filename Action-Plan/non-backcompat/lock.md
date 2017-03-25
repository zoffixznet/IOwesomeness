## Improve `IO::Handle.lock` Arguments [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/18)

- [✘] docs
- [✘] roast

**Current behaviour:**

`IO::Handle.lock` takes a single `Int:D` that specifies the type of lock
to acquire.

**Proposed behaviour:**
I'd like to make the arguments more user-friendly, without creating a new
enum, if possible, as those interfere with parenthesis-less subroutine calls.

From [the sourcecode](https://github.com/MoarVM/MoarVM/blob/a8448142d8b49a742a6b167907736d0ebbae9779/src/io/syncfile.c#L303-L358), I gather the `Int:D` argument
represents whether: (a) a lock is *exclusive* or *shared*;
(b) the method will block until a lock is acquired or it'll throw if it cannot
be acquired.

I can count on my fingers how many times I've used locks in my life, so I'm
unsure which mode is more frequently used and whether one type of mode is
way more frequent for it to be used as a reasonable default.

Unless an alternative is suggested, I'd like to change the method to take the
possible modes via `.lock(:exclusive, :wait)` arguments and default to a
shared, non-blocking lock.
