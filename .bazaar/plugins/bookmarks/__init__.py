# -*- coding: utf-8 -*-
# Copyright (C) 2007 Lukáš Lalinsky <lalinsky@gmail.com>
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
Bazaar Bookmarks
=================
This plugin allows you to add, remove or modify a commonly used network location.

Create a bookmark:
  bzr bookmark BOOKMARKNAME [LOCATION]
$ bzr bookmark bzr.dev http://bazaar-vcs.org/bzr/bzr.dev/

Use the bookmark:
 $ bzr branch bookmark:bzr.dev

This can also be shortened to:
 $ bzr branch bm:bzr.dev

More information is available from:
 $ bzr help bookmark
and
 $ bzr help bookmarks
"""

from bzrlib.urlutils import unescape_for_display
from bzrlib.config import GlobalConfig, ensure_config_dir_exists
from bzrlib.commands import Command, register_command
from bzrlib.errors import InvalidURL, BzrCommandError, NotBranchError
from bzrlib.option import Option
from bzrlib.branch import Branch
from bzrlib.transport import get_transport, register_transport


class GlobalBookmarkProvider(object):

    def set_bookmark(self, name, location):
        config = GlobalConfig()
        parser = config._get_parser()
        if "BOOKMARKS" not in parser:
            parser["BOOKMARKS"] = {}
        parser["BOOKMARKS"][name] = location
        parser.write(file(config._get_filename(), 'wb'))

    def unset_bookmark(self, name):
        config = GlobalConfig()
        parser = config._get_parser()
        del parser["BOOKMARKS"][name]
        parser.write(file(config._get_filename(), 'wb'))

    def resolve_bookmark(self, name):
        config = GlobalConfig()
        try:
            return config._get_parser().get_value("BOOKMARKS", name)
        except KeyError:
            return None

    def get_bookmarks(self):
        bookmarks = {}
        config = GlobalConfig()
        filename = config._get_filename()
        for name, value in config._get_parser().get("BOOKMARKS", {}).items():
            bookmarks[name] = filename, value
        return bookmarks


class LocationBookmarkProvider(object):

    def __init__(self, base='.'):
        try:
            self.branch = Branch.open_containing(base)[0]
        except NotBranchError:
            self.branch = None

    def set_bookmark(self, name, location):
        if self.branch is None:
            return NotBranchError
        config = self.branch.get_config()
        return config.set_user_option("bookmark_%s" % name, location)

    def unset_bookmark(self, name):
        if self.branch is None:
            return NotBranchError
        config = self.branch.get_config()
        # FIXME: missing API to delete an option
        return config.set_user_option("bookmark_%s" % name, '')

    def resolve_bookmark(self, name):
        if self.branch is None:
            return None
        config = self.branch.get_config()
        return config._get_user_option("bookmark_%s" % name)

    def get_bookmarks(self):
        bookmarks = {}
        if self.branch is None:
            return bookmarks
        config = self.branch.get_config()
        for source_class in config.option_sources:
            source = source_class()
            try:
                filename = source._get_filename()
            except AttributeError:
                filename = source._config._transport.base + source._config._filename
                filename = unescape_for_display(filename, 'utf-8')
            for section_name, extra_path in source._get_matching_sections():
                parser = source._get_parser()
                if section_name in parser:
                    section = parser[section_name]
                elif section_name == "DEFAULT":
                    section = parser
                else:
                    section = {}
                for name, value in section.items():
                    if name.startswith('bookmark_'):
                        bookmarks[name[9:]] = filename, value
        return bookmarks


def resolve_bookmark(base_url):
    if base_url.startswith('bookmark:'):
        name = base_url[9:]
    elif base_url.startswith('bm:'):
        name = base_url[3:]
    else:
        raise InvalidURL(path=base_url)
    if '/' in name:
        bookmark, name = name.split('/', 1)
    else:
        bookmark = name

    providers = [LocationBookmarkProvider, GlobalBookmarkProvider]
    for provider_class in providers:
        provider = provider_class()
        real_url = provider.resolve_bookmark(bookmark)
        if real_url:
            if bookmark != name:
                real_url = '/'.join([real_url, name])
            break
    else:
        raise InvalidURL(path=base_url)
    return real_url


def bookmark_transport_indirect(base_url):
    return get_transport(resolve_bookmark(base_url))


class BookmarkDirectory(object):

    def look_up(self, name, url):
        url = resolve_bookmark(url)
        url = directories.dereference(url)
        return url


class cmd_bookmark(Command):
    """Add, remove or modify a bookmark."""
    
    _see_also = ["bookmarks"]

    takes_args = ['name', 'location?']
    takes_options = [
        Option('delete', help='Delete this bookmark.'),
        Option('branch', help='Branch-specific bookmark.'),
        ]

    def run(self, name, location=None, delete=False, branch=False):
        if branch:
            provider = LocationBookmarkProvider()
        else:
            provider = GlobalBookmarkProvider()
        ensure_config_dir_exists()
        if delete:
            if provider.resolve_bookmark(name) is None:
                raise BzrCommandError(
                    'bookmark "%s" does not exist' % (name,))
            provider.unset_bookmark(name)
        else:
            if '/' in name:
                raise BzrCommandError(
                    '"%s" contains a "/" character, bookmarks should not contain"/" characters"' % name)
            if not location:
                raise BzrCommandError(
                    'no location provided for bookmark "%s"' % (name,))
            provider.set_bookmark(name, location)


class cmd_bookmarks(Command):
    """List bookmarks."""

    _see_also = ["bookmark"]

    def run(self):
        providers = [LocationBookmarkProvider, GlobalBookmarkProvider]
        bookmarks = {}
        for provider_class in providers:
            provider = provider_class()
            for name, (source, url) in provider.get_bookmarks().items():
                bookmarks.setdefault(source, {})[name] = url
        for source, items in sorted(bookmarks.items()):
            self.outf.write('%s:\n' % (source,))
            for name, url in sorted(items.items()):
                self.outf.write('  %-20s %s\n' % (name, url))


# Don't run any tests on BookmarkTransport as it is not intended to be
# a full implementation of Transport, just redirects.
def get_test_permutations():
    return []


try:
    from bzrlib.directory_service import directories
    directories.register(
        'bookmark:', BookmarkDirectory)
    directories.register(
        'bm:', BookmarkDirectory)
except ImportError:
    register_transport(
        'bookmark:', bookmark_transport_indirect)
    register_transport(
        'bm:', bookmark_transport_indirect)


register_command(cmd_bookmark)
register_command(cmd_bookmarks)
