# search, a bzr plugin for searching within bzr branches/repositories.
# Copyright (C) 2008 Robert Collins
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as published
# by the Free Software Foundation.
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

"""search is a bzr plugin for searching bzr content.

Commands
========

`bzr search TERM` will return the list of documents TERM occurs in.

`bzr index [URL]` will create an index of a branch.

Documentation
=============

See `bzr help search` or `bzr help plugins/search`.
"""

import bzrlib.commands

# Relative because at __init__ time the module does not exist.
from bzrlib.branch import Branch
from bzrlib import log
import commands
import errors
import index


for command in [
    'index',
    'search',
    ]:
    bzrlib.commands.register_command(getattr(commands, 'cmd_' + command))


version_info = (1, 7, 0, 'dev', 0)


def auto_index_branch(result):
    """Handled for the post_change_branch_tip hook to update a search index."""
    try:
        search_index = index.open_index_branch(result.branch)
    except errors.NoSearchIndex:
        return
    search_index.index_branch(result.branch, result.new_revid)


def _install_hooks():
    """Install the hooks this plugin uses."""
    Branch.hooks.install_named_hook('post_change_branch_tip',
        auto_index_branch, "index")


_install_hooks()

if getattr(log, 'log_adapters', None):
    # disable the regex search when bzr-search is active
    index._original_make_search_filter = log._make_search_filter
    log.log_adapters.insert(log.log_adapters.index(log._make_search_filter),
        index.make_disable_search_filter)
    log.log_adapters.remove(index._original_make_search_filter)
    log._make_search_filter = index.make_disable_search_filter
    # provide bzr-search based searches
    log.log_adapters.insert(log.log_adapters.index(log._make_revision_objects),
        index.make_log_search_filter)


def test_suite():
    # Thunk across to load_tests for niceness with older bzr versions
    from bzrlib.tests import TestLoader
    loader = TestLoader()
    return loader.loadTestsFromModuleNames(['bzrlib.plugins.search'])


def load_tests(standard_tests, module, loader):
    standard_tests.addTests(loader.loadTestsFromModuleNames(
        ['bzrlib.plugins.search.tests']))
    return standard_tests
