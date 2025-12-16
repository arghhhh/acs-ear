

I executed:

git update-index --skip-worktree png/julia/*.svg

to stop being spammed by git status because Julia seems to change the contents of the svg files every time.
(It seems to choose arbitrary names for tags that change every time.  Does not seem like good software engineering to me....)

See: https://stackoverflow.com/questions/13630849/git-difference-between-assume-unchanged-and-skip-worktree/13631525#13631525

I assume that the files can be explicitly added and commit as usual.

