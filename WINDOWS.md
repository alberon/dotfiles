# Dotfiles on Windows

## Cygwin

[Install Cygwin](https://cygwin.com/install.html) - when prompted add these packages:

- bash-completion
- curl
- git
- git-completion
- less
- links
- tmux
- vim
- wget

**Tip:** Click the "View" button in the top-right corner to select "Full" mode, then use the search box.

When it's installed, run Cygwin Terminal and run this to set the same home directory in Cygwin and Windows (e.g. for gVim config files) - adjust paths as appropriate:

```bash
cd
cd ..
mv Dave Dave.bak && ln -s /cygdrive/c/Users/Dave
```

Then install dotfiles as normal:

```
cd
wget djm.me/cfg
. cfg
```

## ConEmu

[Install ConEmu](https://github.com/Maximus5/ConEmu).

In the settings, go to Startup > Tasks, add a new task and enter this command:

```
C:\cygwin64\bin\mintty -e /bin/bash -c "/bin/tmux -2 attach || /bin/tmux -2 new -s default"
```

Set it as the default task, and in Startup make it the startup task as well.

**Note:** I customised a lot of other options too - but I can't remember which ones!
