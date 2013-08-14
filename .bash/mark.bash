#!/bin/bash

# Based on
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html

MARKPATH=$HOME/.marks

jump() {
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1" >&2
}

mark() {
    mkdir -p $MARKPATH
    mark=${1:-$(basename $PWD)}
    ln -s $(pwd) $MARKPATH/$mark && alias $mark="jump $mark"
}

unmark() {
    mark=${1:-$(basename $PWD)}
    if [ -L $MARKPATH/$mark ]; then
        rm -f $MARKPATH/$mark && unalias $mark
    else
        echo "No such mark: $1" >&2
    fi
}

marks() {
    command ls -l --color=always --classify $MARKPATH | sed '1d;s/  / /g' | cut -d' ' -f9-
}

for mark in `command ls $MARKPATH`; do
    alias $mark="jump $mark"
done
