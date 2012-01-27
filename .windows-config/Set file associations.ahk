; Find the location of gVim
FindExe()
{
    Exe = C:\Program Files\Vim\vim73\gvim.exe
    If FileExist(Exe)
        Return Exe

    Exe = C:\Program Files (x86)\Vim\vim73\gvim.exe
    If FileExist(Exe)
        Return Exe

    MsgBox 0x10, , Gvim not found
    Exit 1
}

Exe := FindExe()

Cmd = "%Exe%" --remote-tab-silent
;Cmd = "%Exe%" --remote-silent

WindowsCmd = %Cmd% "`%1" "`%*"

; Use tabs by default
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\Applications\gvim.exe\shell\edit\command, , %WindowsCmd%

; Add "Edit with Vim" to context menus
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\*\shell\Edit with Vim\command, , %WindowsCmd%

; Create a new file type
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\vim\shell\edit\command, , %WindowsCmd%

; Associate various extensions with that file type
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.bashrc            , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.builder           , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.coffee            , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.conf              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.diff              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.eco               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.ejs               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.erb               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.fcgi              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.gitconfig         , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.gitignore         , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.gvimrc            , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.gvimrc_size       , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.hgignore          , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.hgignore-global   , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.hgrc              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.htaccess          , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.ini               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.inputrc           , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.java              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.markdown          , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.orig              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.patch             , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.php               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.py                , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.rake              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.rb                , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.rhtml             , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.ru                , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.sass              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.scss              , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.sh                , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.snippet           , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.snippets          , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.sql               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vba               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vim               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vimrc             , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.yml               , , vim

; Don't change file type for .txt else New > Text Document disappears from Explorer
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\txtfile\shell\edit\command, , %WindowsCmd%

; Tell Windows to refresh the file associations immediately
DllCall("shell32\SHChangeNotify", uint, 0x08000000, uint, 0, uint, 0, uint, 0)

; WinSCP editor (replaces existing value, but doesn't add it if it's missing)
WinSCPCmd = %Cmd% !.!
StringReplace, WinSCPCmd, WinSCPCmd, \, `%5C, All
StringReplace, WinSCPCmd, WinSCPCmd, %A_Space%, `%20, All

Loop, HKEY_CURRENT_USER, Software\Martin Prikryl\WinSCP 2\Configuration\Interface\Editor, 2
{
    RegRead Value, HKEY_CURRENT_USER, %A_LoopRegSubKey%\%A_LoopRegName%, ExternalEditor
    IfInString, Value, gvim.exe
    {
        ;MsgBox, %Value%`r`n`r`n%WinSCPCmd%
        RegWrite, REG_SZ, HKEY_CURRENT_USER, %A_LoopRegSubKey%\%A_LoopRegName%, ExternalEditor, %WinSCPCmd%
    }
}

; Confirm it's done
MsgBox 0x40, , Done.
