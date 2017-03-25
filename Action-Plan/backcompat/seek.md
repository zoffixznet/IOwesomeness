## `IO::Handle.seek` seek reference [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/1)

- [✔️] docs
- [✔️] master roast
- [✘] 6.c-errata roast

**Current behaviour**:
- The seek reference is taken as an enum which is globally available and is
somewhat long to type: `SeekFromBeginning`, `SeekFromCurrent`, `SeekFromEnd`.
Such type of arguments is rare in the rest of the language and the enums
prevent parenthesis-less subroutine calls of the same name.

**Proposed change**:
- Use mutually exclusive named arguments instead: `:from-start`,
`:from-current`, and `:from-end`. The old enums will be kept in 6.c language and
will be removed in 6.d.
