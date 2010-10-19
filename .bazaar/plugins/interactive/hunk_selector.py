# Copyright (C) 2005, 2006, 2007 Aaron Bentley <aaron.bentley@utoronto.ca>
# Copyright (C) 2005, 2006 Canonical Limited.
# Copyright (C) 2006 Michael Ellerman.
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

import sys

from userinteractor import UserInteractor, UserOption
from errors import NoColor
import copy

class HunkSelector:
    strings = {}

    def __init__(self, patches, color=None):
        if color is True or color is None:
            try:
                from colordiff import DiffWriter
                from terminal import has_ansi_colors
                if has_ansi_colors():
                    self.diff_stream = DiffWriter(sys.stdout,
                                                  check_style=False)
                else:
                    if color is True:
                        raise NoColor()
                    self.diff_stream = sys.stdout
            except ImportError:
                if color is True:
                    raise NoColor()
                self.diff_stream = sys.stdout
        else:
            self.diff_stream = sys.stdout

        self.standard_options = [
            UserOption('y', self._selected, self.strings['select_desc'],
                default=True),
            UserOption('n', self._unselected, self.strings['unselect_desc']),
            UserOption('d', UserInteractor.FINISH, 'done, skip to the end.'),
            UserOption('i', self._invert,
                'invert the current selection status of all hunks.'),
            UserOption('s', self._status,
                'show selection status of all hunks.'),
            UserOption('q', UserInteractor.QUIT, 'quit')
        ]

        self.end_options = [
            UserOption('y', UserInteractor.FINISH, self.strings['finish_desc'],
                default=True),
            UserOption('r', UserInteractor.RESTART,
                'restart the hunk selection loop.'),
            UserOption('s', self._status,
                'show selection status of all hunks.'),
            UserOption('i', self._invert,
                'invert the current selection status of all hunks.'),
            UserOption('q', UserInteractor.QUIT, 'quit')
        ]

        self.patches = patches
        self.total_hunks = 0

        self.interactor = UserInteractor()
        self.interactor.set_item_callback(self._hunk_callback)
        self.interactor.set_start_callback(self._start_callback)
        self.interactor.set_end_callback(self._end_callback)

        for patch in patches:
            for hunk in patch.hunks:
                # everything's selected by default
                hunk.selected = True
                self.total_hunks += 1
                # we need a back pointer in the callbacks
                hunk.patch = patch
                self.interactor.add_item(hunk)

    # Called at the start of the main loop
    def _start_callback(self):
        self.last_printed = -1
        self.interactor.set_prompt(self.strings['prompt'])
        self.interactor.set_options(self.standard_options)

    # Called at the end of the item loop, return False to indicate that the
    # interaction isn't finished and the confirmation prompt should be displayed
    def _end_callback(self):
        self._status()
        self.interactor.set_prompt(self.strings['end_prompt'])
        self.interactor.set_options(self.end_options)
        return False

    # Called once for each hunk
    def _hunk_callback(self, hunk, count):
        if self.last_printed != count:
            self.diff_stream.write(str(hunk.patch.get_header()))
            self.diff_stream.write(str(hunk))
            self.last_printed = count

        if hunk.selected:
            self.interactor.get_option('y').default = True
            self.interactor.get_option('n').default = False
        else:
            self.interactor.get_option('y').default = False
            self.interactor.get_option('n').default = True

    # The user chooses to (un)shelve a hunk
    def _selected(self, hunk):
        hunk.selected = True
        return True

    # The user chooses to keep a hunk
    def _unselected(self, hunk):
        hunk.selected = False
        return True

    # The user chooses to invert the selection
    def _invert(self, hunk):
        for patch in self.patches:
            for hunk in patch.hunks:
                if hunk.__dict__.has_key('selected'):
                    hunk.selected = not hunk.selected
                else:
                    hunk.selected = True
        self._status()
        return False

    # The user wants to see the status
    def _status(self, hunk=None):
        print '\nStatus:'
        for patch in self.patches:
            print '  %s' % patch.oldname
            selected = 0
            unselected = 0
            for hunk in patch.hunks:
                if hunk.selected:
                    selected += 1
                else:
                    unselected += 1

            print '  ', self.strings['status_selected'] % selected
            print '  ', self.strings['status_unselected'] % unselected
            print

        # Tell the interactor we're not done with this item
        return False

    def select(self):
        if self.total_hunks == 0 or not self.interactor.interact():
            # False from interact means they chose to quit
            return ([], [])

        # Go through each patch and collect all selected/unselected hunks
        for patch in self.patches:
            patch.selected = []
            patch.unselected = []
            for hunk in patch.hunks:
                if hunk.selected:
                    patch.selected.append(hunk)
                else:
                    patch.unselected.append(hunk)

        # Now build two lists, one of selected patches the other unselected
        selected_patches = []
        unselected_patches = []

        for patch in self.patches:
            if len(patch.selected):
                tmp = copy.copy(patch)
                tmp.hunks = tmp.selected
                del tmp.selected
                del tmp.unselected
                selected_patches.append(tmp)

            if len(patch.unselected):
                tmp = copy.copy(patch)
                tmp.hunks = tmp.unselected
                del tmp.selected
                del tmp.unselected
                unselected_patches.append(tmp)

        return (selected_patches, unselected_patches)

class RecordPatchHunkSelector(HunkSelector):
    def __init__(self, patches, color=None):
        self.strings = {}
        self.strings['status_selected'] = '%d hunks to be recorded'
        self.strings['status_unselected'] = '%d hunks to be kept'
        self.strings['select_desc'] = 'record this change.'
        self.strings['unselect_desc'] = 'do not record this change.'
        self.strings['finish_desc'] = 'record selected changes.'
        self.strings['prompt'] = 'Record this change? (%(count)d of %(total)d)'
        self.strings['end_prompt'] = 'Record these changes?'
        HunkSelector.__init__(self, patches, color)
