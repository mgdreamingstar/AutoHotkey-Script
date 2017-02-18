;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 系统静音
; ThinkPad系列有静音键，控制面板也有静音选项，按下静音键会导致静音选项变化.
; 静音键似乎是直接操控的音频硬件，因此它的操作会改变控制面板静音选项，但反之却不然，因此可能出现二者不同步
; 一旦两者不同步，将导致系统始终无声(静音键显示静音，但静音选项却没有勾上；静音键显示有声，但静音选项却被勾上)
; 为了避免出现这种情况，我干脆舍弃静音键，用脚本直接控制静音选项
;
; 启动该脚本，却听到声音，不正常!
; 关闭该脚本，却没听到声音，不正常!
;
; gaochao.morgen@gmail.com
; 2014/1/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

OnExit, MuteOff			; 确保到脚本退出时声音打开.

CoordMode, ToolTip, Screen  ; 把ToolTips放置在相对于屏幕坐标的位置
ToolTip, Mute On, 640, 400
Sleep, 1000
ToolTip
SoundSet, 1,, MUTE
SoundPlay, %A_WinDir%\Media\Windows XP 信息栏.wav, WAIT
Return

MuteOff:
	CoordMode, ToolTip, Screen  ; 把ToolTips放置在相对于屏幕坐标的位置
	ToolTip, Mute Off, 640, 400
	Sleep, 1000
	ToolTip
	SoundSet, 0,, MUTE
	SoundPlay, %A_WinDir%\Media\Windows XP 信息栏.wav, WAIT
ExitApp

