## Make `IO::Path.child` fail for non-child paths / Add `IO::Path.concat-with`

- [✔️] docs (but no description of ability to use nested paths or parent paths)
- [✔️] roast (but no tests of ability to use nested paths or parent paths)

**Current behaviour:**
`.child` can accept any path part, so
`"/tmp/files/".IO.child("../../my/secrets")` is a valid operation and based
on the argument given to `.child`, the resulting path may be something that
is **not** a child of the original path.

**Proposed behaviour:**

The proposed change is two-part: rename current method and add another behaviour
under the name `.child`:

1) Make the current behaviour of `.child` available via `.concat-with` method.
    The goal of the name change is to make it indicative that the user can
    provide any type of path fragment—not necessarily a child one or singular—
    and that giving what looks like an absolute path as the argument will merely
    concatenate it to the original path:

    ```perl6
        # non-child path is OK
        "/tmp/files/".IO.concat-with("../../my/secrets").say;
        # OUTPUT: "/tmp/files/../../my/secrets".IO

        # "absolute" path gets tacked on to original
        "/tmp/files/".IO.concat-with("/my/secrets").say;
        # OUTPUT: "/tmp/files//my/secrets".IO

        # child file is OK
        "/tmp/files/".IO.concat-with("foo.txt").say;
        # OUTPUT: "/tmp/files/foo.txt".IO
    ```

2) Make `.child` fully resolve the resultant path and `fail` if it's not the
    child of the original path. The last part of the path does not have to
    actually
    exist in order to pass the check. The idea behind the new behaviour is to
    make it possible to *securely* use code like this and not worry that
    `$user-input` would contain any path that would be able to read from
    or write to outside the original path (in the example, that is
    `/tmp/files/`):

    ```perl6
        my $stuff = "/tmp/files/".IO;

        if $stuff.child($user-input) -> $_ {
            when :!e {
                .spurt: "Stuff started on {DateTime.now}";
                say "Started new file for your stuff!";
            }
            say "The content of your stuff is:\n{.slurp}";
        }
        else -> $file {
            die "Cannot use $file as a valid file to read/write from";
        }
    ```
