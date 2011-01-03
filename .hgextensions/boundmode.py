#!/usr/bin/env python

# boundmode.py - bound mode (commit automatically pushes)
#
# Copyright 2009 Bill Barry <after.fallout@gmail.com>
#
# Copyright 2010 Dave James Miller - davejamesmiller.com
# Modified to:
# - Remove bound-push option (I don't see the point in it)
# - Make the bind path optional (use default path if none given)
#
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.

"""allows a repository to auto-push when you commit

Using this extension you will have two modes of operation:
1. unbound mode - repository behaves normally
   (commit is local; push must be done manually)
2. bound mode - commit automatically attempts push

You enter bound mode with the command 'hg bind' and can exit with 'hg unbind'.

This is a proof of concept extension. You can optionally configure repositories
to be in bound mode automatically when cloning by adding a file called
.hgboundrc to the root of your repository. This file must be an an ini file
and can contain:

  [paths]
  auto-push = <auto-push path>

  [ui]
  bound = <False | True>

to provide defaults for boundmode.
"""

from mercurial.i18n import _
from mercurial import commands, cmdutil, extensions, hg, util
from ConfigParser import RawConfigParser, NoSectionError
import os, sys

class boundrc:
    def parserc(self, fn):
        if not os.path.exists(fn):
            return None, None
        
        ini = RawConfigParser({
                'auto-push': None,
                'bound': False,
        })
        
        ini.read([fn])
        
        try:
            autopush = ini.get('paths', 'auto-push')
        except NoSectionError:
            autopush = None
        
        try:
            isbound = ini.get('ui', 'bound')
        except NoSectionError:
            isbound = None
        
        return autopush, isbound

    def __init__(self, ui, repo):
        self.userrc = os.sep.join([repo.root, '.hg', 'boundrc'])
        self.reporc = os.sep.join([repo.root, '.hgboundrc'])
        self.repo = repo
        self.ui = ui
        self.repoautopush, self.repoisbound = self.parserc(self.reporc)
        self.userautopush, self.userisbound = self.parserc(self.userrc)
        
    def isbound(self):
        if self.userisbound is not None:
            return self.userisbound == 'True'
        return self.repoisbound == 'True'
        
    def unbind(self):
        self.userisbound = 'False'

    def pushloc(self):
        path = self.userautopush or self.repoautopush
        if path:
            return hg.parseurl(self.ui.expandpath(path, None), None)[0]
        return None

    def saveitem(self, ini, section, name, value):
        if value is not None:
            if not ini.has_section(section):
                ini.add_section(section)
            ini.set(section, name, value)

    def saverc(self):
        addline = False
        fn = self.userrc
        ini = RawConfigParser()
        self.saveitem(ini, 'paths', 'auto-push', self.userautopush)
        self.saveitem(ini, 'ui', 'bound', self.userisbound)
        
        try:
            f = open(fn, "w")
            ini.write(f)
            f.close()
        except IOError:
            return 1
            
    def bind(self):
        self.userisbound = True

    def setloc(self, name):
        self.userautopush = name

def bind(ui, repo, name=None, **opts):
    """enters bound mode"""
    b = boundrc(ui, repo)
    if name != None:
        b.setloc(name)
    b.bind()
    b.saverc()
    ui.note(_('now in bound mode\n'))

def unbind(ui, repo, **opts):
    """exits bound mode"""
    b = boundrc(ui, repo)
    if not b.isbound():
        raise util.Abort(_('repository is not bound'))
    b.unbind()
    b.saverc()
    ui.note(_('now in unbound mode\n'))

def autopushwrapper(orig, ui, repo, *args, **opts):
    """if in bound mode this will attempt a push after calling the wrapped
       method
    """
    orig(ui, repo, *args, **opts)
    b = boundrc(ui, repo)
    if b.isbound():
        ui.note(_('commit succeeded; attempting push\n'))
        pushfunc = cmdutil.findcmd('push', commands.table)[1][0]
        dest = b.pushloc()
        pushfunc(ui, repo, dest, **opts)

def extsetup():
    'here we will wrap every command that commits in order to auto push'
    'some example methods are record, import, qfinish, and qremove'
    extensions.wrapcommand(commands.table, 'commit', autopushwrapper)

cmdtable = {
    'bind': (
        bind, [],
        _('hg bind [options] [name]')),

    'unbind': (
        unbind, [],
        _('hg unbind'))
}
