# Dotfiles

These dotfiles are mine and you should not install them yourself - but feel free to copy any bits you find useful. Or if you really want you can fork them and replace my user details with your own (Tip: `git grep davejamesmiller`).

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

I'm lazy so I have a lot of Bash aliases - here are the most useful ones:

| Alias    | Expansion                                     | Comments                                                 |
|----------|-----------------------------------------------|----------------------------------------------------------|
| `c`      | `cd && ls`                                    |                                                          |
| `u`      | `cd ..`                                       |                                                          |
| `uu`     | `cd ../..`                                    | Repeat "u" up to 6 times                                 |
| `b`      | `cd -`                                        |                                                          |
| `cg`     | `cd <git root>`                               |                                                          |
| `cw`     | `cd $www_dir`                                 | Set in ~/.bashrc_config (e.g. /home/www)                 |
| `cwc`    | `cd wp-content/`                              | Searches for it if necessary                             |
| `cwp`    | `cd wp-content/plugins/`                      |                                                          |
| `cwt`    | `cd wp-content/themes/<theme>/`               | If there's only one theme - else uses wp-content/themes/ |
| `l`      | `ls -hFl`                                     | Also hides *.pyc and *.sublime-workspace files           |
| `ls`     | `ls -hF`                                      |                                                          |
| `la`     | `ls -hFal`                                    |                                                          |
| `lsa`    | `ls -hFa`                                     |                                                          |
| `md`     | `mkdir && cd`                                 |                                                          |
| `g`      | `git`                                         | See .gitconfig for a list of Git aliases                 |
| `e`      | `vim`                                         | Short for "editor"                                       |
| `v`      | `vagrant`                                     |                                                          |
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
| `reload` | `exec bash -l`                                | Run this after modifying any Bash config file            |

## Git aliases

Combined with the `g` alias above, these make easy to type Git commands, e.g. `g s` instead of `git status`:

| Alias    | Expansion                                     | Comments                                                 |
|----------|-----------------------------------------------|----------------------------------------------------------|
| `a`      | `add -A`                                      | Adds *and* removes files                                 |
| `amend`  | `commit --amend --no-edit --reset-author`     | Modify the previous commit, keep the same message        |
| `b`      | `branch`                                      |                                                          |
| `ba`     | `branch -a`                                   |                                                          |
| `c`      | `commit -m`                                   | e.g. `g c "Commit message"                               |
| `co`     | `checkout`                                    |                                                          |
| `cp`     | `cherry-pick`                                 |                                                          |
| `d`      | `diff`                                        |                                                          |
| `dc`     | `diff --cached`                               |                                                          |
| `edit`   | `commit --amend --reset-author`               | Modify the previous commit, edit the message             |
| `f`      | `fetch`                                       |                                                          |
| `g`      | `grep`                                        |                                                          |

TODO: More... (See .gitconfig)

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
- `pow`
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
