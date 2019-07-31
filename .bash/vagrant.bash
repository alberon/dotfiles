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
