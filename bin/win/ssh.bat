@echo off

REM This script is used by Vagrant on Windows - see ~/.vagrant.d/Vagrantfile

IF EXIST "c:\Program Files\VanDyke Software\SecureCRT\SecureCRT.exe" (

    REM Run SecureCRT using the "ssh" Bash script which handles translating parameters

    REM If there are no arguments do nothing - Vagrant does that to check for Plink
    REM https://github.com/mitchellh/vagrant/blob/b421af58e8b34411b1fe06d2976c0d2dc68dd704/lib/vagrant/util/ssh.rb#L85
    REM IF NOT "%1" == "" (
        sh.exe ssh %*
    REM )

) ELSE (

    REM Standard OpenSSH - crashes if run via sh.exe above so we run it directly here
    grep.exe -v "ControlPersist\|ControlPath" %HOME%\.ssh\config > %TMP%\ssh-config-windows
    ssh.exe -F %TMP%\ssh-config-windows %*

)
