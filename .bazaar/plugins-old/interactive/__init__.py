# Copyright (C) 2005, 2006, 2007 Aaron Bentley <aaron.bentley@utoronto.ca>
# Copyright (C) 2005, 2006 Canonical Limited.
# Copyright (C) 2006 Michael Ellerman.
# Copyright (C) 2007, 2008 Ali Sabil <ali.sabil@gmail.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


"""User interaction support for Bazaar.

This plugin includes the following commands:
    record-patch    Records a patch interactively and store it in the patches/ subfolder.

This plugin adds the --interactive (-i) option to the following commands:
    commit          Allows the user to select the hunks to be committed interactively."""

__version__ = '1.2.0'
version_info = tuple(int(n) for n in __version__.split('.'))

from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
from bzrlib import help
import record
import subprocess
""")

import sys
import os.path

import bzrlib.commands
import bzrlib.builtins
from bzrlib.option import Option

from errors import CommandError, PatchFailed, PatchInvokeError
from patchsource import BzrPatchSource
from hunk_selector import RecordPatchHunkSelector


class cmd_record_patch(bzrlib.commands.Command):
    """Records a set of changes into a patch file.

    Record is heavily inspirated from darcs record command, and it's goal is
    to be able to produce nice patches to be sent directly upstream.

    By default record asks you what you want to record, press '?' at the
    prompt to get help. To record everything run record --all.

    If filenames are specified, only the changes to those files will be
    recorded, other files will be left untouched.

    If a revision is specified, changes since that revision will be recorded.
    """

    takes_args = ['file*']
    takes_options = ['message', 'revision',
            Option('all', help='Record all changes without prompting'),
            Option('no-color', help='Never display changes in color'),
            Option('keep', help='Keep the changes in the tree')]

    def run(self, all=False, file_list=None, message=None, revision=None,
            no_color=False, keep=False):
        if revision is not None and revision:
            if len(revision) == 1:
                revision = revision[0]
            else:
                raise CommandError("record only accepts a single revision "
                                  "parameter.")

        source = BzrPatchSource(revision, file_list)
        s = record.Record(source.base)
        s.record(source, all, message, no_color, keep)
        return 0


old_commit = bzrlib.commands.get_cmd_object("commit",True).__class__

class cmd_commit(old_commit):
    takes_options = old_commit.takes_options + \
                    [Option("interactive",
                     short_name="i",
                     help="Prompt user interactively about "
                     "the changes to commit.")]

    __doc__ = old_commit.__doc__

    # TODO: this command should warn about unknown files, and possibly ask
    # whether some files should be ignored, or added.
    def run(self, selected_list=None, interactive=False, message=None, file=None, **kw):
        if interactive:
            source = BzrPatchSource(None, selected_list)
            self.base = source.base
            patches = source.readpatches()
            to_commit, to_keep = RecordPatchHunkSelector(patches).select()

            if len(to_commit) == 0:
                raise CommandError('Nothing to commit')

            # Remove the changes not be committed from the tree
            self._run_patch_retry(to_keep, source.base, reverse=True)
            try:
                old_commit.run(self, selected_list=selected_list,
                        message=message, file=file, **kw)
            finally:
                # Readd the changes not be committed from the tree
                self._run_patch_retry(to_keep, source.base)
        else:
            old_commit.run(self, selected_list=selected_list,
                    message=message, file=file, **kw)

    def _run_patch_retry(self, patches, base_dir, reverse=False, *args, **kwargs):
        if len(patches) > 0:
            try:
                self._run_patch(patches, base_dir, reverse=reverse, *args, **kwargs)
            except PatchFailed:
                try:
                    self._run_patch(patches, base_dir, reverse=reverse, strip=1, *args, **kwargs)
                except PatchFailed:
                    raise CommandError("Failed removing changes not to be "
                        "committed from the working tree!")

    def _run_patch(self, patches, base_dir, strip=0, reverse=False, dry_run=False):
        args = ['patch', '-d', base_dir, '-s', '-p%d' % strip, '-f']

        if sys.platform == "win32":
            args.append('--binary')

        if reverse:
            args.append('-R')
        if dry_run:
            args.append('--dry-run')
            stdout = stderr = subprocess.PIPE
        else:
            stdout = stderr = None

        try:
            process = subprocess.Popen(args, stdin=subprocess.PIPE,
                                       stdout=stdout, stderr=stderr)
            for patch in patches:
                process.stdin.write(str(patch))

        except IOError, e:
            raise PatchInvokeError(e, process.stderr.read())

        process.communicate()

        result = process.wait()
        if result != 0:
            raise PatchFailed()

        return result


commands = [
            {'command' : cmd_record_patch, 'decorate' : False},
            {'command' : cmd_commit,       'decorate' : True},
            ]

if hasattr(bzrlib.commands, 'register_command'):
    for command in commands:
        bzrlib.commands.register_command(command['command'],
                                         command['decorate'])


def test_suite():
    from bzrlib.tests.TestUtil import TestLoader
    import tests
    from doctest import DocTestSuite, ELLIPSIS
    from unittest import TestSuite
    import bzrtools
    import tests.clean_tree
    import tests.is_clean
    import tests.upstream_import
    import zap
    import tests.blackbox
    import tests.shelf_tests
    result = TestSuite()
    return result
