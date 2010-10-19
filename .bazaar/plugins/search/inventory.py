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

"""Inventory related helpers for indexing."""

import re

from bzrlib import lazy_regex
from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
from bzrlib import xml_serializer
""")

_file_ids_name_regex = lazy_regex.lazy_compile(
        r'file_id="(?P<file_id>[^"]+)"'
        r'(?:.* name="(?P<name>[^"]*)")?'
        r'(?:.* parent_id="(?P<parent_id>[^"]+)")?'
        )

_unescape_re = lazy_regex.lazy_compile("&amp;|&apos;|&quot;|&lt;|&gt;")
_unescape_map = {
    '&amp;': '&',
    "&apos;": "'",
    "&quot;": '"',
    "&lt;": '<',
    "&gt;": '>',
    }
def _unescape_replace(match, map=_unescape_map):
    return map[match.group()]


def paths_from_ids(xml_inventory, serializer, file_ids):
    """Extract the paths for some file_ids from xml_inventory."""
    if not serializer.support_altered_by_hack:
        raise ValueError("Cannot process with serializer %r" % serializer)
    search = _file_ids_name_regex.search
    # escaped ids to match against the xml:
    escape_re = xml_serializer.escape_re
    _escape_replace = xml_serializer._escape_replace
    escaped_to_raw_ids = {}
    for file_id in file_ids:
        escaped_to_raw_ids[escape_re.sub(_escape_replace, file_id)] = file_id
    unresolved_ids = set(escaped_to_raw_ids)
    # TODO: only examine lines we need to, break early, track unprocessed
    found_ids = {}
    id_paths = {}
    result = {}
    if type(xml_inventory) == str:
        xml_inventory = xml_inventory.splitlines()
    for line in xml_inventory:
        match = search(line)
        if match is None:
            continue
        file_id, name, parent_id = match.group('file_id', 'name', 'parent_id')
        if name is None and parent_id is None:
            # format 5 root
            name = ''
        found_ids[file_id] = (name, parent_id)
        if parent_id is None:
            # no parent, stash its name now to avoid special casing
            # later.
            path = _unescape_re.sub(_unescape_replace, name)
            id_paths[file_id] = path
            if file_id in unresolved_ids:
                result[escaped_to_raw_ids[file_id]] = path
    needed_ids = set(unresolved_ids)
    while needed_ids:
        # ---
        # lookup_ids_here
        # ---
        missing_ids = set()
        for file_id in needed_ids:
            name, parent_id = found_ids.get(file_id, (None, None))
            if name is None:
                # Unresolved id itself
                missing_ids.add(file_id)
            else:
                # We have resolved it, do we have its parent
                if parent_id is not None and parent_id not in found_ids:
                    # No, search for it
                    missing_ids.add(parent_id)
        if missing_ids == needed_ids:
            # We didn't find anything on this pass
            raise Exception("Did not find ids %s" % missing_ids)
        needed_ids = missing_ids
    # We have looked up the path-to-root for all asked ids,
    # now to resolve it
    while unresolved_ids:
        wanted_file_id = unresolved_ids.pop()
        path = id_paths.get(wanted_file_id)
        if path is not None:
            result[escaped_to_raw_ids[wanted_file_id]] = path
            continue
        lookup_stack = [wanted_file_id]
        lookup_names = []
        # May be looked up already
        while lookup_stack:
            file_id = lookup_stack[-1]
            name, parent_id = found_ids[file_id]
            parent_path = id_paths.get(parent_id, None)
            if parent_path is None:
                # recurse:
                lookup_stack.append(parent_id)
                lookup_names.append(name)
            else:
                # resolve:
                path = _unescape_re.sub(_unescape_replace, name)
                if parent_path:
                    parent_path = parent_path + '/' + path
                else:
                    parent_path = path
                id_paths[file_id] = parent_path
                if file_id == wanted_file_id:
                    result[escaped_to_raw_ids[file_id]] = parent_path
                lookup_stack.pop(-1)
                while lookup_stack:
                    file_id = lookup_stack.pop(-1)
                    path = _unescape_re.sub(_unescape_replace,
                        lookup_names.pop(-1))
                    if parent_path:
                        parent_path = parent_path + '/' + path
                    else:
                        parent_path = path
                    id_paths[file_id] = parent_path
                    if file_id == wanted_file_id:
                        result[escaped_to_raw_ids[file_id]] = parent_path
    return result
