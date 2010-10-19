# (c) Alexander Belchenko, 2007

"""Extend branch command with --lightweight option.

This option allows to branch one lightweight checkout
and get another lightweight checkout with corresponding
branch in shared repository.
"""

from bzrlib import builtins
from bzrlib.commands import Command, register_command
from bzrlib.option import Option


class cmd_branch(builtins.cmd_branch):

    __doc__ = builtins.cmd_branch.__doc__

    takes_options = builtins.cmd_branch.takes_options + \
                    [Option('lightweight', help='Make branch in shared repo '
                                                'and lightweight checkout')]

    def run(self, from_location, to_location=None, lightweight=False, **kw):
        if lightweight:
            import errno
            import os
            from bzrlib.branch import Branch
            from bzrlib.errors import BzrError
            from bzrlib.urlutils import basename, dirname, join
            from bzrlib.workingtree import WorkingTree

            br_from = Branch.open(from_location)
            repo = br_from.repository
            if not repo.is_shared():
                raise BzrError('branch --lightweight supported '
                               'only for shared repository')
            wt_from = WorkingTree.open(from_location)
            working_path = wt_from.bzrdir.root_transport.base
            from_branch_path = br_from.bzrdir.root_transport.base
            if working_path == from_branch_path:
                raise BzrError('source branch is not lightweight checkout')
            if to_location is None:
                raise BzrError('you should specify name for new branch')
            from_basename = basename(from_branch_path)
            to_basename = basename(to_location)
            if from_basename == to_basename:
                raise BzrError('basename of source and destination is equal')
            to_branch_path = join(dirname(from_branch_path), to_basename)
            # make branch
            print >>self.outf, 'Create branch: %s => %s' % (from_branch_path,
                                                            to_branch_path)
            builtins.cmd_branch.run(self, from_branch_path, to_branch_path, **kw)
            # make lightweight chekout
            source = Branch.open(to_branch_path)
            revision_id = source.last_revision()
            try:
                os.mkdir(to_location)
            except OSError, e:
                if e.errno == errno.EEXIST:
                    raise errors.BzrCommandError('Target directory "%s" already'
                                                 ' exists.' % to_location)
                if e.errno == errno.ENOENT:
                    raise errors.BzrCommandError('Parent of "%s" does not exist.'
                                                 % to_location)
                else:
                    raise
            source.create_checkout(to_location, revision_id, lightweight)
        else:
            builtins.cmd_branch.run(self, from_location, to_location, **kw)


register_command(cmd_branch)
