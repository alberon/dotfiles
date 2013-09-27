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
