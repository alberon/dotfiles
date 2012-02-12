if [ `id -u` -eq 0 ]; then
    umask $umask_root
else
    umask $umask_user
fi
