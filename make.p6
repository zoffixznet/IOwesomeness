#!/usr/bin/env perl6

constant AP = 'Action-Plan/'.IO;

'Action-Plan.md'.IO.spurt:
    add-TOC
        join "\n\n" ~ "-" x 30 ~ "\n\n",
            AP.child('header.md').slurp,
                <non-conflicting  backcompat  non-backcompat
                    controversial  removals>.map({read-section AP.child: $_}),
            AP.child('footer.md').slurp;

sub read-section {
    join "\n\n" ~ "-" x 30 ~ "\n\n",
        $^name.IO.child('header.md').slurp,
        |$name.&dir(:test(none <. .. header.md>)).sort».slurp
}

sub add-TOC {
    join "\n", "# Table of Contents",
        $^content.lines.grep(*.starts-with: '#').map({
            /^ ('#'+) \s* (\N+)/ or next;
            my ($indent, $title) = ~$0, ~$1;
            my $discussion = $title.contains: 'for discussion';
            $title.subst-mutate: /\s* '[' \N+/, '';
            '    ' x$indent.chars-1
                ~ "- [$title](#$title.subst(:g, ' ', '-').subst(/<-[\w-]>/, '', :g).lc()"
                ~ "{'-issue-for-discussion' x $discussion})"
        }),
    $content;
}
