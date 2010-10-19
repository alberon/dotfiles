# Copyright (C) 2005, 2006, 2007 Aaron Bentley <aaron.bentley@utoronto.ca>
# Copyright (C) 2005, 2006 Canonical Limited.
# Copyright (C) 2006 Michael Ellerman.
# Copyright (C) 2007, 2008 Ali Sabil<ali.sabil@gmail.com>
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

import os
import sys
import subprocess

from errors import CommandError, PatchFailed, PatchInvokeError
from hunk_selector import RecordPatchHunkSelector


class Record(object):
    MESSAGE_PREFIX = "# patch: "

    _paths = {
        'base'          : 'patches'
    }

    def __init__(self, base):
        self.base = os.path.normpath(base)
        self.__setup()

        self.dir = os.path.join(self.base, self._paths['base'])

    def __setup(self):
        # Create required directories etc.
        for dir in [self._paths['base']]:
            dir = os.path.join(self.base, dir)
            if not os.path.isdir(dir):
                os.mkdir(dir)

    def log(self, msg):
        sys.stderr.write(msg)

    def record(self, patch_source, all=False, patch_name=None, no_color=False,
            keep_in_tree=False):
        if no_color is False:
            color = None
        else:
            color = False

        patches = patch_source.readpatches()

        if all:
            to_shelve = patches
        else:
            to_shelve = RecordPatchHunkSelector(patches, color).select()[0]

        if len(to_shelve) == 0:
            raise CommandError('Nothing to record')

        if patch_name is None:
            patch_name = raw_input('Patch name: ')

        assert '\n' not in patch_name

        patch_path = os.path.join(self.dir, patch_name + ".diff")
        self.log('Saving patch to: "%s"\n' % patch_path)

        f = open(patch_path, 'w')

        f.write("%s%s\n" % (self.MESSAGE_PREFIX, patch_name))

        for patch in to_shelve:
            f.write(str(patch))

        f.flush()
        os.fsync(f.fileno())
        f.close()

        if keep_in_tree:
            return

        try:
            self._run_patch(to_shelve, reverse=True, dry_run=True)
            self._run_patch(to_shelve, reverse=True)
        except PatchFailed:
            try:
                self._run_patch(to_shelve, reverse=True, strip=1, dry_run=True)
                self._run_patch(to_shelve, reverse=True, strip=1)
            except PatchFailed:
                raise CommandError("Failed removing recorded changes from the"
                    "working tree!")

    def _run_patch(self, patches, strip=0, reverse=False, dry_run=False):
        args = ['patch', '-d', self.base, '-s', '-p%d' % strip, '-f']

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

