
import stat

from bzrlib import errors, urlutils
from bzrlib.branch import BranchFormat
from bzrlib.bzrdir import BzrDir
from bzrlib.trace import note


def list_branches(repo):
    trans = repo.bzrdir.root_transport
    dirs_to_check = ['.']
    branches = []
    while len(dirs_to_check) > 0:
        filename = dirs_to_check.pop(0)
        if stat.S_ISDIR(trans.stat(filename).st_mode):
            # is this a branch inside the given repository?
            try:
                br_dir = BzrDir.open(trans.abspath(filename))
                branch = br_dir.open_branch()
            except errors.NotBranchError:
                branch = None

            # if we have a branch, add it to the result set, provided
            # that it uses the same repository.
            if branch is not None:
                # if the branch uses a different repository, then
                # don't include it.
                if (branch.repository.bzrdir.root_transport.base !=
                    trans.base):
                    continue
                # XXX: hack to make sure the branch is using the same
                # repository instance, for locking purposes
                branch.repository = repo
                branches.append(branch)

            # extend the list of dirs to check.
            dirs_to_check.extend([urlutils.join(filename, name)
                                  for name in trans.list_dir(filename)
                                  if name != '.bzr'])
    return branches


def get_branch(repo, relpath, format=None):
    """Return existing branch in destination repo. Create new if don't exist.

    @param  format:     force create new branch in specified format.
    """
    repo_trans = repo.bzrdir.root_transport
    try:
        br_dir = BzrDir.open(repo_trans.abspath(relpath))
        branch = br_dir.open_branch()
    except errors.NotBranchError:
        # create destination branch directory, creating parents as needed.
        needed = [relpath]
        while needed:
            try:
                repo_trans.mkdir(needed[-1])
                needed.pop()
            except errors.NoSuchFile:
                parent = urlutils.dirname(needed[-1])
                if parent == '':
                    raise errors.BzrCommandError('Could not create branch dir')
                needed.append(parent)
        br_dir = BzrDir.create(repo_trans.abspath(relpath))
        if format is None:
            format = BranchFormat.get_default_format()
        branch = format.initialize(br_dir)

        note('Created destination branch %s' % relpath)

    if branch.repository.bzrdir.root_transport.base != repo_trans.base:
        raise errors.BzrCommandError('Branch %s does not use repository %s'
                                     % (relpath, repo_trans.base))
    # XXX: hack to make sure the branch is using the same repository
    # instance, for locking purposes
    branch.repository = repo
    return branch


def repo_push(src_repo, dst_repo, pb, overwrite=False):
    src_repo.lock_read()
    try:
        dst_repo.lock_write()
        try:
            src_repo_trans = src_repo.bzrdir.root_transport
            dst_repo_trans = dst_repo.bzrdir.root_transport

            pb.update('Getting list of branches', 0, 1)
            branches = list_branches(src_repo)
            note('Pushing %d branches from %s to %s'
                 % (len(branches), src_repo_trans.base, dst_repo_trans.base))
            
            # XXX: ideally this would only fetch the tips of the
            # branches we found previously.
            pb.update('Fetching entire repo', 0, 1)
            dst_repo.fetch(src_repo, pb=pb)

            # Now synchronise the revision histories of the local and
            # remote branches.  The previous fetch() call has made
            # sure that the corresponding revisions exist in dst_repo.
            for index, src_branch in enumerate(branches):
                pb.update('Updating branches', index, len(branches))
                relpath = src_repo_trans.relpath(
                    src_branch.bzrdir.root_transport.base)
                format = BranchFormat.find_format(src_branch.bzrdir)
                dst_branch = get_branch(dst_repo, relpath, format)

                src_history = src_branch.revision_history()
                dst_history = dst_branch.revision_history()

                # If we aren't overwriting and the destination history
                # is not a subset of the source history, error out.
                # XXX this implementation is buggy in some cases
                if not overwrite and (src_history[:len(dst_history)] !=
                                      dst_history):
                    raise errors.BzrCommandError('Branch %s has diverged'
                                                 % relpath)

                # push tags
                src_branch.tags.merge_to(dst_branch.tags)

                if src_history != dst_history:
                    dst_branch.set_revision_history(src_history)
                    note('%d revision(s) pushed to %s'
                         % (len(src_history) - len(dst_history), relpath))
        finally:
            dst_repo.unlock()
    finally:
        src_repo.unlock()
