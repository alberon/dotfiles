# Copyright 2008 Neil Martinsen-Burrell
# Copyright (C) 2005, 2006, 2007 Canonical Ltd
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

import subprocess
from bzrlib import (
    branch,
    errors,
    trace
)

class NoRemoteBranch(errors.NotBranchError):

    _fmt = ("No branch to mirror to at %(path)s.\n"
            "Please create the remote branch to mirror to.")


class Updater(object):

    """Update another branch to this branch's head"""

    def __init__(self, branch, revid, config):
        self.branch = branch
        self.revid = revid
        self.config = config

    def should_run(self):
        """Determine whether we can and should do anything.

        We only update the remote branch if it is local or accessible by ssh,
        which means URLs which start with bzr+ssh, ssh or sftp.
        """
    
        location = self.target()
        if location is None:
            return False

        def _is_probably_not_a_path(loc):
            return '://' in loc

        if _is_probably_not_a_path(location):
            if (location.startswith('sftp://') or  
               location.startswith('ssh://') or 
               location.startswith('bzr+ssh://') or  
               location.startswith('file://')):
                return True
            else:
                trace.note('Not updating post_commit_mirror location %s' % 
                         location)
                return False
        else:
            return True

    def target(self):
        """Get the target location.  Return None if not present."""
        return self.config.get_user_option('post_commit_mirror')

    def _get_target_branch(self):
        """Get a branch for the target.

        Borrowed from push-and-update.  DO NOT create a new branch at the
        target location.
        """
        target = self.target()
        try:
            target_branch = branch.Branch.open(target) 
        except errors.NotBranchError:
            raise NoRemoteBranch(target)
        return target_branch
 
    def mirror_to_target(self):
        """Push the new revision, run update on the target's tree."""
        if not self.should_run():
            return

        self.target_branch = self._get_target_branch()
        self.branch.push(self.target_branch, overwrite=True)
        self.update_working_copy()

    def update_working_copy(self):
        """Update the target branch's working copy.

        Code borrowed from push-and-update.
        """
        try:
            wt = self.target_branch.bzrdir.open_workingtree()
        except errors.NotLocalUrl:
            self.update_remote_working_copy()
        else:
            wt.update()

    def update_remote_working_copy(self):
        """Update the target branch's working copy if it isn't local."""
        target_transport = self.target_branch.bzrdir.root_transport
        user = getattr(target_transport, '_user', None)
        host = getattr(target_transport, '_host')
        port = getattr(target_transport, '_port', None)
        path = getattr(target_transport, '_path', None)
        if user:
            user = '%s@' % (user,)
        else:
            user = ''

        if port:
            port = ':%s' % (port,)
        else:
            port = ''

        if path.startswith('/~/'):
            path = path[3:] # This is meant to be a relative path

        remote_bzr = self.target_branch.get_config().get_bzr_remote_path()
        # The path needs to be double escaped. We pass it to ssh as a single
        # argument, but ssh passes it to the child shell as a whole string.
        path = '"%s"' % (path,)
        cmd = ['ssh', user+host+port, remote_bzr, 'update', path]
        trace.mutter('running "%s"' % (' '.join(cmd)))

        subprocess.call(cmd)
        
        
