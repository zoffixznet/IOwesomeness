`$*IN.ins`: https://github.com/perl6/doc/issues/401

-------------------------------------------------------------------------------------

stat() / .e caching issue:

18:25 	japhb 	IOninja: FWIW, the general problem is that the stat(2) system call
		is both very common and very slow.  The perl 5 solution to this was
		that every filesystem test defaulted to doing a fresh stat() for
		correctness, but it would also keep a copy of the most recently
		gathered stat buffer around, and you could explicitly indicate you
		wanted a filesystem test to operate on the cached stat buffer
		rather than do a fresh stat().
18:26 		This made a huge difference when doing multiple tests on the same
		directory entry -- the difference for tree walkers was rather extreme.
18:27 		It also allowed you to explicitly take a stat() at a given point in
		time and make use of that data, without worrying that someone would
		change the filesystem out from under you while you were working on it.
18:27 		*working with that point-in-time stat() snapshot

-------------------------------------------------------------------------------------
