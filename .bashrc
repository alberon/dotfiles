#
# This file is executed when Bash is loaded, but ONLY in an interactive session
#
# Also see: .bash_profile
#

#===============================================================================
# Setup
#===============================================================================

#---------------------------------------
# Safety checks
#---------------------------------------

# Make sure .bash_profile is loaded first
source ~/.bash_profile

# Only load this file once
[[ -n $BASHRC_SOURCED ]] && return
BASHRC_SOURCED=true

# Only load in interactive shells
[[ -z $PS1 ]] && return


#---------------------------------------
# Third party scripts
#---------------------------------------

# Auto-completion - seems to be loaded automatically on some servers but not on others
shopt -s extglob
[[ -f /etc/bash_completion ]] && source /etc/bash_completion

# fzf - fuzzy finder
if [[ -f ~/.fzf.bash ]]; then
    # Manual install
    source ~/.fzf.bash
else
    # Ubuntu package
    [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]] && source /usr/share/doc/fzf/examples/key-bindings.bash
    [[ -f /usr/share/doc/fzf/examples/completion.bash ]] && source /usr/share/doc/fzf/examples/completion.bash
fi

# Google Cloud Shell
[[ -f /google/devshell/bashrc.google ]] && source /google/devshell/bashrc.google

# lesspipe
[[ -x /usr/bin/lesspipe ]] && eval "$(/usr/bin/lesspipe)"

# Python virtualenv
if [[ -f /usr/local/bin/virtualenvwrapper_lazy.sh ]]; then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

# Ruby rvm
if [[ -s ~/.rvm/scripts/rvm ]]; then
    rvm_project_rvmrc=0
    source ~/.rvm/scripts/rvm
fi

# The F**k
if command -v thefuck &>/dev/null; then
    eval $(thefuck --alias 2>/dev/null)
    eval $(thefuck --alias doh 2>/dev/null)
fi


#===============================================================================
# Aliases
#===============================================================================

# The full path is needed for 'sudo <alias>' to work correctly
sudo="$HOME/.bin/maybe-sudo"

alias a2disconf="$sudo a2disconf"
alias a2dismod="$sudo a2dismod"
alias a2dissite="$sudo a2dissite"
alias a2enconf="$sudo a2enconf"
alias a2enmod="$sudo a2enmod"
alias a2ensite="$sudo a2ensite"
alias addgroup="$sudo addgroup"
alias adduser="$sudo adduser"

if is-cygwin; then
    alias agi='apt-cyg install'
    alias agr='apt-cyg remove'
    alias agu='apt-cyg update'
    alias acs='apt-cyg searchall'
else
    alias aar="$sudo add-apt-repository"
    alias acs='command apt search'
    alias acsh='command apt show'
    alias agac="$sudo apt autoclean"
    alias agi="$sudo apt install"
    alias agr="$sudo apt remove"
    alias agar="$sudo apt autoremove"
    alias agu="$sudo apt update && $sudo apt full-upgrade"
    alias agupdate="$sudo apt update"
    alias agupgrade="$sudo apt upgrade"
    alias apt="$sudo apt"
    alias apt-add-repository="$sudo apt-add-repository"
    alias apt-mark="$sudo apt-mark"
fi

alias b='c -'

if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    alias bat='batcat'
fi

alias cat="$HOME/.bin/bat-or-cat"
alias chmox='chmod' # Common typo
alias cp='cp -i'
alias cy='cypress'

alias db='docker build'
alias dc='docker-compose'
alias dpkg-reconfigure="$sudo dpkg-reconfigure"
alias dr='docker run'
alias dri='docker run -it --rm'

alias gcm='g co master'
alias grep="$(command -v grep-less)" # command -v makes it work with sudo
alias groupadd="$sudo groupadd"
alias groupdel="$sudo groupdel"
alias groupmod="$sudo groupmod"

alias host='_domain-command host'

alias ide='t ide-helper'

alias k='kubectl'
alias ka='kubectl apply -f'
alias kcx='kubectl config use-context'
alias kd='kubectl describe'
alias ke='kubectl edit'
alias kg='kubectl get'
alias kns='kubectl config set-context --current --namespace'
alias krm='kubectl delete'

if is-mac; then
    alias l="ls -hGFl"
    alias la="ls -hGFlA"
    alias ls="ls -hGF"
    alias lsa="ls -hGFA"
else
    alias l="ls -hFl --color=always --hide='*.pyc' --hide='*.sublime-workspace'"
    alias la="ls -hFlA --color=always --hide='*.pyc' --hide='*.sublime-workspace'"
    alias ls="ls -hF --color=always --hide='*.pyc' --hide='*.sublime-workspace'"
    alias lsa="ls -hFA --color=always --hide='*.pyc' --hide='*.sublime-workspace'"
fi

alias mux='tmuxinator'

alias nslookup='_domain-command nslookup'

alias php5dismod="$sudo php5dismod"
alias php5enmod="$sudo php5enmod"
alias phpdismod="$sudo phpdismod"
alias phpenmod="$sudo phpenmod"
alias poweroff="$sudo poweroff"
alias pow="$sudo poweroff"
alias pu='phpunit'
alias puw='when-changed -r -s -1 app database tests -c "clear; scripts/phpunit.sh"'

alias reboot="$sudo reboot"
alias reload='exec bash -l'
alias rm='rm -i'

alias s='sudo '
alias scra="$sudo systemctl reload apache2 && $sudo systemctl status apache2"
alias service="$sudo service"
alias shutdown="$sudo poweroff"
alias snap="$sudo snap"
alias sshak='ssh -o StrictHostKeyChecking=accept-new'
alias sshstop='ssh -O stop'
alias storm='phpstorm'
alias sudo='sudo ' # Expand aliases

alias tree='tree -C'

alias u='c ..'
alias uu='c ../..'
alias uuu='c ../../..'
alias uuuu='c ../../../..'
alias uuuuu='c ../../../../..'
alias uuuuuu='c ../../../../../..'

alias ufw="$sudo ufw"
alias updatedb="$sudo updatedb"
alias useradd="$sudo useradd"
alias userdel="$sudo userdel"
alias usermod="$sudo usermod"

alias v='vagrant'

alias watch='watch --color '
alias whois='_domain-command whois'

alias yum="$sudo yum"


#===============================================================================
# Functions
#===============================================================================

1x() {
    rm -f $HOME/.config/bash/hidpi
    _update-dpi
}

2x() {
    mkdir -p $HOME/.config/bash
    touch $HOME/.config/bash/hidpi
    _update-dpi
}

art() {
    artisan "$@"
}

c() {
    # 'cd' and 'ls'
    if [[ $@ != . ]]; then
        cd "$@" >/dev/null || return
    fi
    _ls-current-directory
}

cd() {
    local dir="$PWD"

    builtin cd "$@" &&
        _dirhistory-push-past "$dir" &&
        _record-last-directory
}

cg() {
    # cd to git root

    # Look in parent directories
    path="$(cd .. && git rev-parse --show-toplevel 2>/dev/null)"

    # Look in child directories
    if [[ -z $path ]]; then
        path="$(find . -mindepth 2 -maxdepth 2 -type d -name .git 2>/dev/null)"
        if [[ $(echo "$path" | wc -l) -gt 1 ]]; then
            echo 'Multiple repositories found:' >&2
            echo "$path" | sed 's/^.\//  /g; s/.git$//g' >&2
            return 2
        else
            path="${path%/.git}"
        fi
    fi

    # Go to the directory, if found
    if [[ -z $path ]]; then
        echo 'No Git repository found in parent directories or immediate children' >&2
        return 1
    fi

    c "$path"
}

com() {
    composer "$@"
}

cv() {
    if ! local dir="$(findup -d vendor/alberon)"; then
        echo 'No vendor/alberon/ directory found' >&2
        return 1
    fi

    if [[ -z $1 ]]; then
        c "$dir/vendor/alberon"
    elif [[ -d "$dir/vendor/alberon/$1" ]]; then
        c "$dir/vendor/alberon/$1"
    else
        local matches=("$dir/vendor/alberon/"*"$1"*)
        if [[ ${#matches[@]} -eq 0 || ! -d "${matches[0]}" ]]; then
            c "$dir/vendor/alberon"
            echo >&2
            c "$1" # Will fail
        elif [[ ${#matches[@]} -eq 1 ]]; then
            c "${matches[0]}"
        else
            c "$dir/vendor/alberon"
            echo >&2
            echo 'Multiple matches found:' >&2
            printf '%s\n' "${matches[@]}" >&2
        fi
    fi
}

composer() {
    if dir="$(findup -x scripts/composer.sh)"; then
        "$dir/scripts/composer.sh" "$@"
    else
        command composer "$@"
    fi
}

cw() {
    # cd to web root
    if [[ -d /vagrant ]]; then
        c /vagrant
    elif [[ -d ~/repo ]]; then
        c ~/repo
    elif [[ -d /home/www ]]; then
        c /home/www
    elif is-root-user && [[ -d /home ]]; then
        c /home
    elif [[ -d /var/www ]]; then
        c /var/www
    elif is-wsl; then
        c "$(wsl-mydocs-path)"
    else
        c ~
    fi
}

cwc() {
    # cd to wp-content/
    wp_content=$(_find-wp-content) || return
    c $wp_content
}

cwp() {
    # cd to WordPress plugins
    wp_content=$(_find-wp-content) || return
    if [ -d $wp_content/plugins ]; then
        c $wp_content/plugins
    else
        echo "Cannot find wp-content/plugins/ directory" >&2
        return 1
    fi
}

cwt() {
    # cd to WordPress theme
    wp_content=$(_find-wp-content) || return
    if [ -d $wp_content/themes ]; then
        wp_theme=$(find $wp_content/themes -mindepth 1 -maxdepth 1 -type d -not -name twentyten -not -name twentyeleven)
        if [ $(echo "$wp_theme" | wc -l) -eq 1 ]; then
            # Only 1 non-default theme found - assume we want that
            c $wp_theme
        else
            # 0 or 2+ themes found - go to the main directory
            c $wp_content/themes
        fi
    else
        echo "Cannot find wp-content/themes/ directory" >&2
        return 1
    fi
}

docker-compose() {
    if dir="$(findup -x scripts/docker-compose.sh)"; then
        "$dir/scripts/docker-compose.sh" "$@"
    else
        command docker-compose "$@"
    fi
}

dump-path() {
    echo -e "${PATH//:/\\n}"
}

exitif() {
    test "$@" && exit || return 0
}

g() {
    git "$@"
}

git() {
    if [[ $# -gt 0 ]]; then
        command git "$@"
    elif command -v lazygit &>/dev/null; then
        lazygit
    else
        command git status
    fi
}

gs() {
    if [[ $# -eq 0 ]]; then
        # 'gs' typo -> 'g s'
        g s
    else
        command gs "$@"
    fi
}

hacked() {
    # Switch a Composer package to dist mode
    # Has to be a function because it deletes & recreates the working directory
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

hackit() {
    # Switch a Composer package to dev (source) mode
    # Has to be a function because it deletes & recreates the working directory
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
    echo
    git checkout master
}

m() {
    session="${1:-$USER}"

    # Launch tmux, replacing the current shell (so when we quit, we don't have to exit again)
    if [ -z "$TMUX" ]; then
        exec tmux -2 new -A -s "$session"
    fi

    # Already running - switch session
    current=$(tmux display-message -p '#S')
    if [[ $session = $current ]]; then
        echo "Already in '$session' session."
    else
        tmux -2 new -d -s "$session" 2>/dev/null
        tmux -2 switch -t "$session"
    fi
}

man() {
    # http://boredzo.org/blog/archives/2016-08-15/colorized-man-pages-understood-and-customized
    LESS_TERMCAP_mb=$(printf "\e[91m") \
    LESS_TERMCAP_md=$(printf "\e[91m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[93;44m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[92m") \
        command man "$@"
}

mark() {
    mkdir -p $HOME/.marks
    local mark="${1:-$(basename "$PWD")}"
    local target="${2:-$PWD}"

    if ! [[ $mark =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid mark name"
        return 1
    fi

    ln -nsf "$target" "$HOME/.marks/$mark" &&
        alias $mark="c -P '$target'"
}

marks() {
    mkdir -p $HOME/.marks

    if is-mac; then
        CLICOLOR_FORCE=1 command ls -lF "$HOME/.marks" | sed '1d;s/  / /g' | cut -d' ' -f9-
    else
        command ls -l --color=always "$HOME/.marks" | sed '1d;s/  / /g' | cut -d' ' -f9- | {
            if command -v column &>/dev/null; then
                column -t
            else
                cat
            fi
        }
    fi
}

md() {
    mkdir -p "$1" && cd "$1"
}

mv() {
    # 'mv' - interactive if only one filename is given
    # https://gist.github.com/premek/6e70446cfc913d3c929d7cdbfe896fef
    if [ "$#" -ne 1 ]; then
        command mv -i "$@"
    elif [ ! -e "$1" ]; then
        command file "$@"
    else
        read -p "Rename to: " -ei "$1" newfilename &&
            [ -n "$newfilename" ] &&
            mv -iv "$1" "$newfilename"
    fi
}

nextd() {
    local dir="$PWD"

    while [[ ${dirhistory_future[0]} == $dir ]]; do
        dirhistory_future=("${dirhistory_future[@]:1}")
    done

    if [[ ${#dirhistory_future[@]} -gt 0 ]]; then
        if builtin cd "${dirhistory_future[0]}"; then
            _dirhistory-push-past "$dir"
            _record-last-directory
            _ls-current-directory
        fi
    fi
}


php() {
    if dir="$(findup -x scripts/php.sh)"; then
        "$dir/scripts/php.sh" "$@"
    else
        command php "$@"
    fi
}

phpstorm() {
    local args=()
    local path

    if [[ $# -eq 0 ]] && path=$(findup -d .idea); then

        # Automatically launch the current project
        if is-wsl; then
            path=$(wslpath -aw "$path" | sed 's/\\\\wsl.localhost\\/\\\\wsl$\\/')
        fi

        args=($path)

    elif [[ -d ${1:-} ]] && is-wsl; then

        # Convert the path to WSL format
        path=$(wslpath -aw "$1" | sed 's/\\\\wsl.localhost\\/\\\\wsl$\\/')
        shift
        args=($path)

    fi

    # Run PhpStorm in the background
    command phpstorm "${args[@]}" "$@" &>> ~/.cache/phpstorm.log &
}

prevd() {
    local dir="$PWD"

    while [[ ${dirhistory_past[0]} == $dir ]]; do
        dirhistory_past=("${dirhistory_past[@]:1}")
    done

    if [[ ${#dirhistory_past[@]} -gt 0 ]]; then
        if builtin cd "${dirhistory_past[0]}"; then
            _dirhistory-push-future "$dir"
            _record-last-directory
            _ls-current-directory
        fi
    fi
}

prompt() {
    prompt_color=''

    while [[ -n $1 ]]; do
        case "$1" in
            # Stop parsing parameters
            --)         shift; break ;;

            # Presets
            -l|--live)     prompt_color='bg-red' ;;
            -s|--staging)  prompt_color='bg-yellow black' ;;
            -d|--dev)      prompt_color='bg-green black' ;;
            -x|--special)  prompt_color='bg-blue' ;;

            # Other colours/styles (see ~/.bash/color.bash)
            --*)        prompt_color="$prompt_color ${1:2}" ;;

            # Finished parsing parameters
            *)          break ;;
        esac

        shift
    done

    prompt_message="$@"
}

sc() {
    case "${1:-}" in
        d|down) shift; systemctl stop "$@" ;;
        e) shift; systemctl edit "$@" ;;
        l) shift; systemctl log "$@" ;;
        r) shift; systemctl reload-or-restart "$@" ;;
        rl) shift; systemctl reload "$@" ;;
        rs) shift; systemctl restart "$@" ;;
        s) shift; systemctl status "$@" ;;
        u|up) shift; systemctl start "$@" ;;
        *) systemctl "$@"
    esac
}

setup-docker() {
    maybe-sudo add-apt-repository universe &&
    maybe-sudo apt install docker.io &&
    maybe-sudo usermod -aG docker "$USER" &&
    exec maybe-sudo su -l "$USER"
}

status() {
    # Show the result of the last command
    local status=$?

    if [[ $status -eq 0 ]]; then
        color bg-lgreen black 'Success'
    else
        color bg-red lwhite "Failed with code $status"
    fi

    return $status
}

sudo() {
    # Add additional safety checks for cp, mv, rm
    if [ "$1" = "cp" -o "$1" = "mv" -o "$1" = "rm" ]; then
        exe="$1"
        shift
        command sudo "$exe" -i "$@"
    else
        command sudo "$@"
    fi
}

systemctl() {
    if [[ -n ${COMP_WORDS:-} ]]; then
        # Bash completion (no sudo because it would interrupt the prompt asking for a password)
        command systemctl "$@"
    elif in_array '--user' "$@"; then
        # User mode (no sudo)
        command systemctl "$@"
    elif [[ ${1:-} = 'log' ]]; then
        # Custom command: sc log [unit] [grep]
        if [[ -n ${3:-} ]]; then
            maybe-sudo journalctl --lines 100 --follow --unit "$2" --grep "$3"
        elif [[ -n ${2:-} ]]; then
            maybe-sudo journalctl --lines 100 --follow --unit "$2"
        else
            maybe-sudo journalctl --lines 100 --follow
        fi
    else
        maybe-sudo systemctl "$@"
    fi
}

unmark() {
    local marks="${@:-$(basename "$PWD")}"

    for mark in $marks; do
        if [[ -L $HOME/.marks/$mark ]]; then
            rm -f "$HOME/.marks/$mark" && unalias $mark
        else
            echo "No such mark: $mark" >&2
        fi
    done
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

yarn() {
    # Make 'yarn' more like 'composer'
    case $1 in
        in|ins) shift; args=(install) ;;
        out) shift; args=(outdated) ;;
        re|rem) shift; args=(remove) ;;
        up|update) shift; args=(upgrade) ;;
        *) args=() ;;
    esac

    if dir="$(findup -x scripts/yarn.sh)"; then
        "$dir/scripts/yarn.sh" "${args[@]}" "$@"
    else
        command yarn "${args[@]}" "$@"
    fi
}


#---------------------------------------
# Helper functions
#---------------------------------------

# These are in separate files because they are used by other scripts too
source ~/.bash/ask.sh
source ~/.bash/color.bash
source ~/.bash/in_array.bash

_dirhistory-push-future() {
    if [[ ${#dirhistory_future[@]} -eq 0 || ${dirhistory_future[0]} != "$1" ]]; then
        dirhistory_future=("$1" "${dirhistory_future[@]:0:49}")
    fi
}

_dirhistory-push-past() {
    if [[ ${#dirhistory_past[@]} -eq 0 || ${dirhistory_past[0]} != "$1" ]]; then
        dirhistory_past=("$1" "${dirhistory_past[@]:0:49}")
    fi
}

_domain-command() {
    command="$1"
    shift

    # Accept URLs and convert to domain name only
    domain=$(echo "$1" | sed 's#https\?://\([^/]*\).*/#\1#')

    if [[ -n $domain ]]; then
        shift
        command $command "$domain" "$@"
    else
        command $command "$@"
    fi
}

_find-wp-content() {
    if dir=$(findup -d wp-content); then
        echo "$dir/wp-content"
    elif dir=$(findup -d www/wp-content); then
        echo "$dir/www/wp-content"
    else
        echo "Cannot find wp-content/ directory" >&2
        return 1
    fi
}

_ls-current-directory() {
    echo
    color lwhite underline -- "$PWD"
    ls
}

_prompt-before() {
    local status=$?

    # Save (append) the Bash history after every command, instead of waiting until exit
    history -a

    # Update the window title (no output)
    _prompt-titlebar

    # Show the exit status for the previous command if it failed
    if [[ $status -gt 0 ]]; then
        color bg-lred black "Exited with code $status"
    fi

    # Leave a blank line between the previous command's output and this one
    echo
}

_prompt() {
    # Message
    local message="${prompt_message:-$prompt_default}"
    if [[ -n $message ]]; then
        local spaces=$(printf '%*s\n' $(( $COLUMNS - ${#message} - 1 )) '')
        color lwhite bg-magenta $prompt_color -- " $message$spaces"
    fi

    # Information
    color -n lblack '['
    color -n lred "$USER"
    color -n lblack '@'
    color -n lgreen "$prompt_hostname"
    color -n lblack ':'
    _prompt-pwd-git
    color -n lblack ' at '
    color -n white "$(date +%H:%M:%S)"
    color -n lblack ']'
}

_prompt-pwd-git() {
    local root

    # Look for .git directory
    if ! root=$(findup -d .git); then
        # No .git found - just show the working directory
        color -n lyellow "$PWD"
        return
    fi

    # Display working directory & highlight the git root in a different colour
    local relative=${PWD#$root}
    if [[ $relative = $PWD ]]; then
        color -n lyellow "$PWD"
    else
        color -n lyellow "$root"
        color -n lcyan "$relative"
    fi

    # Branch/tag/commit
    # This must be split into two lines to get the exit code
    # https://unix.stackexchange.com/a/346880/14368
    local branch_output
    branch_output=$(command git branch --no-color 2>&1)
    if [[ $? -eq 128 && $branch_output = *"is owned by someone else"* ]]; then
        # https://github.blog/2022-04-12-git-security-vulnerability-announced/
        color -n lred ' (repo owned by another user)'
        return
    fi

    local branch=$(echo "$branch_output" | sed -nE 's/^\* (.*)$/\1/p')
    if [[ -z $branch ]]; then
        # e.g. Before any commits are made
        branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
    fi
    color -n lblack ' on '
    color -n lmagenta "${branch:-(unknown)}"

    # Status (only the most important one, to make it easy to understand)
    if [[ -f "$root/.git/MERGE_HEAD" ]]; then
        color -n fg-111 ' (merging)'
    elif [[ -f "$root/.git/rebase-apply/applying" ]]; then
        color -n fg-111 ' (applying)'
    elif [[ -d "$root/.git/rebase-merge" || -d "$root/.git/rebase-apply/rebase-apply" ]]; then
        color -n fg-111 ' (rebasing)'
    elif [[ -f "$root/.git/CHERRY_PICK_HEAD" ]]; then
        color -n fg-111 ' (cherry picking)'
    elif [[ -f "$root/.git/REVERT_HEAD" ]]; then
        color -n fg-111 ' (reverting)'
    elif [[ -f "$root/.git/BISECT_LOG" ]]; then
        color -n fg-111 ' (bisecting)'
    else
        local gstatus
        gstatus=$(timeout 1 git status --porcelain=2 --branch 2>/dev/null)
        local exitcode=$?
        local using_status_v2=true

        if [[ $exitcode -eq 129 ]]; then
            # Old version of Git - we won't be able to get ahead/behind info
            gstatus=$(timeout 1 git status --porcelain --branch 2>/dev/null)
            exitcode=$?
            using_status_v2=false
        fi

        if [[ $exitcode -eq 124 ]]; then
            color -n fg-245 ' (git timeout)'
        elif [[ -n $(echo "$gstatus" | grep -v '^#' | head -1) ]]; then
            color -n fg-111 ' (modified)'
        elif [[ -f "$root/.git/logs/refs/stash" ]]; then
            color -n fg-111 ' (stashed)'
        else
            local ahead behind
            read -r ahead behind <<< $(echo "$gstatus" | sed -nE 's/^# branch\.ab \+([0-9]+) \-([0-9]+)$/\1\t\2/p')

            if [[ $ahead -gt 0 ]]; then
                if [[ $behind -gt 0 ]]; then
                    color -n fg-111 ' (diverged)'
                else
                    color -n fg-111 " ($ahead ahead)"
                fi
            else
                if [[ $behind -gt 0 ]]; then
                    color -n fg-111 " ($behind behind)"
                elif $using_status_v2 && ! echo "$gstatus" | grep -qE '^# branch.upstream '; then
                    color -n fg-245 ' (no upstream)'
                fi
            fi
        fi
    fi
}

_prompt-titlebar() {
    # This doesn't work in Windows Terminal
    #echo -ne "\001\e]2;"
    echo -ne "\e]2;"
    if [[ -n $prompt_message ]]; then
        echo -n "[$prompt_message] "
    fi
    echo -n "$USER@$prompt_hostname:$PWD"
    #echo -ne "\a\002"
    echo -ne "\a"
}

_record-last-directory() {
    pwd > ~/.local/bash-last-directory
}

_update-dpi() {
    # Note: Can't use `command -v php` here because of the function
    if [[ -x /usr/bin/php ]]; then
        if [[ -f $HOME/.config/bash/hidpi ]]; then
            export GDK_SCALE=2
            _set-phpstorm-font-size 10 11
        else
            export GDK_SCALE=1
            _set-phpstorm-font-size 13 15
        fi
    fi
}


#===============================================================================
# Key bindings
#===============================================================================
# Also see .inputrc

# Helpers
bind -x '"\200": TEMP_LINE=$READLINE_LINE; TEMP_POINT=$READLINE_POINT'
bind -x '"\201": READLINE_LINE=$TEMP_LINE; READLINE_POINT=$TEMP_POINT; unset TEMP_POINT; unset TEMP_LINE'

# Ctrl-Alt-Left/Right
bind '"\e[1;7D": "\200\C-a\C-kprevd\C-m\201"'
bind '"\e[1;7C": "\200\C-a\C-knextd\C-m\201"'

# Ctrl-Alt-Up
bind '"\e[1;7A": "\200\C-a\C-kc ..\C-m\201"'

# Ctrl-Alt-Down
if declare -f __fzf_cd__ &>/dev/null; then
    # See /usr/share/doc/fzf/examples/key-bindings.bash
    bind '"\e[1;7B": "\ec"'
else
    bind '"\e[1;7B": "\C-a\C-kc \e[Z"'
fi

# Space - Expand history (!!, !$, etc.) immediately
bind 'Space: magic-space'


#===============================================================================
# Settings
#===============================================================================

dirhistory_past=()
dirhistory_future=()

export DOCKER_USER="$(id -u):$(id -g)" # https://stackoverflow.com/a/68711840/167815
export GPG_TTY=$(tty)
export HISTCONTROL='ignoreboth'
export HISTIGNORE='&'
export HISTSIZE=50000
export HISTTIMEFORMAT='[%Y-%m-%d %H:%M:%S] '
export QUOTING_STYLE='literal'

shopt -s autocd
shopt -s cdspell
shopt -s checkhash
shopt -s checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dirspell
shopt -s globstar
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s lithist
shopt -s no_empty_cmd_completion
shopt -u sourcepath

stty -ixon # Disable Ctrl-S
tabs -4

_update-dpi


#---------------------------------------
# Prompt
#---------------------------------------

PROMPT_COMMAND='_prompt-before'
# Note: $() doesn't work here in Git Bash
PS1='`_prompt`\n\[\e[91m\]$\[\e[0m\] '

prompt_color=''
prompt_command=''
prompt_default=''
prompt_message=''

if [[ -z $prompt_default ]] && is-root-user && ! is-docker; then
    prompt_color='bg-red'
    prompt_default='Logged in as ROOT!'
fi

prompt_hostname=$(get-full-hostname)


#---------------------------------------
# fzf - fuzzy finder
#---------------------------------------
# https://github.com/junegunn/fzf

# Custom filters
_fzf_compgen_path() {
    echo "$1"
    command find -L "$1" \
        -name .cache -prune -o \
        -name .git -prune -o \
        -name .hg -prune -o \
        -name .svn -prune -o \
        \( -type d -o -type f -o -type l \) \
        -not -path "$1" \
        -print \
        2>/dev/null \
    | sed 's#^\./##'
}

_fzf_compgen_dir() {
    command find -L "$1" \
        -name .cache -prune -o \
        -name .git -prune -o \
        -name .hg -prune -o \
        -name .svn -prune -o \
        -type d \
        -not -path "$1" \
        -print \
        2>/dev/null \
    | sed 's#^\./##'
}

export FZF_DEFAULT_COMMAND='
    find -L . \
        -name .cache -prune -o \
        -name .git -prune -o \
        -name .hg -prune -o \
        -name .svn -prune -o \
        \( -type d -o -type f -o -type l \) \
        -print \
        2>/dev/null \
    | sed "s#^./##"
'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_CTRL_T_OPTS="
    --select-1
    --preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'
"

export FZF_ALT_C_OPTS="
    --preview 'tree -C {} | head -200'
"

# Type "cd #<Tab>" (and other commands) to trigger fzf - because the default "cd **<Tab>" is harder to type
export FZF_COMPLETION_TRIGGER='#'

if declare -f _fzf_setup_completion &>/dev/null; then
    _fzf_setup_completion dir c
    _fzf_setup_completion dir l
    _fzf_setup_completion dir la
    _fzf_setup_completion dir ll
    _fzf_setup_completion dir ls
    _fzf_setup_completion path e
    _fzf_setup_completion path g
    _fzf_setup_completion path git
fi

# Override Alt-C / Ctrl-Alt-Down to use 'c' instead of 'cd'
# Based on /usr/share/doc/fzf/examples/key-bindings.bash
__fzf_cd__() {
  local cmd dir
  cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  dir=$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m) && printf 'c %q' "$dir"
}


#---------------------------------------
# Load marks
#---------------------------------------

if [ -d "$HOME/.marks" ]; then
    for target in $HOME/.marks/*; do
        mark=$(basename "$target")
        alias $mark="c -P $target"
    done
fi

#---------------------------------------
# WSLtty configuration
#---------------------------------------

# The WSLtty config file is stored outside the Git repo
if is-wsl; then
    WIN_APPDATA="$(command cd /mnt/c && cmd.exe /C 'echo %APPDATA%' | tr -d '\r')"
    WIN_APPDATA_UNIX="$(wslpath "$WIN_APPDATA")"

    if [[ -f $WIN_APPDATA_UNIX/wsltty/config ]] && ! cmp -s $WIN_APPDATA_UNIX/wsltty/config $HOME/.minttyrc; then
        rm -f $WIN_APPDATA_UNIX/wsltty/config
        cp $HOME/.minttyrc $WIN_APPDATA_UNIX/wsltty/config
        echo
        color bg-yellow black 'WSLtty config updated - please reload it'
    fi
fi


#---------------------------------------
# Working directory
#---------------------------------------

# Change to the last visited directory, unless we're already in a different directory
if [[ $PWD = $HOME && -f ~/.local/bash-last-directory ]]; then
    # Throw away errors about that directory not existing (any more)
    command cd "$(cat ~/.local/bash-last-directory)" 2>/dev/null
fi

_dirhistory-push-past "$PWD"


#---------------------------------------
# Custom settings / functions
#---------------------------------------

# Personal settings, for use in forks
[[ -f ~/.bashrc_personal ]] && source ~/.bashrc_personal

# Local settings, not committed to Git
[[ -f ~/.bashrc_local ]] && source ~/.bashrc_local


#===============================================================================
# Outputs
#===============================================================================

# Automatic updates
~/.dotfiles/auto-update

# Show the current directory name & contents
_ls-current-directory


#===============================================================================
# Cloud Shell
#===============================================================================

#---------------------------------------
# Azure Cloud Shell
#---------------------------------------

# Azure will automatically add these if they're not in the file :-\
#ADDED_HIST_CONTROL_CHECK
#ADDED_HIST_PROMPT_COMMAND_CHECK
#source /etc/bash_completion.d/azure-cli
#PS1=${PS1//\\h/Azure}
#source /usr/bin/cloudshellhelp
