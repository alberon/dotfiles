#!/usr/bin/python

import re
from termcolour import TermColour

class DiffStat(object):
    def __init__(self, lines, dir_only=False, colour=False):
        self.dir_only = dir_only
        self.maxname = 0
        self.maxtotal = 0
        self.total_adds = 0
        self.total_removes = 0
        self.stats = {}
        self.files = []
        self.colour = colour
        self.__parse(lines)

    def __parse(self, lines):
        import string
        adds = 0
        removes = 0
        current = None

        # This regex is supposed to take into account the timestamp at the end
        # of the filename, so we can exclude it when outputting the filename
        filename_re = re.compile('^(---|\+\+\+) (.*?)\s+[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} \+[0-9]{4}$')

        for line in lines:
            if line.startswith('+') and not line.startswith('+++'):
                adds += 1
            elif line.startswith('-') and not line.startswith('---'):
                removes += 1
            elif line.startswith('=== '):
                self.__add_stats(current, adds, removes)

                adds = 0
                removes = 0
                context = 0
                current = None
            else:
                match = filename_re.match(line)

                if match != None and \
                   ((match.group(1) == '---' and current is None) or \
                    (match.group(1) == '+++' and current == '/dev/null')):
                    current = match.group(2)

        self.__add_stats(current, adds, removes)

    class Filestat:
        def __init__(self):
            self.adds = 0
            self.removes = 0
            self.total = 0

    def __add_stats(self, file, adds, removes):
        if file is None:
            return
        if (self.dir_only):
            dlist = file.rsplit('/',1)
            if file == dlist[0]:
                file = "."
            else:
                file = dlist[0]
        if file in self.stats:
            fstat = self.stats[file]
        else:
            self.files.append(file)
            fstat = self.Filestat()

        fstat.adds += adds
        fstat.removes += removes
        fstat.total += adds + removes
        self.stats[file] = fstat

        self.maxname = max(self.maxname, len(file))
        self.maxtotal = max(self.maxtotal, fstat.total)
        self.total_adds += adds
        self.total_removes += removes

    def __str__(self):
        if self.colour == True:
            termc = TermColour()

        # Work out widths
        width = 78 - 5
        countwidth = len(str(self.maxtotal))
        graphwidth = width - countwidth - self.maxname
        factor = 1

        # The graph width can be <= 0 if there is a modified file with a
        # filename longer than 'width'. Use a minimum of 10.
        if graphwidth < 10:
            graphwidth = 10

        while (self.maxtotal / factor) > graphwidth:
            factor += 1

        s = ""

        for file in self.files:
            fstat = self.stats[file]

            s += ' %-*s | %*.d ' % (self.maxname, file, countwidth, fstat.total)

            # If diffstat runs out of room it doesn't print anything, which
            # isn't very useful, so always print at least one + or 1
            if fstat.adds > 0:
                adds = '+' * max(fstat.adds / factor, 1)

                if self.colour == True:
                    adds = termc.colour_string(adds, foreground='green')

                s += adds

            if fstat.removes > 0:
                removes = '-' * max(fstat.removes / factor, 1)

                if self.colour == True:
                    removes = termc.colour_string(removes, foreground='red')

                s += removes

            s += '\n'

        if len(self.stats):
            if self.dir_only == True:
                noun = 'directories'
            else:
                noun = 'files'
            s += ' %d %s changed, %d insertions(+), %d deletions(-)' % \
                (len(self.stats), noun, self.total_adds, self.total_removes)

        return s

if __name__ == '__main__':
    import sys
    ds = DiffStat(sys.stdin.readlines())
    print ds
