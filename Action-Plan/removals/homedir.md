## Remove `&homedir` [[Issue for discussion]](https://github.com/zoffixznet/IOwesomeness/issues/24)

- [✘] docs
- [✘] roast

Saves typing half a single line of code and is rarely needed.
The user will set `$*HOME` variable directly, using `my ...` to
localize the effects, and using `.= chdir` if any directory tests need to be
done.
