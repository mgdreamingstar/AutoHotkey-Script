#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;-------------------------------------------------------------------------------
;~ 脚本配置 #Include等
;-------------------------------------------------------------------------------
	;提升性能相关的配置
	#NoEnv						;不检查空变量是否为环境变量
	;#KeyHistory 0				;不记录击键log
	;ListLines Off				;不记录击键log
	SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
	SetKeyDelay, -1, -1			;发送按键不留时间空隙
	SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0
	SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
	;如果以前录制的脚本,因延时变短,出问题,命令 MouseClick, MouseMove 和 MouseClickDrag 都提供了一个用来设置鼠标速度代替默认速度的参数.用它们自己的参数,设定移动速度
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input				;据说SendInput is the fastest send method.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	;#Include %A_LineFile%\..\..\Functions\url_encode_decode.ahk	;该脚本必须以ANSI运行
	#Include %A_LineFile%\..\..\Functions\TrayIcon by FanaticGuru.ahk
	#Include %A_LineFile%\..\..\Functions\WinHttpRequest 网络函数 HTTP get post\WinHttpRequest.ahk
	#Include %A_LineFile%\..\..\Functions\GetActiveBrowserURL 获取浏览器窗口的地址 等信息\GetActiveBrowserURL.ahk

	#InstallKeybdHook		;安装键盘和鼠标钩子 像Input和A_PriorKey，都需要钩子
	#InstallMouseHook
	SetTitleMatchMode Regex	;更改进程匹配模式为正则
	#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
	#Persistent				;持续运行不退出
	#MaxThreadsPerHotkey 5
	CoordMode, Mouse, Client	;鼠标坐标采用Client模式
	;SetCapsLockState,AlwaysOff
	CountStp := 0	;一键多用的计时器

	#Hotstring EndChars  `n				;编辑热字串的终止符
	
	;----------------------------------------------------------------------
	;Win 10 regedit: HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer\EnableLegacyBalloonNotifications=1 
	;need to create 'Explorer' and 'Enable...=1'
	;----------------------------------------------------------------------
	Menu, Tray, Icon, %A_LineFile%\..\Icon\自定义快捷操作.ico, , 1
	Menu, tray, tip, 自定义快捷键、自动保存 by LL
	TrayTip, 提示, 脚本已启动, , 1
	Sleep, 2000
	TrayTip
	;return		;注：这里不能加return  原因搜索帮助文件的「自动执行段」




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



;----------------------------------------------------------------------
; From another script
;----------------------------------------------------------------------













;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
	
	;Unicode发送函数,避免触发输入法,也不受全角影响
	;from [辅助Send 发送ASCII字符 V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
		;MsgBox %Ord%
		inputString:=("string",string)
		Loop, Parse, %inputString%
			ascString.=(_:=%Ord%(A_LoopField))<0x100?"{ASC " _ "}":A_LoopField
		SendInput, % ascString
	}

	;evernote编辑器增强函数
	evernoteEdit(eFoward, eEnd)
	{
		;BlockInput On
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetHtml3()
		;MsgBox, % t
		;t := WinClip.GetText()
		;RegExMatch(t, "s)(?<=StartFragment-->)(.*?)(?=<!--EndFragment)", t)
		;MsgBox, % WinClip.GetHtml2()
		;MsgBox, % WinClip.GetHtml3()
		html = %eFoward%%t%%eEnd%
		;MsgBox, % html
		WinClip.Clear()
		;MsgBox, % html
		WinClip.SetHTML(html)
		Sleep, 300
		;SendInput, {Space}{backspace}
		;Sleep,2000
		Send ^v
		;BlockInput Off
		Return
	}

	;evernote不保留原格式，增强函数
	evernoteEditText(eFoward, eEnd)
	{
		clipboard =
		Send ^c
		ClipWait, 1
		t := WinClip.GetText()
		html = %eFoward%%t%%eEnd%
		WinClip.Clear()
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}

	;evernote无原文本的插入html增强函数
	evernoteInsertHTML(html)
	{
		clipboard =
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}

	WinClip.GetHtml2 := Func("GetHtml2")		; 也可以直接覆盖原来的函数 -> WinClip.GetHtml := Func("GetHtml2")
	WinClip.GetHtml3 := Func("GetHtml_DOM")

	;操作HTML DOM，比GetHTML函数更实用
	GetHtml_DOM(this, Encoding := "UTF-8")
	{
		html := this.GetHtml2(Encoding)
		static doc := ComObjCreate("htmlFile")
		doc.Write(html), doc.Close()
		return doc.all.tags("span")[0].InnerHtml
	}

	;WinClip中Get的UTF-8改写，支持中文
	GetHtml2(this, Encoding := "UTF-8")
	{
	  if !( clipSize := this._fromclipboard( clipData ) )
		return ""
	  if !( out_size := this._getFormatData( out_data, clipData, clipSize, "HTML Format" ) )
		return ""
	  return strget( &out_data, out_size, Encoding )
	}

	;Returns the path of the specified Explorer window, or the path of the active Explorer window if
	;a title is not specified. Works with Explorer windows, desktop and some open/save dialogues.
	;Returns empty path if no path is retrieved.



;-------------------------------------------------------------------------------
;~ 全局程序: 注意全局程序，必须写在#IfWinActive *前面* ，函数后面， 才能正确执行！
;-------------------------------------------------------------------------------
{

}

;-------------------------------------------------------------------------------
;~ test部分: 检测某函数的作用，临时代码段
;-------------------------------------------------------------------------------
{

}

;-------------------------------------------------------------------------------
;~ 全局键位
;-------------------------------------------------------------------------------

	;临时
		Tab & .:: SendL("「」")
		Tab & ,:: SendL("『』")
		Tab & -:: SendL(";----------------------------------------------------------------------")
	;常用软件快速启动
	


	;快捷输入
	{
		Tab & s:: Send, ?{Space}			;	右三角
		Tab & d:: Send, ?{Space}			;	圆点
		;Tab & f:: Send, ■{Space}			;	方点
		Tab & f:: Send, ●{Space}			;	大圆点
		Tab & 1:: Send, ①{Space}
		Tab & 2:: Send, ②{Space}
		Tab & 3:: Send, ③{Space}
		Tab & 4:: Send, ④{Space}
		Tab & 5:: Send, ⑤{Space}
		Tab & 6:: Send, ⑥{Space}
		Tab & 7:: Send, ⑦{Space}
		Tab & 8:: Send, ⑧{Space}
		CapsLock & 1:: Send, ?{Space}
		CapsLock & 2:: Send, ?{Space}
		CapsLock & 3:: Send, ?{Space}
		CapsLock & 4:: Send, ?{Space}
		CapsLock & 5:: Send, ?{Space}
		CapsLock & 6:: Send, ?{Space}
		CapsLock & 7:: Send, ?{Space}
		CapsLock & 8:: Send, ?{Space}

		;Tab & g:: Send, √{Space}
		;多数时候，回车紧接句号，说明前面输入的是英文，那句号应该是英文的点，所以自动修改下



		#If
		*/

}

	;简单映射型 快捷键
	{
		~LButton & r::Reload
		~LButton & s::			;禁用脚本
			Suspend, On			;注意suspend必须在第一行 否则当suspend状态下，这个开关键，本身也会被禁用
			TrayTip, 提示, 已 [禁用] 脚本, , 1
			Sleep, 2000
			TrayTip
			Pause, On
			return
		~LButton & a::
			Suspend, Off
			TrayTip, 提示, 已 [启用] 脚本, , 1
			Sleep, 2000
			TrayTip
			Pause, Off
			return
		~LButton & e::Edit
			

		;Ditto自动分组(快捷输入)
		!Space::^!+l

		;配合Actual Window Manager做虚拟桌面切换
		#F1::SendInput, !#{F1}
		#F2::SendInput, !#{F2}

		;输入 不可见&宽度0 的字符
		Tab & Space:: SendInput, {U+2067}{U+2068}{U+2069}{U+206A}{U+206B}{U+206C}

		;还有些字符也不可见且宽度0，但是由于被列入network.IDN.blacklist_chars，所以经常被过滤掉，例如 {U+115F}{U+1160}{U+200B}{U+1160}{U+115F}{U+2001}{U+2002}{U+2003}{U+2004}{U+2005}{U+2006}{U+2007}{U+2008}{U+2009}{U+200A}{U+200B}{U+2028}{U+2029}{U+202F}{U+205F}{U+3000}{U+3164}{U+FEFF}
		;输入 不可见&宽度非0 的字符
		CapsLock & Space:: SendInput, {U+115A}{U+115B}{U+115C}{U+115D}{U+115E}{U+11A3}{U+11A4}{U+11A5}{U+11A6}{U+11A7}
		;输入 几乎不可见 的字符
		Tab & p:: SendInput, {U+06E4}{U+115B}{U+115C}{U+115D}{U+115E}

		;在farbox web editor中快捷输入meta信息
		Tab & b:: SendInput, {Shift}Title{U+003A}{Space}{Enter}Tags{U+003A}{Space}标签1{U+002C}{Space}标签2{Enter}Status{U+003A}{Space}draft{U+002F}public{Enter}URL{U+003A} this-is-my-first-post
	}

	;复杂型 快捷键
	{
		
		!c::
			MouseGetPos, xpos, ypos 				;记忆鼠标位置
			TrayIcon_Button("cow-taskbar.exe", "R")
			MouseMove, 20, 50,, R
			Sleep, 500
			MouseClick, left
			TrayIcon_Button("cow-taskbar.exe", "R")
			Sleep, 1000
			MouseMove, 20, 40,, R
			MouseClick, left
			MouseMove, xpos, ypos					;恢复鼠标位置
			return


		/*Tab & o::
			Loop, 39
			{
				SendInput, {Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Tab}{Space}
				Sleep, 1500
				SendInput, {Tab}{Space}
				Sleep, 1500
			}
			return
		*/



		;双击esc退出焦点程序
		;~Esc::
		;	if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
		;		Send, !{F4}
		;	return

		;恢复Tab键原本功能,很重要：将tab作为fn一样的按键。因为键盘上确实没有多余的按键可以用作此用了。（Caps lock已经用于移动光标等其他了）
		{
			$Tab::Send, {Tab}
			LAlt & Tab::AltTab
			^Tab::Send, ^{Tab}
			^+Tab::Send, ^+{Tab}
			+Tab::SendInput, +{Tab}
		}


		;evernote新建笔记
		LButton & w::SendInput, ^!n
		$F4::
			SendInput, {F4}
			WinWaitActive, ahk_class ENMainFrame, , 2
			sendL("notebook:""1  Cabinet"" ")		;注意字符中的双引号要转义，不是\"，而是两个引号""
			return

}

;-------------------------------------------------------------------------------
;~ Evernote快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class (ENSingleNoteView|ENMainFrame)
{
	;快捷键: 非编辑器部分
	{

		;en的搜索不支持特殊字符，特快捷输入这些国际字母，以变相支持特殊字符
		` & 1::SendInput, {U+0069}{U+006E}{U+0074}{U+0069}{U+0074}{U+006C}{U+0065}{U+003A}		;输入intitle:，为了避免输入法影响，用unicode输入
		` & 2::SendInput, Δ{Space}
		` & 3::SendInput, ?{Space}
		` & d::SendInput, ^;			;快速插入日期时间
		;Tab & q::evernoteInsertHTML("<span style='color: #e97d23'>[]</span>")			;之前颜色#355986
		Tab & q::SendInput, {U+005B}{U+005D}
		Tab & w::SendInput, √
		Tab & e::SendInput, ×
		;Tab & r::SendInput, ●
		Tab & t::SendInput, ○
		$`::SendInput, ``
		+`::SendInput, ~{Shift}
		~^`::SendInput, ^`

		Tab & Space::controlsend, , ^{Space}, A   	;简化格式
		F1::Menu, LangRenMenu, Show
		F3::SendInput, ^!t				;批量打标签
		CapsLock & r::SendInput !vpb		;显示回收站
		~LButton & a::SendInput, ^!a	;切换账户

		;复制到当前笔记本
		F5::
		{
			SendInput, {AppsKey}c
			Sleep, 200
			SendInput, {Enter}
			return
		}

		;导出笔记
		F6::
		{
			SendInput, {AppsKey}x{Enter}
			WinWait, ahk_class #32770
			SendInput, {Enter}
			return
		}

		;加括号
		Tab & a::
		{
			Send, ^x
			Send, (%Clipboard%)
			return
		}

		;双击右键，高亮，和Firefox习惯一样
		{
			$RButton::
				CountStp := ++CountStp
				SetTimer, TimerPrtSc, 500
				Return
			TimerPrtSc:
				if CountStp > 1 ;大于1时关闭计时器
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;只按一次时执行
					SendInput, {RButton}
				if CountStp = 2 ;按两次时...
					SendInput, ^+h
				CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
				Return
		}
	}

	;颜色 字体格式等
	{
		;方框环绕
		!f::evernoteEdit("<div style='margin-top: 5px; margin-bottom: 9px; word-wrap: break-word; padding: 8.5px; border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(245, 245, 245); border: 1px solid rgba(0, 0, 0, 0.148438)'>", "</div></br>")
		;超级标题
		!s::evernoteEditText("<div style='margin:1px 0px; color:rgb(255, 255, 255); background-color:#8BAAD0; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; text-align:center;'><b>", "</b></div></br>")
		;贯穿线
		^+=::
			evernoteInsertHTML("<div style='margin: 3px 0px; border-top-width: 2px; border-top-style: solid; border-top-color: rgb(116, 98, 67); font-size: 3px'>　</div><span style='font-size: 12px'>&nbsp;</span>")
			SendInput, {Left}
			return
		;底色标题
		;!t::evernoteEditText("<div><div style='padding:0px 5px; margin:3px 0px; display:inline-block; color:rgb(255, 255, 255); text-align:center; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; background-color:#E2A55C;'>", "<br/></div><br/></div><br/>")
		;引用
		!y::evernoteEdit("<div style='margin:0.8em 0px; line-height:1.5em; border-left-width:5px; border-left-style:solid; border-left-color:rgb(127, 192, 66); padding-left:1.5em; '>", "</div>")
		/* 需要其它样式，在这里增加
		*/

		;字体白色（选中可见）
		CapsLock & w::evernoteEditText("反白可见【<span style='color: white;'>", "</span>】")

		;v6版本，鼠标点击方式，实现修改文字颜色
		evernoteMouseChangeColor(r, g, b) {
			CoordMode, Mouse, Screen	;鼠标坐标，临时采用全屏幕模式，否则鼠标不能回归原位
			MouseGetPos, xpos, ypos
			CoordMode, Mouse, Client	;鼠标坐标，返回Client模式
			IfWinActive, ahk_class ENMainFrame
			{
				Click 890, 159		;点击颜色按钮
				Click 935, 341		;点击更多颜色
				;严重依赖窗口视图相对位置，编辑区域中界限，设定为表格刚刚消失不见时的位置，接近于屏幕竖直中线
			}
			IfWinActive, ahk_class ENSingleNoteView
			{
				Click 231, 121		;点击颜色按钮
				Click 262, 304		;点击更多颜色
			}
			;SendL("M")			;进入更多颜色
			Sleep, 50
			Click, 116, 333		;进入自定义颜色
			SendInput, {Tab}{Tab}{Tab}
			SendInput %r%{Tab}%g%{Tab}%b%{Tab}{Space}
			Click, 21, 259		;点击设定好自定义颜色
			SendInput, {Tab}{Space}
			CoordMode, Mouse, Screen	;鼠标坐标，继续改回全屏幕模式，方便移动鼠标
			MouseMove, %xpos%, %ypos%, 0
			CoordMode, Mouse, Client	;鼠标坐标，继续返回Client模式
			return
		}

		{
			;字体红色
			#1::
				evernoteMouseChangeColor(240, 46, 55)
				SendInput, ^b
				return
			;字体蓝色
			#2::
				evernoteMouseChangeColor(55, 64, 230)
				SendInput, ^b
				return
			;字体灰色
			#3::
				evernoteMouseChangeColor(214, 214, 214)
				return
			;字体绿色
			#4::
				evernoteMouseChangeColor(15, 130, 15)
				SendInput, ^b
				return
			;字体白色
			#5::
				evernoteMouseChangeColor(255, 255, 255)
				return

			;周计划专用配色
			;字体橙色
			#F1::evernoteMouseChangeColor(233, 125, 35)
			;字体绿色
			#F2::evernoteMouseChangeColor(55, 64, 230)
			;字体蓝色
			#F3::evernoteMouseChangeColor(91, 133, 170)
			;字体土黄色
			#F4::evernoteMouseChangeColor(255, 188, 41)
			;字体紫色
			#F5::evernoteMouseChangeColor(194, 0, 251)
		}
	}

	;每日Todo的连续操作
	Tab & r::
	{
		Click, 1131, 500
		SendInput, ^a
		Sleep, 20
		SendInput, ^+v
		Sleep, 20
		SendInput, ^h
		Sleep, 20
		SendInput, ^a
		sendL("[]")
		Click, 982, 686
		Sleep, 400
		Click, 1181, 272
		SendInput, ^a
		SendInput, ^+c
		return
	}
}


;关闭上下文相关性，以下命令，全部针对全局
#IfWinActive
;注意以下只能写快捷键。如果写全局命令，不会被执行的。运行的命令，要写在脚本开头

