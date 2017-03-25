## Expand Features of `IO::Path.extension`

**Current Behaviour:**

It's not uncommon to see users asking on IRC how to
obtain or modify an extension of a path. Depending on what is needed, the answer
is usually a gnarly-looking `.subst` or `.split`+`.join` invocation. In
addition, often the desired extension for files like `foo.tar.gz` would be
`tar.gz`, yet the current `.extension` does not offer a means to obtain it.

**Proposed Change:**

- Add `:$parts = 1` named parameter that specifies how many parts (the
    `.whatever` segments, counting from end) to consider as the extension.
    That is `'foo.tar.gz'.IO.extension` returns `'gz'`,
    `'foo.tar.gz'.IO.extension: :2parts` returns `'tar.gz'`, and
    `'foo.tar.gz'.IO.extension: :3parts` returns `''` (signaling there is no
        [3-part] extension on the file).

    In the future we can extend this to take a `Range` or `Junction` of values,
    but for now, just a single `UInt` should be sufficient. The default value
    of `1` preserves the current behaviour of the routine. Value of `0` always
    makes routine return an empty string.
- Add a candidate that accepts a positional `$replacement` argument. This
    candidate will return a new `IO::Path` object, with the extension
    changed to the the `$replacement`. The user can set the `:parts` argument
    to `0` if they want to *append* an extra extension. The operation is
    equivalent to:

    ```perl6
        my $new-ext = 'txt';
        say (.substr(0, .chars - .extension.chars) ~ $new-ext).IO
            with 'foo.tar.gz'.IO
        # OUTPUT: «"foo.tar.txt".IO␤»
    ```

    Note: since `.extension` returns the extension without the leading dot,
    the replacement string does not have it either. However, since the users
    may be inclined to include it, we should warn if it is included.
