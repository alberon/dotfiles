# Author: eduardo.padoan@gmail.com

"""
Bazaar Regexp Mass-Renaming
===========================
This plugin allows you to rename multiple files at once, using
`Regular Expressions`_

$ bzr ls
 somedir/
 somedir/somefile1.txt
 somedir/somefile2.txt
 somedir/subdir/
 somedir/subdir/somefile1.rst
 somedir/subdir/somefile3.txt
 somefile4.XXX
$ bzr mmv "^somefile([0-9])(.*)" "file_\\1_a\\2" --no-prompt
$ bzr st
 R   somefile4.XXX => file_4_a.XXX
 R   somedir/somefile1.txt => somedir/file_1_a.txt
 R   somedir/somefile2.txt => somedir/file_2_a.txt
 R   somedir/subdir/somefile1.rst => somedir/subdir/file_1_a.rst
 R   somedir/subdir/somefile3.txt => somedir/subdir/file_3_a.txt

.. _`Regular Expression`: http://docs.python.org/library/re.html

"""
from bzrlib.option import Option
from bzrlib.commands import Command, register_command

from bzrlib.lazy_import import lazy_import
lazy_import(globals(), '''
import re
from os import path
from bzrlib import workingtree
''')

# TODO:
#  - Implement option for --recursive renaming.
#  - Unit tests.

version_info = '0.0.1 pre-alpha'


class cmd_multi_rename(Command):
    """Renames files using a regular expression.

    Renames files that match the given EXPRESSION, a regexp.
    Substitutes matches of EXPRESSION on each filename with
    REPLACEMENT:

     $ bzr multi-rename "^(test)([a-z0-9]*)" "\\1_\\2"

    This will rename files like "testfoo1.py" to "test_foo1.py".

    The optional LOCATION is the current directory by default.
    """
    aliases = ['mmv', 'multi-move']

    takes_options = [
        Option('no-prompt',
               help='Do not ask for confirmation before renaming.'),
        Option('match-path',
               help='Search the pattern in the whole file path, '
               'not only in the file name.'),
        Option('dry-run',
               help='Do not actually rename the files.'),
        #Option('recursive',
        #       help='Renames files recursively within directories.'),
    ]
    takes_args = ['expression', 'replacement', 'location?']


    def run(self, expression, replacement, location='.',
            no_prompt=False, match_path=False, dry_run=False, recursive=False):

        renamer = MassRenamer(expression, replacement, location,
                              no_prompt, match_path, dry_run,
                              recursive)
        renamer.rename_all()


class MassRenamer(object):

    def __init__(self, expression, replacement, location,
                 no_prompt, match_path, dry_run, recursive):
        # will compile the expression when needed, but only once.
        self.regexp = None
        self.expression = expression
        self.replacement = replacement
        self.location = location
        self.no_prompt = no_prompt
        self.match_path = match_path
        self.dry_run = dry_run

        self.wt = workingtree.WorkingTree.open_containing(location)[0]

    def rename_all(self):
        files_to_rename = self.get_renames()
        if files_to_rename:
            self.rename_files(files_to_rename)
        elif files_to_rename is not None:
            print 'No file name matches the expression: "%s"' % self.expression

    def iter_matches(self):
        for filepath in self.iter_filepaths():
            match = self.get_match(filepath)
            if match:
                yield match

    def iter_filepaths(self):
        self.wt.lock_read()
        try:
            location_id = self.wt.inventory.path2id(self.location)
            for f, i in self.wt.inventory.iter_entries_by_dir(location_id):
                yield f
        finally:
            self.wt.unlock()

    def get_match(self, filepath):

        if self.regexp is None:
            self.regexp = re.compile(self.expression)

        if self.match_path:
            new_filepath, total = self.regexp.subn(self.replacement, filepath)
        else:
            # "subdir/somefile.txt" -> "subdir", "somefile.txt"
            pathroot, filename = path.split(filepath)
            new_filename, total = self.regexp.subn(self.replacement, filename)

        if not total:
            return False

        # "somedir", "subdir/somefile.txt" -> "somedir/subdir/somefile.txt"
        old_filepath = path.join(self.location, filepath)

        if self.match_path:
            # "somedir", "subdir/newname.txt" -> "somedir/subdir/newname.txt"
            new_filepath = path.join(self.location, new_filepath)
        else:
            # "somedir", "subdir", "newname.txt" -> "somedir/subdir/newname.txt"
            new_filepath = path.join(self.location, pathroot, new_filename)

        return old_filepath, new_filepath

    def get_renames(self):
        if self.no_prompt:
            return list(self.iter_matches())

        # we cant just return self.iter_matches(), because
        # it will be consumed by the end, and we dont want
        # to call it twice. So lets create a list of files.
        files_to_rename = []
        for old_name, new_name in self.iter_matches():
            print 'R', old_name, '=>', new_name
            files_to_rename.append((old_name, new_name))

        if files_to_rename:
            total = len(files_to_rename)

            if total > 1:
                question = 'Rename this %s files [y/N]? ' % total
            else:
                question = 'Rename this file [y/N]? '

            if raw_input(question).lower() not in ('y', 'yes'):
                print 'Canceled.'
                files_to_rename = None

        return files_to_rename

    def rename_files(self, files):
        for old_name, new_name in files:
            if not self.dry_run:
                self.wt.rename_one(old_name, new_name)

register_command(cmd_multi_rename)
