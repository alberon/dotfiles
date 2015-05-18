# Dotfiles

## Installing

On Linux:

```bash
cd
wget djm.me/cfg
. cfg
```

On Windows mSysGit (Git Bash) or a system without `wget` installed:

```bash
cd
curl djm.me/cfg > cfg
. cfg
```

That's it. (See http://djm.me/cfg for the script source - don't execute scripts without knowing what they do!)

## Bash aliases & commands

I have a lot of Git aliases and custom commands set up - here are the most useful ones:

| Alias | Expansion     | Comments                                       |
|-------|---------------|------------------------------------------------|
| c     | cd && ls      |                                                |
| u     | cd ..         |                                                |
| uu    | cd ../..      | Repeat "u" up to 6 times                       |
| b     | cd -          |                                                |
| cg    | cd <git root> |                                                |
| l     | ls -hFl       | Also hides *.pyc and *.sublime-workspace files |
| ls    | ls -hF        |                                                |
| la    | ls -hFal      |                                                |
| lsa   | ls -hFa       |                                                |
| g     | git           | See .gitconfig for a list of Git aliases       |
| e     | vim           | Short for "editor"                             |
| se    | sudo vim      |                                                |
