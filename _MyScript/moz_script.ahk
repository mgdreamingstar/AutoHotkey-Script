#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Startup Folder
^!/:: run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
^!\:: run, D:\mozli\documents\github

^+!v::
{
    Send #d
    CoordMode, Mouse, Screen
    MouseClick, left,  1761,  1064
    Sleep, 100
    MouseClick, left,  1761,  1064
    ;SendEvent {click 1760,1065,0}
    Sleep, 1000
    ;MouseClick, left,  1729,  675
    CoordMode, Mouse, Relative
    SendEvent {click 170,210}
    Sleep, 1000
    SendEvent {click 536,310}
    SendEvent {click 550,429}
    SendEvent {click 535,434}
    ;Sleep 10000
    ;Send !{F4}
    Return
    ; Disconnect  VPN
    ^+!d::
    Send #d
    CoordMode, Mouse, Screen
    MouseClick, left,  1761,  1064
    Sleep, 100
    MouseClick, left,  1761,  1064
    ;SendEvent {click 1760,1065,0}
    Sleep, 1000
    ;MouseClick, left,  1729,  675
    CoordMode, Mouse, Relative
    SendEvent {click 170,210}
    Sleep, 1000
    SendEvent {click 536,310}
    SendEvent {click 550,429}
    SendEvent {click 730,430}
    Sleep 100
    Send !{F4}
    Return
}

;-----------------------------------------------------------------------------------------------------
; Quick edit
^+!e::
Edit
return

^+!r::
Reload
return

;------------------------------------------------------------
; Clear the Clipboard and Recycle bin
;------------------------------------------------------------
^!.::
clipboard =
FileRecycleEmpty
Return

;-----------------------------------------------------------
; Map the right alt as win
RAlt::RWin

;-----------------------------------------------------------------------------------------
; Disable the shift key-combo of half-angle and whole-angle
<+space:: Return

;------------------------------------------------------------------------------------------
; switch of VPN on demand
^!9:: run D:\Program Files (x86)\vpnup.bat
^!0:: run D:\Program Files (x86)\vpndown.bat



;-------------------------------------------------------------
; Change the Editor
; If your editor's command-line usage is something like the following,
; this script can be used to set it as the default editor for ahk files:
;
;   Editor.exe "Full path of script.ahk"
;
; When you run the script, it will prompt you to select the executable
; file of your editor.

;  Choose the default editor for *.ahk
;-------------------------------------------------------------
^+!0::
FileSelectFile Editor, 2,, Select your editor, Programs (*.exe)
if ErrorLevel
    ExitApp
RegWrite REG_SZ, HKCR, AutoHotkeyScript\Shell\Edit\Command,, "%Editor%" "`%1"
return

; Run as Admin
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}
;
