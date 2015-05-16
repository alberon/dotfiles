@echo off
grep.exe -v "ControlPersist\|ControlPath" %HOME%\.ssh\config > %TMP%\ssh-config-windows
ssh.exe -F %TMP%\ssh-config-windows %*
