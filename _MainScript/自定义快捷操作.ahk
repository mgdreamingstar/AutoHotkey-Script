;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 声明：
;;; 1、用KeyTweak改键盘映射，capslock改为Numpad0了，否则做快捷键总是激活大小写
;;; 切换，很烦
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include %A_LineFile%\..\..\Library\WinClipAPI.ahk
#Include %A_LineFile%\..\..\Library\WinClip.ahk
;#Include %A_LineFile%\..\..\Library\url_encode_decode.ahk	;该脚本必须以ANSI运行

SetTitleMatchMode Regex	;更改进程匹配模式为正则
#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
#Persistent				;持续运行不退出
#MaxThreadsPerHotkey 5
;SetCapsLockState,AlwaysOff
CountStp := 0	;一键多用的计时器

Menu, Tray, Icon, %A_LineFile%\..\..\icon\自定义快捷操作.ico, , 1
Menu, tray, tip, 自定义快捷键、自动保存 by LL

;-------------------------------------------------------------------------------
;~ 预处理部分
;-------------------------------------------------------------------------------
{
	;控制当前运行是Unicode版,若不是则切换
	SplitPath A_AhkPath,, AhkDir
	If (A_PtrSize = 8 || !A_IsUnicode) {
		U32 := AhkDir . "\AutoHotkeyU32.exe"
		If (FileExist(U32)) {
			Run %U32% %A_LineFile%
			ExitApp
		} Else {
			MsgBox 0x2010, AutoGUI, AutoHotkey 32-bit Unicode not found.
			ExitApp
		}
	}
}

;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
{
	;Unicode发送函数,避免触发输入法,也不受全角影响
	;from [辅助Send 发送ASCII字符 V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
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
		ClipWait, ,
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
		Send ^v
		;BlockInput Off
		Return
	}
	
	;evernote不保留原格式，增强函数
	evernoteEditText(eFoward, eEnd)
	{
		clipboard =
		Send ^c
		ClipWait, ,
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
	ActiveFolderPath(WinTitle="A")
	{
		WinGetClass Class, %WinTitle%
		If (Class ~= "Progman|WorkerW") ;desktop
			WinPath := A_Desktop
		;Else If (Class ~= "(Cabinet|Explore)WClass") ;all other Explorer windows
		Else ;all other windows
		{
			WinGetText, WinPath, A
			RegExMatch(WinPath, "地址:.*", WinPath)
			WinPath := RegExReplace(WinPath, "地址: ") ;remove "Address: " part
		}

		WinPath := RegExReplace(WinPath, "\\+$") ;remove single or double  trailing backslash
		If WinPath ;if path not empty, append single backslash
			WinPath .= "\"
		Return WinPath
	}
}

;-------------------------------------------------------------------------------
;~ 全局键位
;-------------------------------------------------------------------------------
{	
	;常用软件快速启动
	{
		;配合Listary快速启动
		#r::SendInput, ^!+r
		#c::Run "d:\TechnicalSupport\ProgramFiles\babun-1.2.0\.babun\babun.bat"
		;注意主profile不要加--no-remote，否则evernote等打开链接时，会报错「已经运行，没有响应」云云。这里不必装安装版
		#f::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\UseFirefox\firefox\firefox.exe"
		#d::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\DevFirefox\pcxfirefox\firefox.exe" --no-remote
		;#g::Run "d:\TechnicalSupport\ProgramFiles\GoogleChrome 便携版\MyChrome for Use\MyChrome.exe"
		#g::Run "d:\TechnicalSupport\ProgramFiles\GoogleChrome 便携版\MyChrome for Dev\MyChrome.exe"
		#n::Run notepad
		#z::Run "d:\TechnicalSupport\ProgramFiles\AutoHotkey\SciTE\SciTE.exe"
		;#z::Run "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\plugins\wlx\Syn2\Syn.exe" "d:\BaiduYun\@\Software\AHKScript\_MainScript\自定义快捷操作.ahk"
		#x::Run "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE"
		#e::Run "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe"
		#y::Run "d:\TechnicalSupport\ProgramFiles\YodaoDict\YodaoDict.exe"
		#m::Run resmon
		#!c::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\ColorPic 4.1  屏幕取色小插件 颜色 色彩 配色\#ColorPic.exe"
		^#s::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\#Fast Run\st.lnk"
		>!m::Run, "C:\Users\LL\AppData\Roaming\Spotify\Spotify.exe"
		#s::
			Run sx
			Run pp
			return
		;录制gif
		#!s::
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\keycastow 显示击键按键，录制屏幕时很有用\keycastow.exe"
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\#Repository\ScreenToGif 1.4.1 屏幕录制gif\$$ScreenToGif - Preview 9 屏幕录制gif.exe"
			return
		#t::
			if WinExist("ahk_class TTOTAL_CMD") {
				WinClose
			}
			;Sleep, 500
			Run, tc
			WinWait, ahk_class TNASTYNAGSCREEN				;自动点123
			WinGetText, Content, ahk_class TNASTYNAGSCREEN	;获取未注册提示窗口文本信息
			StringMid, Num, Content, 10, 1					;获取随机数字
			ControlSend,, %Num%, ahk_class TNASTYNAGSCREEN	;将随机数字发送到未注册提示窗口
			WinActivate, ahk_class TTOTAL_CMD
			return
		Numpad0 & q::Run "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
	}

	;快捷输入
	{
		::b\::bootislands
		;用unicode方式，以免触发输入法
		:*:b@\::{U+0062}{U+006F}{U+006F}{U+0074}{U+0069}{U+0073}{U+006C}{U+0061}{U+006E}{U+0064}{U+0073}{U+0040}{U+0031}{U+0036}{U+0033}{U+002E}{U+0063}{U+006F}{U+006D}
		:*:bg\::{shift}bootislands@gmail.com
		:*:r@\::riverno@gmail.com
		:*:rg\::riverno@gmail.com
		:*:q@\::{shift}1755381995@qq.com
		:*:bo\::bootislands
		::ahk::AutoHotkey
		:*:yjt\:: ⇒{Space}					;	右箭头
		Tab & s:: Send, ▶{Space}			;	右三角
		Tab & d:: Send, •{Space}			;	圆点
		Tab & f:: Send, ■{Space}			;	方点
		Tab & 1:: Send, ❶{Space}
		Tab & 2:: Send, ❷{Space}
		Tab & 3:: Send, ❸{Space}
		Tab & 4:: Send, ❹{Space}
		Tab & 5:: Send, ❺{Space}
		Tab & 6:: Send, ❻{Space}
		Tab & 7:: Send, ❼{Space}
		Tab & 8:: Send, ❽{Space}
		Tab & 9:: Send, ❾{Space}
		Tab & 0:: Send, ❿{Space}
		;Tab & g:: Send, √{Space}

		::sof::stackoverflow
		
		~LButton & s::Suspend
		~LButton & r::Reload
		~LButton & p::Pause


		;输入 不可见&宽度0 的字符
		Tab & Space:: SendInput, {U+2067}{U+2068}{U+2069}{U+206A}{U+206B}{U+206C}
		;还有些字符也不可见且宽度0，但是由于被列入network.IDN.blacklist_chars，所以经常被过滤掉，例如 {U+115F}{U+1160}{U+200B}{U+1160}{U+115F}{U+2001}{U+2002}{U+2003}{U+2004}{U+2005}{U+2006}{U+2007}{U+2008}{U+2009}{U+200A}{U+200B}{U+2028}{U+2029}{U+202F}{U+205F}{U+3000}{U+3164}{U+FEFF}
		;输入 不可见&宽度非0 的字符
		Numpad0 & Space:: SendInput, {U+115A}{U+115B}{U+115C}{U+115D}{U+115E}{U+11A3}{U+11A4}{U+11A5}{U+11A6}{U+11A7}
		;输入 几乎不可见 的字符
		Tab & p:: SendInput, {U+06E4}{U+115B}{U+115C}{U+115D}{U+115E}
		
		;在farbox web editor中快捷输入meta信息
		Tab & b:: SendInput, {Shift}Title{U+003A}{Space}{Enter}Tags{U+003A}{Space}标签1{U+002C}{Space}标签2{Enter}Status{U+003A}{Space}draft{U+002F}public{Enter}URL{U+003A} this-is-my-first-post
	}
	
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
	Tab & o::SendInput, {Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Space}{Tab}{Tab}{Space}{Tab}{Tab}{Space}
	
	
	
	;双击esc退出焦点程序
	~Esc::
	{
		if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
			Send, !{F4}
		return
	}

	;配合snagit，单击prtsc截屏；双击prtsc5秒延迟截屏
	{
		$PrintScreen::
			CountStp := ++CountStp
			SetTimer, TimerPrtSc, 500
			Return
		TimerPrtSc:
			if CountStp > 1 ;大于1时关闭计时器
				SetTimer, TimerPrtSc, Off
			if CountStp = 1 ;只按一次时执行
				Send, {PrintScreen}
			if CountStp = 2 ;按两次时...
				Send, ^+!{PrintScreen}
			CountStp := 0 ;最后把记录的变量设置为0,于下次记录.
			Return
	}


	;恢复Tab键原本功能
	{
		$Tab::Send, {Tab}
		LAlt & Tab::AltTab
		^Tab::Send, ^{Tab}
		^+Tab::Send, ^+{Tab}
	}
	
	;配合有道词典取词
	~LWin:: Send, {LControl}{LControl}
	
	;豆瓣搜索
	Numpad0 & d::
	{
		clipboard = 
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		clipboard = http://book.douban.com/subject_search?search_text=%clipboard%&cat=1001
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
	
	;谷歌搜索
	Numpad0 & g::
	{
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		clipboard = https://www.google.com/search?newwindow=1&site=&source=hp&q=%clipboard%&=&=&oq=&gs_l=
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
	
	;快速打开复制的链接
	Numpad0 & f::
	{
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		clipboard = http://%clipboard%
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
	
	;快速查词
	Numpad0 & e::
	{
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		clipboard = http://dict.youdao.com/search?q=%clipboard%
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
	
	;配合anki收集
	Numpad0 & s::
	{
		WinActivate, ahk_exe anki.exe
		SendInput, a
		return
	}
	
	;evernote新建笔记
	Numpad0 & a::SendInput, ^!n
	$F4::
		SendInput, {F4}
		Sleep, 200
		SendInput, {U+006E}{U+006F}{U+0074}{U+0065}{U+0062}{U+006F}{U+006F}{U+006B}{U+003A}{U+0022}{U+0031}{U+0020}{U+0020}{U+0043}{U+0061}{U+0062}{U+0069}{U+006E}{U+0065}{U+0074}{U+0022}{U+0020}
		return

}

;-------------------------------------------------------------------------------
;~ Evernote快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class (ENSingleNoteView|ENMainFrame)
{
	;en的搜索不支持特殊字符，特快捷输入这些国际字母，以变相支持特殊字符
	` & 1::SendInput, {U+0069}{U+006E}{U+0074}{U+0069}{U+0074}{U+006C}{U+0065}{U+003A}		;输入intitle:，为了避免输入法影响，用unicode输入
	` & 2::SendInput, Δ{Space}
	` & 3::SendInput, Ø{Space}
	` & d::SendInput, ^;			;快速插入日期时间
	Tab & q::evernoteInsertHTML("<span style='color: #e97d23'>[]</span>")			;之前颜色#355986
	;Tab & q::SendInput, {U+005B}{U+005D}
	Tab & w::SendInput, √
	Tab & e::SendInput, ×
	Tab & r::SendInput, ●
	Tab & t::SendInput, ○
	$`::SendInput, ``
	+`::SendInput, ~{Shift}
	~^`::SendInput, ^`
	
	F3::SendInput, ^!t			;批量打标签
	
	;显示回收站
	Numpad0 & r::SendInput !vpb
	
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
		Sleep, 200
		SendInput, {Enter}
		return
	}
	
	;简化格式
	F1::SendInput, !oSS{Enter}
	
	;加括号
	Tab & a::
	{
		Send, ^x
		Send, (%Clipboard%)
		return
	}
	
	;字体红色
	#1::evernoteEditText("<div style='color: #F02E37;'><b>", "</b></div>")
	;字体绿色
	#4::evernoteEditText("<div style='color: #0F820F;'><b>", "</b></div>")
	;字体灰色
	#3::evernoteEditText("<div style='color: #D6D6D6;'>", "</div>")
	;字体蓝色
	#2::evernoteEditText("<div style='color: #3740E6;'><b>", "</b></div>")
	;字体白色（选中可见）
	Numpad0 & w::evernoteEditText("↓反白可见<div style='color: white;'>", "</div>&nbsp;&nbsp;↑")
	;背景色黄色
	!1::evernoteEdit("<div style='background: #FFFAA5;'>", "</div>")
	;背景色蓝色
	!2::evernoteEdit("<div style='background: #ADD8E6;'>", "</div>")		;不要蓝色#ADD8E6
	;背景色灰色
	!3::evernoteEdit("<div style='background: #D3D3D3;'>", "</div>")
	;背景色绿色
	!4::evernoteEdit("<div style='background: #90EE90;'>", "</div>")		;原颜色#FFD796
	;方框环绕
	!f::evernoteEdit("<div style='margin-top: 5px; margin-bottom: 9px; word-wrap: break-word; padding: 8.5px; border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(245, 245, 245); border: 1px solid rgba(0, 0, 0, 0.148438)'>", "</div></br>")
	;超级标题
	!s::evernoteEditText("<div style='margin:1px 0px; color:rgb(255, 255, 255); background-color:#8BAAD0; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; text-align:center;'><b>", "</b></div></br>")
	;贯穿线
	;^+=::evernoteInsertHTML("<div style='margin: 3px 0px; border-top-width: 2px; border-top-style: solid; border-top-color: rgb(116, 98, 67); font-size: 3px'>　</div></br>")	
	;底色标题
	;!t::evernoteEditText("<div><div style='padding:0px 5px; margin:3px 0px; display:inline-block; color:rgb(255, 255, 255); text-align:center; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; background-color:#E2A55C;'>", "<br/></div><br/></div><br/>")
	;引用
	!y::evernoteEdit("<div style='margin:0.8em 0px; line-height:1.5em; color:rgb(170, 170, 170); border-left-width:5px; border-left-style:solid; border-left-color:rgb(127, 192, 66); padding-left:1.5em; '>", "</div>")
	/* 需要其它样式，在这里增加 
	*/	
	
	;周计划专用配色
	;字体橙色
	#F1::evernoteEditText("<div style='color: #0F820F;'>", "</div>")
	;字体绿色
	#F2::evernoteEditText("<div style='color: #e97d23;'>", "</div>")
	;字体蓝色
	#F3::evernoteEditText("<div style='color: #5B85AA;'>", "</div>")
	;字体土黄色
	#F4::evernoteEditText("<div style='color: #E1BC29;'>", "</div>")
	;字体紫色
	#F5::evernoteEditText("<div style='color: #C200FB;'>", "</div>")
}

;-------------------------------------------------------------------------------
;~ Explorer快捷键
;-------------------------------------------------------------------------------
#IfWinActive, ahk_class (Progman|WorkerW|CabinetWClass|ExploreWClass|#32770|Clover_WidgetWin_0)
{
	;复制路径
	^1::	clipboard := ActiveFolderPath("")

	;复制文件名
	^2::	
	{
		send ^c
		sleep,200
		clipboard = %clipboard%
		SplitPath, clipboard, name
		clipboard = %name%
		return
	}

	;复制含文件名的完整路径
	^3::	
	{
		send ^c
		sleep,200
		clipboard = %clipboard%
		return
	}
	
	;tc中打开同路径目录
	^Up::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, ,
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="%Clipboard%"
		return
	}
	
	;tc中打开沙盘中的同路径
	^Down::
	{
		clipboard =
		clipboard := ActiveFolderPath("")
		ClipWait, ,
		StringReplace, clipboard, clipboard, :
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /L="d:\TechnicalSupport\Sandbox\LiLong\UnstableSoftware\drive\%Clipboard%"
		return
	}
}

;-------------------------------------------------------------------------------
;~ Anki快捷键
;-------------------------------------------------------------------------------
#IfWinActive, ahk_exe anki.exe
{
	;新建cloze
	F1::
		Send, ^+c
		return
	
	;新建cloze，序号不增加
	F2::
		Send, ^+!c
		return
	
	;增量阅读，把透析的快捷键，改变成`
	`::
		Send, ^+!q
		return
		
	;增量阅读，添加为析取qa后，自动关闭，方便下一次析取
	^Enter::
		Send, ^{Enter}
		sleep, 300
		Send, {Esc}
		return
		
	;快速格式化笔记
	F3::
		SendInput, {F7}
		SendInput, ^b
		return
		
	F4::SendInput {F8}
	
	` & 1::	SendInput, ^+!c{Left}{Left}{U+003A}{U+003A}简要复述
	
	;Brower中预览卡片
	Numpad0 & q::SendInput, ^+p
}


;-------------------------------------------------------------------------------
;~ cmd快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class ConsoleWindowClass
{
	~Esc::
	{
		if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
		{
			WinClose A ;这里的大写字母A已经表示了当前激活的窗口,不必更改!
		}
		return
	}
}

;-------------------------------------------------------------------------------
;~ M$ Word快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class OpusApp
{
	;导航窗格的开关，需要先在word里将导航窗格的快捷键指定为^!+p
	F1::
	{
		Send, ^!+p
		return
	}
	
	`::
		Send, ^!m
		return
}

;-------------------------------------------------------------------------------
;~ MLO快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class TfrmMyLifeMain
{
	;mlo的备注不支持中文路径的超链接，因此加这个脚本
	F1::
	{
		Send ^c
		Run %clipboard%
		Return
	}
}

;-------------------------------------------------------------------------------
;~ totalcmd快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class TTOTAL_CMD
{
	/*;为熟悉vim 屏蔽方向键
	{
		Up::
		Down::
		Left::
		Right:: return
	}
	*/
	
	;关闭当前标签
	`::Send, ^w

	;在win7自带资源管理器中打开同路径
	^Up::
		Send, ^1
		Run, %Clipboard%
		return
	
	;在对侧窗口打开沙盘中同路径
	^Down::
		Send, ^1
		StringReplace, clipboard, clipboard, :
		Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE" /O /T /S /R="d:\TechnicalSupport\Sandbox\LiLong\UnstableSoftware\drive\%Clipboard%"
		return
}

;-------------------------------------------------------------------------------
;~ farbox editor快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class QWidget
{
	;^m::
	;send, Tags: 1, 2{Enter}Status: draft
;status: draft
;title: 
;tags: 
}

;-------------------------------------------------------------------------------
;~ potplayer快捷键
;-------------------------------------------------------------------------------
/*#IfWinActive ahk_class PotPlayer64
{
	;为熟悉vim 屏蔽方向键
	{
		Up::
		Down::
		Left::
		Right:: return
	}
}
*/

;-------------------------------------------------------------------------------
;~ acrobat dc快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class AcrobatSDIWindow
{
	;acrobat dc中划词取词失效，改用剪贴板取词
	~LWin:: 
	{
		Send, ^c
		timeNow:=A_TickCount
		while(A_TickCount - timeNow < 500) 				;等1秒钟，
		{
			IfWinExist, ahk_class #32770				;期间出现ahk_class #32770的弹窗
			{
				;WinActivate  ; 自动使用上面找到的窗口.
				Send, {Space}
				return
			}
		}
		return
	}
	
	;修改批注颜色 公用代码函数
	changebg(r, g, b)
	{
		SendInput {RButton}H{RButton}P{Enter}{Down}{Down}{Down}{Down}{Down}{Down}{Enter}
		Sleep, 600
		SendInput {Tab}{Tab}{Tab}{Tab}{Tab}{Tab}{Tab}%r%{Tab}%g%{Tab}%b%{Enter}{Tab}{Tab}{Tab}{Tab}{Tab}{Enter}
		return
	}
	;批注颜色list
	!1::changebg(157, 205, 120)				;绿		#9DCD78，重点
	!2::changebg(135, 201, 217)				;蓝		#87C9D9，
	!3::changebg(241, 202, 93)				;橙		#F1CA5D，
	!4::changebg(255, 138, 128)				;暖红	#FF8A80，
	!5::changebg(185, 192, 199)				;灰		#B9C0C7，最不重要，说明
	;!`::changebg(255, 255, 115)			;黄		#FFFF73，普通批注，acrobat默认，不必设快捷键
	;按住右键，点左键，则普通批注
	MButton::SendInput, {AppsKey}H
	;备用色
	;!1::changebg(205, 164, 133)				;驼色#CDA485，
	
	;双击鼠标左键，自动取词
	/*$RButton::
		SendInput, {RButton}y
		Sleep, 200
		Send {BackSpace}
		
		timeNow:=A_TickCount
		while(A_TickCount - timeNow < 500) 			;等1秒钟，
		{
			IfWinExist, ahk_class #32770				;期间出现ahk_class #32770的弹窗
			{
				;WinActivate  ; 自动使用上面找到的窗口.
				Send, {Space}
				return
			}
		}	
	return
	*/
}

;-------------------------------------------------------------------------------
;~ Firefox快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class MozillaWindowClass
{
	F1::Send, ^+{Tab}	;切换到前一标签
	F2::Send, ^{Tab}	;切换到后一标签
	F3::Send, ^!b		;配合diigo的侧边栏
	$`::Send, ^w		;关闭当前标签
	` & 1::Send, ^+t	;撤销关闭标签
	~^`::Send, ^`		;恢复Ditto本来功能
	!`::Send, ``		;恢复本来的`功能
	^b::Send, ^t^v{Enter}		;快捷打开复制的网址
	
	;某些网页，单击win造成的双击ctrl，会触发js，导致win+a印象笔记摘录失效，所以这里屏蔽一下，改成单击ctrl
	~LWin:: SendInput, {LControl}
	
	Numpad0 & w::
	{
		clipboard = 
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		clipboard = http://zh.wikipedia.org/w/index.php?search=%clipboard%
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}
	
	Numpad0 & q::
	{
		clipboard = 
		Send, ^c
		ClipWait  ; 等待剪贴板中出现文本.
		;str := urlencode(clipboard)
		;clipboard = http://book.szdnet.org.cn/search?Field=all&channel=search&sw=%str%
		clipboard = http://book.szdnet.org.cn/search?Field=all&channel=search&sw=%clipboard%
		WinActivate, ahk_exe firefox.exe
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		return
	}

	;还没想好怎么做
	;自动判断是否选中文本，否的话，替换复制为全选+复制
	;^c::
	;	ControlGet,text,selected,,edit1 ;获取选中的文本
	;	if text=
	;		
	;	return 
}

;-------------------------------------------------------------------------------
;~ google chrome快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_class Chrome_WidgetWin_1
{
	F1::Send, ^+{Tab}	;切换到前一标签
	F2::Send, ^{Tab}	;切换到后一标签
	F3::Send, ^!b		;配合diigo的侧边栏
	$`::Send, ^w		;关闭当前标签
	~^`::Send, ^`
	!`::Send, ``		;恢复本来的`功能
	^b::				;快捷打开复制的网址
		Send, ^t
		Send, ^v
		Send, {Enter}
		return	
	
	;以下都是针对 fe开发 的快捷键
	{
		;快捷输入console.log();
		` & 1:: SendInput, {U+0063}{U+006F}{U+006E}{U+0073}{U+006F}{U+006C}{U+0065}{U+002E}{U+006C}{U+006F}{U+0067}{U+0028}{U+0029}{U+003B}{Left}{Left}
		
		;增加console多行模式的支持
		;$Enter::SendInput, +{Enter}
		;$^Enter::SendInput, {Enter}
		
		;tab
		;Tab::SendInput, {Space}{Space}{Space}{Space}
	
	}
}

;-------------------------------------------------------------------------------
;~ sublime text 3 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe sublime_text.exe
{	
	;屏蔽全局快捷键 双击esc退出
	~Esc::Send, {Esc}
	
	;用Capslock键 替代 Esc键，配合vim
	Numpad0::Send, {ESC}
	
	Numpad0 & q::SendInput ^!v

	;添加笔记型 注释
	F1::SendL("@note: ")
}

;-------------------------------------------------------------------------------
;~ OneNote 快捷键
;-------------------------------------------------------------------------------
#IfWinActive ahk_exe ONENOTE.EXE
{
	;浏览模式
	F2::
		SendInput, !d
		Sleep, 100
		SendInput, h{F11}
		return
	;编辑模式
	F1::
		SendInput, !d
		Sleep, 100
		SendInput, t{F11}
		return
	
	;给container加背景色：先转成表格，再给单元格加背景色
	Tab & q::
		SendInput, !n
		;Sleep, 50
		SendInput, t{Enter}
		Sleep, 200
		SendInput, {Alt}
		;Sleep, 50
		SendInput, jlh
		;Sleep, 50
		SendInput, {Alt}jlg
		return
}

;-------------------------------------------------------------------------------
;~ 在"另存为""保存"等窗口，配合Listary进行快速穿越快捷键
;-------------------------------------------------------------------------------
/*#IfWinActive ahk_class #32770
{
	Numpad0 & a::SendInput, #o
}
*/


;-------------------------------------------------------------------------------
;~ 自动保存
;-------------------------------------------------------------------------------
{
	窗口1上次保存时间:=A_TickCount-30*1000    ;使下面立即开始检测
	
	SetTimer, 自动保存, 5000  ;5秒钟检测一次，刚好可检测5秒内有没有键盘和鼠标操作
	Return

	; 自动保存函数
	自动保存:
	当前时间:=A_TickCount
	; 如果存在该窗口，且距离上次保存已有5min
	if WinExist("ahk_exe Acrobat.exe") and (当前时间-窗口1上次保存时间>120*1000)
	{
		; 窗口没有激活；或激活了但距离上次用户操作已有5s
		if !WinActive() or ( WinActive() and (A_TimeIdlePhysical>5000) )
		{
			ControlSend, ahk_parent, {Control Down}s{Control Up}, ahk_exe Acrobat.exe
			窗口1上次保存时间:=当前时间
		}
	}
}

