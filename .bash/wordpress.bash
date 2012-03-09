# cwc = "cd wp-content"
# This is because it's very hard to tab-complete "wp-content" because you have
# to type "wp-cont" before you get to a non-ambiguous prefix
function cwc {
    if [ -d wp-content ]; then
        c wp-content
    elif [ -d www/wp-content ]; then
        c www/wp-content
    elif [ -d ../wp-content ]; then
        c ../wp-content
    else
        echo "Cannot find wp-content/ directory" >&2
        return 1
    fi
}
