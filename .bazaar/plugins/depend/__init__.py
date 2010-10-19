# Written by Alexander Belchenko

"""Show versions of installed libraries used by bzr"""


from bzrlib.commands import Command, register_command


class cmd_dependencies(Command):
    """Show versions of installed libraries used by bzr"""

    aliases = ['depend', 'depends']

    def run(self):
        import os
        import sys

        if sys.platform == 'win32':
            self._print("System info", self._windows_version())
        else:
            self._print("System info", (sys.platform, os.name))
        self._print("Python interpreter", '.'.join(str(i) for i in sys.version_info))

        if sys.platform == "win32":
            # pywin32 version
            try:
                import win32file
            except ImportError:
                version = "None"
            else:
                try:
                    from file_version import get_file_version, VersionNotAvailable
                except ImportError:
                    version = '???'
                else:
                    fn = win32file.__file__
                    try:
                        ver = get_file_version(fn)
                    except VersionNotAvailable:
                        version = "unknown version"
                    else:
                        version = ver[2]
            self._print("pywin32", version)

            # ctypes (for win32)
            try:
                import ctypes
                version = ctypes.__version__
            except ImportError:
                version = 'None'
            self._print('ctypes', version)
        
        # elementtree
        et_ver = None
        cet_ver = None

        et_packages = (('xml.etree.ElementTree', 'xml.etree.cElementTree'),
                       ('elementtree.ElementTree', 'cElementTree'),
                      )

        for et, cet in et_packages:
            try:
                etm = __import__(et, globals(), locals(), ['ElementTree'])
                cetm = __import__(cet, globals(), locals(), ['cElementTree'])
            except ImportError:
                continue
            else:
                et_ver = etm.VERSION
                cet_ver = cetm.VERSION
                break

        self._print('ElementTree', et_ver)
        if cet_ver:
            self._print('cElementTree', cet_ver)
        
        # pycurl
        try:
            import pycurl
            version = pycurl.version
        except ImportError:
            version = 'None'
        self._print('PyCurl', version)
        
        # paramiko
        try:
            import paramiko
            version = paramiko.__version__
        except ImportError:
            version = 'None'
        self._print('Paramiko', version)
        
        # pycrypto
        try:
            import Crypto
            version = Crypto.__version__
        except ImportError:
            version = 'None'
        self._print('PyCrypto', version)

    def _print(self, name, version):
        print "%-20s %s" % ("%s:" % name, version)

    def _windows_version(self):
        import sys
        major, minor, build, platform, text = sys.getwindowsversion()
        ver = '%d.%d.%d' % (major, minor, build)
        if platform == 2:
            return 'Windows NT/2000/XP %s %s' % (ver, text)
        elif platform == 1:
            return 'Windows 9x/ME %s %s' % (ver, text)
#/class cmd_dependencies


register_command(cmd_dependencies)
