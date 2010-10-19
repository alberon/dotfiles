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

"""Branch feed generator."""

import itertools
from string import Template
import time

from bzrlib.branch import Branch
from bzrlib.osutils import format_date


def install_hooks():
    """Install the BranchFeed hooks into bzrlib."""
    if 'post_change_branch_tip' in Branch.hooks:
        Branch.hooks.install_named_hook('post_change_branch_tip',
            post_change_hook, 'Creating atom feed')
    else:
        Branch.hooks['set_rh'].append(set_rh_hook)


def post_change_hook(change):
    """Update a branch's atom feed from the post_change_branch_tip hook."""
    BranchFeed(change.branch).update()


def set_rh_hook(branch, rev_history):
    """Update branch's atom feed from the set_rh hook."""
    BranchFeed(branch).update()


class Feed(object):
    """A Feed that can be generated."""

    ATOM_ITEM_TEMPLATE = u"""
<entry>
  <title>$title</title>
  <id>$id</id>
  <author>
    <name>$author</name>
  </author>
  <updated>$updated</updated>
  <content type="xhtml">
    <div xmlns="http://www.w3.org/1999/xhtml">
     <p>$content</p>
    </div>
  </content>
</entry>
"""

    def generate_for_iterator(self, feed, revno_revision_iterator):
        template = Template(self.ATOM_ITEM_TEMPLATE)
        for revno, revision in self.iter_revisions():
            feed += template.substitute({
                'title':'revision %s' % revno,
                'id':revision.revision_id,
                'author':revision.committer,
                'updated':format_date(revision.timestamp,
                    revision.timezone or 0, 'utc', '%Y-%m-%dT%H:%M:%SZ',
                    show_offset=False),
                'content':revision.message,
                })
        return feed


class BranchFeed(Feed):
    """A Branch Feed.

    BranchFeeds can create RSS content from a branch.

    Public attributes:
    now: a time tuple for the time that the feed is executing.
    item_limit: The maximum number of commit items to include. Set to -1 to
        disable.
    """

    ATOM_HEAD_TEMPLATE = u"""<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>$title</title> 
  <id>$id</id>
  <updated>$updated</updated>
  <generator uri="http://atonie.org/code/atomlog" />
"""

    def __init__(self, branch, now=None):
        """Create a BranchFeed on branch.

        :param branch: The branch to generate a feed for.
        :param now: The current time since epochs in seconds.
            If not supplied, time.time is used.
        """
        self.branch = branch
        self.item_limit = 20
        self.now = now or time.time()

    def iter_revisions(self):
        """Walk the revisions to be included."""
        history = self.branch.revision_history()
        tip = len(history)
        if self.item_limit != -1:
            history = history[-self.item_limit:]
        return itertools.izip(xrange(tip, 0, -1),
            reversed(self.branch.repository.get_revisions(history)))

    def generate(self):
        """Generate the feed content.

        The title of the feed is pulled from the branch nick, and the
        id from the branch URL.

        :return: a bytestring containing the feed.
        """
        template = Template(self.ATOM_HEAD_TEMPLATE)
        feed = template.substitute({
            'title':self.branch.nick,
            'id':str(self.branch.base),
            'updated':format_date(self.now, 0, 'utc', '%Y-%m-%dT%H:%M:%SZ',
                show_offset=False)
            })
        feed = self.generate_for_iterator(feed, self.iter_revisions())
        return feed.encode('utf8')

    def update(self):
        """Update the feed in the branch directory."""
        # This is a little ugly: poking under the hood.
        self.branch.control_files._transport.put_bytes(
            'branch.atom', self.generate())
