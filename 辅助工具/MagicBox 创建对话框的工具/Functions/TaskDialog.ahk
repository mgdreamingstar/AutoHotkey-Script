TaskDialog(Instruction, Content := "", Title := "", Buttons := 1, IconID := 0, IconRes := "", Owner := 0x10010) {
    Local hModule, LoadLib, Ret

    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2)
    } Else {
        hModule := 0
        LoadLib := False
    }

    DllCall("TaskDialog"
        , "UInt", Owner        ; hWndParent
        , "UInt", hModule      ; hInstance
        , "UInt", &Title       ; pszWindowTitle
        , "UInt", &Instruction ; pszMainInstruction
        , "UInt", &Content     ; pszContent
        , "UInt", Buttons      ; dwCommonButtons
        , "UInt", IconID       ; pszIcon
        , "Int*", Ret := 0)    ; *pnButton

    If (LoadLib) {
        DllCall("FreeLibrary", "UInt", hModule)
    }

    Return {1: "OK", 2: "Cancel", 4: "Retry", 6: "Yes", 7: "No", 8: "Close"}[Ret]
}