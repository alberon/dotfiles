# Dotfiles

[These dotfiles](https://github.com/alberon/dotfiles) are for use on shared Alberon accounts. You can also fork them to make your own copy.

## How to fork it

- Fork the repo on GitHub
- Install as normal (see below)
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

If there are any conficts, fix them conflicts, add the files (`g a <filename>`) and commit (`g ci`), then push (`g p`).

## Installing

### Installing on Linux

You need to have `git` and `wget` installed - e.g. `sudo apt-get install git wget` or `sudo yum install git wget`.

```bash
cd
wget alberon.uk/cfg
. cfg
```

That's it. (See https://alberon.uk/cfg for the script source - don't execute scripts from the internet without knowing what they do!)

### Installing on Windows:

Install the [Fixedsys Excelsior Mono](http://askubuntu.com/a/725445) font (which is the regular Fixedsys font plus unicode characters).

[Install Cygwin](https://cygwin.com/install.html) - select [any local mirror](https://cygwin.com/mirrors.html) (e.g. `mirrorservice.org` for UK), and when prompted add these packages:

- `git`
- `vim`
- `wget`

**Tip:** Select View > Full mode, then use the search box to find them.

Once it's installed, run Cygwin Terminal and run this to set the same home directory in Cygwin and Windows:

```bash
cd /
mv $HOME $HOME.bak && ln -s "$(cygpath "$USERPROFILE")" $HOME
```

Then install dotfiles as above:

```bash
cd
wget alberon.uk/cfg
. cfg
```

Close and re-open Cygwin Terminal to reload the configuration. (**Note:** When testing I had to reload it *twice* before it picked up the changed font.)

Then run this to install some additional useful packages:

```bash
apt-cyg install bash-completion bind-utils chere curl dos2unix git-completion inetutils less links make ncurses procps-ng tmux tree unzip whois xinit
```

(They can also be installed from the GUI - but it's much more tedious to find them all!)

And run this to add Cygwin to Explorer's right-click menu:

```bash
chere -icmf -t mintty -s bash -e 'Open with Cygwin'
```

### Installing on Git for Windows (formerly mSysGit):

I don't recommend [Git for Windows](https://msysgit.github.io/) any more, but it should still work:

```bash
cd
curl alberon.uk/cfg > cfg
. cfg
```

## Upgrading

When you log in, a maximum of once per day, dotfiles will automatically check for and install any updates.

To upgrade manually, run `cfg pull` (or, equivalently, `cd; git pull`).

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
| `d`        | `docker`                                      |                                                          |
| `dc`       | `docker-compose`                              |                                                          |
| `db`       | `docker build`                                |                                                          |
| `dr`       | `docker run`                                  |                                                          |
| `dri`      | `docker run -it`                              | Run interactively, e.g. `dri ubuntu`                     |
| `dsh`      | `docker run ... /bin/bash`                    | Run /bun/bash in the container (with agent forwarding)   |
| `dresume`  | `docker start -ai "$(docker ps ...)"`         | Resume most recently stopped container                   |
| `dstop`    | `docker stop $(docker ps -ql)`                | Stop most recent container                               |
| `dstopall` | `docker stop $(docker ps -q)`                 | Stop all running containers                              |
| `dkill`    | `docker kill $(docker ps -ql)`                | Kill most recent container                               |
| `dkillall` | `docker kill $(docker ps -q)`                 | Kill all running containers                              |
| `dclean`   | `docker container prune; docker image prune`  | Clean up stopped containers and untagged images          |

**Note:** Some expansions are simplified in the list above - e.g. `l` is actually aliased to `ls -hFl --color=always --hide=*.pyc --hide=*.sublime-workspace` on Linux or `LSCOLORS=ExGxFxDaCaDaDahbaDacec ls -hFlG` on Mac.

## Git aliases

Combined with the `g` alias above, these make easy to type Git commands, e.g. `g s` instead of `git status`:

| Alias        | Expansion                                         | Comments                                                 |
|--------------|---------------------------------------------------|----------------------------------------------------------|
| `g s`        | `git status`                                      |                                                          |
| `g a`        | `git add -A`                                      | Adds *and* removes files                                 |
| `g d`        | `git diff`                                        |                                                          |
| `g dc`       | `git diff --cached`                               | Shows diff for staged files                              |
| `g c`        | `git commit -m`                                   | e.g. `g c "Commit message"`                              |
| `g amend`    | `git commit --amend --no-edit`                    | Modify the previous commit, keep the same message        |
| `g edit`     | `git commit --amend`                              | Modify the previous commit, edit the message             |
| `g l`        | `git log --name-status`                           | Includes list of modified files                          |
| `g l1`       | `git log --name-status --pretty=...`              | Single-line format                                       |
| `g lg`       | `git log --graph`                                 |                                                          |
| `g lg1`      | `git log --graph --pretty=...`                    | Single-line format                                       |
| `g ll`       | `git log`                                         | Without list of modified files                           |
| `g lp`       | `git log --patch`                                 | Displays diff with each log entry                        |
| `g lpw`      | `git log --patch --ignore-all-space`              | Displays diff excluding whitespace changes               |
| `g in`       | `git log origin/master..`                         | Lists commits incoming from the default remote           |
| `g io`       | `git log --left-right origin/master..HEAD`        | Lists commits incoming & outgoing to the default remote  |
| `g out`      | `git log ..origin/master`                         | Lists commits outgoing to the default remote             |
| `g f`        | `git fetch`                                       |                                                          |
| `g p`        | `git push`                                        |                                                          |
| `g pt`       | `git push --tags`                                 |                                                          |
| `g pu`       | `git push -u origin HEAD`                         | Push and set upstream                                    |
| `g b`        | `git branch`                                      |                                                          |
| `g ba`       | `git branch -a`                                   |                                                          |
| `g co`       | `git checkout`                                    |                                                          |
| `g g`        | `git grep`                                        |                                                          |
| `g g3`       | `git grep --context=3`                            | Also `g6` and `g9`                                       |
| `g gi`       | `git grep --ignore-case`                          |                                                          |
| `g gi3`      | `git grep --ignore-case --context=3`              | Also `gi6` and `gi9`                                     |
| `g todo`     | `git grep 'TODO\|XXX\|FIXME'`                     |                                                          |
| `g cls`      | `git grep -i "class\s\+$1\b"`                     | Search for class definition                              |
| `g fun`      | `git grep -i "function\s\+$1\b"`                  | Search for function definition                           |
| `g cp`       | `git cherry-pick`                                 |                                                          |
| `g m`        | `git merge`                                       |                                                          |
| `g mt`       | `git mergetool`                                   |                                                          |
| `g sub`      | `git submodule`                                   |                                                          |
| `g sync`     | `git submodule sync; submodule update --init`     |                                                          |
| `g files`    | `git ls-files \| grep`                            | Find file by name                                        |

## Vagrant shortcuts

Combined with the `v` alias above, these make easy to type Vagrant commands, e.g. `v s` instead of `vagrant status`:

| Alias      | Expansion                                     | Comments                                                 |
|------------|-----------------------------------------------|----------------------------------------------------------|
| `s`        | `status`                                      |                                                          |
| `gs`       | `global-status`                               |                                                          |
| `u`        | `up`                                          |                                                          |
| `p`        | `provision`                                   |                                                          |
| `d`/`down` | `suspend`                                     |                                                          |
| `bu`       | `box update`                                  |                                                          |
| `rebuild`  | `destroy && box update && up`                 |                                                          |
| `hosts`    | `hostmanager`                                 | [Update /etc/hosts files](https://github.com/smdahlen/vagrant-hostmanager) |
| `x`/`exec` | `ssh -c "cd /vagrant; $*"`                    | Run a command on the guest machine without opening Bash  |
| `h`/`tmux` | `ssh -- -t 'tmux attach \|\| tmux new'`       | More or less - see source for the full command!          |
| `uh`       | `up && tmux`                                  |                                                          |

Note: Since Vagrant doesn't really support aliases, this is actually a [Bash function](.bash/vagrant.bash) sitting in front of the real Vagrant.

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
