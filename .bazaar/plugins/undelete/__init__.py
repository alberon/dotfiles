# Author: Parth Malwankar <parth.malwankar@gmail.com>

"""Undelete the file(s) deleted using 'bzr rm'"""

from bzrlib.commands import Command, register_command

from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
from bzrlib import errors, bzrdir
from bzrlib.revisionspec import RevisionSpec
from bzrlib.option import Option
from bzrlib.builtins import _parse_limit, _get_revision_range

from undelete import (
    _vprint,
    _undelete_file,
    _list_files,
    _get_revision_from_limit,
    )
""")

version_info = (0, 2, 0)

class cmd_undelete(Command):
    """Undelete file(s) deleted using 'bzr rm'

    This commands reverts to the last known version of a
    previously deleted file. It steps back in revisions
    starting from previous till the specified '--limit'
    (default: 20).
    Note that --limit and --revision are mutually exclusive.
    For revision filtering, the older revision should be specified
    on the left. For e.g.,
      -r -5.. will search backwards from the current revision to
              (current - 5) revision.for file to undelete.
      -r 3..8 will search from revno:8 to revno:3 to undelete the
              latest known version of the specified file.
    """
    takes_args = ['file*']
    _see_also = ['revisionspec']
    takes_options = [ 'verbose',
        'revision',
        Option('limit',
                short_name='l',
                help='Limit the search to the first N revisions. (default:20)',
                argname='N',
                type=_parse_limit),
        Option("find", type = str,
            help = "List the deleted file(s) with name "
                    "matching regular expression"),
        ]

    DEFAULT_LIMIT = -21

    def run(self, file_list = None,
            find = None,
            verbose = False,
            revision = None,
            limit = None):

        if (limit != None) and (revision != None):
            raise errors.BzrCommandError(
                "--limit and --revision are mutually exclusive")

        if (revision == None) and (limit == None):
            revision = _get_revision_from_limit(cmd_undelete.DEFAULT_LIMIT)

        if revision == None:
            # looks like user specified a limit
            revision = _get_revision_from_limit(-limit - 1)

        bd = bzrdir.BzrDir.open_containing('.')[0]
        br = bd.open_branch()

        if find != None:
            _list_files(find, verbose, revision, br, self.name())
            return

        for filename in file_list:
            _undelete_file(filename, verbose, revision, br, self.name())

def test_suite():
    import tests
    import tests.basic
    import tests.blackbox

    from unittest import TestSuite

    result = TestSuite()
    result.addTest(tests.blackbox.test_suite())
    result.addTest(tests.basic.test_suite())
    return result

register_command(cmd_undelete)

