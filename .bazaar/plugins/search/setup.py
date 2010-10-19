#!/usr/bin/env python2.4
from distutils.core import setup

bzr_plugin_name = 'search'

bzr_plugin_version = (1, 7, 0, 'dev', 0)
bzr_commands = ['index', 'search']
bzr_minimum_version = (1, 6, 0)

if __name__ == '__main__':
    setup(name="bzr search",
          version="1.7.0dev0",
          description="bzr search plugin.",
          author="Robert Collins",
          author_email="bazaar@lists.canonical.com",
          license = "GNU GPL v2",
          url="https://launchpad.net/bzr-search",
          packages=['bzrlib.plugins.search',
                    'bzrlib.plugins.search.tests',
                    ],
          package_dir={'bzrlib.plugins.search': '.'})
