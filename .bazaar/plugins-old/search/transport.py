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

"""Transport facilities to support the index engine.

The primary class here is FileView, an adapter for exposing a number of files 
in a pack (with identity encoding only!) such that they can be accessed via
readv.
"""

from cStringIO import StringIO


class FileView(object):
    """An adapter from a pack file to multiple smaller readvable files.

    A typical use for this is to embed GraphIndex objects in a pack and then
    use this to allow the GraphIndex logic to readv while actually reading
    from the pack.

    Currently only the get and readv methods are supported, all the rest of the
    transport interface will raise AttributeError - this is deliberate to catch
    unexpected uses.
    """

    def __init__(self, backing_transport, backing_file, file_map):
        """Create a FileView.

        :param backing_transport: The transport the pack file is located on.
        :param backing_file: The url fragment name of the pack file.
        :param file_map: A dict from file url fragments, to byte ranges in
            the pack file. Pack file header and trailer overhead should not
            be included in these ranges.
        """
        self._backing_transport = backing_transport
        self._backing_file = backing_file
        self._file_map = file_map

    def get(self, relpath):
        """See Transport.get."""
        start, stop = self._file_map[relpath]
        length = stop - start
        _, bytes = self._backing_transport.readv(self._backing_file,
            [(start, length)]).next()
        return StringIO(bytes)

    def readv(self, relpath, offsets, adjust_for_latency=False,
        upper_limit=None):
        """See Transport.readv.

        This adapter will clip results back to the range defined by the
        file_map.
        """
        base, upper_limit = self._file_map[relpath]
        # adjust offsets
        new_offsets = []
        for offset, length in offsets:
            new_offsets.append((offset + base, length))
        for offset, data in self._backing_transport.readv(self._backing_file,
            new_offsets, adjust_for_latency=adjust_for_latency,
            upper_limit=upper_limit):
            if offset + len(data) > upper_limit:
                upper_trim = len(data) + offset - upper_limit
            else:
                upper_trim = None
            if offset < base:
                lower_trim = base - offset
                offset = base
            else:
                lower_trim = 0
            data = data[lower_trim:upper_trim]
            offset = offset - base
            yield offset, data

    def recommended_page_size(self):
        """See Transport.recommended_page_size."""
        return self._backing_transport.recommended_page_size()
