;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Google中译英，英译汉
; 能自动识别中英文
; 
; Enter: 翻译
; Ctrl + Enter: 文本换行
; F1: 朗读
;
; gaochao.morgen@gmail.com
; 2014/5/5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Include ../lib/Anchor.ahk

#SingleInstance Force
#NoTrayIcon
#NoEnv

; 判断全英文的正则表达式
global EnglishPattern := "^[0-9a-zA-Z \.,_\-'""]+$"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        GUI                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 允许调整窗口大小
Gui, +Resize

; 设置在没有为控件指定明确的位置时使用的边距/间隔
Gui, Margin, 0, 0

Gui, Add, Edit, x0 w200 +Multi vSource
GuiControl,, Source, %ClipBoard%
Gui, Add, StatusBar
SB_SetParts(50)
Gui, Show,, Google翻译
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                      主画面响应                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GuiClose:
	ExitApp
Return

GuiSize:
	DllCall("QueryPerformanceCounter", "Int64P", t0)
	; Edit控件自动跟随窗口大小
	Anchor("Source", "wh")
	DllCall("QueryPerformanceCounter", "Int64P", t1)
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                        热键                           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 回车进行查询
#IfWinActive Google翻译
Enter::
	Gui, Submit, Nohide
	SB_SetText("", 1)
	SB_SetText("", 2)

	; 判断中译英还是英译中
	pos := RegExMatch(Source, EnglishPattern)
	if (ErrorLevel = 0 && pos > 0)
		url = http://translate.google.com.hk/translate_a/t?client=t&text=%Source%&sl=en&tl=zh-CN
	else
		url = http://translate.google.com.hk/translate_a/t?client=t&text=%Source%&sl=zh-CN&tl=en

	SB_SetText("正在翻译", 1)
	GoogleText := ByteToStr(WinHttpRequest(url), "UTF-8")
	NeedleRegEx = O)"(.*?)"	; BUG 这个模式只能返回第一段的结果
	FoundPos := RegExMatch(GoogleText, NeedleRegEx, OutMatch)
	ResultText := (! ErrorLevel) ? OutMatch.Value(1) : ""
	GuiControl,, Result, %ResultText%
	ClipBoard := ResultText
	SB_SetText("已复制", 1)
	SB_SetText(ResultText, 2)
Return
#IfWinActive

; Ctrl + Enter 代替平时的回车，用于换行
#IfWinActive Google翻译
^Enter::
	Send {`r}
Return
#IfWinActive

; F1进行朗读
#IfWinActive Google翻译
F1::
	TTSPlay(ClipBoard)
Return
#IfWinActive

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                       函数                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; 请求网页，返回结果
WinHttpRequest(HttpUrl)
{
	; 不产生错误. 当域名不能解析时，会报错造成脚本中断
	ComObjError(false)

	XMLHTTP := ComObjCreate("Microsoft.XMLHTTP")
	XMLHTTP.Open("GET", HttpUrl, false)
	XMLHTTP.SetRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 5.1; rv:11.0) Gecko/20100101 Firefox/11.0")
	XMLHTTP.Send()

	Return XMLHTTP.ResponseBody
}

; 将原始数据流以指定的编码的形式读出
ByteToStr(body, charset)
{
	STREAM := ComObjCreate("Adodb.Stream")
	STREAM.Type := 1
	STREAM.Mode := 3
	STREAM.Open()
	STREAM.Write(body)
	STREAM.Position := 0
	STREAM.Type := 2
	STREAM.Charset := charset
	str := STREAM.ReadText()
	STREAM.Close()

	Return str
}

; 朗读，使用Google语音引擎
TTSPlay(String = "")
{
	if (StrLen(String) > 100)
	{
		Msgbox, 16,, String too long, a maximum of 100 characters!
		Return
	}

	; 用Google翻译的语音引擎朗读
	; 英文直接朗读没有问题
	; 中文直接朗读很慢，原因不明. 因此先下载，再读
	pos := RegExMatch(String, EnglishPattern)
	if (ErrorLevel = 0 && pos > 0)
	{
		GTTS := ComObjCreate("WMPlayer.OCX")
		GTTS.settings.volume := 100
		GTTS.url := "http://translate.google.com/translate_tts?tl=EN&q=" . String
	}
	else
	{
		FilePath := A_ScriptDir . "\tts.mp3"
		Unicode2UTF8(String, Utf8Str)
		target := UrlEncode(Utf8Str)
		url := "http://translate.google.com/translate_tts?tl=zh-CN&ie=UTF-8&q=" . target
		UrlDownloadToFile, %url%, %FilePath%
		SoundPlay, %FilePath%, wait
		FileDelete, %FilePath%
	}
}

; Unicode转为UTF-8编码. AHKL内部使用Unicode，因此中文一般都需要先转成UTF-8
Unicode2UTF8(ByRef wString, ByRef sString)
{
	nSize := DllCall("WideCharToMultiByte"
				   , "Uint", 65001
				   , "Uint", 0
				   , "Uint", &wString
				   , "int",  -1
				   , "Uint", 0
				   , "int", 0
				   , "Uint", 0
				   , "Uint", 0) 

	VarSetCapacity(sString, nSize)

	DllCall("WideCharToMultiByte"
			, "Uint", 65001
			, "Uint", 0
			, "Uint", &wString
			, "int",  -1
			, "str",  sString
			, "int",  nSize
			, "Uint", 0
			, "Uint", 0)
}

; 解析UTF-8编码的中文字符
UrlEncode(ChineseUtf8)
{
	OldFormat := A_FormatInteger
	SetFormat, Integer, H		; 设置数学运算得到的整数为16进制
	
	; AHKL对一个UTF-8编码的汉字，会循环2次
	Loop, Parse, ChineseUtf8
	{
		if A_LoopField is alnum	; 仅当A_LoopField包含[0-9a-zA-Z]时为真
		{
			Out .= A_LoopField
			continue
		}

		; Asc(ChineseUtf8): 返回ChineseUtf8中首个字符的字符编码(介于1和255(在ANSI版本中)或65535(在Unicode版本中)的数字). 
		; 因此要考虑ANSI版和Unicode版的行为不一致性
		; 比如"高"字，UTF-8：E9 AB 98，ANSI版循环三次(0xE9, 0xAB, 0x98)，但是Unicode版循环两次(0xABE9, 0x98)
		LittleEndianHex := Asc(A_LoopField)

		if (A_IsUnicode)
		{
			if (StrLen(LittleEndianHex) = 6) ; "0xABE9"
			{
				Hex := SubStr(LittleEndianHex, 5, 2)
				Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
				Hex := SubStr(LittleEndianHex, 3, -2)
				Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
			}
			else if (StrLen(LittleEndianHex) = 4) ; "0x98"
			{
				Hex := SubStr(LittleEndianHex, 3, 2)
				Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
			}
		}
		else
		{
			Hex := SubStr( Asc( A_LoopField ), 3 )
			Out .= "%" . ( StrLen( Hex ) = 1 ? "0" . Hex : Hex )
		}
	}

	SetFormat, Integer, %OldFormat%
	Return Out
}

