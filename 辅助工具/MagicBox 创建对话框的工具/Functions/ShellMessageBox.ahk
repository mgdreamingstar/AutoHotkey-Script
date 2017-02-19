ShellMessageBox(Text, Title := "", Options := 0, Owner := 0) {
    If (DllCall("GetVersion") & 0xFF < 6) {
        hModule := DllCall("GetModuleHandle", "Str", "shlwapi.dll", "Ptr")
        ShellMessageBoxW := DllCall("GetProcAddress", "UInt", hModule, "UInt", 388, "Ptr")
    } Else {
        ShellMessageBoxW := "Shlwapi\ShellMessageBox"
    }

    Ret := DllCall(ShellMessageBoxW
        , "UInt", 0
        , "UInt", Owner ? Owner : DllCall("GetDesktopWindow")
        , "Str" , Text
        , "Str" , Title
        , "UInt", Options)

    Static Result := {1: "OK", 2: "Cancel", 3: "Abort", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again", 11: "Continue"}
    Return Result[Ret]
}