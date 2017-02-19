;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 该脚本是由于url_encode_decode.ahk必须运行于ANSI AutoHotkey，但原脚本必须
;;; 运行于Unicode下,不能共存,因此单独把ANSI的代码部分摘出来,用AutoHotkeyA32版
;;; 本另外运行
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include %A_LineFile%\..\..\Library\url_encode_decode.ahk

SetTitleMatchMode Regex	;更改进程匹配模式为正则
#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
#Persistent				;持续运行不退出
#MaxThreadsPerHotkey 5
Menu, Tray, Icon, %A_LineFile%\..\..\icon\自定义快捷操作_子脚本.ico, , 1
Menu, tray, tip, ANSI版本 by LL

;控制当前运行是ANSI版,若不是则切换
SplitPath A_AhkPath,, AhkDir
If (A_PtrSize = 8 || A_IsUnicode) {			;如果是64位程序,或是Unicode版，则进入切换版本的该循环
    A32 := AhkDir . "\AutoHotkeyA32.exe"	;U32的路径
    If (FileExist(A32)) {
        Run %A32% %A_LineFile%				;如果存在,用U32再运行当前脚本
        ExitApp								;退出当前这个实例
    } Else {
        MsgBox 0x2010, AutoGUI, AutoHotkey 32-bit ANSI not found.	;如果不存在,报错
        ExitApp
    }
}

~RButton & r::Reload

;-------------------------------------------------------------------------------
;~ Firefox快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class MozillaWindowClass
{
	Numpad0 & q::
	{
		clipboard = 
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		str := urlencode(clipboard)
		clipboard = http://book.szdnet.org.cn/search?Field=all&channel=search&sw=%str%
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
}