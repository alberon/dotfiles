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

## Bash aliases

I'm lazy so I have a lot of Bash aliases - here are the most useful ones:

| Alias   | Expansion                                     | Comments                                                 |
|---------|-----------------------------------------------|----------------------------------------------------------|
| `c`     | `cd && ls`                                    |                                                          |
| `u`     | `cd ..`                                       |                                                          |
| `uu`    | `cd ../..`                                    | Repeat "u" up to 6 times                                 |
| `b`     | `cd -`                                        |                                                          |
| `cg`    | `cd <git root>`                               |                                                          |
| `cw`    | `cd $www_dir`                                 | Set in ~/.bashrc_config (e.g. /home/www)                 |
| `cwc`   | `cd wp-content/`                              | Searches for it if necessary                             |
| `cwp`   | `cd wp-content/plugins/`                      |                                                          |
| `cwt`   | `cd wp-content/themes/<theme>/`               | If there's only one theme - else uses wp-content/themes/ |
| `l`     | `ls -hFl`                                     | Also hides *.pyc and *.sublime-workspace files           |
| `ls`    | `ls -hF`                                      |                                                          |
| `la`    | `ls -hFal`                                    |                                                          |
| `lsa`   | `ls -hFa`                                     |                                                          |
| `md`    | `mkdir && cd`                                 |                                                          |
| `g`     | `git`                                         | See .gitconfig for a list of Git aliases                 |
| `e`     | `vim`                                         | Short for "editor"                                       |
| `v`     | `vagrant`                                     |                                                          |
| `s`     | `sudo`                                        |                                                          |
| `se`    | `sudo vim`                                    |                                                          |
| `sl`    | `sudo ls`                                     |                                                          |
| `agi`   | `sudo apt-get install`                        |                                                          |
| `agr`   | `sudo apt-get remove`                         |                                                          |
| `agar`  | `sudo apt-get autoremove`                     |                                                          |
| `agu`   | `sudo apt-get update && sudo apt-get upgrade` |                                                          |
| `acs`   | `apt-cache search`                            |                                                          |
| `acsh`  | `apt-cache show`                              |                                                          |

## Git aliases

TODO

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
