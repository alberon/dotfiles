#!/usr/bin/env python
# Copyright (C) 2008 Marius Kruger <amanic@gmail.com>
# Published under the GNU GPL v2 or later


from cStringIO import StringIO
from bzrlib.lazy_import import lazy_import
lazy_import(globals(), """
import os, re
from bzrlib import (
    diff,
    errors,
    globbing,
    osutils,
    patiencediff,
    textfile,
    trace,
    )
""")


_text_check_warn_only=False


class TextCheckFailed(errors.BzrError):

    _fmt = ("%(msg)s")

    def __init__(self, message):
        errors.BzrError.__init__(self)
        self.msg = message


def check_coding_style(old_filename, oldlines, new_filename, newlines, to_file,
                  allow_binary=False, sequence_matcher=None,
                  path_encoding='utf8'):
    """text_differ to be passed to diff.DiffText, which checks code style """
    if allow_binary is False:
        textfile.check_text_lines(oldlines)
        textfile.check_text_lines(newlines)

    if sequence_matcher is None:
        sequence_matcher = patiencediff.PatienceSequenceMatcher

    started = [False] #trick to access parent scoped variable
    def start_if_needed():
        if not started[0]:
            to_file.write('+++ %s\n' % new_filename)
            started[0] = True

    def check_newlines(j1, j2):
        for i, line in enumerate(newlines[j1:j2]):
            bad_ws_match = re.match(r'^(([\t]*)(.*?)([\t ]*))(\r?\n)?$', line)
            if bad_ws_match:
                line_content = bad_ws_match.group(1)
                has_leading_tabs = bool(bad_ws_match.group(2))
                has_trailing_whitespace = bool(bad_ws_match.group(4))
                if has_leading_tabs:
                    start_if_needed()
                    to_file.write('line %i has leading tabs: "%r"\n'% (
                        i+1+j1, line_content))
                if has_trailing_whitespace:
                    start_if_needed()
                    to_file.write('line %i has trailing whitespace: "%r"\n'% (
                        i+1+j1, line_content))
                if len(line_content) > 79:
                    print (
                        '\nFile %s\nline %i is longer than 79 characters:'
                        '\n"%r"'% (new_filename, i+1+j1, line_content))

    for group in sequence_matcher(None, oldlines, newlines
            ).get_grouped_opcodes(0):
        for tag, i1, i2, j1, j2 in group:
            if tag == 'replace' or tag == 'insert':
                check_newlines(j1, j2)
                if len(newlines) == j2 and not newlines[j2-1].endswith('\n'):
                    start_if_needed()
                    to_file.write("\\ No newline at end of file\n")


def get_config(branch):
    config = branch.get_config()
    action = config.get_user_option(
        'text_check_action')
    if _text_check_warn_only or action is None or action == '':
        action = 'warn'

    file_filters = config.get_user_option(
        'text_check_file_filters')
    if isinstance(file_filters, unicode) or isinstance(file_filters, str):
        # if it doesn't have a comma somewhere, get_value returns a
        # unicode value, but we want a list
        file_filters = [file_filters,]
    if file_filters is None:
        file_filters = []
    file_filters = [f for f in file_filters if len(f) > 0]
    return file_filters, action


def _check_text(globster, old_tree, new_tree):
    diff_output = StringIO()
    old_tree.lock_read()
    new_tree.lock_read()
    try:
        iterator = new_tree.iter_changes(old_tree)
        for (file_id, paths, changed_content, versioned, parent,
            name, kind, executable) in iterator:
            if (changed_content and paths[1] is not None and
                    globster.match(paths[1])):
                if kind == ('file', 'file'):
                    diff_text = diff.DiffText(old_tree, new_tree,
                        to_file=diff_output,
                        text_differ=check_coding_style)
                    diff_text.diff(file_id, paths[0], paths[1],
                        kind[0], kind[1])
                else:
                    check_coding_style(name[0], (), name[1],
                        new_tree.get_file(file_id).readlines(),
                        diff_output)
    finally:
        old_tree.unlock()
        new_tree.unlock()
    return diff_output.getvalue()


def _warn_or_fail(ws_diff, action='warn'):
    if len(ws_diff) > 0:
        msg = "Some text-checks failed:\n" + ws_diff
        if action == 'warn':
            trace.warning(msg)
        elif action == 'fail':
            raise TextCheckFailed(msg)


def check_text(local_branch, new_tree):
    file_filters, action = get_config(local_branch)
    old_tree = local_branch.basis_tree()
    globster = globbing.Globster(file_filters)
    ws_diff = _check_text(globster, old_tree, new_tree)
    _warn_or_fail(ws_diff, action)


def _get_backup_name(path):
    def name_gen():
        counter = 1
        while True:
            yield "%s.~%d~" % (path, counter)
            counter += 1
    for new_path in name_gen():
        if not os.path.exists(new_path):
            return new_path


def _replace_file(path, new_text):
    statval = os.lstat(path)
    os.rename(path, _get_backup_name(path))
    f = open(path, 'wb', statval.st_mode)
    try:
        text = f.write(new_text)
    finally:
        f.close()
    os.chmod(path, statval.st_mode)


def _remove_trailing_whitespace(path, tr_ws_re):
    f = open(path, 'rb')
    try:
        text = f.read()
    finally:
        f.close()
    lines = text.splitlines(True)
    line_count = 0
    new_lines = []
    for line_no, line in enumerate(lines):
        if line.endswith(' \n'):
            mo = tr_ws_re.match(line)
            if mo:
                #print "%i) old '%s'" % (line_no, line[:-1])
                new_line = mo.group(1) + mo.group(3)
                #print "%i) new '%s'" % (line_no, new_line[:-1])
                new_lines.append(new_line)
                line_count += 1
            else:
                print "Internal error"
                new_lines.append(line)
        else:
            new_lines.append(line)
    if line_count > 0:
        _replace_file(path, ''.join(new_lines))
        print "%s: %i lines fixed" % (path , line_count)
    return line_count


def remove_trailing_whitespace(name_pattern_list):
    globster = globbing.Globster(name_pattern_list)
    tr_ws_re = re.compile(r'^(.*?)( *)(\r?\n)?$')
    files_changed_count=0
    line_count=0
    for root, dirs, files in os.walk('.'):
        for f in files:
            path = osutils.pathjoin(root, f)
            if globster.match(path):
                flc = _remove_trailing_whitespace(path, tr_ws_re)
                if flc > 0:
                    files_changed_count += 1
                    line_count += flc
    print "%i files and %i lines were updated." % (files_changed_count,
        line_count)
