# Copyright (C) 2005 Aaron Bentley, 2006 Michael Ellerman
# <aaron.bentley@utoronto.ca>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import os
try:
    from bzrlib.errors import BzrCommandError as CommandError
    from bzrlib.errors import BzrError
except ImportError:
    class CommandError(Exception):
        pass

class PatchFailed(Exception):
    """Failed applying patch!"""

class PatchInvokeError(BzrError):

    _fmt = """Error invoking patch: %(errstr)s\n%(stderr)s"""
    internal_error = False

    def __init__(self, e, stderr):
        self.exception = e
        self.errstr = os.strerror(e.errno)
        self.stderr = stderr

class NoColor(Exception):
    """Color not available on this terminal."""

