# BranchFeed: A plugin for bzr to generate rss feeds for branches.
# Copyright (C) 2007 Canonical Limited.
#   Author: Robert Collins.
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
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# 

"""BranchFeed is a plugin for bzr to generate rss feeds for branches.

This plugin creates a branch.atom file after every commit, push and pull. The
amount of detail contained in the branch.atom file currently is always 20
items, but it is planned to be made configurable.
"""

import os
from stat import S_ISDIR

from bzrlib.commands import Command, register_command
from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
from bzrlib.branch import Branch
from bzrlib.transport import get_transport
""")
try:
    from pyinotify import EventsCodes, Notifier, ProcessEvent, WatchManager
    feedgen = True
except ImportError:
    feedgen = False
from bzrlib.plugins.branchfeed.branch_feed import install_hooks, BranchFeed


if feedgen:
    class ProcessClose(ProcessEvent):

        def event_path(self, event):
            if event.name:
                path = "%s" % os.path.join(event.path, event.name)
            else:
                path = "%s" % event.path
            return path

        def process_default(self, event):
            return
            print event
            # import pdb;pdb.set_trace()

        def _process_IN_CLOSE(self, event):
            """Update a branch when last-revision is written."""
            print "%s: closed" % self.event_path(event)

        def process_IN_CREATE(self, event):
            if event.is_dir:
                self._bzr_wm.add_watch(self.event_path(event), dir_mask)

        def process_IN_MOVED_TO(self, event):
            path = self.event_path(event)
            if path.endswith('last-revision'):
                b, _ = Branch.open_containing(path)
                BranchFeed(b).update()
                print "updated", b.base

    dir_mask = EventsCodes.IN_MOVED_TO | EventsCodes.IN_CREATE #EventsCodes.ALL_EVENTS


    class cmd_feedgen(Command):
        """Generate feeds for many branches."""

        takes_args = ['location?']

        def run(self, location='.'):
            transport = get_transport(location)
            root = transport.local_abspath('.')
            new_dirs = set('.')
            relpaths = set('.')
            while relpaths:
                relpath = relpaths.pop()
                paths = transport.list_dir(relpath)
                for path in paths:
                    st = transport.stat(relpath + '/' + path)
                    if S_ISDIR(st.st_mode):
                        if path != '.bzr':
                            new_dirs.add(relpath + '/' + path)
                        relpaths.add(relpath + '/' + path)
            # gather all dirs
            wm = WatchManager()
            added_flag = False
            handler = ProcessClose()
            handler._bzr_wm = wm
            notifier = Notifier(wm, handler)
            # read and process events
            try:
                while True:
                    if new_dirs:
                        for path in new_dirs:
                            wm.add_watch(root + '/' + path, dir_mask)
                        new_dirs = set()
                    notifier.process_events()
                    if notifier.check_events():
                        notifier.read_events()
            finally:
                notifier.stop()


def test_suite():
    import bzrlib.plugins.branchfeed.tests
    return bzrlib.plugins.branchfeed.tests.test_suite()


install_hooks()
if feedgen:
    register_command(cmd_feedgen)
