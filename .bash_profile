#!/bin/bash

if [ -f ~/.bashrc -a "$BASHRC_DONE" != 1 ]
then
    source ~/.bashrc
fi
