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

import os
from bzrlib.tests import TestCaseWithTransport, KnownFailure


class TestAutoMove(TestCaseWithTransport):

    def assertMoved(self, from_path, to_path):
        self.failIfExists(from_path)
        self.assertNotInWorkingTree(from_path)
        self.failUnlessExists(to_path)
        self.assertInWorkingTree(to_path)

    def test_move_unchanged(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'foo\n')])
        tree.add(['a'])
        tree.commit('init')
        os.rename('a', 'b')
        out, err = self.run_bzr('automv')
        self.assertEquals('a => b (100% similar)\n', out)
        self.assertMoved('a', 'b')

    def test_move_changed(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'a\nb\nc\nd\ne\nf\n')])
        tree.add(['a'])
        tree.commit('init')
        os.rename('a', 'b')
        self.build_tree_contents([('b', 'a\nb\nc\nX\ne\nf\n')])

        out, err = self.run_bzr('automv')
        self.assertEquals('a => b (83% similar)\n', out)
        self.assertMoved('a', 'b')

    def test_move_back_and_forth_with_commit(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'foo\n')])
        tree.add(['a'])
        tree.commit('init')
        os.rename('a', 'b')
        out, err = self.run_bzr('automv')
        self.assertEquals('a => b (100% similar)\n', out)
        self.assertMoved('a', 'b')
        tree.commit('move')
        os.rename('b', 'a')
        out, err = self.run_bzr('automv')
        self.assertEquals('b => a (100% similar)\n', out)
        self.assertMoved('b', 'a')

    def test_move_back_and_forth_without_commit(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'foo\n')])
        tree.add(['a'])
        tree.commit('init')
        os.rename('a', 'b')
        out, err = self.run_bzr('automv')
        self.assertEquals('a => b (100% similar)\n', out)
        self.assertMoved('a', 'b')
        os.rename('b', 'a')
        out, err = self.run_bzr('automv')
        self.assertEquals('b => a (100% similar)\n', out)
        self.assertMoved('b', 'a')

    def test_move_into_subdir(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'foo\n')])
        tree.add(['a'])
        tree.commit('init')
        os.mkdir('b')
        os.rename('a', 'b/c')
        out, err = self.run_bzr('automv')
        self.assertEquals('a => b/c (100% similar)\n', out)
        self.assertMoved('a', 'b/c')

    def test_move_into_nested_subdir(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree_contents([('a', 'foo\n')])
        tree.add(['a'])
        tree.commit('init')
        os.mkdir('b')
        os.mkdir('b/c')
        os.rename('a', 'b/c/d')
        out, err = self.run_bzr('automv')
        self.assertEquals('a => b/c/d (100% similar)\n', out)
        self.assertMoved('a', 'b/c/d')

    def test_move_directory(self):
        tree = self.make_branch_and_tree('.')
        self.build_tree(['a/'])
        self.build_tree_contents([('a/x', 'foo\n')])
        tree.add(['a/', 'a/x'])
        tree.commit('init')
        dir_a_id = tree.path2id('a')
        os.rename('a', 'b')
        out, err = self.run_bzr('automv')
        self.assertEquals('a/x => b/x (100% similar)\n', out)
        self.assertMoved('a/x', 'b/x')
        raise KnownFailure("`automv` can't rename directories yet")
        self.assertEquals(dir_a_id, tree.path2id('b'))
