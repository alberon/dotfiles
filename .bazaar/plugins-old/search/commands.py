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

"""The command console user interface for bzr search."""

import bzrlib.commands
from bzrlib.option import Option
from bzrlib.plugins.search import errors
from bzrlib.plugins.search import index as _mod_index
from bzrlib.transport import get_transport


class cmd_index(bzrlib.commands.Command):
    """Create or update a search index.

    This locates documents in bzr at a given url and creates a search index for
    that url.
    """

    _see_also = ['search']
    takes_args = ['url?']

    def run(self, url=None):
        if url is None:
            url = "."
        trans = get_transport(url)
        _mod_index.index_url(trans.base)


class cmd_search(bzrlib.commands.Command):
    """Perform a search within bzr history.

    This locates documents that match the query and reports them to the
    console.
    """

    encoding_type = 'replace'
    _see_also = ['index']
    takes_options = [Option('suggest', short_name='s',
        help="Suggest possible terms to complete the search."),
                     Option('directory', short_name='d', type=unicode,
        help='Branch to search rather than the one in the current directory.'),
        ]
    takes_args = ['query+']

    def run(self, query_list=[], suggest=False, directory="."):
        trans = get_transport(directory)
        index = _mod_index.open_index_url(trans.base)
        # XXX: Have a query translator etc.
        query = [(query_item,) for query_item in query_list]
        index._branch.lock_read()
        try:
            if suggest:
                terms = index.suggest(query)
                terms = list(terms)
                terms.sort()
                self.outf.write("Suggestions: %s\n" % terms)
            else:
                seen_count = 0
                for result in index.search(query):
                    self.outf.write(result.document_name())
                    self.outf.write(" Summary: '%s'\n" % result.summary())
                    seen_count += 1
                if seen_count == 0:
                    raise errors.NoMatch(query_list)
        finally:
            index._branch.unlock()
