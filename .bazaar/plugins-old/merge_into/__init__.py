# Copyright (C) 2007 Canonical Ltd
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

"""Provide the 'merge-into' command.

This command allows you to merge other branches into subdirectories, rather
than always merging into root, and then needing to be moved around.
"""

from bzrlib import (
    commands,
    )


class cmd_merge_into(commands.Command):
    """Merge a branch into a subdirectory of the current one.

    LOCATION is the branch that will be merged into this one.
    SUBDIR is the subdirectory that will be used for merging.
      (defaults to basename of LOCATION)

    After running 'bzr merge OTHER SUBDIR' all of the files from OTHER will be
    present underneath the subdirectory SUBDIR.
    """

    takes_args = ['location', 'subdir?']
    takes_options = []

    def run(self, location, subdir=None):
        if not subdir: # default to same name as source dir
            import os
            subdir = os.path.basename(location)
        import merge_into
        conflicts = merge_into.merge_into_helper(location, subdir)
        if not conflicts:
            self.outf.write('merge-into successful\n')
        else:
            self.outf.write('merge-into conflicts: %s\n' % (conflicts,))
            return 1



commands.register_command(cmd_merge_into)


def load_tests(standard_tests, module, loader):
    standard_tests.addTests(loader.loadTestsFromModuleNames(
        [__name__ + '.' + x for x in [
        'test_merge_into',
        'test_bb_merge_into',
    ]]))
    return standard_tests
