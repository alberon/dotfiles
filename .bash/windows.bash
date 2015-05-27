if $WINDOWS; then

    # Use PuTTY instead of OpenSSH so I don't have to re-enter the SSH key password
    # if [ -f /c/Program\ Files/PuTTY/plink.exe ]; then

    #     export GIT_SSH=/c/Program\ Files/PuTTY/plink.exe
    #     alias ssh="/c/Program\ Files/PuTTY/plink.exe"

    # elif [ -f /c/Program\ Files\ \(x86\)/PuTTY/plink.exe ]; then

    #     export GIT_SSH=/c/Program\ Files\ \(x86\)/PuTTY/plink.exe
    #     alias ssh="/c/Program\ Files\ \(x86\)/PuTTY/plink.exe"

    # fi

    # Use Pageant for SSH keys so I don't have to re-enter the SSH key password
    # https://github.com/cuviper/ssh-pageant
    case "$(uname -a)" in
        CYGWIN_*i686*)
            # Untested because all my PCs are 64-bit
            agent=ssh-pageant-1.4-prebuilt-cygwin32
            ;;
        CYGWIN_*x86_64*)
            agent=ssh-pageant-1.4-prebuilt-cygwin64
            ;;
        MINGW32_*)
            agent=ssh-pageant-1.4-prebuilt-msys32
            ;;
        *)
            agent=
    esac

    if [ -n "$agent" ]; then
        eval $($HOME/opt/$agent/ssh-pageant -r -a "/tmp/.ssh-pageant-$USERNAME")
    fi

    # Clear the MSysGit MOTD (at this point it's already been shown, but this
    # gets rid of it for the future)
    if [ -w /etc/motd ]; then
        > /etc/motd
    fi

    # Emulate apt-get with apt-cyg
    alias agi='apt-cyg install'
    alias agr='apt-cyg remove'
    alias agu='apt-cyg update'
    alias acs='apt-cyg searchall'

fi
