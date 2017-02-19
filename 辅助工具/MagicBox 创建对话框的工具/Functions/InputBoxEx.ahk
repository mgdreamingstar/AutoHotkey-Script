InputBoxEx(Instruction := "", Content := "", Title := "", Default := "", ControlType := "", ControlOptions := "", Width := "", x := "", y := "", WindowOptions := "", Timeout := "", Owner := "") {
    Static py, Prompt1, Prompt2, pp, ppy, pph, Input, ip, ipy, iph, Footer, ww, Value, ExitCode

    Gui New, hWndhWnd LabelInputBoxEx -0xA0000 -DPIScale
    Gui % (Owner) ? "+Owner" . Owner : ""
    Gui Font
    Gui Color, White
    Gui Margin, 10, 12
    py := 10
    Width := (Width) ? Width : 430
    
    If (Instruction != "") {
        Gui Font, s12 c0x003399, Segoe UI
        Gui Add, Text, vPrompt1 y10, %Instruction%
        py := 40
    }

    Gui Font, s9 cDefault, Segoe UI

    If (Content != "") {
        Gui Add, Link, % "vPrompt2 x10 y" . py . " w" . (Width - 20), %Content%
    }

    GuicontrolGet pp, Pos, % (Content != "") ? "Prompt2" : "Prompt1"
    py := (Instruction != "" || Content !="") ? (ppy + pph + 16) : 22
    ControlType := (ControlType != "") ? ControlType : "Edit"
    Gui Add, %ControlType% , % "hWndInput x10 y" . py . " w" . (Width - 20) . "h21 " . ControlOptions, %Default%

    GuiControlGet ip, Pos, %Input%
    py := ipy + iph + 20
    Gui Add, Text, hWndFooter y%py% -Background +Border

    Gui Add, Button, % "gInputBoxExOK x" . (Width - 176) . " yp+12 w80 h23 Default", &OK
    Gui Add, Button, % "gInputBoxExClose xp+86 yp w80 h23", &Cancel

    Gui Show, % "w" . Width . " x" . (x ? x : "Center") . " y" . (y ? y : "Center"), %Title%
    Gui +SysMenu %WindowOptions%

    WinGetPos,,, ww,, ahk_id %hWnd%
    Guicontrol MoveDraw, %Footer%, % "x-1 " . " w" . ww . " h" . 48

    If (Timeout) {
        SetTimer InputBoxExTIMEOUT, % Round(Timeout) * 1000
    }

    If (Owner) {
        WinSet Disable,, ahk_id %Owner%
    }

    GuiControl Focus, %Input%
    Gui Font

    WinWaitClose ahk_id %hWnd%
    ErrorLevel := ExitCode
    Return Value

    InputBoxExESCAPE:
    InputBoxExCLOSE:
    InputBoxExTIMEOUT:
    InputBoxExOK:
        SetTimer InputBoxExTIMEOUT, Delete

        If (Owner) {
            WinSet Enable,, ahk_id %Owner%
        }

        GuiControlGet Value, %hWnd%:, %Input%
        Gui %hWnd%: Destroy
        ExitCode := (A_ThisLabel == "InputBoxExOK") ? 0 : (A_ThisLabel == "InputBoxExTIMEOUT") ? 2 : 1
    Return
}
