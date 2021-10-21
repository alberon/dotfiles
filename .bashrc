# Google Cloud Shell (required)
if $HAS_TERMINAL; then
    if [ -f "/google/devshell/bashrc.google" ]; then
        source "/google/devshell/bashrc.google"
    fi
fi

#=== 000-vars.bash ===
# Detect operating system
CYGWIN=false
DOCKER=false
MSYSGIT=false
MAC=false
WINDOWS=false
WSL=false

if grep -q 'WSL\|Microsoft' /proc/version; then
    # Note: WINDOWS=false in WSL because it's more Linux-like than Windows-like
    WSL=true
    # These paths are useful for some functions & scripts
    WIN_APPDATA="$(cd /mnt/c && cmd.exe /C 'echo %APPDATA%' | tr -d '\r')"
    WIN_APPDATA_UNIX="$(wslpath "$WIN_APPDATA")"
    WIN_TEMP="$(cd /mnt/c && cmd.exe /C 'echo %TEMP%' | tr -d '\r')"
    WIN_TEMP_UNIX="$(wslpath "$WIN_TEMP")"
    WIN_MYDOCS="$(powershell.exe -Command "[Environment]::GetFolderPath('MyDocuments')" | tr -d '\r')"
    WIN_MYDOCS_UNIX="$(wslpath "$WIN_MYDOCS")"
else
    case "$(uname -a)" in
        CYGWIN*) WINDOWS=true; CYGWIN=true ;;
        MINGW*)  WINDOWS=true; MSYSGIT=true ;;
        Darwin)  MAC=true ;;
    esac
fi

if [ -f /.dockerenv ]; then
    DOCKER=true
fi

# Detect whether there's a terminal
# - $TERM=dumb for 'scp' command
# - $BASH_EXECUTION_STRING is set for forced commands like 'gitolite'
# - [ -t 0 ] (open input file descriptor) is false when Vagrant runs 'salt-call'
if [ "$TERM" != "dumb" -a -z "${BASH_EXECUTION_STRING:-}" -a -t 0 ]; then
    HAS_TERMINAL=true
else
    HAS_TERMINAL=false
fi


#=== 010-config.bash ===
# Defaults
prompt_default=
prompt_type=
umask_root=022
umask_user=007
www_dir=

# Default prompt is hostname with uppercase first letter with pink background
#if $WINDOWS; then
#    hostname="`hostname`"
#else
#    hostname="`hostname -s`"
#fi
#prompt_default="$(echo "${hostname:0:1}" | tr [a-z] [A-Z])${hostname:1}"

# Load custom config options
if [ -f ~/.bashrc_config ]; then
    source ~/.bashrc_config
fi

#=== 020-umask.bash ===
if [ `id -u` -eq 0 ]; then
    umask $umask_root
else
    umask $umask_user
fi

#=== 030-path.bash ===
# Note: The most general ones should be at the top, and the most specific at the
# bottom (e.g. local script) so they override the general ones if needed

# MacPorts
$MAC && PATH="/opt/local/bin:/opt/local/sbin:$PATH"

# Yarn
PATH="$HOME/.yarn/bin:$PATH"

# RVM
PATH="$HOME/.rvm/bin:$PATH"

# Composer
PATH="$HOME/.config/composer/vendor/bin:$HOME/.composer/vendor/bin:$HOME/.composer/packages/vendor/bin:$PATH"

# Go
PATH="$HOME/go/bin:$PATH"

# Manually installed packages
for bin in $HOME/opt/*/bin; do
    PATH="$bin:$PATH"
done

# Custom scripts
PATH="$HOME/.bin:$PATH"

# Custom OS-specific scripts
if $MAC; then
    PATH="$HOME/.bin/osx:$PATH"
elif $WINDOWS; then
    PATH="$HOME/.bin/win:$PATH"
fi

# Custom local scripts (specific to a machine so not in Git)
PATH="$HOME/local/bin:$PATH"

# Export the path so subprocesses can use it
export PATH

# Add extra man pages
#if command -v manpath &>/dev/null; then
#    MANPATH="$(manpath 2>/dev/null)"
#    export MANPATH
#fi

# Tool to debug the path
dump_path()
{
    echo -e "${PATH//:/\\n}"
}

#=== 040-auto-update.bash ===
if $HAS_TERMINAL; then

    # Check what the current revision is
    old_head=$(cd; git rev-parse HEAD)

    # Catch Ctrl-C - sometimes if GitHub or my internet connection is down I
    # need to be able to cancel the update without skipping the rest of .bashrc
    trap 'echo' INT

    # Run the auto-update
    ~/.dotfiles/auto-update

    trap - INT

    # Reload Bash if any changes were made
    if [ "$(cd; git rev-parse HEAD)" != "$old_head" ]; then
        exec bash -l
    fi

fi

#=== 050-motd.bash ===
if [ -n "$TMUX" ]; then
    # Show the MOTD inside tmux, since it won't be shown if we load tmux
    # immediately from ssh instead of Bash
    if [ -f /run/motd.dynamic ]; then
        cat /run/motd.dynamic
        hr="$(printf "%${COLUMNS}s" | tr ' ' -)"
        echo -e "\033[30;1m$hr\033[0m"
    fi
fi

#=== ask.sh ===
source ~/.bash/ask.sh

#=== bind.bash ===
if $HAS_TERMINAL; then
    # Couldn't get these working in .inputrc
    bind '"\eOC":forward-word'
    bind '"\eOD":backward-word'
fi

#=== build-tools.bash ===
# Grunt
if command -v grunt &>/dev/null; then
    eval "$(grunt --completion=bash)"
fi

p() {
    red bold "The 'p' (gulp) command is deprecated - you should use 'a' (assets) instead, which supports webpack"
    gulp "$@"
}

#=== cd-ls.bash ===
if $HAS_TERMINAL; then

    # Remember the last directory visited
    record_bash_lastdirectory() {
        pwd > ~/.bash_lastdirectory
    }

    cd() {
        command cd "$@" && record_bash_lastdirectory
    }

    # Change to the last visited directory, unless we're already in a different directory
    if [ "$PWD" = "$HOME" ]; then
        if [ -f ~/.bash_lastdirectory ]; then
            # Throw away errors about that directory not existing (any more)
            command cd "$(cat ~/.bash_lastdirectory)" 2>/dev/null
        elif [ -n "$www_dir" ]; then
            # If this is the first login, try going to the web root instead
            # Mainly useful for Vagrant boxes
            cd "$www_dir"
        fi
    fi

    # Detect typos in the cd command
    shopt -s cdspell

    # Need some different options for ls on Mac
    if $MAC; then
        # Mac
        ls_opts='-G'
    elif ls --hide=*.pyc >/dev/null 2>&1; then
        # Recent Linux
        ls_opts='--color=always --hide=*.pyc --hide=*.sublime-workspace'
    else
        # Old Linux (without --hide support)
        ls_opts='--color=always'
    fi

    # c = cd; ls
    c() {

        # cd to the given directory
        if [[ "$@" != "." ]]; then
            # If "." don't do anything, so that "cd -" still works
            # Don't output the path as I'm going to anyway (done by "cd -" and cdspell)
            cd "$@" >/dev/null || return
        fi

        # Output the path
        echo
        echo -en "\033[4;1m"
        echo $PWD
        echo -en "\033[0m"

        # List the directory contents
        ls -hF $ls_opts

    }

    # Various shortcuts for `ls`
    # ls, lsa   = short format
    # l,  la    = long format
    # ll, lla   = long format (deprecated)
    alias ls="ls -hF $ls_opts"
    alias lsa="ls -hFA $ls_opts"

    alias l="ls -hFl $ls_opts"
    alias la="ls -hFlA $ls_opts"

    # Old aliases
    alias ll='l'
    alias lla='la'

    # Use colours for 'tree' too
    alias tree='tree -C'

    # Custom 'ls' colours
    if $MAC; then
        # Use the same color scheme as Debian
        # http://geoff.greer.fm/lscolors/
        export LSCOLORS=ExGxFxDaCaDaDahbaDacec
    else
        # These don't work on CentOS 5: rs (RESET), mh (MULTIHARDLINK), ca (CAPABILITY) - but we're using the defaults so it doesn't really matter
        #export LS_COLORS='rs=0:fi=01;37:di=01;33:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32'
        export LS_COLORS='fi=01;37:di=01;33:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32'
    fi

    # Stop newer versions of Bash quoting the filenames in ls
    # http://unix.stackexchange.com/a/258687/14368
    export QUOTING_STYLE=literal

    # u = up
    alias u='c ..'
    alias uu='c ../..'
    alias uuu='c ../../..'
    alias uuuu='c ../../../..'
    alias uuuuu='c ../../../../..'
    alias uuuuuu='c ../../../../../..'

    # b = back
    alias b='c -'

    # cw = web files directory
    if [ -n "$www_dir" ]; then
        alias cw="c $www_dir"
    fi

fi

#=== chmox.bash ===
# I keep typing this wrong:
alias chmox='chmod'

#=== color.bash ===
source ~/.bash/color.bash

#=== colors.sh ===
# LEGACY - See color.bash for the new version

colorize() {
    while [ $# -gt 0 ]; do
        case "$1" in

            resetAll)
                echo -en "\e[0m"
                shift
                ;;

            resetUnderline)
                echo -en "\e[24m"
                shift
                ;;

            resetReverse)
                echo -en "\e[27m"
                shift
                ;;

            resetFg)
                echo -en "\e[39m"
                shift
                ;;

            resetBg)
                echo -en "\e[49m"
                shift
                ;;

            bold)
                echo -en "\e[1m"
                shift
                ;;

            bright)
                echo -en "\e[2m"
                shift
                ;;

            underline)
                echo -en "\e[4m"
                shift
                ;;

            reverse)
                echo -en "\e[7m"
                shift
                ;;

            black)
                echo -en "\e[30m"
                shift
                ;;

            red)
                echo -en "\e[31m"
                shift
                ;;

            green)
                echo -en "\e[32m"
                shift
                ;;

            yellow)
                echo -en "\e[33m"
                shift
                ;;

            blue)
                echo -en "\e[34m"
                shift
                ;;

            magenta)
                echo -en "\e[35m"
                shift
                ;;

            cyan)
                echo -en "\e[36m"
                shift
                ;;

            white)
                echo -en "\e[37m"
                shift
                ;;

            blackBg)
                echo -en "\e[40m"
                shift
                ;;

            redBg)
                echo -en "\e[41m"
                shift
                ;;

            greenBg)
                echo -en "\e[42m"
                shift
                ;;

            yellowBg)
                echo -en "\e[43m"
                shift
                ;;

            blueBg)
                echo -en "\e[44m"
                shift
                ;;

            magentaBg)
                echo -en "\e[45m"
                shift
                ;;

            cyanBg)
                echo -en "\e[46m"
                shift
                ;;

            whiteBg)
                echo -en "\e[47m"
                shift
                ;;

            --)
                shift
                echo -n "$@"
                resetAll
                echo
                return
                ;;

            *)
                echo -n "$@"
                resetAll
                echo
                return
                ;;

        esac
    done
}

resetAll()       { colorize resetAll       "$@"; }
resetUnderline() { colorize resetUnderline "$@"; }
resetReverse()   { colorize resetReverse   "$@"; }
resetFg()        { colorize resetFg        "$@"; }
resetBg()        { colorize resetBg        "$@"; }
bold()           { colorize bold           "$@"; }
bright()         { colorize bright         "$@"; }
underline()      { colorize underline      "$@"; }
reverse()        { colorize reverse        "$@"; }
black()          { colorize black          "$@"; }
red()            { colorize red            "$@"; }
green()          { colorize green          "$@"; }
yellow()         { colorize yellow         "$@"; }
blue()           { colorize blue           "$@"; }
magenta()        { colorize magenta        "$@"; }
cyan()           { colorize cyan           "$@"; }
white()          { colorize white          "$@"; }
blackBg()        { colorize blackBg        "$@"; }
redBg()          { colorize redBg          "$@"; }
greenBg()        { colorize greenBg        "$@"; }
yellowBg()       { colorize yellowBg       "$@"; }
blueBg()         { colorize blueBg         "$@"; }
magentaBg()      { colorize magentaBg      "$@"; }
cyanBg()         { colorize cyanBg         "$@"; }
whiteBg()        { colorize whiteBg        "$@"; }

#=== completion.bash ===
# This is needed to prevent this error when using SSH:
#   /usr/share/bash-completion/completions/ssh: line 357: syntax error near unexpected token `('
#   /usr/share/bash-completion/completions/ssh: line 357: `        !(*:*)/*|[.~]*) ;; # looks like a path'
# https://trac.macports.org/ticket/44558#comment:13
shopt -s extglob

# This seems to be loaded automatically on some servers and not on others

if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Don't tab-complete an empty line - there's not really any use for it
shopt -s no_empty_cmd_completion

#=== docker.bash ===
# Shorthand
alias d='docker'
alias db='docker build'
alias dc='docker-compose'
alias dr='docker run'
alias dri='docker run -it'

# Clean up stopped containers and dangling (untagged) images
dclean()
{
    docker container prune
    docker image prune
}

# Kill most recent container
dkill()
{
    container="${1:-}"
    if [ -z "$container" ]; then
        container="$(docker ps -qlf status=running)"
    fi

    if [ -n "$container" ]; then
        docker kill $container
    fi
}

# Kill all containers
dkillall()
{
    containers="$(docker ps -qf status=running)"

    if [ -n "$containers" ]; then
        docker kill $containers
    fi
}

# Resume
dresume()
{
    # http://stackoverflow.com/a/37886136/167815
    container="$(docker ps -qlf status=exited)"

    if [ -n "$container" ]; then
        docker start -ai "$container"
    else
        echo "No stopped images found." >&2
        return 1
    fi
}

# Serve a directory of files over HTTP for quick local sharing
# https://github.com/halverneus/static-file-server
dserve()
{
    dr -v "$PWD:/web" -p 80:8080 halverneus/static-file-server
}

# Shell
dsh()
{
    # Set up SSH agent forwarding
    if [ -n "$SSH_AUTH_SOCK" ]; then
        opt=(--volume $SSH_AUTH_SOCK:/tmp/ssh-agent --env SSH_AUTH_SOCK=/tmp/ssh-agent)
    else
        opt=()
    fi

    # Build the command to run a shell on the specified image
    local image="${1:-ubuntu}"
    local entrypoint="${2:-/bin/bash}"
    shift $(($# > 2 ? 2 : $#))

    docker run "${opt[@]}" -it "$@" --entrypoint "$entrypoint" "$image"
}

# Stop most recent container
dstop()
{
    container="${1:-}"
    if [ -z "$container" ]; then
        container="$(docker ps -qlf status=running)"
    fi

    if [ -n "$container" ]; then
        docker stop $container
    fi
}

# Stop all containers
dstopall()
{
    containers="$(docker ps -qf status=running)"

    if [ -n "$containers" ]; then
        docker stop $containers
    fi
}

#=== domain-tools.bash ===
domain_command() {
    command="$1"
    shift

    # Accept URLs and convert to domain name only
    domain=$(echo "$1" | sed 's#https\?://\([^/]*\).*/#\1#')

    if [ -n "$domain" ]; then
        shift
        command $command "$domain" "$@"
    else
        command $command "$@"
    fi
}

alias host="domain_command host"
alias nslookup="domain_command nslookup"
alias whois="domain_command whois"

#=== editor.bash ===
export EDITOR=vim
export GEDITOR=vim

if $MAC; then

    # Only if using a local terminal not SSH
    if [ -z "$SSH_CLIENT" ]; then
        if [ -f /Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl ]; then

            # Sublime Text 2
            export EDITOR='subl -w'
            export GEDITOR=subl

        elif mvim --version &>/dev/null; then

            # MacVim
            # Note: Can't use `command -v mvim` above because the mvim script exists
            # whether or not the actual MacVim.app exists - so we have to run
            # the script to determine whether it returns an error or not
            alias gvim=mvim
            export EDITOR='mvim --cmd "let g:nonerdtree = 1" -f'
            export GEDITOR=mvim

        fi
    fi

elif $MSYSGIT; then

    # Use the complete version of Vim on Windows instead of the cut down version
    # that's included with Git Bash
    for vimpath in \
        "/c/Program Files (x86)/Vim/vim74" \
        "/c/Program Files/Vim/vim74" \
        "/c/Program Files (x86)/Vim/vim73" \
        "/c/Program Files/Vim/vim73";
    do
        if [ -f "$vimpath/vim.exe" ]; then
            PATH="$vimpath:$PATH"
            alias vi=vim.exe
            alias vim=vim.exe
            alias gvim=gvim.exe
            export EDITOR=vim.exe
            export GEDITOR=vim.exe
            break
        fi
    done

    unset vimpath

fi

export VISUAL=$EDITOR

#=== git.bash ===
# g = git
alias g='git'

# 'git' with no parameters loads interactive REPL
git() {
    if [ $# -gt 0 ]; then
        command git "$@"
    else
        command git status
    fi
}

# cd to repo root
cg() {
    # Look in parent directories
    path="$(git rev-parse --show-toplevel 2>/dev/null)"

    # Look in child directories
    if [ -z "$path" ]; then
        path="$(find . -mindepth 2 -maxdepth 2 -type d -name .git 2>/dev/null)"
        if [ $(echo "$path" | wc -l) -gt 1 ]; then
            echo "Multiple repositories found:" >&2
            echo "$path" | sed 's/^.\//  /g; s/.git$//g' >&2
            return
        else
            path="${path%/.git}"
        fi
    fi

    # Go to the directory, if found
    if [ -n "$path" ]; then
        c "$path"
    else
        echo "No Git repository found in parent directories or immediate children" >&2
    fi
}

# 'gs' typo -> 'g s'
gs() {
    if [ $# -eq 0 ]; then
        g s
    else
        command gs "$@"
    fi
}

# Workaround for Git hanging when using Composer
# Currently disabled because it doesn't work in Vagrant provisioner, and I don't
# need it right now because I disabled ControlMaster as it's not supported in Cygwin
#export GIT_SSH='ssh-noninteractive'

#=== history.bash ===
if $HAS_TERMINAL; then

    # Start typing then use Up/Down to see *matching* history items
    bind '"\e[A":history-search-backward'
    bind '"\e[B":history-search-forward'

    # Don't store duplicate entries in history
    export HISTIGNORE="&"

    # Save history immediately, so multiple terminals don't overwrite each other!
    shopt -s histappend
    PROMPT_COMMAND='history -a'

    # Record multi-line commands as a single entry
    shopt -s cmdhist

    # Preserve new lines in history instead of converting to semi-colons
    shopt -s lithist

    # Confirm history expansions (e.g. "!1") before running them
    shopt -s histverify

    # If a history expansion fails, let the user re-edit the command
    shopt -s histreedit

    # Display history with additional time information
    alias history-time='HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] " history'

fi

#=== htop.bash ===
# Older versions of htop don't like non-standard $TERM's like screen-256color,
# but I can't change that because it would cause nested tmux's when using ssh or
# su. Tested on 0.8.3 (CentOS) which needs it and 1.0.1 (Debian) which doesn't.
alias htop='TERM=xterm-256color htop'

#=== ignore-case.bash ===
# Ignore case when tab-completing
set completion-ignore-case on

#=== info.bash ===
alias info="info --vi-keys"

#=== man.bash ===
man()
{
    # http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
    LESS_TERMCAP_mb=$(printf "\e[1;31m") \
    LESS_TERMCAP_md=$(printf "\e[1;31m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;32m") \
        command man "$@"
}

#=== mark.bash ===
# Based on
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html

MARKPATH=$HOME/.marks

jump() {
    c -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1" >&2
}

mark() {
    mkdir -p $MARKPATH
    mark="${1:-$(basename "$PWD")}"

    if ! [[ $mark =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid mark name"
        return 1
    fi

    ln -sn "$(pwd)" "$MARKPATH/$mark" && alias $mark="jump '$mark'"
}

unmark() {
    mark="${1:-$(basename "$PWD")}"

    if [ -L "$MARKPATH/$mark" ]; then
        rm -f "$MARKPATH/$mark" && unalias $mark
    else
        echo "No such mark: $mark" >&2
    fi
}

marks() {
    if $MAC; then
        CLICOLOR_FORCE=1 command ls -lGF "$MARKPATH" | sed '1d;s/  / /g' | cut -d' ' -f9-
    else
        command ls -l --color=always --classify "$MARKPATH" | sed '1d;s/  / /g' | cut -d' ' -f9-
    fi
}

if [ -d "$MARKPATH" ]; then
    for mark in $(command ls "$MARKPATH"); do
        alias $mark="jump $mark"
    done
fi

#=== md.bash ===
# md = mkdir; cd
md() {
    mkdir -p "$1" && cd "$1"
}

#=== pager.bash ===
export PAGER=less

# If output fits on one screen exit immediately
export LESS=FRX

# Use lesspipe to convert non-text files, if available
if [ -x /usr/bin/lesspipe ]; then
    eval "$(/usr/bin/lesspipe)"
fi

# Grep with pager
# Note: This has to be a script not a function so it can detect a pipe
# But the script cannot be called "grep", because that gets called by scripts
# So we have a function "grep" calling a script "grep-less"
# And we need to use 'command -v' so that 'sudo grep' works
if ! $WINDOWS; then
    alias grep="$(command -v grep-less)"
fi

#=== php.bash ===
alias com='composer'
alias ide='t ide-helper'
alias mfs='art migrate:fresh --drop-views --seed'
alias pu='phpunit'

composer() {
    if dir="$(findup -x scripts/composer.sh)"; then
        "$dir/scripts/composer.sh" "$@"
    else
        command composer "$@"
    fi
}

php() {
    if dir="$(findup -x scripts/php.sh)"; then
        "$dir/scripts/php.sh" "$@"
    else
        command php "$@"
    fi
}

hackit() {
    # Has to be a function because it deletes the working directory
    if [ "$(basename "$(dirname "$(dirname "$PWD")")")" != "vendor" ]; then
        echo "Not in a Composer vendor directory" >&2
        return 1
    fi

    if [ -e .git ]; then
        echo "Already in development mode" >&2
        return 1
    fi

    ask "Delete this directory and reinstall in development mode?" Y || return

    local package="$(basename "$(dirname "$PWD")")/$(basename "$PWD")"
    local oldpwd="${OLDPWD:-}"
    local pwd="$PWD"

    # Delete the dist version
    cd ../../..
    rm -rf "$pwd"

    # Install the dev version
    composer update --prefer-source "$package"

    # Go back to that directory + restore "cd -" path
    cd "$pwd"
    OLDPWD="$oldpwd"

    # Switch to the latest development version
    # TODO: Detect when 'master' is not the main branch?
    git checkout master
}

hacked() {
    if [ "$(basename "$(dirname "$(dirname "$PWD")")")" != "vendor" ]; then
        echo "Not in a Composer vendor directory" >&2
        return 1
    fi

    if [ ! -e .git ]; then
        echo "Not in development mode" >&2
        return 1
    fi

    if [ -n "$(git status --porcelain)" ]; then
        echo "There are uncommitted changes" >&2
        return 1
    fi

    ask "Delete this directory and reinstall in production mode?" Y || return

    local package="$(basename "$(dirname "$PWD")")/$(basename "$PWD")"
    local oldpwd="${OLDPWD:-}"
    local pwd="$PWD"

    # Delete the dev version
    cd ../../..
    rm -rf "$pwd"

    # Install the dist version
    composer update --prefer-dist "$package"

    # Go back to that directory + restore "cd -" path
    cd "$pwd"
    OLDPWD="$oldpwd"
}

xdebug() {
    if [[ ${1:-} = 'on' ]]; then
        export XDEBUG_SESSION=${2:-1}
    elif [[ ${1:-} = 'off' ]]; then
        unset XDEBUG_SESSION
    fi

    if [[ ${XDEBUG_SESSION:-} = 1 ]]; then
        echo "Xdebug step debugging is enabled"
    elif [[ -n ${XDEBUG_SESSION:-} ]]; then
        echo "Xdebug step debugging is enabled (trigger_value=$XDEBUG_SESSION)"
    else
        echo "Xdebug step debugging is disabled"
    fi
}

#=== phpstorm.bash ===
phpstorm() {
    if [ $# -gt 0 ]; then
        command phpstorm "$@" &>> ~/tmp/phpstorm.log &
    elif [ -d .idea ]; then
        command phpstorm "$PWD" &>> ~/tmp/phpstorm.log &
    else
        command phpstorm &>> ~/tmp/phpstorm.log &
    fi
}

alias storm='phpstorm'

#=== postgres.bash ===
# Use the 'postgres' database by default because it's more likely to exist than the current username
export PGDATABASE=postgres

#=== prompt.bash ===
if $HAS_TERMINAL; then

    # Enable dynamic $COLUMNS and $LINES variables
    shopt -s checkwinsize

    # Get hostname
    prompthostname() {
        if [ -f ~/.hostname ]; then
            # Custom hostname
            cat ~/.hostname
        elif $WINDOWS || $WSL; then
            # Titlecase hostname on Windows (no .localdomain)
            #hostname | sed 's/\(.\)\(.*\)/\u\1\L\2/'
            # Lowercase hostname on Windows (no .localdomain)
            hostname | tr '[:upper:]' '[:lower:]'
        else
            # FQDN hostname on Linux
            hostname -f
        #elif [ "$1" = "init" ]; then
        #    hostname -s
        #else
        #    echo '\H'
        fi
    }

    # Set the titlebar & prompt to "[user@host:/full/path]\n$"
    case "$TERM" in
        xterm*|screen*|cygwin*)
            Titlebar="\u@$(prompthostname):\$PWD"
            # Set titlebar now, before SSH key is requested, for KeePass
            echo -ne "\033]2;${USER:-$USERNAME}@$(prompthostname init):$PWD\a"
            ;;
        *)
            Titlebar=""
            ;;
    esac

    # Git/Mercurial prompt
    vcsprompt()
    {
        # Walk up the tree looking for a .git directory
        # This is faster than trying each in turn and means we get the one
        # that's closer to us if they're nested
        root=$(pwd 2>/dev/null)
        while [ ! -e "$root/.git" ]; do
            if [ "$root" = "" ]; then break; fi
            root=${root%/*}
        done

        if [ -e "$root/.git" ]; then
            # Git
            relative=${PWD#$root}
            if [ "$relative" != "$PWD" ]; then
                echo -en "$root\033[36;1m$relative"
                #         ^yellow  ^aqua
            else
                echo -n $PWD
                #       ^yellow
            fi

            # Show the branch name / tag / id
            # Note: Using 'command git' to bypass 'hub' which is slightly slower and not needed here
            branch=`command git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
            if [ -n "$branch" -a "$branch" != "(no branch)" ]; then
                echo -e "\033[30;1m on \033[35;1m$branch\033[30;1m"
                #        ^grey       ^pink           ^light grey
            else
                tag=`command git describe --always 2>/dev/null`
                if [ -z "$tag" ]; then
                    tag="(unknown)"
                fi
                echo -e "\033[30;1m at \033[35;1m$tag \033[0m(git)\033[30;1m"
                #        ^grey       ^pink        ^light grey  ^ grey
            fi
        else
            # No .git found
            echo $PWD
        fi
    }

    # Python virtualenvwrapper prompt
    venvprompt()
    {
        if [ -n "$VIRTUAL_ENV" ]; then
            echo -e " ENV=${VIRTUAL_ENV##*/}"
        fi
    }

    # Function to update the prompt with a given message (makes it easier to distinguish between different windows)
    # TODO: Tidy this up, especially the variable names!
    MSG()
    {
        # Determine prompt colour
        if [ "${1:0:2}" = "--" ]; then
            # e.g. --live
            PromptType="${1:2}"
            shift
        else
            PromptType="$prompt_type"
        fi

        if [ "$PromptType" = "dev" ]; then
            prompt_color='30;42' # Green (black text)
        elif [ "$PromptType" = "live" ]; then
            prompt_color='41;1' # Red
        elif [ "$PromptType" = "staging" ]; then
            prompt_color='30;43' # Yellow (black text)
        elif [ "$PromptType" = "special" ]; then
            prompt_color='44;1' # Blue
        else
            prompt_color='45;1' # Pink
        fi

        # Display the provided message above the prompt and in the titlebar
        if [ -n "$*" ]; then
            PromptMessage="$*"
        elif [ -n "$prompt_default" ]; then
            PromptMessage="$prompt_default"
        elif ! $DOCKER && [ $EUID -eq 0 ]; then
            PromptMessage="Logged in as ROOT!"
            prompt_color='41;1' # Red
        else
            PromptMessage=""
        fi

        if [ -n "$PromptMessage" ]; then
            # Lots of escaped characters here to prevent this being executed
            # until the prompt is displayed, so it can adjust when the window
            # is resized
            spaces="\$(printf '%*s\n' \"\$((\$COLUMNS-${#PromptMessage}-1))\" '')"
            MessageCode="\033[${prompt_color}m $PromptMessage$spaces\033[0m\n"
            TitlebarCode="\[\033]2;[$PromptMessage] $Titlebar\a\]"
        else
            MessageCode=
            TitlebarCode="\[\033]2;$Titlebar\a\]"
        fi

        # If changing the titlebar is not supported, remove that code
        if [ -z "$Titlebar" ]; then
            TitlebarCode=
        fi

        # Set the prompt
        PS1="${TitlebarCode}\n"                     # Titlebar (see above)
        PS1="${PS1}${MessageCode}"                  # Message (see above)
        PS1="${PS1}\[\033[30;1m\]["                 # [                         Grey
        PS1="${PS1}\[\033[31;1m\]\u"                # Username                  Red
        PS1="${PS1}\[\033[30;1m\]@"                 # @                         Grey
        PS1="${PS1}\[\033[32;1m\]$(prompthostname)" # Hostname                  Green
        PS1="${PS1}\[\033[30;1m\]:"                 # :                         Grey
        PS1="${PS1}\[\033[33;1m\]\`vcsprompt\`"     # Working directory / Git   Yellow
        PS1="${PS1}\[\033[30;1m\]\`venvprompt\`"    # Python virtual env        Grey
        PS1="${PS1}\[\033[30;1m\] at "              # at                        Grey
        PS1="${PS1}\[\033[37;0m\]\D{%T}"            # Time                      Light grey
        PS1="${PS1}\[\033[30;1m\]]"                 # ]                         Grey
        PS1="${PS1}\[\033[1;35m\]\$KeyStatus"       # SSH key status            Pink
        PS1="${PS1}\n"                              # (New line)
        PS1="${PS1}\[\033[31;1m\]\\\$"              # $                         Red
        PS1="${PS1}\[\033[0m\] "
    }

    # Default to prompt with no message
    MSG

else

    # Prevent errors when MSG is set in .bashrc_local
    MSG() {
        : Do nothing
    }

fi

#=== python.bash ===
if [ -f /usr/local/bin/virtualenvwrapper_lazy.sh ]; then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

#=== reload.bash ===
# Reload Bash config
alias reload='exec bash -l'

#=== ruby.bash ===
if $HAS_TERMINAL; then

    # rvm
    rvm_project_rvmrc=0 # RVM 1.22.1 breaks my 'cd' alias, and I don't need this

    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

fi

#=== safety-checks.bash ===
if $HAS_TERMINAL; then
    alias cp='cp -i'
    alias mv='mv -i'
    alias rm='rm -i'
fi

#=== ssh.bash ===
alias sshstop='ssh -O stop'

# Fix running chromium via SSH
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY=$HOME/.Xauthority
fi

#=== ssh-key.bash ===
agent=
file=

# Check for local keys
# macOS loads them automatically
if ! $MAC; then
    if [ -n "$HOME/.ssh/id_rsa" ]; then
        file="$HOME/.ssh/id_rsa"
    elif [ -f "$HOME/.ssh/id_dsa" ]; then
        file="$HOME/.ssh/id_dsa"
    fi
fi

# Bridge to Pageant on Windows so we can share keys
if $WSL; then

    # Windows System for Linux
    # https://github.com/benpye/wsl-ssh-pageant
    if ! pgrep -l wsl-ssh-pageant >/dev/null; then
        # WSL won't run a Windows app that's inside the Linux filesystem, so copy it to a temp directory first
        # This sometimes fails even when pgrep doesn't think it's running, but that's generally OK
        rm -f "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe" "$WIN_TEMP_UNIX/wsl-ssh-pageant.sock" 2>/dev/null && \
        cp $HOME/opt/wsl-ssh-pageant/wsl-ssh-pageant-amd64.exe "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe"

        "$WIN_TEMP_UNIX/wsl-ssh-pageant.exe" --wsl "$WIN_TEMP/wsl-ssh-pageant.sock" &>/dev/null &
    fi

    export SSH_AUTH_SOCK="$WIN_TEMP_UNIX/wsl-ssh-pageant.sock"

elif $CYGWIN; then

    # Cygwin
    # https://github.com/cuviper/ssh-pageant
    case "$(uname -a)" in
        CYGWIN_*i686*)
            eval $($HOME/opt/ssh-pageant-1.4-prebuilt-cygwin32/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
            ;;
        CYGWIN_*x86_64*)
            eval $($HOME/opt/ssh-pageant-1.4-prebuilt-cygwin64/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
            ;;
    esac

fi

# Local key file / agent
if [ -f "$file" ]; then

    # ssh-agent
    # Make sure the agent is running
    if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null); then

        UNAME="$(uname)"

        # Try the stored settings instead
        if [ -f ~/.ssh/environment-$HOSTNAME-$UNAME ]; then
            source ~/.ssh/environment-$HOSTNAME-$UNAME
        fi

        if [ -z "$SSH_AGENT_PID" ] || (! kill -0 "$SSH_AGENT_PID" 2>/dev/null); then
            chmod 700 ~/.ssh
            ssh-agent | head -2 > ~/.ssh/environment-$HOSTNAME-$UNAME
            source ~/.ssh/environment-$HOSTNAME-$UNAME
        fi

    fi

    # Ask for password
    if $HAS_TERMINAL && ! ssh-add -l >/dev/null; then

        # Make it clear which server is asking for the password!
        # echo
        # echo -e "\033[31;1mYou are connected to $HOSTNAME.\033[33;1m"

        # Set titlebar for KeePass
        case "$TERM" in
            xterm*|cygwin)
                echo -ne "\033]2;Enter SSH Key Password\a"
                ;;
        esac

        # Trap Ctrl-C
        trapped=0
        trap 'trapped=1' SIGINT

        # Prompt for password
        chmod 700 ~/.ssh
        chmod 600 "$file"
        ssh-add "$file"

        if [ $? -eq 0 -a $trapped -eq 0 ]; then
            echo -e "\033[32;1mSSH keys are now unlocked.\033[0m"
            KeyStatus=$KeyStatusUnlocked
            return 0
        else
            echo -e "\033[30;1mCancelled. SSH keys are still locked.\033[0m"
            KeyStatus=$KeyStatusLocked
        fi

        # Reset trap
        trap SIGINT
        trapped=

    fi
fi

# Workaround for losing SSH agent connection when reconnecting tmux: update a
# symlink to the socket each time we reconnect and use that as the socket in
# every session.
# Currently not working on Mac, but I don't use it
# And it stops working on MSys when you run "reload", but I don't use that either
# And it doesn't work but also isn't necessary on WSL
if ! $MAC && ! $MSYSGIT && ! $WSL; then

    # First we make sure there's a valid socket connecting us to the agent and
    # it's not already pointing to the symlink.
    link="$HOME/.ssh/ssh_auth_sock"
    if [ "$SSH_AUTH_SOCK" != "$link" -a -S "$SSH_AUTH_SOCK" ]; then
        # We also check if the agent has any keys loaded - PuTTY will still open an
        # agent connection even if we used password authentication
        if ssh-add -l >/dev/null 2>&1; then
            ln -nsf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh_auth_sock"
        fi
    fi

    # Now that's done we can use the symlink for every session
    export SSH_AUTH_SOCK="$HOME/.ssh/ssh_auth_sock"

fi

#=== sudo.bash ===
if $HAS_TERMINAL && ! $WINDOWS; then

    # s=sudo
    s() {
        if [[ $# == 0 ]]; then
            # Use eval to expand aliases
            eval "sudo $(history -p '!!')"
        else
            sudo "$@"
        fi
    }

    # apt (formerly apt-get and apt-cache)
    if [ $UID -eq 0 ]; then
        alias agi='apt install'
        alias agr='apt remove'
        alias agar='apt autoremove'
        alias agu='apt update && apt full-upgrade'
        alias agupdate='apt update'
        alias agupgrade='apt upgrade'
    else
        alias agi='sudo apt install'
        alias agr='sudo apt remove'
        alias agar='sudo apt autoremove'
        alias agu='sudo apt update && sudo apt full-upgrade'
        alias agupdate='sudo apt update'
        alias agupgrade='sudo apt upgrade'
    fi

    alias acs='apt search'
    alias acsh='apt show'

    # Power aliases
    if [ $UID -eq 0 ]; then
        alias pow='poweroff'
        alias shutdown='poweroff'
    else
        alias pow='sudo poweroff'
        alias shutdown='sudo poweroff'
    fi

    # These commands require sudo
    if [ $UID -ne 0 ]; then
        alias a2dismod='sudo a2dismod'
        alias a2dissite='sudo a2dissite'
        alias a2enmod='sudo a2enmod'
        alias a2ensite='sudo a2ensite'
        alias addgroup='sudo addgroup'
        alias adduser='sudo adduser'
        alias dpkg-reconfigure='sudo dpkg-reconfigure'
        alias groupadd='sudo groupadd'
        alias groupdel='sudo groupdel'
        alias groupmod='sudo groupmod'
        alias php5dismod='sudo php5dismod'
        alias php5enmod='sudo php5enmod'
        alias phpdismod='sudo phpdismod'
        alias phpenmod='sudo phpenmod'
        alias poweroff='sudo poweroff'
        alias reboot='sudo reboot'
        alias service='sudo service'
        alias snap='sudo snap'
        alias ufw='sudo ufw'
        alias updatedb='sudo updatedb'
        alias useradd='sudo useradd'
        alias userdel='sudo userdel'
        alias usermod='sudo usermod'
        alias yum='sudo yum'
    fi

    systemctl() {
        if [ "$1" = "list-units" ]; then
            # The 'list-units' subcommand is used by tab completion
            command systemctl "$@"
        else
            command sudo systemctl "$@"
        fi
    }

    alias sc='systemctl'

    # Add sbin folder to my path so they can be auto-completed
    PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"

    # Add additional safety checks for cp, mv, rm
    sudo() {
        if [ "$1" = "cp" -o "$1" = "mv" -o "$1" = "rm" ]; then
            exe="$1"
            shift
            command sudo "$exe" -i "$@"
        else
            command sudo "$@"
        fi
    }

    # Expand aliases after sudo - e.g. 'sudo ll'
    # http://askubuntu.com/a/22043/29806
    alias sudo='sudo '
    alias s='s '

fi

#=== terminal-settings.bash ===
# Disable Ctrl-S = Stop output (except it's not available in Git's Cygwin)
if $HAS_TERMINAL && command -v stty &>/dev/null; then
    stty -ixon
fi

# Use 4 space tabs
if $HAS_TERMINAL && command -v tabs &>/dev/null && [ "$TERM" != "cygwin" ]; then
    # This outputs a blank line, but that doesn't seem preventable - if you
    # redirect to /dev/null it has no effect
    tabs -4
fi

#=== thefuck.bash ===
if $HAS_TERMINAL; then

    if command -v thefuck &>/dev/null; then
        eval $(thefuck --alias)
    fi

fi

#=== tmux.bash ===
# Currently not working on Mac
# But not using tmux on Mac anyway so it'll do for now!
if ! $MAC; then

    # tmux attach (local)
    tm() {
        local name="${1:-default}"

        if [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then
            tmux -2 new -A -s "$name"
        else
            tmux -2 new -d -s "$name" 2>/dev/null
            tmux -2 switch -t "$name"
        fi
    }

    # ssh + tmux ('h' for 'ssH', because 's' is in use)
    h() {
        local host="$1"
        local name="${2:-default}"
        local path="${3:-.}"

        # Special case for 'h vagrant' / 'h v' ==> 'v h' => 'vagrant tmux' (see vagrant.bash)
        if [ "$host" = "v" -o "$host" = "vagrant" ] && [ $# -eq 1 ]; then
            vagrant tmux
            return
        fi

        # For 'h user@host ^', upload SSH public key - easier than retyping it
        if [ $# -eq 2 -a "$name" = "^" ]; then
            ssh-copy-id "$host"
            return
        fi

        # For 'h user@host X', close the master connection
        if [ $# -eq 2 -a "$name" = "X" ]; then
            ssh -O stop "$host"
            return
        fi

        # Not running tmux
        if [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then

            local server="${host#*@}"

            case $server in
                # Run tmux on the local machine, as it's not available on the remote server
                a|aria|b|baritone|d|dragon|f|forte|t|treble)

                    # The name defaults to the host name given, rather than 'default'
                    name="${2:-$host}"

                    # Create a detached session (if there isn't one already)
                    tmux -2 new -s "$name" -d "ssh -o ForwardAgent=yes -t '$host' 'cd \"$path\"; bash -l'"

                    # Set the default command for new windows to connect to the same server, so we can have multiple panes
                    tmux set -t "$name" default-command "ssh -o ForwardAgent=yes -t '$host' 'cd \"$path\"; bash -l'"

                    # Connect to the session
                    tmux -2 attach -t "$name"

                    ;;

                # Run tmux on the remote server
                *)
                    ssh -o ForwardAgent=yes -t "$host" "cd '$path'; command -v tmux &>/dev/null && tmux -2 new -A -s '$name' || bash -l"
                    ;;
            esac

            return
        fi

        # Already running tmux *and* the user tried to specify a session name
        if [ $# -ge 2 ]; then
            echo 'sessions should be nested with care, unset $TMUX to force' >&2
            return 1
        fi

        # Already running tmux so connect without it
        ssh -o ForwardAgent=yes "$host"
    }

fi

#=== userinfo.bash ===
EMAIL=info@alberon.co.uk

#=== vagrant.bash ===
alias v=vagrant

vagrant() {
    # WSL support
    local vagrant=vagrant

    if command -v vagrant.exe >/dev/null; then
        vagrant=vagrant.exe
    fi

    # No parameters
    if [ $# -eq 0 ]; then
        command $vagrant

        # 1 = Help message displayed (or maybe other errors?)
        # 127 = Command not found
        if [ $? -eq 1 ]; then
            echo "Custom commands:"
            echo "     exec      Run the given command on the guest machine"
            echo "     rebuild   Destroy and rebuild the box"
            echo "     tmux      Run tmux (terminal multiplexer) inside the guest machine"
            echo
            echo "Shortcuts:"
            echo "     bu        box update"
            echo "     d, down   suspend"
            echo "     h         tmux"
            echo "     gs        global-status"
            echo "     hosts     hostmanager - update /etc/hosts files"
            echo "     p         provision"
            echo "     s         status"
            echo "     u         up"
            echo "     uh        up && tmux"
            echo "     x         exec"
        fi

        return
    fi

    # Parse the first parameter for shortcuts - because I'm lazy!
    cmd="$1"
    shift

    case "$cmd" in
        d)     cmd=suspend       ;;
        down)  cmd=suspend       ;;
        exe)   cmd=exec          ;;
        gs)    cmd=global-status ;;
        h)     cmd=tmux          ;;
        hosts) cmd=hostmanager   ;;
        p)     cmd=provision     ;;
        s)     cmd=status        ;;
        st)    cmd=status        ;;
        stop)  cmd=halt          ;;
        u)     cmd=up            ;;
        x)     cmd=exec          ;;
    esac

    # Box update
    if [ "$cmd" = "bu" ]; then
        command $vagrant box update
        return
    fi

    # Execute a command on the guest
    if [ "$cmd" = "exec" ]; then
        command $vagrant ssh -c "cd /vagrant; $*"
        return
    fi

    # Destroy and rebuild
    if [ "$cmd" = "rebuild" ]; then
        command $vagrant destroy "$@" && command vagrant box update && command vagrant up
        return
    fi

    # up & tmux
    if [ "$cmd" = "uh" ]; then
        command $vagrant up || return
        cmd="tmux"
    fi

    # tmux
    if [ "$cmd" = "tmux" ]; then
        # TODO Refactor this whole section!

        # if [ -z "$TMUX" ]; then
        #     # Not running tmux - Run tmux inside Vagrant (if available)
        #     command vagrant ssh -- -t 'command -v tmux &>/dev/null && { tmux attach || tmux new -s default; } || bash -l'
        # elif $CYGWIN; then
        #     # We're running tmux already - on Cygwin
        #     # For some reason Cygwin -> tmux -> vagrant (ruby) -> ssh is *really* slow
        #     # But if we skip ruby it's fine!
        #     # Note: The Vagrant setup may still be slow... So I don't use tmux in Cygwin much
        #     (umask 077 && command vagrant ssh-config > /tmp/vagrant-ssh-config)
        #     ssh -F /tmp/vagrant-ssh-config default
        # else
        #     # We're running tmux on another platform - just connect as normal
        #     command vagrant ssh
        # fi

        # For some reason Cygwin -> tmux -> vagrant (ruby) -> ssh is *really* slow
        # And since I upgraded Vagrant, Cygwin -> vagrant -> ssh doesn't work properly
        # So bypass Vagrant and use the Cygwin ssh instead, always
        (umask 077 && command $vagrant ssh-config > /tmp/vagrant-ssh-config)

        if $WSL; then
            # Fix this error:
            # Permissions 0755 for '/mnt/d/path/to/.vagrant/machines/default/virtualbox/private_key' are too open.
            # It is required that your private key files are NOT accessible by others.
            # This private key will be ignored.
            root="$(findup -f .vagrant/machines/default/virtualbox/private_key)"
            if [ -n "$root" ]; then
                rm -f /tmp/vagrant-ssh-key
                cp "$root/.vagrant/machines/default/virtualbox/private_key" /tmp/vagrant-ssh-key
                chmod 600 /tmp/vagrant-ssh-key
                sed -i "s#  IdentityFile .*#  IdentityFile /tmp/vagrant-ssh-key#" /tmp/vagrant-ssh-config
            fi
        fi

        if [ -z "$TMUX" ] && [[ "$TERM" != screen* ]]; then
            # Not running tmux - Run tmux inside Vagrant (if available)
            ssh -F /tmp/vagrant-ssh-config default -t 'command -v tmux &>/dev/null && tmux new -A -s default || bash -l'
        else
            # We're running tmux already
            ssh -F /tmp/vagrant-ssh-config default
        fi

        return
    fi

    # Other commands
    command $vagrant "$cmd" "$@"
}

# Workaround for Vagrant bug on Cygwin
# https://github.com/mitchellh/vagrant/issues/6026
if $CYGWIN; then
    export VAGRANT_DETECTED_OS=cygwin
fi

#=== watch.bash ===
# Expand aliases after watch
# http://unix.stackexchange.com/a/25329/14368
# And show colours
alias watch='watch --color '

#=== windows.bash ===
# Configure X server display
if $WINDOWS || $WSL; then
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=localhost:0.0
    fi
fi

# Emulate apt-get with apt-cyg
if $CYGWIN; then
    alias agi='apt-cyg install'
    alias agr='apt-cyg remove'
    alias agu='apt-cyg update'
    alias acs='apt-cyg searchall'
fi

# Expand aliases after 'winpty'
if $WINDOWS; then
    alias winpty='winpty '
fi

# Clear the MSysGit MOTD (at this point it's already been shown, but this
# gets rid of it for the future)
if $MSYSGIT; then
    if [ -w /etc/motd ]; then
        > /etc/motd
    fi
fi

# The MinTTY config file is stored outside the Git repo
if $WSL; then
    if ! cmp -s $WIN_APPDATA_UNIX/wsltty/config $HOME/.minttyrc; then
        rm -f $WIN_APPDATA_UNIX/wsltty/config
        cp $HOME/.minttyrc $WIN_APPDATA_UNIX/wsltty/config
        echo
        yellowBg black "MinTTY config updated - please reload it"
    fi
fi

#=== wordpress.bash ===
find_wordpress_wp_content() {
    if [ -d wp-content ]; then
        echo wp-content
    elif [ -d www/wp-content ]; then
        echo www/wp-content
    elif [ -d ../wp-content ]; then
        echo ../wp-content
    elif [ -d ../../wp-content ]; then
        echo ../../wp-content
    elif [ -d ../../../wp-content ]; then
        echo ../../../wp-content
    else
        echo "Cannot find wp-content/ directory" >&2
        return 1
    fi
}

# cwc = "cd wp-content"
# This is because it's very hard to tab-complete "wp-content" because you have
# to type "wp-cont" before you get to a non-ambiguous prefix
cwc() {
    wp_root=$(find_wordpress_wp_content) || return
    c $wp_root
}

# cwp = "cd WordPress plugins"
cwp() {
    wp_root=$(find_wordpress_wp_content) || return
    if [ -d $wp_root/plugins ]; then
        c $wp_root/plugins
    else
        echo "Cannot find wp-content/plugins/ directory" >&2
        return 1
    fi
}

# cwt = "cd WordPress Theme"
cwt() {
    wp_root=$(find_wordpress_wp_content) || return
    if [ -d $wp_root/themes ]; then
        wp_theme=$(find $wp_root/themes -mindepth 1 -maxdepth 1 -type d -not -name twentyten -not -name twentyeleven)
        if [ $(echo "$wp_theme" | wc -l) -eq 1 ]; then
            # Only 1 non-default theme found - assume we want that
            c $wp_theme
        else
            # 0 or 2+ themes found - go to the main directory
            c $wp_root/themes
        fi
    else
        echo "Cannot find wp-content/themes/ directory" >&2
        return 1
    fi
}

#=== yarn.bash ===
yarn() {
    if [ "$1" = "update" ]; then
        # yarn run v1.19.1
        # error Command "update" not found.
        # info Visit https://yarnpkg.com/en/docs/cli/run for documentation about this command.
        shift
        command yarn upgrade "$@"
    else
        command yarn "$@"
    fi
}

# === .bashrc ===
# Custom settings for this machine/account
if [ -f ~/.bashrc_local ]; then
    source ~/.bashrc_local
fi

# *After* doing the rest, show the current directory contents, except in
# Git Bash home directory - there's a load of system files in there
if $HAS_TERMINAL && ! ($WINDOWS && [ "$PWD" = "$HOME" ]); then
    c .
fi

# Git Bash loads this file *and* .bash_profile so set a flag to tell
# .bash_profile not to load .bashrc again
BASHRC_DONE=true

# Prevent Serverless Framework messing with the Bash config
# https://github.com/serverless/serverless/issues/4069
# tabtab source for serverless package
# tabtab source for sls package
