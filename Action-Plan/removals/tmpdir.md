## Remove `&tmpdir` [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/25)

- [✘] docs
- [✘] roast
- [✘] routine is broken and never worked since Christmas

Saves typing half a single line of code and is rarely needed.
The user will set `$*TMPDIR` variable directly, using `my ...` to
localize the effects, and using `.= chdir` if any directory tests need to be
done.
