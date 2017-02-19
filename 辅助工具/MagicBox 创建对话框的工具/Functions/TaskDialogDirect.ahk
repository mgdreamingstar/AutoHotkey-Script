TaskDialogDirect(Instruction, Content := "", Title := "", CustomButtons := "", CommonButtons := 0, MainIcon := 0, Flags := 0, Owner := 0x10010, VerificationText := "", ExpandedText := "", FooterText := "", FooterIcon := 0, Width := 0) {
    Static x64 := A_PtrSize == 8, Button := 0, Checked := 0

    If (CustomButtons != "") {
        Buttons := StrSplit(CustomButtons, "|", "*")
        cButtons := Buttons.Length()
        VarSetCapacity(pButtons, 4 * cButtons + A_PtrSize * cButtons, 0)
        Loop % cButtons {
            iButtonText := &(b%A_Index% := Buttons[A_Index])
            NumPut(100 + A_Index, pButtons, (4 + A_PtrSize) * (A_Index - 1))
            NumPut(iButtonText, pButtons, (4 + A_PtrSize) * A_Index - A_PtrSize)
        }
    } Else {
        cButtons := 0
        pButtons := 0
    }

    NumPut(VarSetCapacity(TDC, (x64) ? 160 : 96, 0), TDC, 0) ; cbSize
    NumPut(Owner, TDC, 4) ; hwndParent
    NumPut(Flags, TDC, (x64) ? 20 : 12) ; dwFlags
    NumPut(CommonButtons, TDC, (x64) ? 24 : 16) ; dwCommonButtons
    NumPut(&Title, TDC, (x64) ? 28 : 20) ; pszWindowTitle
    NumPut(MainIcon, TDC, (x64) ? 36 : 24) ; pszMainIcon
    NumPut(&Instruction, TDC, (x64) ? 44 : 28) ; pszMainInstruction
    NumPut(&Content, TDC, (x64) ? 52 : 32) ; pszContent
    NumPut(cButtons, TDC, (x64) ? 60 : 36) ; cButtons
    NumPut(&pButtons, TDC, (x64) ? 64 : 40) ; pButtons
    NumPut(&VerificationText, TDC, (x64) ? 92 : 60) ; pszVerificationText
    NumPut(&ExpandedText, TDC, (x64) ? 100 : 64) ; pszExpandedInformation
    NumPut(FooterIcon, TDC, (x64) ? 124 : 76) ; pszFooterIcon
    NumPut(&FooterText, TDC, (x64) ? 132 : 80) ; pszFooter
    NumPut(Width, TDC, (x64) ? 156 : 92, "UInt") ; cxWidth

    If (DllCall("Comctl32.dll\TaskDialogIndirect", "UInt", &TDC, "Int*", Button, "Int", 0, "Int*", Checked) == 0) {
        Return (VerificationText == "") ? Button : [Button, Checked]
    } Else {
        Return "ERROR"
    }
}
