; Find the location of gVim
FindExe()
{
    Exe = c:\Program Files\Vim\vim73\gvim.exe
    If FileExist(Exe)
        Return Exe

    Exe = c:\Program Files (x86)\Vim\vim73\gvim.exe
    If FileExist(Exe)
        Return Exe

    MsgBox 0x10, , Gvim not found
    Exit 1
}

Exe := FindExe()
;Exe = "%Exe%" --remote-tab-silent "`%1" "`%*"
Exe = "%Exe%" --remote-silent "`%1" "`%*"

; Use tabs by default
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\Applications\gvim.exe\shell\edit\command, , %Exe%

; Add "Edit with Vim" to context menus
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\*\shell\Edit with Vim\command, , %Exe%

; Create a new file type
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\vim\shell\edit\command, , %Exe%

; Associate various extensions with that file type
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.bashrc            , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.conf              , , vim
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
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.sh                , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.snippet           , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.snippets          , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.sql               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vba               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vim               , , vim
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\.vimrc             , , vim

; Don't change file type for .txt else New > Text Document disappears from Explorer
RegWrite REG_SZ, HKEY_CURRENT_USER, Software\Classes\txtfile\shell\edit\command, , %Exe%

; Tell Windows to refresh the file associations immediately
DllCall("shell32\SHChangeNotify", uint, 0x08000000, uint, 0, uint, 0, uint, 0)

; Confirm it's done
MsgBox 0x40, , Done.
