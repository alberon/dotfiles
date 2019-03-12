# Detect operating system
CYGWIN=false
DOCKER=false
MSYSGIT=false
MAC=false
WINDOWS=false

case "$(uname)" in
    CYGWIN*) WINDOWS=true; CYGWIN=true ;;
    MINGW*)  WINDOWS=true; MSYSGIT=true ;;
    Darwin)  MAC=true ;;
esac

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

