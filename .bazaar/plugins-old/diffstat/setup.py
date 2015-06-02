#!/usr/bin/env python
from distutils.core import setup
setup(name="bzr-diffstat",
      version="0.2.0",
      description="Diffstat plugin for bzr.",
      author="Russ Brown",
      author_email="pickscrape@gmail.com",
      license = "GPLV2",
      url="https://launchpad.net/bzr-diffstat",
      packages=['bzrlib.plugins.diffstat',
                'bzrlib.plugins.diffstat.tests',
                ],
      package_dir={'bzrlib.plugins.diffstat': '.'},
      )
