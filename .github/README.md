# Dotfiles

[These dotfiles](https://github.com/alberon/dotfiles) are for use on shared or personal Alberon accounts.

You can also fork them to make your own copy, which you can customise to your liking (see below).

## Installation

### Installing on Linux

```bash
cd
wget alberon.uk/cfg
. cfg
```

If you are installing the main Alberon dotfiles (not a fork) on a personal account (not shared), set your name and email address:

```bash
setup-identity 'Your Name' 'yourname@alberon.co.uk'
```

(This will write to `~/.gitconfig_local`.)

### Installing on Windows Subsystem for Linux (WSL) with Windows Terminal

Install the [Fira Code](https://github.com/tonsky/FiraCode) font.

[Install Windows Terminal](https://www.microsoft.com/en-gb/p/windows-terminal/9n0dx20hk701#activetab=pivot:overviewtab). (Note: If you installed it *before* setting up Ubuntu, run "configure WSL shortcuts" to add the shortcuts.)

Click Start, search for `features` and select "Turn Windows features on or off". Tick "Windows Subsystem for Linux" and click OK. Reboot.

[Install Ubuntu](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6?activetab=pivot:overviewtab). Run it, wait while it completes setup, set a username and password when prompted, then quit.

[Install VcXsrv](https://sourceforge.net/projects/vcxsrv/), then run XLaunch from the Start Menu. Accept the default settings except untick "Primary Selection". Save the configuration into the `shell:startup` folder so it's started automatically.

Launch Windows Terminal from the start menu, click the tab dropdown menu, then Ubuntu.

Run:

```bash
cd
wget alberon.uk/cfg
. cfg
```

**Tip:** To reinstall Ubuntu without re-downloading it, open a Command Prompt tab (or PowerShell) and run `wslconfig /u Ubuntu`, then re-launch Ubuntu from the Start Menu. It will take a few minutes to reinstall.

### Installing on Windows Subsystem for Linux (WSL) with WSLtty

Install the [Fira Code](https://github.com/tonsky/FiraCode) font.

Click Start, search for `features` and select "Turn Windows features on or off". Tick "Windows Subsystem for Linux" and click OK. Reboot.

[Install Ubuntu](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6?activetab=pivot:overviewtab). Run it, wait while it completes setup, set a username and password when prompted, then quit.

[Install WSLtty](https://github.com/mintty/wsltty) (`x86_64`). (Note: If you installed it *before* setting up Ubuntu, run "configure WSL shortcuts" to add the shortcuts.)

[Install VcXsrv](https://sourceforge.net/projects/vcxsrv/), then run XLaunch from the Start Menu. Accept the default settings except untick "Primary Selection". Save the configuration into the `shell:startup` folder so it's started automatically.

Run "Ubuntu Terminal" from the start menu. Run:

```bash
cd
wget djm.me/cfg
. cfg
```

Close and re-open Ubuntu Terminal to reload the WSLtty configuration.

Optionally, install updates and some additional packages:

```bash
agu
agar
agi dos2unix php-cli tree unzip whois zip
```

### Installing on Cygwin (Windows)

***This is not actively tested - WSL is recommended.***

Install the [Fira Code](https://github.com/tonsky/FiraCode) font.

[Install Cygwin](https://cygwin.com/install.html) - select [any local mirror](https://cygwin.com/mirrors.html) (e.g. `mirrorservice.org` for UK), and when prompted add these packages:

- `git`
- `wget`

**Tip:** Select View > Full mode, then use the search box to find them.

Once it's installed, run Cygwin Terminal and run this:

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
wget -O /bin/apt-cyg https://rawgit.com/transcode-open/apt-cyg/master/apt-cyg
chmod +x /bin/apt-cyg
apt-cyg install bash-completion bind-utils chere curl dos2unix git-completion inetutils less links make ncurses procps-ng tmux tree unzip vim whois xinit
```

(They can also be installed from the GUI - but it's much more tedious to find them all!)

And run this to add Cygwin to Explorer's right-click menu:

```bash
chere -icmf -t mintty -s bash -e 'Open in Cygwin Terminal'
```

## Upgrading

When you log in, a maximum of once per day, dotfiles will automatically check for and install any updates from the configured upstream repo.

To upgrade manually, run `cfg pull` (or, equivalently, `cd; git pull`).

**Note:** If you have forked the repo, it won't check the `alberon` repo automatically - see above.

## Bash aliases and commands

There are lots of aliases and commands. Here are the most useful ones:

| Alias        | Expansion                                     | Comments                                                 |
|--------------|-----------------------------------------------|----------------------------------------------------------|
| `a`          | `webpack`, `gulp` or `npm run`                | Asset builder                                            |
| `acsq`       | `apt search`                                  | } Originally `apt-cache ...`                             |
| `acsh`       | `apt show`                                    | }                                                        |
| `agac`       | `sudo apt autoclean`                          | } Originally `apt-get ...`                               |
| `agar`       | `sudo apt autoremove`                         | }                                                        |
| `agi`        | `sudo apt install`                            | }                                                        |
| `agr`        | `sudo apt remove`                             | }                                                        |
| `agu`        | `sudo apt update && sudo apt-get upgrade`     | }                                                        |
| `art`        | `php artisan`                                 | For Laravel (searches parent directories too)            |
| `b`          | `cd -`                                        | Go Back                                                  |
| `c`          | `cd && ls`                                    | Change directory then list files                         |
| `cfg`        | `cd $HOME && git ...`                         | Run a `git` command on the Dotfiles                      |
| `cg`         | `cd <git root>`                               | Go to Git repository root                                |
| `com`        | `composer`                                    |                                                          |
| `cv`         | `cd vendor/alberon/`                          | You can also pass in a package name                      |
| `cw`         | `cd <web root>`                               | Go to web root                                           |
| `cwc`        | `cd wp-content/`                              | Go to WordPress content directory                        |
| `cwp`        | `cd wp-content/plugins/`                      | Go to WordPress plugins directory                        |
| `cwt`        | `cd wp-content/themes/<theme>/`               | Go to WordPress theme directory                          |
| `cy`         | `cypress`                                     |                                                          |
| `d`          | `docker`                                      |                                                          |
| `db`         | `docker build`                                |                                                          |
| `dc`         | `docker-compose`                              |                                                          |
| `dclean`     | `docker container prune; docker image prune`  | Clean up stopped containers and untagged images          |
| `dev`        | `a h` and `phpstorm` in Tmux split panes      | Tmux must already be running                             |
| `dkill`      | `docker kill $(docker ps -ql)`                | Kill most recent container                               |
| `dkillall`   | `docker kill $(docker ps -q)`                 | Kill all running containers                              |
| `dr`         | `docker run`                                  |                                                          |
| `dresume`    | `docker start -ai "$(docker ps ...)"`         | Resume most recently stopped container                   |
| `dri`        | `docker run -it`                              | Run interactively, e.g. `dri ubuntu`                     |
| `dsh`        | `docker run ... /bin/bash`                    | Run /bun/bash in the container (with agent forwarding)   |
| `dstop`      | `docker stop $(docker ps -ql)`                | Stop most recent container                               |
| `dstopall`   | `docker stop $(docker ps -q)`                 | Stop all running containers                              |
| `dus`        | `du -sh`                                      | Also sorts files/directories by size                     |
| `e`          | `vim`                                         | Editor                                                   |
| `g`          | `git`                                         | See below for a list of Git aliases                      |
| `h`          | `ssh $1 tmux ...`                             | Connect to remote server and run Tmux on it              |
| `ide`        | `scripts/ide-helper.sh`                       | Laravel [IDE Helper](https://github.com/barryvdh/laravel-ide-helper) |
| `l`          | `ls -l`                                       |                                                          |
| `la`         | `ls -lA`                                      | List with hidden files                                   |
| `lsa`        | `ls -A`                                       |                                                          |
| `m`          | `exec tmux ...`                               | Launch Tmux or switch sessions                           |
| `mark`       |                                               | Creates an alias for the current directory (`cd $PWD`)   |
| `marks`      |                                               | List current directory aliases                           |
| `md`         | `mkdir && cd`                                 |                                                          |
| `mfs`        | `php artisan migrate:fresh --seed`            |                                                          |
| `mp`         | `multipass`                                   | [Multipass](https://multipass.run/)                      |
| `mux`        | `tmuxinator`                                  | [Tmuxinator](https://github.com/tmuxinator/tmuxinator)   |
| `myip`       | `curl ipinfo.io`                              | Show your current public IP address info                 |
| `pow`        | `sudo poweroff`                               |                                                          |
| `pping`      |                                               | Pretty Ping (visual `ping`)                              |
| `pu`         | `phpunit`                                     |                                                          |
| `pwgen`      |                                               | Password generator                                       |
| `redis`      | `redis-cli`                                   |                                                          |
| `reload`     | `exec bash -l`                                | Run this after modifying any Bash config file            |
| `s`          | `sudo`                                        |                                                          |
| `sc`         | `systemctl`                                   |                                                          |
| `se`         | `sudo vim`                                    |                                                          |
| `sf`         | `./symfony`                                   | For Symfony (searches parent directories too)            |
| `sl`         | `sudo ls`                                     |                                                          |
| `sls`        | `serverless`                                  | [Serverless Framework](https://www.serverless.com/)      |
| `storm`      | `phpstorm`                                    |                                                          |
| `t`          |                                               | See below for details about the `t` script runner        |
| `tarc`       | `tar jcvf ...` or `7z a ...`                  | Zip up the given directory                               |
| `tf`         | `terraform`                                   |                                                          |
| `u`          | `cd ..`                                       | Go Up                                                    |
| `uu`         | `cd ../..`                                    | Repeat `u` up to 6 times to go up 6 levels               |
| `unmark`     |                                               | Delete a directory alias (see `mark`)                    |
| `v`          | `vagrant`                                     |                                                          |
| `xdebug on`  | export XDEBUG_SESSION=1                       | Enable Xdebug step debugging for CLI scripts             |
| `xdebug off` | unset XDEBUG_SESSION                          | Disable Xdebug step debugging                            |
| `xe`         | `vim && chmod +x`                             | Create new executable file and edit it                   |
| `xp`         | `explorer.exe`                                | Run Windows Explorer from WSL / Cygwin                   |

**Note:** Some expansions are simplified in the list above - e.g. `l` is actually aliased to `ls -hFl --color=always --hide=*.pyc --hide=*.sublime-workspace` on Linux or `LSCOLORS=ExGxFxDaCaDaDahbaDacec ls -hFlG` on Mac.

There are also two custom key combinations:

- `Ctrl-Alt-Left`: `prevd` - Go back a directory (like `b` or `cd -`, but it can be repeated several times like in a web browser)
- `Ctrl-Alt-Right`: `nextd` - Go forward a directory

## Git aliases and custom subcommands

Combined with the `g` alias above, these make easy to type Git commands, e.g. `g s` instead of `git status`:

| Alias        | Expansion                                         | Comments                                                 |
|--------------|---------------------------------------------------|----------------------------------------------------------|
| `g a`        | `git add -A`                                      | Adds *and* removes files                                 |
| `g b`        | `git branch`                                      |                                                          |
| `g ba`       | `git branch -a`                                   |                                                          |
| `g bclean`   | `git branch -d ...`                               | Delete branches that have been merged into `master`      |
| `g c`        | `git commit -m`                                   | e.g. `g c "Commit message"`                              |
| `g ca`       | `git commit --amend --no-edit`                    | Modify the previous commit, keep the same message        |
| `g ce`       | `git commit --amend`                              | Modify the previous commit, edit the message             |
| `g cls`      | `git grep -i "class\s\+$1\b"`                     | Search for class definition                              |
| `g co`       | `git checkout`                                    |                                                          |
| `g cp`       | `git cherry-pick`                                 |                                                          |
| `g d`        | `git diff`                                        |                                                          |
| `g dc`       | `git diff --cached`                               | Shows diff for staged files                              |
| `g f`        | `git fetch`                                       |                                                          |
| `g files`    | `git ls-files \| grep`                            | Find file by name                                        |
| `g fun`      | `git grep -i "function\s\+$1\b"`                  | Search for function definition                           |
| `g g`        | `git grep`                                        |                                                          |
| `g g3`       | `git grep --context=3`                            | Also `g6` and `g9`                                       |
| `g ga`       | `git rev-list | grep ...`                         | Grep all files in the Git history                        |
| `g gc-all`   | `git gc ...`                                      | Run garbage collection on everything possible            |
| `g gf`       | `git ls-files | grep ...`                         | Find files by name                                       |
| `g gi`       | `git grep --ignore-case`                          |                                                          |
| `g gi3`      | `git grep --ignore-case --context=3`              | Also `gi6` and `gi9`                                     |
| `g in`       | `git log origin/master..`                         | Lists commits incoming from the default remote           |
| `g io`       | `git log --left-right origin/master..HEAD`        | Lists commits incoming & outgoing to the default remote  |
| `g l`        | `git log --name-status`                           | Includes list of modified files                          |
| `g l1`       | `git log --name-status --pretty=...`              | Single-line format                                       |
| `g lg`       | `git log --graph`                                 |                                                          |
| `g lg1`      | `git log --graph --pretty=...`                    | Single-line format                                       |
| `g ll`       | `git log`                                         | Without list of modified files                           |
| `g lp`       | `git log --patch`                                 | Displays diff with each log entry                        |
| `g lpw`      | `git log --patch --ignore-all-space`              | Displays diff excluding whitespace changes               |
| `g m`        | `git merge`                                       |                                                          |
| `g mi`       | `git checkout $1 && git merge <old> && ...`       | Merge the current branch into the target branch          |
| `g mt`       | `git mergetool`                                   |                                                          |
| `g out`      | `git log ..origin/master`                         | Lists commits outgoing to the default remote             |
| `g p`        | `git push`                                        |                                                          |
| `g pt`       | `git push --tags`                                 |                                                          |
| `g pu`       | `git push -u origin HEAD`                         | Push and set upstream                                    |
| `g s`        | `git status`                                      |                                                          |
| `g sub`      | `git submodule`                                   |                                                          |
| `g sync`     | `git submodule sync; submodule update --init`     |                                                          |
| `g todo`     | `git grep 'TODO\|XXX\|FIXME'`                     |                                                          |

## Automatic sudo

These commands will automatically be prefixed with `sudo`:

- `a2disconf`
- `a2dismod`
- `a2dissite`
- `a2enconf`
- `a2enmod`
- `a2ensite`
- `addgroup`
- `adduser`
- `apt`
- `apt-add-repository`
- `dpkg-reconfigure`
- `groupadd`
- `groupdel`
- `groupmod`
- `php5dismod`
- `php5enmod`
- `phpdismod`
- `phpenmod`
- `poweroff`
- `reboot`
- `service`
- `shutdown`
- `snap`
- `systemctl` (unless `--user` flag is given)
- `ufw`
- `updatedb`
- `useradd`
- `userdel`
- `usermod`
- `yum`

If you want to force them to run under the current user, prefix them with `command` (bypasses the alias).

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
- Use tab-completion (e.g. `t d<tab> s<tab>` is 7 keys instead of 18)

## How to fork Dotfiles

This is only necessary if you want to customise your Dotfiles.

- Fork the repo on GitHub
- Install as normal (see above), OR (if you have already installed the Alberon Dotfiles), switch to your fork:
  ```bash
  git remote set-url origin https://github.com/YOURUSERNAME/dotfiles.git
  git remote set-url --push origin git@github.com:YOURUSERNAME/dotfiles.git
  git remote add alberon https://github.com/alberon/dotfiles.git
  git fetch
  ```
- Set your name and email in `~/.gitconfig_personal`
- Optional:
  - Configure your personal accounts/servers in `~/.ssh/config_personal`
  - Put your public key in `~/.ssh/id_rsa.pub`
  - Add any custom Bash configuration to `~/.bashrc` and `~/.bash_profile`
- Commit and push those changes

### How to update your fork

To update your fork with the latest changes:

```bash
cd
g pl alberon master
```

If there are any conficts, fix them, add the files (`g a <filename>`) and commit (`g ci`).

Then push your updated version to GitHub:

```bash
g p
```

