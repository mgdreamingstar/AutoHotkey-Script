;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 系统切换到北京时间，退出时自动还原为巴西时间
;
; gaochao.morgen@gmail.com
; 2014/2/17
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

OnExit, ResumeBrazil	; 任何原因引起的脚本退出，均会执行ResumeBrazil段

Diff := 11				; 里约与北京时间差，11小时

Now := A_Now
EnvAdd, Now, Diff, Hours  
SetSystemTime(Now)
Return					; 必须让脚本在这里结束任务，否则会继续往下执行

ResumeBrazil:
	Now := A_Now
	EnvAdd, Now, Diff*(-1), Hours  
	SetSystemTime(Now)
ExitApp

; 设置系统时钟为指定的日期和时间.
; 调用者必须确保传入的参数是有效的日期时间戳
; (本地时间, 非 UTC). 成功时返回非零值, 否则返回零.
SetSystemTime(YYYYMMDDHHMISS)
{
	; 把参数从本地时间转换为 UTC 以便用于 SetSystemTime().
	UTC_Delta -= A_NowUTC, Seconds ; 取整后秒数会更精确.
	UTC_Delta := Round(-UTC_Delta/60) ; 取整到最近的分钟数以确保精度.
	YYYYMMDDHHMISS += UTC_Delta, Minutes ; 对本地时间应用偏移来转换到 UTC.
	
	VarSetCapacity(SystemTime, 16, 0) ; 此结构由 8 个 UShort 组成 (即 8*2=16).
	
	StringLeft, Int, YYYYMMDDHHMISS, 4 ; YYYY (年份)
	NumPut(Int, SystemTime, 0, "UShort")
	StringMid, Int, YYYYMMDDHHMISS, 5, 2 ; MM (年中的月数, 1-12)
	NumPut(Int, SystemTime, 2, "UShort")
	StringMid, Int, YYYYMMDDHHMISS, 7, 2 ; DD (月中的天数)
	NumPut(Int, SystemTime, 6, "UShort")
	StringMid, Int, YYYYMMDDHHMISS, 9, 2 ; HH (24 小时制的小时数)
	NumPut(Int, SystemTime, 8, "UShort")
	StringMid, Int, YYYYMMDDHHMISS, 11, 2 ; MI (分钟数)
	NumPut(Int, SystemTime, 10, "UShort")
	StringMid, Int, YYYYMMDDHHMISS, 13, 2 ; SS (秒数)
	NumPut(Int, SystemTime, 12, "UShort")
	
	return DllCall("SetSystemTime", Ptr, &SystemTime)
}

