#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;-------------------------------------------------------------------------------
;~ �ű����� #Include��
;-------------------------------------------------------------------------------
	;����������ص�����
	#NoEnv						;�����ձ����Ƿ�Ϊ��������
	;#KeyHistory 0				;����¼����log
	;ListLines Off				;����¼����log
	SetBatchLines, -1			;��֮�����в���ʱ���϶,Ĭ������10ms�ļ��
	SetKeyDelay, -1, -1			;���Ͱ�������ʱ���϶
	SetMouseDelay, -1			;ÿ������ƶ��������Զ�����ʱ=0
	SetDefaultMouseSpeed, 0		;������ Click �� MouseMove/Click/Drag ��û��ָ������ٶ�ʱʹ�õ��ٶ� = ˲���ƶ�.
	;�����ǰ¼�ƵĽű�,����ʱ���,������,���� MouseClick, MouseMove �� MouseClickDrag ���ṩ��һ��������������ٶȴ���Ĭ���ٶȵĲ���.�������Լ��Ĳ���,�趨�ƶ��ٶ�
	SetWinDelay, 0
	SetControlDelay, 0
	SendMode Input				;��˵SendInput is the fastest send method.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	#Include %A_LineFile%\..\..\Functions\WinClip\WinClipAPI.ahk
	#Include %A_LineFile%\..\..\Functions\WinClip\WinClip.ahk
	;#Include %A_LineFile%\..\..\Functions\url_encode_decode.ahk	;�ýű�������ANSI����
	#Include %A_LineFile%\..\..\Functions\TrayIcon by FanaticGuru.ahk
	#Include %A_LineFile%\..\..\Functions\WinHttpRequest ���纯�� HTTP get post\WinHttpRequest.ahk
	#Include %A_LineFile%\..\..\Functions\GetActiveBrowserURL ��ȡ��������ڵĵ�ַ ����Ϣ\GetActiveBrowserURL.ahk

	#InstallKeybdHook		;��װ���̺���깳�� ��Input��A_PriorKey������Ҫ����
	#InstallMouseHook
	SetTitleMatchMode Regex	;���Ľ���ƥ��ģʽΪ����
	#SingleInstance ignore	;�������ű��Ѿ�����ʱ�Ƿ��������ٴ����С�
	#Persistent				;�������в��˳�
	#MaxThreadsPerHotkey 5
	CoordMode, Mouse, Client	;����������Clientģʽ
	;SetCapsLockState,AlwaysOff
	CountStp := 0	;һ�����õļ�ʱ��

	#Hotstring EndChars  `n				;�༭���ִ�����ֹ��
	
	;----------------------------------------------------------------------
	;Win 10 regedit: HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer\EnableLegacyBalloonNotifications=1 
	;need to create 'Explorer' and 'Enable...=1'
	;----------------------------------------------------------------------
	Menu, Tray, Icon, %A_LineFile%\..\Icon\�Զ����ݲ���.ico, , 1
	Menu, tray, tip, �Զ����ݼ����Զ����� by LL
	TrayTip, ��ʾ, �ű�������, , 1
	Sleep, 2000
	TrayTip
	;return		;ע�����ﲻ�ܼ�return  ԭ�����������ļ��ġ��Զ�ִ�жΡ�




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
;~ ��������
;-------------------------------------------------------------------------------
	
	;Unicode���ͺ���,���ⴥ�����뷨,Ҳ����ȫ��Ӱ��
	;from [����Send ����ASCII�ַ� V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
		;MsgBox %Ord%
		inputString:=("string",string)
		Loop, Parse, %inputString%
			ascString.=(_:=%Ord%(A_LoopField))<0x100?"{ASC " _ "}":A_LoopField
		SendInput, % ascString
	}

	;evernote�༭����ǿ����
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

	;evernote������ԭ��ʽ����ǿ����
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

	;evernote��ԭ�ı��Ĳ���html��ǿ����
	evernoteInsertHTML(html)
	{
		clipboard =
		WinClip.SetHTML(html)
		Sleep, 300
		Send ^v
		Return
	}

	WinClip.GetHtml2 := Func("GetHtml2")		; Ҳ����ֱ�Ӹ���ԭ���ĺ��� -> WinClip.GetHtml := Func("GetHtml2")
	WinClip.GetHtml3 := Func("GetHtml_DOM")

	;����HTML DOM����GetHTML������ʵ��
	GetHtml_DOM(this, Encoding := "UTF-8")
	{
		html := this.GetHtml2(Encoding)
		static doc := ComObjCreate("htmlFile")
		doc.Write(html), doc.Close()
		return doc.all.tags("span")[0].InnerHtml
	}

	;WinClip��Get��UTF-8��д��֧������
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
;~ ȫ�ֳ���: ע��ȫ�ֳ��򣬱���д��#IfWinActive *ǰ��* ���������棬 ������ȷִ�У�
;-------------------------------------------------------------------------------
{

}

;-------------------------------------------------------------------------------
;~ test����: ���ĳ���������ã���ʱ�����
;-------------------------------------------------------------------------------
{

}

;-------------------------------------------------------------------------------
;~ ȫ�ּ�λ
;-------------------------------------------------------------------------------

	;��ʱ
		Tab & .:: SendL("����")
		Tab & ,:: SendL("����")
		Tab & -:: SendL(";----------------------------------------------------------------------")
	;���������������
	


	;�������
	{
		Tab & s:: Send, ?{Space}			;	������
		Tab & d:: Send, ?{Space}			;	Բ��
		;Tab & f:: Send, ��{Space}			;	����
		Tab & f:: Send, ��{Space}			;	��Բ��
		Tab & 1:: Send, ��{Space}
		Tab & 2:: Send, ��{Space}
		Tab & 3:: Send, ��{Space}
		Tab & 4:: Send, ��{Space}
		Tab & 5:: Send, ��{Space}
		Tab & 6:: Send, ��{Space}
		Tab & 7:: Send, ��{Space}
		Tab & 8:: Send, ��{Space}
		CapsLock & 1:: Send, ?{Space}
		CapsLock & 2:: Send, ?{Space}
		CapsLock & 3:: Send, ?{Space}
		CapsLock & 4:: Send, ?{Space}
		CapsLock & 5:: Send, ?{Space}
		CapsLock & 6:: Send, ?{Space}
		CapsLock & 7:: Send, ?{Space}
		CapsLock & 8:: Send, ?{Space}

		;Tab & g:: Send, ��{Space}
		;����ʱ�򣬻س����Ӿ�ţ�˵��ǰ���������Ӣ�ģ��Ǿ��Ӧ����Ӣ�ĵĵ㣬�����Զ��޸���



		#If
		*/

}

	;��ӳ���� ��ݼ�
	{
		~LButton & r::Reload
		~LButton & s::			;���ýű�
			Suspend, On			;ע��suspend�����ڵ�һ�� ����suspend״̬�£�������ؼ�������Ҳ�ᱻ����
			TrayTip, ��ʾ, �� [����] �ű�, , 1
			Sleep, 2000
			TrayTip
			Pause, On
			return
		~LButton & a::
			Suspend, Off
			TrayTip, ��ʾ, �� [����] �ű�, , 1
			Sleep, 2000
			TrayTip
			Pause, Off
			return
		~LButton & e::Edit
			

		;Ditto�Զ�����(�������)
		!Space::^!+l

		;���Actual Window Manager�����������л�
		#F1::SendInput, !#{F1}
		#F2::SendInput, !#{F2}

		;���� ���ɼ�&���0 ���ַ�
		Tab & Space:: SendInput, {U+2067}{U+2068}{U+2069}{U+206A}{U+206B}{U+206C}

		;����Щ�ַ�Ҳ���ɼ��ҿ��0���������ڱ�����network.IDN.blacklist_chars�����Ծ��������˵������� {U+115F}{U+1160}{U+200B}{U+1160}{U+115F}{U+2001}{U+2002}{U+2003}{U+2004}{U+2005}{U+2006}{U+2007}{U+2008}{U+2009}{U+200A}{U+200B}{U+2028}{U+2029}{U+202F}{U+205F}{U+3000}{U+3164}{U+FEFF}
		;���� ���ɼ�&��ȷ�0 ���ַ�
		CapsLock & Space:: SendInput, {U+115A}{U+115B}{U+115C}{U+115D}{U+115E}{U+11A3}{U+11A4}{U+11A5}{U+11A6}{U+11A7}
		;���� �������ɼ� ���ַ�
		Tab & p:: SendInput, {U+06E4}{U+115B}{U+115C}{U+115D}{U+115E}

		;��farbox web editor�п������meta��Ϣ
		Tab & b:: SendInput, {Shift}Title{U+003A}{Space}{Enter}Tags{U+003A}{Space}��ǩ1{U+002C}{Space}��ǩ2{Enter}Status{U+003A}{Space}draft{U+002F}public{Enter}URL{U+003A} this-is-my-first-post
	}

	;������ ��ݼ�
	{
		
		!c::
			MouseGetPos, xpos, ypos 				;�������λ��
			TrayIcon_Button("cow-taskbar.exe", "R")
			MouseMove, 20, 50,, R
			Sleep, 500
			MouseClick, left
			TrayIcon_Button("cow-taskbar.exe", "R")
			Sleep, 1000
			MouseMove, 20, 40,, R
			MouseClick, left
			MouseMove, xpos, ypos					;�ָ����λ��
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



		;˫��esc�˳��������
		;~Esc::
		;	if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
		;		Send, !{F4}
		;	return

		;�ָ�Tab��ԭ������,����Ҫ����tab��Ϊfnһ���İ�������Ϊ������ȷʵû�ж���İ����������������ˡ���Caps lock�Ѿ������ƶ����������ˣ�
		{
			$Tab::Send, {Tab}
			LAlt & Tab::AltTab
			^Tab::Send, ^{Tab}
			^+Tab::Send, ^+{Tab}
			+Tab::SendInput, +{Tab}
		}


		;evernote�½��ʼ�
		LButton & w::SendInput, ^!n
		$F4::
			SendInput, {F4}
			WinWaitActive, ahk_class ENMainFrame, , 2
			sendL("notebook:""1  Cabinet"" ")		;ע���ַ��е�˫����Ҫת�壬����\"��������������""
			return

}

;-------------------------------------------------------------------------------
;~ Evernote��ݼ�
;-------------------------------------------------------------------------------
#IfWinActive ahk_class (ENSingleNoteView|ENMainFrame)
{
	;��ݼ�: �Ǳ༭������
	{

		;en��������֧�������ַ����ؿ��������Щ������ĸ���Ա���֧�������ַ�
		` & 1::SendInput, {U+0069}{U+006E}{U+0074}{U+0069}{U+0074}{U+006C}{U+0065}{U+003A}		;����intitle:��Ϊ�˱������뷨Ӱ�죬��unicode����
		` & 2::SendInput, ��{Space}
		` & 3::SendInput, ?{Space}
		` & d::SendInput, ^;			;���ٲ�������ʱ��
		;Tab & q::evernoteInsertHTML("<span style='color: #e97d23'>[]</span>")			;֮ǰ��ɫ#355986
		Tab & q::SendInput, {U+005B}{U+005D}
		Tab & w::SendInput, ��
		Tab & e::SendInput, ��
		;Tab & r::SendInput, ��
		Tab & t::SendInput, ��
		$`::SendInput, ``
		+`::SendInput, ~{Shift}
		~^`::SendInput, ^`

		Tab & Space::controlsend, , ^{Space}, A   	;�򻯸�ʽ
		F1::Menu, LangRenMenu, Show
		F3::SendInput, ^!t				;�������ǩ
		CapsLock & r::SendInput !vpb		;��ʾ����վ
		~LButton & a::SendInput, ^!a	;�л��˻�

		;���Ƶ���ǰ�ʼǱ�
		F5::
		{
			SendInput, {AppsKey}c
			Sleep, 200
			SendInput, {Enter}
			return
		}

		;�����ʼ�
		F6::
		{
			SendInput, {AppsKey}x{Enter}
			WinWait, ahk_class #32770
			SendInput, {Enter}
			return
		}

		;������
		Tab & a::
		{
			Send, ^x
			Send, (%Clipboard%)
			return
		}

		;˫���Ҽ�����������Firefoxϰ��һ��
		{
			$RButton::
				CountStp := ++CountStp
				SetTimer, TimerPrtSc, 500
				Return
			TimerPrtSc:
				if CountStp > 1 ;����1ʱ�رռ�ʱ��
					SetTimer, TimerPrtSc, Off
				if CountStp = 1 ;ֻ��һ��ʱִ��
					SendInput, {RButton}
				if CountStp = 2 ;������ʱ...
					SendInput, ^+h
				CountStp := 0 ;���Ѽ�¼�ı�������Ϊ0,���´μ�¼.
				Return
		}
	}

	;��ɫ �����ʽ��
	{
		;������
		!f::evernoteEdit("<div style='margin-top: 5px; margin-bottom: 9px; word-wrap: break-word; padding: 8.5px; border-top-left-radius: 4px; border-top-right-radius: 4px; border-bottom-right-radius: 4px; border-bottom-left-radius: 4px; background-color: rgb(245, 245, 245); border: 1px solid rgba(0, 0, 0, 0.148438)'>", "</div></br>")
		;��������
		!s::evernoteEditText("<div style='margin:1px 0px; color:rgb(255, 255, 255); background-color:#8BAAD0; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; text-align:center;'><b>", "</b></div></br>")
		;�ᴩ��
		^+=::
			evernoteInsertHTML("<div style='margin: 3px 0px; border-top-width: 2px; border-top-style: solid; border-top-color: rgb(116, 98, 67); font-size: 3px'>��</div><span style='font-size: 12px'>&nbsp;</span>")
			SendInput, {Left}
			return
		;��ɫ����
		;!t::evernoteEditText("<div><div style='padding:0px 5px; margin:3px 0px; display:inline-block; color:rgb(255, 255, 255); text-align:center; border-top-left-radius:5px; border-top-right-radius:5px; border-bottom-right-radius:5px; border-bottom-left-radius:5px; background-color:#E2A55C;'>", "<br/></div><br/></div><br/>")
		;����
		!y::evernoteEdit("<div style='margin:0.8em 0px; line-height:1.5em; border-left-width:5px; border-left-style:solid; border-left-color:rgb(127, 192, 66); padding-left:1.5em; '>", "</div>")
		/* ��Ҫ������ʽ������������
		*/

		;�����ɫ��ѡ�пɼ���
		CapsLock & w::evernoteEditText("���׿ɼ���<span style='color: white;'>", "</span>��")

		;v6�汾���������ʽ��ʵ���޸�������ɫ
		evernoteMouseChangeColor(r, g, b) {
			CoordMode, Mouse, Screen	;������꣬��ʱ����ȫ��Ļģʽ��������겻�ܻع�ԭλ
			MouseGetPos, xpos, ypos
			CoordMode, Mouse, Client	;������꣬����Clientģʽ
			IfWinActive, ahk_class ENMainFrame
			{
				Click 890, 159		;�����ɫ��ť
				Click 935, 341		;���������ɫ
				;��������������ͼ���λ�ã��༭�����н��ޣ��趨Ϊ���ո���ʧ����ʱ��λ�ã��ӽ�����Ļ��ֱ����
			}
			IfWinActive, ahk_class ENSingleNoteView
			{
				Click 231, 121		;�����ɫ��ť
				Click 262, 304		;���������ɫ
			}
			;SendL("M")			;���������ɫ
			Sleep, 50
			Click, 116, 333		;�����Զ�����ɫ
			SendInput, {Tab}{Tab}{Tab}
			SendInput %r%{Tab}%g%{Tab}%b%{Tab}{Space}
			Click, 21, 259		;����趨���Զ�����ɫ
			SendInput, {Tab}{Space}
			CoordMode, Mouse, Screen	;������꣬�����Ļ�ȫ��Ļģʽ�������ƶ����
			MouseMove, %xpos%, %ypos%, 0
			CoordMode, Mouse, Client	;������꣬��������Clientģʽ
			return
		}

		{
			;�����ɫ
			#1::
				evernoteMouseChangeColor(240, 46, 55)
				SendInput, ^b
				return
			;������ɫ
			#2::
				evernoteMouseChangeColor(55, 64, 230)
				SendInput, ^b
				return
			;�����ɫ
			#3::
				evernoteMouseChangeColor(214, 214, 214)
				return
			;������ɫ
			#4::
				evernoteMouseChangeColor(15, 130, 15)
				SendInput, ^b
				return
			;�����ɫ
			#5::
				evernoteMouseChangeColor(255, 255, 255)
				return

			;�ܼƻ�ר����ɫ
			;�����ɫ
			#F1::evernoteMouseChangeColor(233, 125, 35)
			;������ɫ
			#F2::evernoteMouseChangeColor(55, 64, 230)
			;������ɫ
			#F3::evernoteMouseChangeColor(91, 133, 170)
			;��������ɫ
			#F4::evernoteMouseChangeColor(255, 188, 41)
			;������ɫ
			#F5::evernoteMouseChangeColor(194, 0, 251)
		}
	}

	;ÿ��Todo����������
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


;�ر�����������ԣ��������ȫ�����ȫ��
#IfWinActive
;ע������ֻ��д��ݼ������дȫ��������ᱻִ�еġ����е����Ҫд�ڽű���ͷ

