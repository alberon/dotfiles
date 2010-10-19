#!/usr/bin/env python
USAGE = """
Just run runtest.py.
Any supplied arguments are treated as PYTHONPATH prefixes."""

import sys
import os.path
import unittest
import tempfile
import shutil

path_prefix = []
if len(sys.argv) > 1:
    if sys.argv[1] in ("-h", "--help", ""):
        print USAGE
        sys.exit(0)
    path_prefix = sys.argv[1:]

path_prefix.append(os.path.join(os.path.dirname(__file__), ".."))
sys.path = [os.path.realpath(p) for p in path_prefix] + sys.path

try:
    import undelete
except ImportError, e:
    if len(sys.argv) == 1 and "undelete" in str(e):
        print "You can specify the path to bzrlib as the first argument"
    raise

suite = undelete.test_suite()
runner = unittest.TextTestRunner(verbosity=0)
tempdir = tempfile.mkdtemp()

try:
    os.chdir(tempdir)
    result = runner.run(suite)
finally:
    shutil.rmtree(tempdir)

sys.exit({True: 0, False: 3}[result.wasSuccessful()])

