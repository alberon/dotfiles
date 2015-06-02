# Author: Parth Malwankar <parth.malwankar@gmail.com>

from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
import os

from bzrlib import revisiontree, errors, bzrdir
from bzrlib.option import Option
from bzrlib.revisionspec import RevisionSpec
from bzrlib.workingtree import WorkingTree
from bzrlib.builtins import _parse_limit, _get_revision_range
""")


def _list_files(rxname, verbose, revision, br, command_name):
    import re

    compiled_rx = re.compile(rxname)

    start_rev, end_rev = _get_undelete_revision_range(revision,
                            br, command_name)

    for i in range(start_rev.revno, end_rev.revno - 1, -1):
        revision_spec = RevisionSpec.from_string(str(i))

        try:
            revision_id = revision_spec.as_revision_id(br)
        except errors.InvalidRevisionSpec:
            return

        tree = revision_spec.as_tree(br)
        tree.lock_read()

        try:
            rt = revisiontree.RevisionTree(br, tree.inventory, revision_id)
            print_rev = True
            for file in rt.list_files():
                name = file[0]
                m = compiled_rx.search(name)
                if m:
                    if print_rev:
                        print 'revno:', br.revision_id_to_revno(revision_id)
                        print_rev = False
                    print '    ', name

        finally:
            tree.unlock()

def _undelete_file(filename, verbose, revision, br, command_name):
    wt = WorkingTree.open_containing('.')[0]
    filepath = wt.relpath(os.path.abspath(filename))

    if wt.has_filename(filepath):
        _vprint("nothing to do for '" + filename + "'", True)
        return

    start_rev, end_rev = _get_undelete_revision_range(revision,
                            br, command_name)

    for i in range(start_rev.revno, end_rev.revno - 1, -1):
        revision_spec = RevisionSpec.from_string(str(i))

        try:
            revision_id = revision_spec.as_revision_id(br)
        except errors.InvalidRevisionSpec:
            _vprint("revisions not found for '" + filename + "'", True)
            return

        tree = revision_spec.as_tree(br)
        tree.lock_read()
        try:
            rt = revisiontree.RevisionTree(br, tree.inventory, revision_id)
            if rt.has_filename(filepath):
                f_id = tree.path2id(filepath)
                wt.revert(filenames = [filepath], old_tree=tree)
                _vprint("reverting '" + filename
                    + "' to revno:" + str(i) , verbose)
                return
        finally:
            tree.unlock()

    _vprint("revisions not found for '" + filename + "'", True)
    _vprint("you could look deeper in the history using "
            "the --limit option.", True)

def _get_revision_from_limit(limit):
    end_rev = RevisionSpec.from_string(str(limit))
    start_rev = RevisionSpec.from_string(None)
    revision = [end_rev, start_rev]
    return revision


def _get_undelete_revision_range(revision, br, command_name):
    br.lock_read()
    try:
        end_rev, start_rev = _get_revision_range(revision, br, command_name)
        if end_rev.revno > start_rev.revno:
            raise errors.BzrCommandError(
                "bzr %s requires start revision to be older"
                " than end revision for last first search"
                % command_name)
    finally:
        br.unlock()
    return (start_rev, end_rev)


def _vprint(s, verbose):
    if verbose == True:
        print s

