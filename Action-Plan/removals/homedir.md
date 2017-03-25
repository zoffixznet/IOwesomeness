## `&homedir`

- [✘] docs
- [✘] roast

Saves typing half a single line of code and is rarely needed.
The user will set `$*HOME` variable directly, using `my ...` to
localize the effects, and using `.= chdir` if any directory tests need to be
done.
