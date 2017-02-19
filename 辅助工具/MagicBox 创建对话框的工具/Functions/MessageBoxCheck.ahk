MessageBoxCheck(Text, Title := "", Options := 0, RegVal := "", Owner := 0) {
    If (DllCall("GetVersion") & 0xFF < 6) {
        hModule := DllCall("GetModuleHandle", "Str", "shlwapi.dll", "Ptr")
        SHMessageBoxCheck := DllCall("GetProcAddress", "UInt", hModule, "UInt", (A_IsUnicode) ? 191 : 185, "Ptr")
    } Else {
        SHMessageBoxCheck := "Shlwapi\SHMessageBoxCheck"
    }
    
    Ret := DllCall(SHMessageBoxCheck
        , "UInt", Owner ? Owner : DllCall("GetDesktopWindow")
        , "Str" , Text
        , "Str" , Title
        , "UInt", Options
        , "int" , 0
        , "Str" , (RegVal != "") ? RegVal : A_ScriptFullPath)

    Static Answer := {0: "Suppressed", 1: "OK", 2: "Cancel", 3: "Abort", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again", 11: "Continue"}
    Return Answer[Ret]
}