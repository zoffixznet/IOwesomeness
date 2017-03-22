#!/usr/bin/env perl6

constant AP = 'Action-Plan/'.IO;

'Action-Plan.md'.IO.spurt:
    join "\n\n" ~ "-" x 30 ~ "\n" ~ "-" x 30 ~ "\n\n",
    AP.child('header.md').slurp,
    |<removals  non-backcompat  backcompat  non-conflicting  controversial>
        .map({read-section AP.child: $_}),
    AP.child('footer.md').slurp;

sub read-section {
    join "\n\n" ~ "-" x 30 ~ "\n\n",
        $^name.IO.child('header.md').slurp,
        |$name.&dir(:test(none <. .. header.md>)).sort».slurp
}
