# Dotfiles

These dotfiles are a fork of [Dave's](https://github.com/davejamesmiller/dotfiles), suitable for use on shared accounts.

To create your own, fork the repo on GitHub, install as normal, then use `g gi alberon` (`git grep -i alberon`) to find all the places to replace with your own name / email address.

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

## Bash aliases

I'm lazy so I have a lot of Bash aliases and short commands - here are the most useful ones:

| Alias    | Expansion                                     | Comments                                                 |
|----------|-----------------------------------------------|----------------------------------------------------------|
| `c`      | `cd && ls`                                    | Change directory then list files                         |
| `u`      | `cd ..`                                       | Go Up                                                    |
| `uu`     | `cd ../..`                                    | Repeat `u` up to 6 times to go up 6 levels               |
| `b`      | `cd -`                                        | Go Back                                                  |
| `cg`     | `cd <git root>`                               | Go to Git repository root                                |
| `cw`     | `cd $www_dir`                                 | Go to WWW root - set in `~/.bashrc_config`               |
| `cwc`    | `cd wp-content/`                              | Go to WordPress content directory                        |
| `cwp`    | `cd wp-content/plugins/`                      | Go to WordPress plugins directory                        |
| `cwt`    | `cd wp-content/themes/<theme>/`               | Go to WordPress theme directory                          |
| `l`      | `ls -l`                                       |                                                          |
| `la`     | `ls -lA`                                      | List with hidden files (except `.` and `..`)             |
| `lsa`    | `ls -A`                                       |                                                          |
| `md`     | `mkdir && cd`                                 |                                                          |
| `g`      | `git`                                         | See below for a list of Git aliases                      |
| `e`      | `vim`                                         | Editor                                                   |
| `xe`     | `vim && chmod +x`                             | Create new executable file and edit it                   |
| `v`      | `vagrant`                                     |                                                          |
| `art`    | `php artisan`                                 | For Laravel (searches parent directories too)            |
| `sf`     | `./symfony`                                   | For Symfony (searches parent directories too)            |
| `t`      | `vendor/bin/phpunit` or `phpunit` (global)    | Searches parent directories too                          |
| `redis`  | `redis-cli`                                   |                                                          |
| `s`      | `sudo`                                        |                                                          |
| `se`     | `sudo vim`                                    |                                                          |
| `sl`     | `sudo ls`                                     |                                                          |
| `agi`    | `sudo apt-get install`                        |                                                          |
| `agr`    | `sudo apt-get remove`                         |                                                          |
| `agar`   | `sudo apt-get autoremove`                     |                                                          |
| `agu`    | `sudo apt-get update && sudo apt-get upgrade` |                                                          |
| `acs`    | `apt-cache search`                            |                                                          |
| `acsh`   | `apt-cache show`                              |                                                          |
| `dus`    | `du -sh`                                      | Also sorts files/directories by size                     |
| `pow`    | `sudo poweroff`                               |                                                          |
| `reload` | `exec bash -l`                                | Run this after modifying any Bash config file            |

**Note:** Expansions may be simplified in the list above - e.g. `l` is actually aliased to `ls -hFl --color=always --hide=*.pyc --hide=*.sublime-workspace` on Linux or `LSCOLORS=ExGxFxDaCaDaDahbaDacec ls -hFlG` on Mac.

## Git aliases

Combined with the `g` alias above, these make easy to type Git commands, e.g. `g s` instead of `git status`:

| Alias    | Expansion                                     | Comments                                                 |
|----------|-----------------------------------------------|----------------------------------------------------------|
| `s`      | `status`                                      |                                                          |
| `a`      | `add -A`                                      | Adds *and* removes files                                 |
| `d`      | `diff`                                        |                                                          |
| `dc`     | `diff --cached`                               | Shows diff for staged files                              |
| `c`      | `commit -m`                                   | e.g. `g c "Commit message"`                              |
| `amend`  | `commit --amend --no-edit`                    | Modify the previous commit, keep the same message        |
| `edit`   | `commit --amend`                              | Modify the previous commit, edit the message             |
| `l`      | `log --name-status`                           | Includes list of modified files                          |
| `l1`     | `log --name-status --pretty=...`              | Single-line format                                       |
| `lg`     | `log --graph`                                 |                                                          |
| `lg1`    | `log --graph --pretty=...`                    | Single-line format                                       |
| `ll`     | `log`                                         | Without list of modified files                           |
| `lp`     | `log --patch`                                 | Displays diff with each log entry                        |
| `lpw`    | `log --patch --ignore-all-space`              | Displays diff excluding whitespace changes               |
| `in`     | `log origin/master..`                         | Lists commits incoming from the default remote           |
| `io`     | `log --left-right origin/master..HEAD`        | Lists commits incoming & outgoing to the default remote  |
| `out`    | `log ..origin/master`                         | Lists commits outgoing to the default remote             |
| `f`      | `fetch`                                       |                                                          |
| `p`      | `push`                                        |                                                          |
| `pt`     | `push --tags`                                 |                                                          |
| `pu`     | `push -u origin HEAD`                         | Push and set upstream                                    |
| `b`      | `branch`                                      |                                                          |
| `ba`     | `branch -a`                                   |                                                          |
| `co`     | `checkout`                                    |                                                          |
| `g`      | `grep`                                        |                                                          |
| `g3`     | `grep --context=3`                            | Also `g6` and `g9`                                       |
| `gi`     | `grep --ignore-case`                          |                                                          |
| `gi3`    | `grep --ignore-case --context=3`              | Also `gi6` and `gi9`                                     |
| `todo`   | `grep 'TODO\|XXX\|FIXME'`                     |                                                          |
| `cls`    | `grep -i "class\s\+$1\b"`                     | Search for class definition                              |
| `fun`    | `grep -i "function\s\+$1\b"`                  | Search for function definition                           |
| `cp`     | `cherry-pick`                                 |                                                          |
| `m`      | `merge`                                       |                                                          |
| `mt`     | `mergetool`                                   |                                                          |
| `sub`    | `submodule`                                   |                                                          |
| `sync`   | `submodule sync; submodule update --init`     |                                                          |
| `files`  | `ls-files | grep`                             | Find file by name                                        |

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

## Supported operating systems

Tested on:

- Linux - Debian, Ubuntu, CentOS
- Windows (under MSysGit)
- Mac OS X (may be out of date!)
