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
