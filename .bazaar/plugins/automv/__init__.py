# Copyright (C) 2008 Lukas Lalinsky <lalinsky@gmail.com>
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

"""Automatically detect renames/moves in the working tree."""

import os
from bzrlib import osutils, trace, errors
from bzrlib.option import Option
from bzrlib.commands import register_command, Command


class cmd_automv(Command):
    """Automatically detect renames/moves in the working tree."""

    takes_options = [
        Option("threshold", type=int,
            help="Minimal textual similarity of files, to be considered "
                 "renamed (0..100, default 55)."),
        Option("dry-run",
            help="Show what would be done, but don't actually do anything."),
        ]

    def run(self, threshold=55, dry_run=False):
        from bzrlib.workingtree import WorkingTree
        tree = WorkingTree.open_containing('.')[0]
        tree.lock_write()
        try:
            self.tree = tree
            self.basis_tree = tree.basis_tree()
            self._detect_moves(threshold / 100.0, dry_run)
        finally:
            tree.unlock()

    def _detect_moves(self, threshold, dry_run):
        delta = self.tree.changes_from(self.basis_tree, want_unversioned=True)
        inv = self.tree.inventory
        unknowns = self._find_unknowns(delta)
        removed = set()
        matches = []
        for path, file_id, kind in delta.removed:
            if kind == "directory":
                continue
            path = inv.id2path(file_id)
            for new_path, new_kind in unknowns:
                if kind != new_kind:
                    continue
                similarity = self._compare_files(file_id, new_path)
                matches.append((similarity, path, new_path))
            removed.add(path)
        matches.sort(reverse=True)

        # Try to detect file renames, based on text similarity
        used = set()
        file_renames = []
        for similarity, old_path, new_path in matches:
            if similarity < threshold:
                self.outf.write(
                    "Skipping %d file(s) with similarity below "
                    "%d%%.\n" % (len(removed), threshold * 100))
                break
            if old_path not in removed or new_path in used:
                trace.mutter("File %s already moved", old_path)
                continue
            used.add(new_path)
            removed.remove(old_path)
            file_renames.append((similarity, old_path, new_path))

        # Try to detect directory renames, based on file renames
        dir_renames = []
        dir_rename_map = {}
        for similarity, old_path, new_path in file_renames:
            old_dirs = osutils.splitpath(old_path)[:-1]
            new_dirs = osutils.splitpath(new_path)[:-1]
            for old_dir, new_dir in zip(old_dirs, new_dirs):
                dir_rename_map.setdefault(old_dir, set()).add(new_dir)
        for old_dir, new_dirs in sorted(dir_rename_map.iteritems()):
            if len(new_dirs) != 1:
                continue
            new_dir = iter(new_dirs).next()
            dir_renames.append((-1, old_dir, new_dir))
        # needs to be smarted to be enabled
        dir_renames = []

        # Actually rename
        renames = dir_renames + file_renames
        for similarity, old_path, new_path in renames:
            if not dry_run:
                parent_dirs = []
                to_dir = new_path
                while True:
                    to_dir, to_tail = os.path.split(to_dir)
                    if inv.path2id(to_dir) is None:
                        parent_dirs.append(to_dir)
                    if not to_tail or not to_dir:
                        break
                if parent_dirs:
                    self.tree.add(reversed(parent_dirs))
                    self.tree.flush()
                self.tree.rename_one(old_path, new_path, after=True)
            if similarity == -1:
                self.outf.write("%s => %s\n" % (old_path, new_path))
            else:
                self.outf.write("%s => %s (%d%% similar)\n" % (
                    old_path, new_path, similarity * 100))

    def _find_unknowns(self, delta):
        unknowns = []
        for path, file_id, kind in delta.unversioned:
            if self.tree.is_ignored(path):
                continue
            if kind == "directory":
                for (relroot, top), block in osutils.walkdirs(path):
                    for relname, name, kind, statvalue, abspath in block:
                        unknowns.append([abspath, kind])
            else:
                unknowns.append([path, kind])
        return unknowns

    def _compare_files(self, file_id, path):
        old_lines = self.basis_tree.get_file(file_id).readlines()
        new_lines = self.tree.get_file_byname(path).readlines()
        total = len(old_lines) + len(new_lines)
        if total:
            from bzrlib.patiencediff import PatienceSequenceMatcher
            matcher = PatienceSequenceMatcher(None, old_lines, new_lines)
            matched = sum(b[2] for b in matcher.get_matching_blocks())
            ratio = 2.0 * matched / total
        else:
            ratio = 1.0
        return ratio


register_command(cmd_automv)


def test_suite():
    from bzrlib.tests import TestUtil
    suite = TestUtil.TestSuite()
    loader = TestUtil.TestLoader()
    testmod_names = ['test_automv']
    suite.addTest(loader.loadTestsFromModuleNames(
            ["%s.%s" % (__name__, name) for name in testmod_names]))
    return suite
