![](https://raw.githubusercontent.com/zoffixznet/debug/133cd87bf1334511e8308df97e75f8610e9744b1/assets/IOsomeness.png)

# Advance Notice of Significant Changes

As part of [the IO grant](http://news.perlfoundation.org/2017/01/grant-proposal-standardization.html) run by The Perl Foundation, we're improving our IO-related methods and
subroutines. We've identified several of the changes that will have moderate
impact on the users and may require you to update your code.

The exact changes to be made will be known by March 18th, 2017 and the
implementation will be part of the 2017.04 Rakudo compiler release on April,
15th, which will be followed by the 2017.04 Rakudo Star Perl 6 release.

## Details

### Why Are We Changing Stuff?

Our contract with the users is we don't change anything that's covered
by the Perl 6.c language version tests. This means most of the language
remains reliably stable, but IO features got short-changed on the love. The
tests for them are sparse—a big reason why the IO grant is running in the
first place—which gives core developers a lot of freedom to change them
and *to improve* them.

Despite that freedom, we realize broken code isn't a nice thing, and will
attempt to reduce the impact of the changes, by providing backwards compatible
interface to support old API, where feasible. Where not, we will provide
information of the upcoming changes; this notice is a part of that effort.

### What's Changing?

The grant covers all of IO routines and methods (excluding sockets). All of the
final changes are yet to be deliberated and ratified and we'll share the
details once they're known.

Currently, it is speculated that `link()` routine will change the order
of arguments (no backwards compatible support will be provided) and `seek()`
routine will take seek reference as a named argument instead of an enum value
(backwards compatible support *will* be provided).

It's very likely many more changes will be made. We'll be using the code of
all the modules in the ecosystem to judge the potential impact of the change
and evaluate each change on a case-by-case basis.

### Timeline

- **March 18, 2017:** finalized information on the changes will be known to the
    Core Team. Upgrade instructions for users will follow shortly after.
- **April 15, 2017:** all of the changes will be completed and 2017.04
    compiler release will be made. Rakudo Star Perl 6 distribution will
    be created from this release in the following week or two.

### Help and More Info

If you need help or more information, please [join our IRC
channel](https://webchat.freenode.net/?channels=#perl6) and ask there. You can
also contact the person performing this work via
[Twitter @zoffix](https://twitter.com/zoffix)
