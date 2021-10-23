# This is implemented as a function not a command because it runs many times per
# prompt, and we don't want any extra overhead (timed at 0m0.016s per call)
color() {

    # Disable trailing new line?
    local newline=true
    if [[ ${1:-} = '-n' ]]; then
        newline=false
        shift
    fi

    # Save the original parameters
    local args=( "$@" )

    # Help Bash calculate the correct prompt size (Note: "\[" doesn't work here)
    # This doesn't work in Windows Terminal
    #echo -en "\001"

    # Reset to prevent any previous styles interfering
    echo -en "\e[0m"

    # Output ANSI codes and text
    while [ $# -gt 0 ]; do
        local color="$1"

        # Automatically calculate the inverse colour, if required
        # Warning: This is relative slow (10ms) so don't use it unless necessary
        # It is mainly here for use in the 'color-test' script
        if [[ $color = 'fg-auto' ]]; then
            color="fg-$(_color-inverse fg lwhite "${args[@]}")"
        elif [[ $color = 'bg-auto' ]]; then
            color="bg-$(_color-inverse bg black "${args[@]}")"
        fi

        case "$color" in

            bold)                   echo -en "\e[1m" ;; # May do the same as the "l" colours, or may actually be bold
            dim)                    echo -en "\e[2m" ;;
            italic)                 echo -en "\e[3m" ;;
            underline)              echo -en "\e[4m" ;;
            blink)                  echo -en "\e[5m" ;;
            rapidblink)             echo -en "\e[6m" ;; # Not widely supported
            reverse)                echo -en "\e[7m" ;;
            hide)                   echo -en "\e[8m" ;;
            strike)                 echo -en "\e[9m" ;;

            fg-black|black)         echo -en "\e[30m" ;;
            fg-red|red)             echo -en "\e[31m" ;;
            fg-green|green)         echo -en "\e[32m" ;;
            fg-yellow|yellow)       echo -en "\e[33m" ;;
            fg-blue|blue)           echo -en "\e[34m" ;;
            fg-magenta|magenta)     echo -en "\e[35m" ;;
            fg-cyan|cyan)           echo -en "\e[36m" ;;
            fg-white|white)         echo -en "\e[37m" ;;

            fg-lblack|lblack)       echo -en "\e[90m" ;;
            fg-lred|lred)           echo -en "\e[91m" ;;
            fg-lgreen|lgreen)       echo -en "\e[92m" ;;
            fg-lyellow|lyellow)     echo -en "\e[93m" ;;
            fg-lblue|lblue)         echo -en "\e[94m" ;;
            fg-lmagenta|lmagenta)   echo -en "\e[95m" ;;
            fg-lcyan|lcyan)         echo -en "\e[96m" ;;
            fg-lwhite|lwhite)       echo -en "\e[97m" ;;

            fg-?|fg-??|fg-???)      echo -en "\e[38;5;${1:3}m" ;;
            fg-??????)              echo -en "\e[38;2;$(_color-hex-to-ansi "${1:3}")m" ;;

            bg-black)               echo -en "\e[40m" ;;
            bg-red)                 echo -en "\e[41m" ;;
            bg-green)               echo -en "\e[42m" ;;
            bg-yellow)              echo -en "\e[43m" ;;
            bg-blue)                echo -en "\e[44m" ;;
            bg-magenta)             echo -en "\e[45m" ;;
            bg-cyan)                echo -en "\e[46m" ;;
            bg-white)               echo -en "\e[47m" ;;

            bg-lblack)              echo -en "\e[100m" ;;
            bg-lred)                echo -en "\e[101m" ;;
            bg-lgreen)              echo -en "\e[102m" ;;
            bg-lyellow)             echo -en "\e[103m" ;;
            bg-lblue)               echo -en "\e[104m" ;;
            bg-lmagenta)            echo -en "\e[105m" ;;
            bg-lcyan)               echo -en "\e[106m" ;;
            bg-lwhite)              echo -en "\e[107m" ;;

            bg-?|bg-??|bg-???)      echo -en "\e[48;5;${1:3}m" ;;
            bg-??????)              echo -en "\e[48;2;$(_color-hex-to-ansi "${1:3}")m" ;;

            --)
                shift
                ;& # Fall through
            *)
                #echo -en "\002"
                echo -n "$@"
                #echo -en "\001\e[0m\002"
                echo -en "\e[0m"
                if $newline; then
                    echo
                fi
                return
                ;;

        esac

        shift
    done
}

_color-hex-to-ansi() {
    local r="${1:0:2}"
    local g="${1:2:2}"
    local b="${1:4:2}"

    echo "$((16#$r));$((16#$g));$((16#$b))"
}

_color-inverse() {
    local type="$1"
    local inverse="$2"
    shift 2

    for color in $@; do
        case "$color" in

            bg-auto|fg-auto) ;;
            bold|dim|italic|underline|blink|rapidblink|reverse|hide|strike) ;;

            fg-black|black)         [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 0)" ;;
            fg-red|red)             [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 1)" ;;
            fg-green|green)         [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 2)" ;;
            fg-yellow|yellow)       [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 3)" ;;
            fg-blue|blue)           [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 4)" ;;
            fg-magenta|magenta)     [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 5)" ;;
            fg-cyan|cyan)           [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 6)" ;;
            fg-white|white)         [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 7)" ;;

            fg-lblack|lblack)       [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 8)";;
            fg-lred|lred)           [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 9)";;
            fg-lgreen|lgreen)       [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 10)";;
            fg-lyellow|lyellow)     [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 11)";;
            fg-lblue|lblue)         [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 12)";;
            fg-lmagenta|lmagenta)   [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 13)";;
            fg-lcyan|lcyan)         [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 14)";;
            fg-lwhite|lwhite)       [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg 15)";;

            fg-?|fg-??|fg-???)      [[ $type = bg ]] && inverse="$(_color-contrast-ansi bg ${color:3})" ;;
            fg-??????)              [[ $type = bg ]] && inverse="$(_color-contrast-hex bg "${color:3}")" ;;

            bg-black)               [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 0)" ;;
            bg-red)                 [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 1)" ;;
            bg-green)               [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 2)" ;;
            bg-yellow)              [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 3)" ;;
            bg-blue)                [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 4)" ;;
            bg-magenta)             [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 5)" ;;
            bg-cyan)                [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 6)" ;;
            bg-white)               [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 7)" ;;

            bg-lblack)              [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 8)" ;;
            bg-lred)                [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 9)" ;;
            bg-lgreen)              [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 10)" ;;
            bg-lyellow)             [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 11)" ;;
            bg-lblue)               [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 12)" ;;
            bg-lmagenta)            [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 13)" ;;
            bg-lcyan)               [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 14)" ;;
            bg-lwhite)              [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg 15)" ;;

            bg-?|bg-??|bg-???)      [[ $type = fg ]] && inverse="$(_color-contrast-ansi fg ${color:3})" ;;
            bg-??????)              [[ $type = fg ]] && inverse="$(_color-contrast-hex fg "${color:3}")" ;;

            *)                      break ;;

        esac
    done

    echo $inverse
}

# Based on https://gist.github.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263
# (c) Tom Hale, 2016. MIT Licence
_color-contrast-ansi() {
    local type=$1
    local color=$2

    # Initial 16 ANSI colours
    if (( color < 16 )); then
        case "$color" in
            0)  _color-contrast-rgb $type    0    0    0  ;; # black
            1)  _color-contrast-rgb $type  191    0    0  ;; # red
            2)  _color-contrast-rgb $type    0  191    0  ;; # green
            3)  _color-contrast-rgb $type  191  191    0  ;; # yellow
            4)  _color-contrast-rgb $type   59   72  227  ;; # blue (Note: I adjusted this in MinTTY to make it more readable)
            5)  _color-contrast-rgb $type  191    0  191  ;; # magenta
            6)  _color-contrast-rgb $type    0  191  191  ;; # cyan
            7)  _color-contrast-rgb $type  191  191  191  ;; # white
            8)  _color-contrast-rgb $type   64   64   64  ;; # lblack
            9)  _color-contrast-rgb $type  255   64   64  ;; # lred
            10) _color-contrast-rgb $type   64  255   64  ;; # lgreen
            11) _color-contrast-rgb $type  255  255   64  ;; # lyellow
            12) _color-contrast-rgb $type  125  135  236  ;; # lblue (Note: I adjusted this in MinTTY to make it more readable)
            13) _color-contrast-rgb $type  255   64  255  ;; # lmagenta
            14) _color-contrast-rgb $type   64  255  255  ;; # lcyan
            15) _color-contrast-rgb $type  255  255  255  ;; # lwhite
            *) echo 'lwhite' ;;
        esac
        return
    fi

    # Greyscale
    local r g b
    if (( color > 231 )); then
        r=$(( ((color-232) * 11) + 1 ))
        g=$r
        b=$r
    else
        # All other colours:
        # 6x6x6 colour cube = 16 + 36*R + 6*G + B  # Where RGB are [0..5]
        # See http://stackoverflow.com/a/27165165/5353461
        # That makes each be in the range 0..5, and we need to convert to 0..255
        r=$(( 51 * (color-16) / 36 ))
        g=$(( 51 * ((color-16) % 36) / 6 ))
        b=$(( 51 * (color-16) % 6 ))
    fi

    _color-contrast-rgb $type $r $g $b
}

_color-contrast-hex() {
    local type=$1
    local hex=$2

    local r=${hex:0:2}
    local g=${hex:2:2}
    local b=${hex:4:2}

    _color-contrast-rgb $type $((16#$r)) $((16#$g)) $((16#$b))
}

_color-contrast-rgb() {
    local type=$1
    local r=$2
    local g=$3
    local b=$4

    local luminance=$(( ($r * 299) + ($g * 587) + ($b * 114) ))

    # Calculate percieved brightness
    # See https://www.w3.org/TR/AERT#color-contrast and http://www.itu.int/rec/R-REC-BT.601
    # Luminance range is 0..255000
    local cutoff=127500
    if [[ $type = bg ]]; then
        # Adjusted for the background because we want a dark background as much as possible
        cutoff=50000
    fi

    (( $luminance > $cutoff )) && echo black || echo lwhite
}
