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

class UserOption:
    def __init__(self, char, action, help, default=False):
        self.char = char
        self.action = action
        self.default = default
        self.help = help

class UserInteractor(object):
    # Special actions
    RESTART = 0
    QUIT = 1
    FINISH = 2

    def __init__(self):
        self.items = []

    def add_item(self, item):
        self.items.append(item)
        self.__total_items = len(self.items)

    def set_items(self, item_list):
        self.items = item_list
        self.__total_items = len(self.items)

    def set_item_callback(self, cb):
        self.item_callback = cb

    def set_start_callback(self, cb):
        self.start_callback = cb

    def set_end_callback(self, cb):
        self.end_callback = cb

    def set_prompt(self, prompt):
        self.prompt = prompt

    def set_options(self, opt_list):
        self._options = []
        self._option_dict = {}
        for option in opt_list:
            self.add_option(option)

    def add_option(self, option):
        self._options.append(option)
        self._option_dict[option.char] = option

    def get_option(self, char):
        return self._option_dict[char]

    def __do_action(self, action, item):
        if type(action) is int:
            if action == self.QUIT:
                self.__quit = True
                self.__finished = True
            elif action == self.RESTART:
                self.__restart = True
                self.__finished = False
            elif action == self.FINISH:
                self.__finished = True
            return True
        else:
            return action(item)

    def __select_loop(self):
        i = 0
        self.start_callback()
        while i < len(self.items):
                item = self.items[i]

                self.item_callback(item, i + 1)

                if self.__ask_once(item, i + 1):
                    i += 1

                if self.__quit or self.__finished:
                    break

    def interact(self):
        self.__quit = False
        self.__finished = False

        while not self.__quit and not self.__finished:
            self.__restart = False

            self.__select_loop()
            if self.__quit:
                break

            if self.end_callback():
                break

            self.__finished = False

            self.__ask_once(None, self.__total_items)
            while not self.__finished and not self.__restart:
                self.__ask_once(None, -1)

        return not self.__quit

    def __ask_once(self, item, count):
        args = {'count': count, 'total' : self.__total_items}

        while True:
            sys.stdout.write(self.prompt % args)
            sys.stdout.write(' [')
            for opt in self._options:
                if opt.default:
                    default = opt
                sys.stdout.write(opt.char)
            sys.stdout.write('?] (%s): ' % default.char)

            response = self.__getchar()

            # default, which we see as newline, is 'n'
            if response in ['\n', '\r', '\r\n']:
                response = default.char

            print response # because echo is off

            for opt in self._options:
                if opt.char == response:
                    return self.__do_action(opt.action, item)

            self.__show_help()

        return False # keep pychecker happy

    def __show_help(self):
        for opt in self._options:
            print '  %s - %s' % (opt.char, opt.help)

    if sys.platform == "win32":
        def __getchar(self):
            import msvcrt
            return msvcrt.getch()
    else:
        def __getchar(self):
            import tty
            import termios
            fd = sys.stdin.fileno()
            settings = termios.tcgetattr(fd)
            try:
                tty.setraw(fd)
                ch = sys.stdin.read(1)
            finally:
                termios.tcsetattr(fd, termios.TCSADRAIN, settings)
            return ch
