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

"""Error objects for search functions."""

import bzrlib.commands
from bzrlib.errors import BzrError
import bzrlib.errors


class CannotIndex(BzrError):
    """Raised when a particular control dir class is unrecognised."""

    _fmt = "Cannot index %(thing)r, it is not a known control dir type."

    def __init__(self, thing):
        self.thing = thing


class NoSearchIndex(BzrError):
    """Raised when there is no search index for a url."""

    _fmt = "No search index present for %(url)r. Please see 'bzr help index'."

    def __init__(self, url):
        self.url = url


class NoMatch(BzrError):
    """Raised by the ui when no searches are found.

    The library functions are generators and raising exceptions there is ugly.
    """

    _fmt = "No matches were found for the search %(search)s."

    def __init__(self, search):
        self.search = search
