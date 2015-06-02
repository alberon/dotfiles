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

"""The guts of the 'merge_into' command."""

from bzrlib import (
    branch,
    errors,
    generate_ids,
    inventory,
    merge,
    osutils,
    revision,
    repository,
    trace,
    workingtree,
    )


class MergeIntoMerger(merge.Merger):
    """Merger that understands other_tree will be merged into a subdir.

    This also changes the Merger api so that it uses real Branch, revision_id,
    and RevisonTree objects, rather than using revision specs.
    """

    target_subdir = ''

    def __init__(self, this_tree, other_branch, other_tree, target_subdir):
        """Create a new MergeIntoMerger object.

        :param this_tree: The tree that we will be merging into.
        :param other_branch: The Branch we will be merging from.
        :param other_tree: The RevisionTree object we want to merge.
        :param target_subdir: The relative path where we want to merge
            other_tree into this_tree
        """
        # It is assumed that we are merging a tree that is not in our current
        # ancestry, which means we are using the "EmptyTree" as our basis.
        null_ancestor_tree = this_tree.branch.repository.revision_tree(
                                revision.NULL_REVISION)
        super(MergeIntoMerger, self).__init__(
            this_branch=this_tree.branch,
            this_tree=this_tree,
            other_tree=other_tree,
            base_tree=null_ancestor_tree,
            )
        self._target_subdir = target_subdir
        self.other_branch = other_branch
        self.other_rev_id = other_tree.get_revision_id()
        self.other_basis = self.other_rev_id
        self.base_is_ancestor = True
        self.backup_files = True
        self.merge_type = merge.Merge3Merger
        self.show_base = False
        self.reprocess = False
        self.interesting_ids = None
        self.merge_type = Wrapper(Merge3MergeIntoMerger,
                                  target_subdir=self._target_subdir)
        self._finish_init()

    def _finish_init(self):
        """Now that member variables are set, finish initializing."""

        # This is usually done in set_other(), but we already set it as part of
        # the constructor.
        self.this_branch.fetch(self.other_branch,
                               last_revision=self.other_basis)


class Merge3MergeIntoMerger(merge.Merge3Merger):
    """This handles the file-by-file merging."""

    def __init__(self, *args, **kwargs):
        # All of the interesting work happens during Merge3Merger.__init__(),
        # so we have have to hack in to get our extra parameters set.
        self._target_subdir = kwargs.pop('target_subdir')
        this_tree = kwargs.get('this_tree')
        other_tree = kwargs.get('other_tree')
        self._fix_other_tree(this_tree, other_tree)

        super(Merge3MergeIntoMerger, self).__init__(*args, **kwargs)

    def _fix_other_tree(self, this_tree, other_tree):
        """We need to pretend that other_tree's root is actually not at ''."""
        parent_dir, name = osutils.split(self._target_subdir)
        parent_id = this_tree.path2id(parent_dir)

        root_ie = other_tree.inventory.root
        root_ie.parent_id = parent_id
        root_ie.name = name

        new_file_id = generate_ids.gen_file_id(name)
        trace.mutter('munging root_ie.file_id: %s => %s', root_ie.file_id,
                     new_file_id)
        del other_tree.inventory._byid[root_ie.file_id]
        root_ie.file_id = new_file_id
        other_tree.inventory._byid[new_file_id] = root_ie
        # We need to fake a new id for root_ie
        for child_ie in root_ie.children.itervalues():
            child_ie.parent_id = new_file_id

    def fix_root(self):
        """Clean up the roots for the final inventory."""
        # In the main bzrlib code, this forces the new tree to use the same
        # tree root as the old tree. But merge-into explicitly doesn't want
        # that. So the first portion is just a copy of the old code, and then
        # we change the rest.
        try:
            self.tt.final_kind(self.tt.root)
        except NoSuchFile:
            self.tt.cancel_deletion(self.tt.root)
        if self.tt.final_file_id(self.tt.root) is None:
            self.tt.version_file(self.tt.tree_file_id(self.tt.root),
                                 self.tt.root)
        # All we do is skip the step which used to sanitize the root id.


class Wrapper(object):
    """Wrap a class to provide extra parameters."""

    # Merger.do_merge() sets up its own set of parameters to pass to the
    # 'merge_type' member. And it is difficult override do_merge without
    # re-writing the whole thing, so instead we create a wrapper which will
    # pass the extra parameters.

    def __init__(self, merge_type, **kwargs):
        self._extra_kwargs = kwargs
        self._merge_type = merge_type

    def __call__(self, *args, **kwargs):
        kwargs.update(self._extra_kwargs)
        return self._merge_type(*args, **kwargs)

    def __getattr__(self, name):
        return getattr(self._merge_type, name)


def merge_into_helper(location, subdir, this_location='.'):
    """Handle the command line functionality, etc."""
    import os
    wt, subdir_relpath = workingtree.WorkingTree.open_containing(
                        osutils.pathjoin(this_location, subdir))
    branch_to_merge = branch.Branch.open(location)

    wt.lock_write()
    branch_to_merge.lock_read()
    try:
        # 'subdir' is given relative to 'this_location', convert it back into a
        # path relative to wt.basedir. This also normalizes the path, so things
        # like '.' and '..' are removed.
        target_tree = branch_to_merge.basis_tree()
        target_tree.lock_read()
        try:
            merger = MergeIntoMerger(this_tree=wt,
                                     other_tree=target_tree,
                                     other_branch=branch_to_merge,
                                     target_subdir=subdir_relpath,
                                    )
            merger.set_base_revision(revision.NULL_REVISION, branch_to_merge)
            conflicts = merger.do_merge()
            merger.set_pending()
        finally:
            target_tree.unlock()
    finally:
        branch_to_merge.unlock()
        wt.unlock()
    return conflicts
