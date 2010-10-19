# Copyright 2008 Neil Martinsen-Burrell
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


"""
Automatically update another branch and working tree on commit.

To enable mirroring, you need to add the ``post_commit_mirror``
configuration option on a branch.  See ``bzr help configuration`` about
ways this can be accomplished.  The simplest is to add
``post_commit_mirror = <URL>`` to the ``.bzr/branch/branch.conf`` file,
e.g.::

echo "post_commit_mirror = bzr+ssh://webserver.example.com/var/htdocs/site" >> .bzr/branch/branch.conf

Mirroring currently only works on local paths or URLs that imply ssh
access to the remote machine (sftp:// or bzr+ssh://).
"""
__version__ = '0.0.2'
version_info = tuple(int(n) for n in __version__.split('.'))

from bzrlib import trace
from bzrlib.branch import Branch
#from bzrlib.lazy_import import lazy_import

from updater import *

def branch_commit_hook(local, master, 
                       old_revno, old_revid,
                       new_revno, new_revid):
    """This is the hook that will actually run after commit."""
    Updater(master, new_revid, master.get_config()).mirror_to_target()

def install_hooks():
    """Install the hooks to run after commit."""
    Branch.hooks.install_named_hook('post_commit', branch_commit_hook,
                                    'automirror')

def test_suite():
    from unittest import TestSuite
    import bzrlib.plugins.automirror.tests
    res = TestSuite()
    res.addTest(bzrlib.plugins.automirror.tests.test_suite())
    return res

install_hooks()
