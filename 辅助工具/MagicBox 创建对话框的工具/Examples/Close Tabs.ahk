#Include ..\Functions\MagicBox.ahk

Text := "You are about to close 3 tabs. Are you sure you want to continue?"
CheckText := "*Warn me when I attempt to close multiple tabs"

Result := MagicBox(Text, "Confirm close", "Close tabs|Cancel", 3, CheckText)
; ...
ExitApp
