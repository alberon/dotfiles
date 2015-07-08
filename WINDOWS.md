# Dotfiles on Windows

## Cygwin

[Install Cygwin](https://cygwin.com/install.html) - select [any nearby mirror](https://cygwin.com/mirrors.html) and when prompted add these packages:

- bash-completion
- bind-utils (includes `dig`, `host` and `nslookup`)
- curl
- dos2unix
- git
- git-completion
- less
- links
- tmux
- vim
- wget
- whois

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

Finally, close and re-open Cygwin *twice* to reload the configuration.

## Apt-Cyg

To make it easier to install additional packages, install [apt-cyg](https://github.com/transcode-open/apt-cyg) by running `install-apt-cyg` (or follow the instructions on the apt-cyg website to install it manually).
