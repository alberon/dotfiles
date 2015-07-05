# Tests for repo-push

import os

from bzrlib import (
    branch,
    bzrdir,
    )
from bzrlib.tests import TestCaseWithTransport


class TestRepoPush(TestCaseWithTransport):

    def test_repo_push_create_new_branch(self):
        # source
        src_repo = self.make_repository('src', shared=True)
        os.chdir('src')
        br_a = src_repo.bzrdir.create_branch_convenience('branch',
            force_new_tree=True)
        wt = br_a.bzrdir.open_workingtree()
        self.build_tree(['branch/foo'])
        wt.add('foo')
        wt.commit('1', rev_id='one-id')
        # dest
        dest = self.make_repository('../dest', shared=True)
        # repo-push
        self.run_bzr('repo-push ../dest')
        # inspect result
        br_b = branch.Branch.open_containing('../dest/branch')[0]
        self.assertEquals(
            branch.BranchFormat.find_format(br_a.bzrdir).__class__,
            branch.BranchFormat.find_format(br_b.bzrdir).__class__)
        self.assertEquals(['one-id'], br_b.revision_history())

    def test_repo_push_create_new_branch_in_old_format(self):
        # source
        src_repo = self.make_repository('src', shared=True)
        os.chdir('src')
        br_dir = bzrdir.BzrDir.create('branch')
        br_a = branch.BzrBranchFormat5().initialize(br_dir)
        wt = br_a.bzrdir.create_workingtree()
        self.build_tree(['branch/foo'])
        wt.add('foo')
        wt.commit('1', rev_id='one-id')
        # dest
        dest = self.make_repository('../dest', shared=True)
        # repo-push
        self.run_bzr('repo-push ../dest')
        # inspect result
        br_b = branch.Branch.open_containing('../dest/branch')[0]
        self.assertEquals(branch.BzrBranchFormat5,
            branch.BranchFormat.find_format(br_b.bzrdir).__class__)
        self.assertEquals(['one-id'], br_b.revision_history())

    def test_repo_push_tags(self):
        # source
        src_repo = self.make_repository('src', shared=True)
        os.chdir('src')
        br_dir = bzrdir.BzrDir.create('branch')
        br_a = branch.BzrBranchFormat6().initialize(br_dir)
        wt = br_a.bzrdir.create_workingtree()
        self.build_tree(['branch/foo'])
        wt.add('foo')
        wt.commit('1', rev_id='one-id')
        # add tag
        br_a.tags.set_tag('mytag', 'one-id')
        # dest
        dest = self.make_repository('../dest', shared=True)
        # repo-push
        self.run_bzr('repo-push ../dest')
        # inspect tags
        br_b = branch.Branch.open_containing('../dest/branch')[0]
        self.assertEquals({'mytag': 'one-id'}, br_b.tags.get_tag_dict())
