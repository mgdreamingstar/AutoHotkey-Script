;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 闹钟
; 注意：启动时没有声音，表示声音有问题，需要手动解决
;
; gaochao.morgen@gmail.com
; 2014/1/19
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

; 默认早上6点40的闹钟
dStartH := 6			; 默认起始时间
dStartM := 40			; 默认起始时间
dDuration := 5			; 默认时长, 单位min

; 如果处于静音状态，则打开声音
SoundGet, master_mute,, MUTE
if (master_mute = "On")
	SoundSet, 0,, MUTE

SoundPlay, %A_WinDir%\Media\start.wav, WAIT

SetTimer, Alarm, 120000	; 两分钟

Alarm:
	if (A_WDay = 1 || A_WDay = 7)			; 星期日、星期六
		Return

	diff := (A_Hour-dStartH)*60 + (A_Min-dStartM)
	if (diff >= 0 && diff < dDuration)
	{
		SoundGet, master_volume
		SoundSet, 20
		SoundPlay, %A_WinDir%\Media\town.mid, WAIT	; 该音乐持续时间1分19秒
		SoundSet, master_volume
	}
Return

