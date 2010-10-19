"""Push all branches from one shared repo to another"""

from bzrlib import errors
from bzrlib.bzrdir import BzrDir
from bzrlib.commands import Command, register_command
from bzrlib.config import LocationConfig
from bzrlib.ui import ui_factory


version_info = (1, 1, 0)
__version__ = '.'.join(map(str, version_info))


class cmd_repo_push(Command):
    """Push a repository and all its branches to another location."""

    takes_args = ['destination?']
    takes_options = ['remember', 'overwrite']

    def run(self, destination=None, remember=False, overwrite=False):
        from repopush import repo_push

        # get the repository for the branch we're currently in
        bzrdir = BzrDir.open_containing('.')[0]
        try:
            branch = bzrdir.open_branch()
            src_repo = branch.repository
        except errors.NotBranchError:
            src_repo = bzrdir.open_repository()
        repo_config = LocationConfig(src_repo.bzrdir.root_transport.base)

        if destination is None:
            destination = repo_config.get_user_option('public_repository')
            if destination is None:
                raise errors.BzrCommandError('No destination specified')

        dst_repo = BzrDir.open(destination).open_repository()

        if remember or (repo_config.get_user_option('public_repository')
                        is None):
            repo_config.set_user_option('public_repository',
                                        dst_repo.bzrdir.root_transport.base)

        pb = ui_factory.nested_progress_bar()
        try:
            repo_push(src_repo, dst_repo, pb=pb, overwrite=overwrite)
        finally:
            pb.finished()


register_command(cmd_repo_push)


def test_suite():
    from bzrlib.tests.TestUtil import TestLoader
    import test
    return TestLoader().loadTestsFromModule(test)
