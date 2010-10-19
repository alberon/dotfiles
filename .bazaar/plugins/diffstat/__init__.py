#!/usr/bin/python
"""diffstat - show stats about changes to the working tree"""

import bzrlib

from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
import sys
import re
from bzrlib import (
    builtins,
    option,
    config
    )

from bzrlib.option import Option
""")

from bzrlib.commands import display_command, register_command

version_info = (0, 2, 0, 'final', 0)

def version_string():
    """Convert version_info into a string"""
    if version_info[3] == 'final':
        version_string = '%d.%d.%d' % version_info[:3]
    else:
        version_string = '%d.%d.%d%s%d' % version_info
    return version_string

plugin_name = 'diffstat'
__version__ = version_string()

class cmd_diff(builtins.cmd_diff):
    builtins.cmd_diff.takes_options.append(option.Option('stat', help='Show diff summary statistics'))
    builtins.cmd_diff.takes_options.append(option.Option('stat-dir',  help='Show diff summary statistics per directory'))
    __doc__ = builtins.cmd_diff.__doc__
    encoding_type = 'replace'

    @display_command
    def run(self, *args, **kwargs):
        stat = kwargs.pop('stat', False)
        stat_dir = kwargs.pop('stat_dir', False)

        # Find out if coloured output is enabled. We allow both colour and color spellings
        c = config.GlobalConfig()
        colour = c.get_user_option('colour') or c.get_user_option('color')
        if colour is None:
            colour = False
        else:
            # In lieu of a clever way of obtaining a boolean from config direct, a little parsing...
            colour = re.match('^(true|1|on)$', colour, re.IGNORECASE) is not None

        if stat or stat_dir:
            # Base class writes to stdout only, so temporarily redirect it
            from StringIO import StringIO
            diff_output = StringIO()
            tmp_stdout  = sys.stdout
            sys.stdout  = diff_output

        retval = diff_class.run(self, *args, **kwargs)

        if stat or stat_dir:
            from diffstat import DiffStat

            # Put stdout back where it belongs
            sys.stdout = tmp_stdout

            diff_output.seek(0)

            diffstat_output = str(DiffStat(diff_output.readlines(), stat_dir, colour=colour))

            if len(diffstat_output):
                print diffstat_output

        return retval



class cmd_diffstat(cmd_diff):
    """diffstat - show stats about changes to the working tree"""
    takes_args = ['file*']
    takes_options = ['revision', Option('dir-only',  help='Only list directories')]
    aliases = ['ds']
    def run(self, revision=None, dir_only=False, file_list=None):
        return cmd_diff().run(file_list=file_list, stat=True, stat_dir=dir_only,
                              revision=revision)



register_command(cmd_diffstat)
diff_class = register_command(cmd_diff, decorate=True)

def test_suite():
    import tests
    return tests.test_suite()
