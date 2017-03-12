### `IO::Handle.seek` seek reference [[Issue for dicussion]](https://github.com/zoffixznet/IOwesomeness/issues/1)

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

**Current behaviour**:
- The seek reference is taken as an enum which is globally available and is
somewhat long to type: `SeekFromBeginning`, `SeekFromCurrent`, `SeekFromEnd`.
`.seek` is nearly unique in using such a calling convention.

**Proposed change**:
- Use mutually exclusive named arguments instead: `:from-start`,
`:from-current`, and `:from-end`. The old enums will be kept in 6.c language and
will be removed in 6.d.
