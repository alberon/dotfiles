# Changelog

## Dotfiles Version 2 (Oct 2021)

This is a major update that includes the following changes:

- Moved `~/bin` to `~/.bin`, so it's hidden from regular directory listings. If
  you have any custom scripts in `bin/`, move them to `.bin/`. (**Note:** Leave
  `bin/cfg-update` in place until you have updated *all* servers/accounts. I will
  remove it from the Alberon repo at some point in the future.)

- Moved user-specific configuration to `.bashrc_personal`, `.bash_profile_personal`,
  `.gitconfig_personal`, `.ssh/config_personal`, and the `_local` equivalents.

- Removed Bazaar (`bzr`) and Mercurial (`hg`) scripts and configuration files.

- Removed (rather old versions of)
  [Git Extras](https://github.com/tj/git-extras),
  [icdiff](https://www.jefftk.com/icdiff) and
  [mdview](https://pypi.org/project/mdview/).
  (If you use any of them and want them back, let me know and I can update them
  instead.)

- Local SSH keys (`.ssh/id_rsa`) are no longer loaded automatically, since this
  is generally handled by the operating system (Ubuntu, macOS) or Pageant.

- A load of changes to Git and Bash aliases. I didn't make a list of them all,
  so let me know if anything you use no longer works as expected!

**Expect some merge conflicts!**

Less important changes include:

- Simplified Vim configuration. Packages are now installed on first launch by
  [vim-plug](https://github.com/junegunn/vim-plug) instead of being in this
  repo. (Press `,pu` in Vim to upgrade plugins.)

- It's now possible to install the Alberon Dotfiles and set your name & email
  without forking the repo (see [README](README.md)).

- Moved `bin/cfg-install` and `bin/cfg-update` scripts to
  `.dotfiles/post-install` and `.dotfiles/post-update` respectively. (They're
  hooks, not meant to be run manually. **Note:** `bin/cfg-update` is now a
  symlink for backwards-compatibility. It can be removed once *all*
  servers/accounts have been updated to the new version.)

- Moved `README.md` to `.github/` directory so it's hidden.

- Disabled the default `sudo` notifications for new users.

It has been tested in WSL, Cygwin and Git Bash - although I strongly recommend
using WSL, if you aren't already, because I don't routinely test changes in the
other two.

--Dave
