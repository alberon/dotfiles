# Defaults
enable_sudo=0
umask_user=007
umask_root=022
www_dir=

# Default prompt is hostname with uppercase first letter with pink background
#if $WINDOWS; then
#    hostname="`hostname`"
#else
#    hostname="`hostname -s`"
#fi
#prompt_default="$(echo "${hostname:0:1}" | tr [a-z] [A-Z])${hostname:1}"
prompt_default=
prompt_type=

# Load custom config options
if [ -f ~/.bashrc_config ]; then
    source ~/.bashrc_config
fi
