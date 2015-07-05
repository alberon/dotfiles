# Author: barry@canonical.com

"""bzr touch"""

import os

from bzrlib.commands import Command, register_command
from bzrlib.workingtree import WorkingTree

version_info = (1, 1)

# Ripped straight from GNU touch(1)
FLAGS = os.O_WRONLY | os.O_CREAT | os.O_NONBLOCK | os.O_NOCTTY


class cmd_touch(Command):
    """Basically: touch <file> && bzr add <file>."""

    takes_args = ['file*']

    def run(self, file_list):
        wt = WorkingTree.open_containing('.')
        # Create the files if they don't exist.
        for filename in file_list:
            filepath = os.path.join(os.getcwd(), filename)
            fd = os.open(filepath, FLAGS, 0666)
            os.close(fd)
        wt[0].smart_add(file_list, recurse=False)


register_command(cmd_touch)
