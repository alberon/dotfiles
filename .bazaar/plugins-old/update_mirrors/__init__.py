#!/usr/bin/env python
"""\
Update all mirrors found inside a given directory.
"""

import os
import sys

from bzrlib.bzrdir import BzrDir
from bzrlib.commands import Command, register_command
from bzrlib.errors import (NoSuchFile, NotBranchError,
                           DivergedBranches, UnsupportedFormatError,
                           NoWorkingTree)
from bzrlib.progress import DotsProgressBar
import bzrlib.ui


def pull_branch(br_dir, overwrite=False, verbose=False):
    """Pull a branch up-to-date with its parent.

    :param br_dir: The bzrdir we are updating
    :param overwrite: If the revision-history should be clobbered
    :param verbose: Print what changed
    """
    try:
        br = br_dir.open_branch()
    except NotBranchError:
        return 2

    parent = br.get_parent() or br.get_bound_location()
    if not parent:
        return 0 # No parent, nothing to do
    try:
        br_from = BzrDir.open(parent).open_branch()
    except NotBranchError:
        return 2 # Cannot connect to parent?

    isatty = getattr(sys.stdout, 'isatty', None)
    if not isatty or not isatty():
        if hasattr(bzrlib.ui.ui_factory, '_bar_type'):
            bzrlib.ui.ui_factory._bar_type = DotsProgressBar

    old_rh = br.revision_history()
    other_rh = br_from.revision_history()
    if other_rh != old_rh:
        print '='*65
    print 'Updating %s' % (br.base,)
    print '    from %s' % (br_from.base,)
    sys.stdout.flush()
    try:
        try:
            br_dir.open_workingtree().pull(br_from, overwrite)
        except NoWorkingTree:
            br.pull(br_from, overwrite)
    except DivergedBranches:
        return 2 # Failure

    new_rh = br.revision_history()
    if old_rh == new_rh:
        print
        #print 'no change'
        # When writing to a file sys.stdout is buffered, but
        # sys.stderr is not, so things happen at the wrong time.
        # Flushing should help
        sys.stdout.flush()
        return 0 # Nothing changed
    else:
        if verbose:
            try:
                from bzrlib.log import show_changed_revisions
            except ImportError:
                def show_changed_revisions(b, old, new):
                    pass
            show_changed_revisions(br, old_rh, new_rh)
        else:
            print '  %d new revisions' % (len(new_rh) - len(old_rh))
        # Add a blank line
        print
        sys.stdout.flush()
        return 1 # Something updated
    

class cmd_update_mirrors(Command):
    """Update all branches found below the supplied directory.

    The return codes used are:
    0   - Nothing changed
    1   - Something was updated
    2   - There were conflicts, or unable to update
    3   - Error using command
    """
    takes_args = ['base_dir?']
    takes_options = ['overwrite', 'verbose']

    def run(self, base_dir='.', overwrite=False, verbose=False):
        if not os.path.exists(base_dir):
            print 'Base directory does not exist.'
            return 3

        retcode = 0

        for root, dirs, files in os.walk(base_dir):
            to_remove = []
            for i, d in enumerate(dirs):
                if d in ('{arch}', 'CVS'
                       , '.svn', '_svn'
                       , '.bzr'):
                    to_remove.append(i)
                elif d.endswith('.tmp') or d.startswith(',,'):
                    to_remove.append(i)
            to_remove.reverse()
            for i in to_remove:
                dirs.pop(i)

            try:
                try:
                    br_dir = BzrDir.open(root)
                except NotBranchError:
                    continue
                except UnsupportedFormatError, e:
                    print '='*50
                    print 'Branch at %s' % root
                    print 'in an unsupported format'
                    print e
                    print

                r = pull_branch(br_dir, verbose=verbose, overwrite=overwrite)
                retcode = max(retcode, r)
            except KeyboardInterrupt:
                raise
            except Exception, e:
                import traceback
                traceback.print_exc()
                print 'failed while updating: %s' % (root,)
                retcode = 3

        return retcode


def test_suite():
    from unittest import TestSuite, TestLoader
    import test_update_mirrors

    suite = TestSuite()
    suite.addTest(TestLoader().loadTestsFromModule(test_update_mirrors))
    return suite

register_command(cmd_update_mirrors)

