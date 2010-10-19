#!/usr/bin/env python
# Copyright (C) 2008 Marius Kruger <amanic@gmail.com>
# Published under the GNU GPL v2 or later

"""
Plugin to avoid committing trailing white space and other undesired text.

Features:

* Currently we check for new trailing whitespace, leading tabs or files
  not ending with a newline.
* You can specify which files to check by adding a config item eg.:
  ``text_check_file_filters=*.py, NEWS``
* Configurations may appear in the bazaar.conf, locations.conf or branch.conf.
* By default it would just print out warnings when you commit violating text,
  but it can be explicitly configured:
  ``text_check_action=warn``
* If you would like this plugin to prevent you from committing violating text,
  you can do this by adding the following to your configuration:
  ``text_check_action=fail``
* You can force a commit with violating text using a the
  `--text-check-warn-only` commit option.
  When this plugin is configured to 'fail', this option would temporarily
  override the action with 'warn'.
  This is handy if you have a special case and need to commit violating text,
  but don't want to go and change the configs for accepting a rare violation.
  ``bzr commit --text-check-warn-only``
* View the current configuration for a branch, you can do the following:
  ``bzr text-check-info``
* Recursively remove trailing whitespace for files matching a pattern:
  ``remove-trailing-whitespace *.py"``

Planned features, more or less in the order of priority:

* Also check for long lines. Default to 80, but be able to set it eg:
  text_checks_max_line_length=79

* Be able to to configure which checks to perform:
  text_checks=trailing-whitespace, leading-tabs, newline-at-eof, long-lines

* Automatically remove new trailing whitespace when committing. Will probably
  use the new content filters of Ian Clatworthy when that lands in bazaar.
  ``text_check_action=auto-fix``

* rule based configs
[name *.py, *.java, NEWS, README]
trailing_whitespace=fail
leading_tabs=warn
newline_at_eof=warn
long_line_length=80
long_lines=ask

"""

version_info = (0, 2, 0, 'dev', 1)
plugin_name = 'text-checker'


from bzrlib import branch, commands
from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
from bzrlib import builtins, errors, option
""")


def pre_commit_hook(local, master, old_revno, old_revid, future_revno,
        future_revid, tree_delta, future_tree):
    new_tree = future_tree
    if local is not None:
        local_branch = local
    else:
        local_branch = master

    import text_checker
    text_checker.check_text(local_branch, new_tree)


class cmd_commit(builtins.cmd_commit):
    """Commit with added --text-check-warn-only option."""
    # It would have been nice to have some sort of a command decorator for when
    # one only wants to add an option and receive a callback.

    takes_options = builtins.cmd_commit.takes_options + [
        option.Option('text-check-warn-only',
            help='Commit even if some text checks fail.'),
        ]

    def help(self):
        # Get help from above
        return builtins.cmd_commit.help(self)

    def run(self, text_check_warn_only=False, **kwargs):
        import text_checker
        # this it not thread safe, but we're not using threads as far as I know
        old_value = text_checker._text_check_warn_only
        try:
            text_checker._text_check_warn_only = text_check_warn_only
            builtins.cmd_commit.run(self, **kwargs)
        finally:
            text_checker._text_check_warn_only = old_value


class cmd_text_check_info(commands.Command):
    """Print the current config for text-checker."""

    def run(self):
        import text_checker
        br, relpath = branch.Branch.open_containing(u'.')
        file_filters, action = text_checker.get_config(br)
        self.outf.write("file_filters=%s\n" % ', '.join(file_filters))
        self.outf.write("action=%s\n" % action)

class cmd_remove_trailing_whitespace(commands.Command):
    """Remove trailing whitespace from files.

    Although we backup files like `bzr revert`, this is experimental
    so make backups before running this!
    This has

    Usage example:
    /tmp/bzr$ bzr remove-trailing-whitespace bzr
    /tmp/bzr/bzrlib$ bzr remove-trailing-whitespace *.py"
    """

    takes_args = ['name_pattern*']
    def run(self, name_pattern_list=None):
        if not name_pattern_list:
            raise errors.BzrCommandError("this command requires at least one "
                "NAME_PATTERN")
        import text_checker
        text_checker.remove_trailing_whitespace(name_pattern_list)

commands.register_command(cmd_commit, decorate=True)
commands.register_command(cmd_text_check_info, decorate=True)
commands.register_command(cmd_remove_trailing_whitespace, decorate=True)
branch.Branch.hooks.install_named_hook('pre_commit',
    pre_commit_hook, 'text-check')


def test_suite():
    from bzrlib.tests.TestUtil import TestLoader
    import tests
    return TestLoader().loadTestsFromModule(tests)
