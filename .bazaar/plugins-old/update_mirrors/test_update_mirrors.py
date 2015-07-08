"""\
A test suite for the update-mirrors script.
"""

import os
from bzrlib.tests import TestCaseWithTransport

class TestUpdateMirrors(TestCaseWithTransport):
    
    def build_branches(self):
        self.build_tree(['parents/'
                       , 'parents/a/'
                       , 'parents/a/foo'
                       , 'parents/b/'
                       , 'parents/b/baz'
                       ])

        a = self.make_branch_and_tree('parents/a')
        a.add('foo')
        a.commit('foo', rev_id='a-1')

        b = self.make_branch_and_tree('parents/b')
        b.add('baz')
        b.commit('baz', rev_id='b-1')

        os.mkdir('children')

        self.run_bzr('branch', 'parents/a', 'children/a')
        self.run_bzr('branch', 'parents/b', 'children/b')

        # just an empty directory
        os.mkdir('children/c')

        # A child inside an empty directory
        os.mkdir('children/d')
        self.run_bzr('branch', 'parents/a', 'children/d/d')

        # A child inside a child
        self.run_bzr('branch', 'parents/a', 'children/e')
        self.run_bzr('branch', 'parents/b', 'children/e/f')

        open('parents/a/foo', 'wb').write('new foo text\n')
        a.commit('update foo', rev_id='a-2')

        open('parents/b/baz', 'wb').write('new baz text\n')
        b.commit('update baz', rev_id='b-2')

    def test_update_mirrors_retcode(self):
        self.run_bzr('update-mirrors', 'doesntexist', retcode=3)

    def test_update_mirrors(self):
        bzr = self.run_bzr
        bzr_c = self.capture

        self.build_branches()

        os.chdir('children/a')
        self.assertEquals(bzr_c('revno').strip(), '1')
        os.chdir('../b')
        self.assertEquals(bzr_c('revno').strip(), '1')
        os.chdir('../d/d')
        self.assertEquals(bzr_c('revno').strip(), '1')
        os.chdir('../../e')
        self.assertEquals(bzr_c('revno').strip(), '1')
        os.chdir('f')
        self.assertEquals(bzr_c('revno').strip(), '1')
        os.chdir('../../..')

        bzr('update-mirrors', 'children', retcode=1)

        os.chdir('children/a')
        self.assertEquals(bzr_c('revno').strip(), '2')
        os.chdir('../b')
        self.assertEquals(bzr_c('revno').strip(), '2')
        os.chdir('../d/d')
        self.assertEquals(bzr_c('revno').strip(), '2')
        os.chdir('../../e')
        self.assertEquals(bzr_c('revno').strip(), '2')
        os.chdir('f')
        self.assertEquals(bzr_c('revno').strip(), '2')
        os.chdir('../../..')

        # Nothing to be updated
        bzr('update-mirrors', 'children', retcode=0)

