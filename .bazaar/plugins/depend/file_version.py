#!/usr/bin/python

"""Get file version.
Written by Alexander Belchenko, 2006
"""

import os
import sys

import pywintypes   # from pywin32 (http://pywin32.sf.net)
try:
    import win32api     # from pywin32 (http://pywin32.sf.net)
except ImportError:
    # pywin32 not installed?
    if sys.version.startswith('2.4'):
        from py2_4 import win32api
    elif sys.version.startswith('2.5'):
        from py2_5 import win32api
    else:
        raise


__all__ = ['get_file_version', 'FileNotFound', 'VersionNotAvailable']
__docformat__ = "restructuredtext"


class FileNotFound(Exception):
    pass

class VersionNotAvailable(Exception):
    pass


def get_file_version(filename):
    """Get file version (windows properties)
    :param  filename:   path to file
    :return:            4-tuple with 4 version numbers
    """
    if not os.path.isfile(filename):
        raise FileNotFound

    try:
        version_info = win32api.GetFileVersionInfo(filename, '\\')
    except pywintypes.error:
        raise VersionNotAvailable

    return (divmod(version_info['FileVersionMS'], 65536) +
            divmod(version_info['FileVersionLS'], 65536))
