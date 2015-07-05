# Copyright (C) 2005 Canonical Ltd

# GNU GPL v2.

"""vimdiff plugin for bzr"""

from bzrlib.commands import Command, register_command, Option
from bzrlib.errors import BzrError, NotVersionedError, BzrCommandError
import os


horizontal = Option('horizontal',
                    help='Split the display horizontally, not vertically.')
def orient(horizontal):
    if horizontal is True:
        return '-o2'
    else:
        return '-O2'


class cmd_vimdiff(Command):
    """Show changes to a file in vimdiff

    At present this is restricted to showing only the changes to the
    last-committed revision, and only for a single file.

    The working copy may be edited in vimdiff and the differences will
    be kept up to date.

    See also vimdiff.
    """
    takes_args = ['file_to_diff+']
    takes_options = ['revision', horizontal]
    def run(self, file_to_diff_list, revision=None, horizontal=False):
        for file_to_diff in file_to_diff_list:
            vimdiff_to_file(['vim', '-d', orient(horizontal), '-f'], file_to_diff,
                            revision=revision)


class cmd_gvimdiff(Command):
    """Show changes to a file in gvimdiff

    At present this is restricted to showing only the changes to the
    last-committed revision, and only for a single file.

    The working copy may be edited in vimdiff and the differences will
    be kept up to date.

    See also vimdiff.
    """
    takes_args = ['file_to_diff+']
    takes_options = ['revision', horizontal]
    def run(self, file_to_diff_list, revision=None, horizontal=False):
        for file_to_diff in file_to_diff_list:
            vimdiff_to_file(['gvim', '-d', orient(horizontal), '-f'], file_to_diff,
                            revision=revision)


def vimdiff_to_file(vimdiff_args, file_to_diff, revision=None):
    from bzrlib.workingtree import WorkingTree
    work_tree, rel_path = WorkingTree.open_containing(file_to_diff)
    work_tree.lock_read()
    try:
        _vimdiff_to_file(work_tree, rel_path, vimdiff_args, file_to_diff,
                         revision=revision)
    finally:
        work_tree.unlock()


def _vimdiff_to_file(work_tree, rel_path, vimdiff_args, file_to_diff,
                     revision=None):
    branch = work_tree.branch

    file_id = work_tree.path2id(rel_path)
    if file_id is None:
        raise NotVersionedError(rel_path)

    using_working_tree = False
    if revision is None or len(revision) == 1:
        to_tree = work_tree
        to_file = file_to_diff
        using_working_tree = True
    elif len(revision) >= 2:
        to_rev_no, rev_id = revision[1].in_history(branch)
        to_tree = branch.repository.revision_tree(rev_id)

    if not using_working_tree:
        tmp_to = write_old_to_temp(to_tree, file_id, to_rev_no)
        to_file = tmp_to.name

    if revision is None:
        from_tree = work_tree.basis_tree()
        from_rev_no = branch.revno()
    elif len(revision) >= 1:
        from_rev_no, rev_id = revision[0].in_history(branch)
        from_tree = branch.repository.revision_tree(rev_id)

    from_tree.lock_read()
    try:
        tmp_from = write_old_to_temp(from_tree, file_id, from_rev_no)
    finally:
        from_tree.unlock()
    from_file = tmp_from.name

    # must call with -f to wait around, so we can delete the temp file
    # otherwise it gets killed first.
    run_vimdiff(vimdiff_args, to_file, from_file)


def write_old_to_temp(tree, file_id, rev_no):
    # we want the same suffix as before so syntax highlighting works
    from tempfile import NamedTemporaryFile
    from os.path import splitext, basename
    if not tree.has_id(file_id):
        raise BzrError("file {%s} wasn't in the basis version %s"
                       % (file_id, tree))
    old_filename = tree.id2path(file_id)
    name_base, name_suffix = splitext(basename(old_filename))
    basis_tmp = NamedTemporaryFile(suffix=('.%s.tmp%s' % (rev_no, name_suffix)),
                                   prefix=name_base)
    basis_tmp.write(tree.get_file_text(file_id))
    basis_tmp.flush()
    try:
        os.chmod(basis_tmp.name, 0444)
    except OSError:
        pass
    return basis_tmp


def run_vimdiff(vimdiff_args, new_file_path, old_file_path):
    import subprocess
    sub = subprocess.call(vimdiff_args + [new_file_path, old_file_path])


register_command(cmd_gvimdiff)
register_command(cmd_vimdiff)
