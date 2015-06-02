#!/usr/bin/python

# Lastlog command for Bazaar-NG (bzr)
#
# Copyright (c) 2005-2006  Wouter Bolsterlee <uws@xs4all.nl>
# This file is distributed under the same license as bzr itself.

"""lastlog - shows most recent commit messages"""

import sys
import codecs

import bzrlib.commands
import bzrlib.bzrdir as bzrdir
from bzrlib.log import log_formatter, show_log
from bzrlib.revisionspec import RevisionSpec
from bzrlib.trace import warning, error

class cmd_lastlog(bzrlib.commands.Command):
    """Shows most recent commit messages."""
    aliases = ['last']
    takes_args = ['num?']

    def run(self, num=10):
        try:
            num = int(num)
        except (ValueError, TypeError):
            num = 10
            warning('bzr lastlog only accepts numbers, defaulting to %d.' % num)

        dir, relpath = bzrdir.BzrDir.open_containing('.')
        b = dir.open_branch()

        num_revisions = len(b.revision_history())

        if num_revisions == 0:
            error('Sorry, no revisions available.')
            return

        first_revision = num_revisions - num + 1
        last_revision = num_revisions

        if first_revision < 1:
            first_revision = 1

        outf = codecs.getwriter(bzrlib.user_encoding)(sys.stdout,
                errors='replace')

        lf = log_formatter('short',
                           show_ids=False,
                           to_file=outf,
                           show_timezone='original')

        show_log(b,
                 lf,
                 None,
                 verbose=False,
                 direction='forward',
                 start_revision=first_revision,
                 end_revision=last_revision,
                 search=None)



bzrlib.commands.register_command(cmd_lastlog)
