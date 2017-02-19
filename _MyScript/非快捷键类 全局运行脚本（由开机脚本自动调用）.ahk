;单独写该脚本，原因是如果写入开机脚本内，会在同一线程内执行，则Loop期间，部分快捷键会失效，例如Evernote的Alt-F，所以单独提出来

SetTitleMatchMode Regex	;更改进程匹配模式为正则
#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
#Persistent				;持续运行不退出

;-------------------------------------------------------------------------------
;~ 垃圾弹窗 自动关闭 (补充adkiller)
;-------------------------------------------------------------------------------
#IfWinActive
{
	;关闭烦人的about snagit
	Loop
	{
		WinWait, About Snagit
		WinClose
	}
	return
}
