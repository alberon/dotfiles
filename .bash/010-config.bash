# Defaults
enable_sudo=0
umask_user=007
umask_root=022
www_dir=

# Load custom config options
if [ -f ~/.bashrc_config ]; then
    source ~/.bashrc_config
fi
