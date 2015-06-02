# Copyright (C) 2005, 2006, 2007 Aaron Bentley <aaron.bentley@utoronto.ca>
# Copyright (C) 2005, 2006 Canonical Limited.
# Copyright (C) 2006 Michael Ellerman.
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

from bzrlib import patches

class PatchSource(object):
    def __iter__(self):
        def iterator(obj):
            for p in obj.read():
                yield p
        return iterator(self)

    def readlines(self):
        raise NotImplementedError()

    def readpatches(self):
        return patches.parse_patches(self.readlines())

class FilePatchSource(PatchSource):
    def __init__(self, filename):
        self.filename = filename
        PatchSource.__init__(self)

    def readlines(self):
        f = open(self.filename, 'r')
        return f.readlines()

class BzrPatchSource(PatchSource):
    def __init__(self, revision=None, file_list=None):
        from bzrlib.builtins import tree_files
        self.tree, self.file_list = tree_files(file_list)
        self.base = self.tree.basedir
        self.revision = revision

        # Hacks to cope with v0.7 and v0.8 of bzr
        if self.revision is None:
            if hasattr(self.tree, 'basis_tree'):
                self.old_tree = self.tree.basis_tree()
            else:
                self.old_tree = self.tree.branch.basis_tree()
        else:
            revision_id = self.revision.in_store(self.tree.branch).rev_id
            if hasattr(self.tree.branch, 'repository'):
                self.old_tree = self.tree.branch.repository.revision_tree(revision_id)
            else:
                self.old_tree = self.tree.branch.revision_tree(revision_id)

        PatchSource.__init__(self)

    def readlines(self):
        from bzrlib.diff import show_diff_trees
        from StringIO import StringIO
        f = StringIO()

        show_diff_trees(self.old_tree, self.tree, f, self.file_list,
                        old_label='', new_label='')

        f.seek(0)
        return f.readlines()
