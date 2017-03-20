;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 声明：
;;; 1、用KeyTweak改键盘映射，capslock改为Numpad0了，否则做快捷键总是激活大小写
;;; 切换，很烦
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------------------------------------------------------------
;~ 脚本配置 #Include等
;-------------------------------------------------------------------------------
{
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

	Menu, Tray, Icon, %A_LineFile%\..\Icon\自定义快捷操作.ico, , 1
	Menu, tray, tip, 自定义快捷键、自动保存 by LL
	TrayTip, 提示, 脚本已启动, , 1
	Sleep, 1000
	TrayTip
	;return		;注：这里不能加return  原因搜索帮助文件的「自动执行段」

	;最近不怎么用snagit了，先去掉这行
	;Run, d:\BaiduYun\@\Software\AHKScript\_MyScript\非快捷键类 全局运行脚本（由开机脚本自动调用）.ahk
	Run, %A_LineFile%\..\3. 快捷输入.ahk

	;注意：menu菜单的定义，必须在“自动执行段”
	Menu, LangRenMenu, Add, 大厅中找房, 找狂欢版语音
	Menu, LangRenMenu, Add, 占座#9, 占座#9
	Menu, LangRenMenu, Add, 占座#10, 占座#10
	Menu, LangRenMenu, Add, 占座#18, 占座#18
	Menu, LangRenMenu, Add			; 添加分隔线
	Menu, LangRenMenu, Add, &F：快速第一个投票, 快速第一个投票
	Menu, LangRenMenu, Add, &B：全场标记村民, 全场标记村民
	Menu, LangRenMenu, Add			; 添加分隔线
	Menu, LangRenMenu, Add, &1：【踩人】, 找狼不积极
	Menu, LangRenMenu, Add, &2：【踩错不担责】, 踩错声明
	Menu, LangRenMenu, Add, &3：【先知y熊n】, 问先知熊
	Menu, LangRenMenu, Add, &4：【问归】, 问归
	Menu, LangRenMenu, Add, &5：【没时间思考】, 第一个发言没时间
	Menu, LangRenMenu, Add, &6：【不归票】, 局势焦灼
	Menu, WholeOSMenu, Add, 注册表-定位路径, 注册表-定位路径
}

;-------------------------------------------------------------------------------
;~ 函数部分
;-------------------------------------------------------------------------------
{
	;Get memory usage of Process 获取一个进程的内存占用 → 用于监控Firefox内存
	MemUsage(ProcName, Units="K") {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		SetFormat, Float, 0.0 ; round up K

		PrivateBytes := NumGet(memCounters, 40, "UInt")
		if (Units == "B")
			return PrivateBytes
		if (Units == "K")
			Return PrivateBytes / 1024
		if (Units == "M")
			Return PrivateBytes / 1024 / 1024
	}


	  ;--------------------------------------
	  ; 统计字库文字的个数和宽高，将解释文字存入数组并删除<>
	  ;--------------------------------------
	  wenzitab:=[], num:=0, wz:="", j:=""
	  fmt:=A_FormatInteger
	  SetFormat, IntegerFast, d    ; 正则表达式中要用十进制
	  Loop, Parse, wenzi, |
	  {
		v:=A_LoopField, txt:=""
		e1:=cha1, e0:=cha0
		; 用角括号输入每个字库字符串的识别结果文字
		if RegExMatch(v,"<([^>]*)>",r)
		  v:=StrReplace(v,r), txt:=r1
		; 可以用中括号输入每个文字的两个容差，以逗号分隔
		if RegExMatch(v,"\[([^\]]*)]",r)
		{
		  v:=StrReplace(v,r), r2:=""
		  StringSplit, r, r1, `,
		  e1:=r1, e0:=r2
		}
		; 记录每个文字的起始位置、宽、高、10字符的数量和容差
		v:=Trim(RegExReplace(v,"[^_0\n]+"),"`n") . "`n"
		w:=InStr(v,"`n")-1, h:=StrLen(v)//(w+1)
		re:="[0_]{" w "}\n"
		if (w>sw or h>sh or w<1 or RegExReplace(v,re)!="")
		  Continue
		v:=StrReplace(v,"`n")
		if InStr(c,"-")
		  v:=StrReplace(v,"_","1"), r:=e1, e1:=e0, e0:=r
		else
		  v:=StrReplace(StrReplace(v,"0","1"),"_","0")
		len1:=StrLen(StrReplace(v,"0"))
		len0:=StrLen(StrReplace(v,"1"))
		e1:=Round(len1*e1), e0:=Round(len0*e0)
		j.=StrLen(wz) "|" w "|" h
		  . "|" len1 "|" len0 "|" e1 "|" e0 "|"
		wz.=v, wenzitab[++num]:=Trim(txt)
	  }
	  SetFormat, IntegerFast, %fmt%
	  if wz=
		Return, 0
	  ;--------------------------------------
	  ; wz 使用Astr参数类型可以自动转为ANSI版字符串
	  ; in 输入各文字的起始位置等信息，out 返回结果
	  ; ss 等为临时内存，jiange 超过间隔就会加入*号
	  ;--------------------------------------
	  mode:=InStr(c,"**") ? 2 : InStr(c,"*") ? 1 : 0
	  c:=RegExReplace(c,"[*\-]"), jiange:=5, num*=7
	  VarSetCapacity(in,num*4,0), i:=-4
	  Loop, Parse, j, |
		if (A_Index<=num)
		  NumPut(A_LoopField, in, i+=4, "int")
	  VarSetCapacity(gs, sw*sh)
	  VarSetCapacity(ss, sw*sh, Asc("0"))
	  k:=StrLen(wz)*4
	  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
	  VarSetCapacity(out, 1024*4, 0)
	  if DllCall(&MyFunc, "int",mode, "uint",c
		, "int",jiange, "ptr",Scan0, "int",Stride
		, "int",sx, "int",sy, "int",sw, "int",sh
		, "ptr",&gs, "ptr",&ss
		, "Astr",wz, "ptr",&s1, "ptr",&s0
		, "ptr",&in, "int",num, "ptr",&out)
	  {
		ocr:="", i:=-4  ; 返回第一个文字的中心位置
		x:=NumGet(out,i+=4,"int"), y:=NumGet(out,i+=4,"int")
		w:=NumGet(out,i+=4,"int"), h:=NumGet(out,i+=4,"int")
		rx:=x+w//2, ry:=y+h//2
		While (k:=NumGet(out,i+=4,"int"))
		  v:=wenzitab[k//7], ocr.=v="" ? "*" : v
		Return, 1
	  }
	  Return, 0
	}

	MCode(ByRef code, hex)
	{
	  ListLines, Off
	  bch:=A_BatchLines
	  SetBatchLines, -1
	  VarSetCapacity(code, StrLen(hex)//2)
	  Loop, % StrLen(hex)//2
		NumPut("0x" . SubStr(hex,2*A_Index-1,2)
		  , code, A_Index-1, "char")
	  Ptr:=A_PtrSize ? "Ptr" : "UInt"
	  DllCall("VirtualProtect", Ptr,&code, Ptr
		,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
	  SetBatchLines, %bch%
	  ListLines, On
	}


	;判断当前是否为输入状态，比A_CaretX可靠性更好
	IME_GET(WinTitle="A")  {
		ControlGet,hwnd,HWND,,,%WinTitle%
		if  (WinActive(WinTitle))   {
			ptrSize := !A_PtrSize ? 4 : A_PtrSize
			VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
			NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
			hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
					 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
		}
		return DllCall("SendMessage"
			, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
			, UInt, 0x0283  ;Message : WM_IME_CONTROL
			,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
			,  Int, 0)      ;lParam  : 0
}

	;打开超链接
	openLink(before, after) {
		clipboard =
		Send, ^c
		ClipWait, 1  ; 等待剪贴板中出现文本.
		backup := clipboard	; 注意变量的两种赋值方法，或者加冒号不加百分号。或者如下面所示，加百分号不加冒号
		clipboard = %before%%clipboard%%after%
		/*WinActivate, ahk_class MozillaWindowClass
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		*/
		Run, %clipboard%
		Sleep, 500	;这里必须加个延迟，否则下一行太快执行
		clipboard = %backup%
		return
	}

	;打开伪链接
	openFakeLink(before, after) {
		clipboard =
		Send, ^c
		ClipWait, 1  ; 等待剪贴板中出现文本.
		backup := clipboard	; 注意变量的两种赋值方法，或者加冒号不加百分号。或者如下面所示，加百分号不加冒号
		clipboard = %before%%clipboard%%after%
		WinActivate, ahk_class MozillaWindowClass
		SendInput, ^t
		Sleep, 1
		SendInput, ^v{Enter}
		Sleep, 500	;这里必须加个延迟，否则下一行太快执行
		clipboard = %backup%
		return
	}

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

	;=============================================================================================================
	; Func: GetProcessMemory_Private
	; Get the number of private bytes used by a specified process.  Result is in K by default, but can also be in
	; bytes or MB.
	;
	; Params:
	;   ProcName    - Name of Process (e.g. Firefox.exe)
	;   Units       - Optional Unit of Measure B | K | M.  Defaults to K (Kilobytes)
	;
	; Returns:
	;   Private bytes used by the process
	;-------------------------------------------------------------------------------------------------------------
	GetProcessMemory_Private(ProcName, Units="K") {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		SetFormat, Float, 0.0 ; round up K

		PrivateBytes := NumGet(memCounters, 40, "UInt")
		if (Units == "B")
			return PrivateBytes
		if (Units == "K")
			Return PrivateBytes / 1024
		if (Units == "M")
			Return PrivateBytes / 1024 / 1024
	}


	;=============================================================================================================
	; Func: GetProcessMemory_All
	; Get all Process Memory Usage Counters.  Mimics what's shown in Task Manager.
	;
	; Params:
	;   ProcName    - Name of Process (e.g. Firefox.exe)
	;
	; Returns:
	;   String with all values in KB as one big string.  Use a Regular Expression to parse out the value you want.
	;-------------------------------------------------------------------------------------------------------------
	GetProcessMemory_All(ProcName) {
		Process, Exist, %ProcName%
		pid := Errorlevel

		; get process handle
		hProcess := DllCall( "OpenProcess", UInt, 0x10|0x400, Int, false, UInt, pid )

		; get memory info
		PROCESS_MEMORY_COUNTERS_EX := VarSetCapacity(memCounters, 44, 0)
		DllCall( "psapi.dll\GetProcessMemoryInfo", UInt, hProcess, UInt, &memCounters, UInt, PROCESS_MEMORY_COUNTERS_EX )
		DllCall( "CloseHandle", UInt, hProcess )

		list := "cb,PageFaultCount,PeakWorkingSetSize,WorkingSetSize,QuotaPeakPagedPoolUsage"
			  . ",QuotaPagedPoolUsage,QuotaPeakNonPagedPoolUsage,QuotaNonPagedPoolUsage"
			  . ",PagefileUsage,PeakPagefileUsage,PrivateUsage"

		n := 0
		Loop, Parse, list, `,
		{
			n += 4
			SetFormat, Float, 0.0 ; round up K
			this := A_Loopfield
			this := NumGet( memCounters, (A_Index = 1 ? 0 : n-4), "UInt") / 1024

			; omit cb
			If A_Index != 1
				info .= A_Loopfield . ": " . this . " K" . ( A_Loopfield != "" ? "`n" : "" )
		}

		Return "[" . pid . "] " . pname . "`n`n" . info ; for everything
	}
}

;-------------------------------------------------------------------------------
;~ 全局程序: 注意全局程序，必须写在#IfWinActive *前面* ，函数后面， 才能正确执行！
;-------------------------------------------------------------------------------
{
	;-------------------------------------------------------------------------------
	;~ 控制当前运行是Unicode64版,若不是则切换 (U64比U32运行更快，尽量用U64)
	;-------------------------------------------------------------------------------
	SplitPath A_AhkPath,, AhkDir
	If ( !(A_PtrSize = 4 && A_IsUnicode ) ) {
		U64 := AhkDir . "\AutoHotkeyU32.exe"
		If (FileExist(U64)) {
			Run %U64% "%A_LineFile%"
			ExitApp
		} Else {
			MsgBox 0x2010, AutoGUI, AutoHotkey 64-bit Unicode not found.
			ExitApp
		}
	}

	;-------------------------------------------------------------------------------
	;~ 自动结束 垃圾进程
	;-------------------------------------------------------------------------------
	trashProcess := ["DownloadSDKServer.exe", "SogouCloud.exe", "SpotifyWebHelper.exe"]			;目标进程名称 =
	Loop {
		For index, value in trashProcess {
			Process, Exist, %value%				;查找进程是否存在
			if ( ErrorLevel != 0 ) {
				Process, Close, %ErrorLevel%		;终止进程
				if ( ErrorLevel = 0 )
					MsgBox, 检测到垃圾进程，但我没有成功的结束它！
			}
			Sleep, 10000
		}
	}

	;-------------------------------------------------------------------------------
	;~ 自动保存pdf等
	;-------------------------------------------------------------------------------
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

;-------------------------------------------------------------------------------
;~ test部分: 检测某函数的作用，临时代码段
;-------------------------------------------------------------------------------
{

}

;-------------------------------------------------------------------------------
;~ 全局键位
;-------------------------------------------------------------------------------
{
	;临时


	;常用软件快速启动
	{
		;配合Listary快速启动
		#r::SendInput, ^!+r
		;#c::Run "d:\TechnicalSupport\ProgramFiles\babun-1.2.0\.babun\babun.bat"
		#c::Run cmd
		!#c::Run, "C:\Windows\System32\cmd.exe"
		;注意主profile不要加--no-remote，否则evernote等打开链接时，会报错「已经运行，没有响应」云云。这里不必装安装版
		#f::Run "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\firefox\firefox.exe"
		;!#f::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\UseFirefox\firefox\firefox.exe" --no-remote
		;#d::Run "D:\TechnicalSupport\ProgramFiles\GreenpcxFirefox\DevFirefox\pcxfirefox\firefox.exe" --no-remote
		;#g::Run "d:\TechnicalSupport\ProgramFiles\GoogleChrome 便携版\MyChrome for Use\MyChrome.exe"
		#g::Run "D:\TechnicalSupport\ProgramFiles\CentBrowser\chrome.exe"
		#n::Run notepad
		#z::Run "d:\TechnicalSupport\ProgramFiles\AutoHotkey\SciTE\SciTE.exe"
		;#z::Run "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\plugins\wlx\Syn2\Syn.exe" "d:\BaiduYun\@\Software\AHKScript\_MyScript\自定义快捷操作.ahk"
		#x::Run "C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE"
		;#e::Run "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe"
		#e::Run "D:\TechnicalSupport\ProgramFiles\Evernote\Evernote\Evernote.exe
		#y::Run "d:\TechnicalSupport\ProgramFiles\YodaoDict\YodaoDict.exe"
		#m::Run resmon
		;^#c::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\ColorPic 4.1  屏幕取色小插件 颜色 色彩 配色\#ColorPic.exe"
		;^#s::Run, "d:\BaiduYun\Technical Backup\ProgramFiles\#Fast Run\st.lnk"
		>!m::Run, "C:\Users\LL\AppData\Roaming\Spotify\Spotify.exe"
		~LButton & F2::SendInput, ^+!#m
		#s::
			Run sx
			Run pp
			;Run ABBYY Screenshot Reader
			return
		;录制gif
		/*#!s::
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\keycastow 显示击键按键，录制屏幕时很有用\keycastow.exe"
			Run "d:\BaiduYun\Technical Backup\ProgramFiles\#Repository\ScreenToGif 1.4.1 屏幕录制gif\$$ScreenToGif - Preview 11 屏幕录制gif.exe"
			return
			*/
		#t::
			if WinExist("ahk_class TTOTAL_CMD") {
				WinClose
			}
			WinWaitClose, ahk_class TTOTAL_CMD, , 2
			Sleep, 500
			Run, "d:\TechnicalSupport\ProgramFiles\Total Commander 8.51a\TOTALCMD.EXE"
			WinWait, ahk_class TNASTYNAGSCREEN				;自动点123
			WinGetText, Content, ahk_class TNASTYNAGSCREEN	;获取未注册提示窗口文本信息
			StringMid, Num, Content, 10, 1					;获取随机数字
			ControlSend,, %Num%, ahk_class TNASTYNAGSCREEN	;将随机数字发送到未注册提示窗口
			WinActivate, ahk_class TTOTAL_CMD
			return
		;Numpad0 & q::Run "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"
	}

	;快捷输入
	{
		Tab & s:: Send, ▶{Space}			;	右三角
		Tab & d:: Send, •{Space}			;	圆点
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
		Numpad0 & 1:: Send, ❶{Space}
		Numpad0 & 2:: Send, ❷{Space}
		Numpad0 & 3:: Send, ❸{Space}
		Numpad0 & 4:: Send, ❹{Space}
		Numpad0 & 5:: Send, ❺{Space}
		Numpad0 & 6:: Send, ❻{Space}
		Numpad0 & 7:: Send, ❼{Space}
		Numpad0 & 8:: Send, ❽{Space}

		;Tab & g:: Send, √{Space}
		;多数时候，回车紧接句号，说明前面输入的是英文，那句号应该是英文的点，所以自动修改下

		}

		#If
		*/
}

	;简单映射型 快捷键
	{
		~LButton & r::Reload
		~LButton & s::			;禁用脚本
			Suspend, On			;注意suspend必须在第一行 否则当suspend状态下，这个开关键，本身也会被禁用
			TrayTip, 提示, 已 [禁用] 脚本, , 1
			Sleep, 1000
			TrayTip
			Pause, On
			return
		~LButton & a::
			Suspend, Off
			TrayTip, 提示, 已 [启用] 脚本, , 1
			Sleep, 1000
			TrayTip
			Pause, Off
			return
		~LButton & e::
			Edit
			return

		;Ditto自动分组(快捷输入)
		!Space::^!+l

		;配合Actual Window Manager做虚拟桌面切换
		#F1::SendInput, !#{F1}
		#F2::SendInput, !#{F2}

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

	;复杂型 快捷键
	{
		注册表-定位路径:
			; 注册表的HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Applets/Regedit
			; 下的LastKey项保存了上一次浏览的注册表项位置，所以在打开注册表编辑器前修改它就行了
			InputBox, NewLastKey, 注册表自动定位工具, 请输入要定位到的路径, , 800, 130
			IfWinExist, 注册表编辑器 ahk_class RegEdit_RegEdit
			{
				WinClose
				WinWaitClose
			}
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %NewLastKey%
			If(ErrorLevel = 1)
				MsgBox failed
			Run, regedit.exe
			return


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
		~Esc::
			if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
				Send, !{F4}
			return

		;恢复Tab键原本功能
		{
			$Tab::Send, {Tab}
			LAlt & Tab::AltTab
			^Tab::Send, ^{Tab}
			^+Tab::Send, ^+{Tab}
			+Tab::SendInput, +{Tab}
		}


		;evernote新建笔记
		Numpad0 & a::SendInput, ^!n
		$F4::
			SendInput, {F4}
			WinWaitActive, ahk_class ENMainFrame, , 2
			sendL("notebook:""1  Cabinet"" ")		;注意字符中的双引号要转义，不是\"，而是两个引号""
			return
	}
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
		` & 3::SendInput, Ø{Space}
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

		^Space::controlsend, , ^{Space}, A   	;简化格式
		F1::Menu, LangRenMenu, Show
		F3::SendInput, ^!t				;批量打标签
		Numpad0 & r::SendInput !vpb		;显示回收站
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
		Numpad0 & w::evernoteEditText("反白可见【<span style='color: white;'>", "</span>】")

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
/* full_command_line := DllCall("GetCommandLine", "str")
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
; */

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
<+space::

;------------------------------------------------------------------------------------------
; switch of VPN on demand
^!9:: run D:\Program Files (x86)\vpnup.bat
^!0:: run D:\Program Files (x86)\vpndown.bat

;-----------------------------------------------------------------------------------------------------
; Quick edit
;^+!e::
;Edit
;return

;^+!r::
;Reload
;return

;------------------------------------------------------------------------
; Connect VPN
;------------------------------------------------------------------------
^+!v::
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
Sleep 10000
Send !{F4}
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
