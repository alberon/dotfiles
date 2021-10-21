# Changelog

## Dotfiles Version 2 (Oct 2021)

This is a major update that includes the following changes:

- Moved `~/bin` to `~/.bin`, so it's hidden from regular directory listings. If
  you have any custom scripts in `bin/`, move them to `.bin/`. (**Note:** Leave
  `bin/cfg-update` in place until you have updated *all* servers/accounts.)

- Removed Bazaar (`bzr`) and Mercurial (`hg`) scripts and configuration files.
  This will probably cause some merge conflicts.

- Removed (rather old versions of)
  [Git Extras](https://github.com/tj/git-extras),
  [icdiff](https://www.jefftk.com/icdiff) and
  [mdview](https://pypi.org/project/mdview/).
  (If you use any of them and want them back, let me know and I can update them
  instead.)

- Simplified Vim configuration. Packages are now installed on first launch by
  [vim-plug](https://github.com/junegunn/vim-plug) instead of being in this
  repo. (Press `,pu` in Vim to upgrade plugins.)

Less important changes include:

- Moved `bin/cfg-install` and `bin/cfg-update` scripts to
  `.dotfiles/post-install` and `.dotfiles/post-update` respectively. (They're
  hooks, not meant to be run manually. **Note:** `bin/cfg-update` is now a
  symlink for backwards-compatibility. It can be removed once *all*
  servers/accounts have been updated to the new version.)

- Moved `README.md` to `.github/` directory so it's hidden.

- Disabled the default `sudo` notifications for new users.

--Dave
