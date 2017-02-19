MessageBoxIndirect(Text, Title := "", Options := 0, IconRes := "", IconID := 1, Owner := 0) {
    If (IconRes != "") {
        hModule := DllCall("GetModuleHandle", "Str", IconRes, "Ptr")
        LoadLib := !hModule
            && hModule := DllCall("LoadLibraryEx", "Str", IconRes, "UInt", 0, "UInt", 0x2)
        Options |= 0x80 ; MB_USERICON
    } Else {
        hModule := 0
        LoadLib := False
    }

    ; MSGBOXPARAMS structure
    NumPut(VarSetCapacity(MBP, A_PtrSize * 7, 0), MBP)
    NumPut(Owner,   MBP, 1 * A_PtrSize, "UInt")
    NumPut(hModule, MBP, 2 * A_PtrSize, "Ptr")
    NumPut(&Text,   MBP, 3 * A_PtrSize, "UInt")
    NumPut(&Title,  MBP, 4 * A_PtrSize, "UInt")
    NumPut(Options, MBP, 5 * A_PtrSize, "UInt")
    NumPut(IconID,  MBP, 6 * A_PtrSize, "UInt")
    Ret := DllCall("MessageBoxIndirect", "Ptr", &MBP)

    If (LoadLib) {
        DllCall("FreeLibrary", "UInt", hModule)
    }

    Static Result := {1: "OK", 2: "Cancel", 3: "Abort", 4: "Retry", 5: "Ignore", 6: "Yes", 7: "No", 10: "Try Again", 11: "Continue"}
    Return Result[Ret]
}