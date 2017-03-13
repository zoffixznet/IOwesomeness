## Bug Fixes

Along with implementation of API changes in this proposal, an attempt to
resolve the following tickets will be made under the [IO grant](http://news.perlfoundation.org/2017/01/grant-proposal-standardization.html).

#### RT Tickets

- [RT#128047: Rakudo may crash if you use get() when -n is used (perl6 -ne 'say get' <<< 'hello')](https://rt.perl.org/Ticket/Display.html?id=128047)
- [RT#125757: shell().exitcode is always 0 when :out is used](https://rt.perl.org/Ticket/Display.html?id=125757)
- [RT#128214: Decide if `.resolve` should work like POSIX `realname`](https://rt.perl.org/Ticket/Display.html?id=128214)
- [RT#130715: IO::Handle::close shouldn't decide what's a failure](https://rt.perl.org/Ticket/Display.html?id=130715)
- [RT#127407: (1) add method IO::Path.stemname; (2) expand method IO::Path.parts](https://rt.perl.org/Ticket/Display.html?id=127407)
- [RT#127682: (OSX) writing more than 8192 bytes to IO::Handle causes it to hang forever](https://rt.perl.org/Ticket/Display.html?id=127682)
- [RT#130900: nul in pathname](https://rt.perl.org/Ticket/Display.html?id=130900)
- [RT#125463: $non-existent-file.IO.unlink returns True](https://rt.perl.org/Ticket/Display.html?id=125463)
- [RT#129845: `.dir` returns corrupted `IO::Path`s under concurrent load](https://rt.perl.org/Ticket/Display.html?id=129845)
- [RT#128062: (MoarVM) chdir does not respect group reading privilege](https://rt.perl.org/Ticket/Display.html?id=128062)
- [RT#130781: Using both :out and :err in run() reports the wrong exit code](https://rt.perl.org/Ticket/Display.html?id=130781)
- [RT#127566: run hangs on slurp-rest with :out and :err if command runs background process](https://rt.perl.org/Ticket/Display.html?id=127566)
- [RT#130898: IO::Spec confused by diacritics](https://rt.perl.org/Ticket/Display.html?id=130898)
- [RT#127772: mkdir($file) succeeds if $file exists and is a regular file](https://rt.perl.org/Ticket/Display.html?id=127772)
- [RT#123838: IO::Handle::tell return 0, no matter what](https://rt.perl.org/Ticket/Display.html?id=123838)

#### GitHub Issues

- [roast/Add tests to make sure that file names roundtrip correctly when they should](https://github.com/perl6/roast/issues/221)
- [doc/IO::Handle "replace" deprecated method ins with kv](https://github.com/perl6/doc/issues/401)


#### Other Issues

- `IO::Path.resolve` is not portable and produces wrong results on Windows.
