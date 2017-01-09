SetTitleMatchMode Regex
#SingleInstance ignore

TrayTip, 提示, 脚本已启动, , 1
Sleep, 1000
TrayTip

F2::Reload

;-------------------------------------------------------------------------------
;~ 游戏 狼人杀 快捷键
;-------------------------------------------------------------------------------
#IfWinExist 狼人游戏
{
	;后台抢座位
	F1::			
		WinGet, active_id, ID, A
		Loop {
			SetControlDelay -1
			ControlClick, X1283 Y609, ahk_id %active_id%,,,, NA	;抢10号位
			Sleep, 100
		}
		return
}