if [ -f /c/Program\ Files/PuTTY/plink.exe ]; then
    export GIT_SSH=/c/Program\ Files/PuTTY/plink.exe
    alias ssh="/c/Program\ Files/PuTTY/plink.exe"
elif [ -f /c/Program\ Files\ \(x86\)/PuTTY/plink.exe ]; then
    export GIT_SSH=/c/Program\ Files\ \(x86\)/PuTTY/plink.exe
    alias ssh="/c/Program\ Files\ \(x86\)/PuTTY/plink.exe"
fi
