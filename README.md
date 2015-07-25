# Dotfiles

[These dotfiles](https://github.com/alberon/dotfiles) are a fork of [Dave's](https://github.com/davejamesmiller/dotfiles), suitable for use on shared accounts.

## How to fork it

- Fork the repo on GitHub
- Ask Dave to add you to the [`djm.me/cfg`](https://djm.me/cfg) script
- Install as normal
- Put your public key in `~/.ssh/<name>.pub` (e.g. `~/.ssh/dave.pub`)
- Uncomment `IdentityFile` and `IdentitiesOnly` in `~/.ssh/config`
- Use `g gi alberon` (i.e. `git grep -i alberon`) to find all the places to replace with your own name / email address - currently this includes:
    - `.bash/userinfo.bash`
    - `.bazaar/bazaar.conf`
    - `.gitconfig`
    - `.grip/settings.py`
    - `.vagrant.d/provision-dotfiles.sh`
    - `bin/bzr-install`
- And optionally change the name in:
    - `.vim/plugin/snipmate-config.vim`
    - `bin/generate-mit-license`
- Commit those changes

## How to update your fork

To update your fork with the latest changes:

```bash
git pull alberon master
```

If there are any conficts, fix them any conflicts, add the files (`g a <filename>`) and commit (`g ci`).

## Installing

### On Linux:

You need to have `git` and `wget` installed - e.g. `sudo apt-get install git wget` or `sudo yum install git wget`.

```bash
cd
wget djm.me/cfg
. cfg
```

That's it. (See https://djm.me/cfg for the script source - don't execute scripts from the internet without knowing what they do!)

### On Windows:

[Install Cygwin](https://cygwin.com/install.html) - select [any local mirror](https://cygwin.com/mirrors.html) (e.g. `mirrorservice.org` for UK), and when prompted add these packages:

- git
- vim
- wget

**Tip:** Click the "View" button in the top-right corner to select "Full" mode, then use the search box.

Once it's installed, run Cygwin Terminal and run this to set the same home directory in Cygwin and Windows:

```bash
cd /
mv $HOME $HOME.bak && ln -s "$(cygpath "$USERPROFILE")" $HOME
```

Then install dotfiles as above:

```bash
cd
wget djm.me/cfg
. cfg
```

Close and re-open Cygwin Terminal to reload the configuration. (**Note:** When testing I had to reload it *twice* before it picked up the changed font.)

Then run this to install some additional useful packages:

```bash
apt-cyg install bash-completion bind-utils curl dos2unix git-completion less links ncurses tmux tree whois
```

### On Git for Windows (formerly mSysGit):

I don't recommend [Git for Windows](https://msysgit.github.io/) any more, but it should still work:

```bash
cd
curl djm.me/cfg > cfg
. cfg
```

## Bash aliases

I'm lazy so I have a lot of Bash aliases and short commands - here are the most useful ones:

| Alias      | Expansion                                     | Comments                                                 |
|------------|-----------------------------------------------|----------------------------------------------------------|
| `c`        | `cd && ls`                                    | Change directory then list files                         |
| `u`        | `cd ..`                                       | Go Up                                                    |
| `uu`       | `cd ../..`                                    | Repeat `u` up to 6 times to go up 6 levels               |
| `b`        | `cd -`                                        | Go Back                                                  |
| `cg`       | `cd <git root>`                               | Go to Git repository root                                |
| `cw`       | `cd $www_dir`                                 | Go to WWW root - set in `~/.bashrc_config`               |
| `cwc`      | `cd wp-content/`                              | Go to WordPress content directory                        |
| `cwp`      | `cd wp-content/plugins/`                      | Go to WordPress plugins directory                        |
| `cwt`      | `cd wp-content/themes/<theme>/`               | Go to WordPress theme directory                          |
| `l`        | `ls -l`                                       |                                                          |
| `la`       | `ls -lA`                                      | List with hidden files (except `.` and `..`)             |
| `lsa`      | `ls -A`                                       |                                                          |
| `md`       | `mkdir && cd`                                 |                                                          |
| `g`        | `git`                                         | See below for a list of Git aliases                      |
| `e`        | `vim`                                         | Editor                                                   |
| `xe`       | `vim && chmod +x`                             | Create new executable file and edit it                   |
| `v`        | `vagrant`                                     |                                                          |
| `art`      | `php artisan`                                 | For Laravel (searches parent directories too)            |
| `sf`       | `./symfony`                                   | For Symfony (searches parent directories too)            |
| `t`        | `find scripts/ -type f`                       | Searches parent directories too                          |
| `t -h`     | `mdview scripts/README.md`                    | Searches parent directories too                          |
| `t <name>` | `scripts/<name>.sh` (or other extension)      | Searches parent directories too                          |
| `pu`       | `vendor/bin/phpunit` or `phpunit` (global)    | Searches parent directories too                          |
| `redis`    | `redis-cli`                                   |                                                          |
| `s`        | `sudo`                                        |                                                          |
| `se`       | `sudo vim`                                    |                                                          |
| `sl`       | `sudo ls`                                     |                                                          |
| `agi`      | `sudo apt-get install`                        |                                                          |
| `agr`      | `sudo apt-get remove`                         |                                                          |
| `agar`     | `sudo apt-get autoremove`                     |                                                          |
| `agu`      | `sudo apt-get update && sudo apt-get upgrade` |                                                          |
| `acs`      | `apt-cache search`                            |                                                          |
| `acsh`     | `apt-cache show`                              |                                                          |
| `dus`      | `du -sh`                                      | Also sorts files/directories by size                     |
| `pow`      | `sudo poweroff`                               |                                                          |
| `reload`   | `exec bash -l`                                | Run this after modifying any Bash config file            |

**Note:** Expansions are simplified in the list above - e.g. `l` is actually aliased to `ls -hFl --color=always --hide=*.pyc --hide=*.sublime-workspace` on Linux or `LSCOLORS=ExGxFxDaCaDaDahbaDacec ls -hFlG` on Mac.

## Git aliases

Combined with the `g` alias above, these make easy to type Git commands, e.g. `g s` instead of `git status`:

| Alias      | Expansion                                     | Comments                                                 |
|------------|-----------------------------------------------|----------------------------------------------------------|
| `s`        | `status`                                      |                                                          |
| `a`        | `add -A`                                      | Adds *and* removes files                                 |
| `d`        | `diff`                                        |                                                          |
| `dc`       | `diff --cached`                               | Shows diff for staged files                              |
| `c`        | `commit -m`                                   | e.g. `g c "Commit message"`                              |
| `amend`    | `commit --amend --no-edit`                    | Modify the previous commit, keep the same message        |
| `edit`     | `commit --amend`                              | Modify the previous commit, edit the message             |
| `l`        | `log --name-status`                           | Includes list of modified files                          |
| `l1`       | `log --name-status --pretty=...`              | Single-line format                                       |
| `lg`       | `log --graph`                                 |                                                          |
| `lg1`      | `log --graph --pretty=...`                    | Single-line format                                       |
| `ll`       | `log`                                         | Without list of modified files                           |
| `lp`       | `log --patch`                                 | Displays diff with each log entry                        |
| `lpw`      | `log --patch --ignore-all-space`              | Displays diff excluding whitespace changes               |
| `in`       | `log origin/master..`                         | Lists commits incoming from the default remote           |
| `io`       | `log --left-right origin/master..HEAD`        | Lists commits incoming & outgoing to the default remote  |
| `out`      | `log ..origin/master`                         | Lists commits outgoing to the default remote             |
| `f`        | `fetch`                                       |                                                          |
| `p`        | `push`                                        |                                                          |
| `pt`       | `push --tags`                                 |                                                          |
| `pu`       | `push -u origin HEAD`                         | Push and set upstream                                    |
| `b`        | `branch`                                      |                                                          |
| `ba`       | `branch -a`                                   |                                                          |
| `co`       | `checkout`                                    |                                                          |
| `g`        | `grep`                                        |                                                          |
| `g3`       | `grep --context=3`                            | Also `g6` and `g9`                                       |
| `gi`       | `grep --ignore-case`                          |                                                          |
| `gi3`      | `grep --ignore-case --context=3`              | Also `gi6` and `gi9`                                     |
| `todo`     | `grep 'TODO\|XXX\|FIXME'`                     |                                                          |
| `cls`      | `grep -i "class\s\+$1\b"`                     | Search for class definition                              |
| `fun`      | `grep -i "function\s\+$1\b"`                  | Search for function definition                           |
| `cp`       | `cherry-pick`                                 |                                                          |
| `m`        | `merge`                                       |                                                          |
| `mt`       | `mergetool`                                   |                                                          |
| `sub`      | `submodule`                                   |                                                          |
| `sync`     | `submodule sync; submodule update --init`     |                                                          |
| `files`    | `ls-files | grep`                             | Find file by name                                        |

## Automatic sudo

These commands will automatically be prefixed with `sudo`:

- `a2dismod`
- `a2enmod`
- `addgroup`
- `adduser`
- `dpkg-reconfigure`
- `groupadd`
- `groupdel`
- `groupmod`
- `php5dismod`
- `php5enmod`
- `poweroff`
- `reboot`
- `service`
- `shutdown`
- `useradd`
- `userdel`
- `usermod`

## Script runner (`t` command)

The `t` command makes it easy to run scripts specific to a project (or anywhere really). First, create a `scripts/` directory in the project root. For example:

```
repo/
├── ...
└── scripts/
    ├── download/
    │   ├── live.sh
    │   └── staging.sh
    └── push.sh
```

To run these three scripts, you would normally type:

```bash
scripts/download/live.sh
scripts/download/staging.sh
scripts/push.sh
```

But using the `t` command this is simplified to:

```bash
t download live
t download staging
t push
```

Note that the file extension is not required (it can be any extension - e.g. `.sh`/`.php` - or no extension), and files in subdirectories become subcommands. It will automatically search up the directory tree, if you are in a subdirectory of the project - in that case it's equivalent to `../../scripts/push.sh` (for example).

You can also:

- Type `t <name> [args...]` to run a script with arguments
- Type `t` alone to list all the scripts available
- Type `t <dir>` to list all the scripts in a subdirectory (e.g. `t download`)
- Type `t -h` (for *help*) to display the contents of the `scripts/README.md` file (which will be syntax-highlighted if Node.js is installed)
- Type `t <dir> -h` to display the contents of `scripts/<dir>/README.md`
- Use tab-completion (e.g. `t d<tab> s<tab>` is 7 keys instead of 18)

## Supported operating systems

These scripts have been tested on various platforms at various times:

- Linux - Debian, Ubuntu, CentOS
- Windows - Cygwin, Git for Windows
- Mac OS X

However, I no longer use Git for Windows or Mac OS X, so there could be bugs.
