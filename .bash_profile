#!/bin/bash

if [ -f ~/.bashrc -a -z "$BASHRC_DONE" ]
then
    source ~/.bashrc
fi

# Setting PATH for Python 3.8
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}"
export PATH
