;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 监控股市实时状态，如果超过预警线，按时提醒
; 由于时差关系，用到了声音提示，在国内可以自行修改成其他方式提醒
;
; gaochao.morgen@gmail.com
; 2014/1/20
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Persistent
#SingleInstance Force
#NoTrayIcon
#NoEnv

;; 夏令时: 巴西时间凌晨4点30，中国时间下午2点30
;TARGET_HOUR := 4
;TARGET_MINUTE := 30

; 巴西时间凌晨3点30，中国时间下午2点30
TARGET_HOUR := 3
TARGET_MINUTE := 30

SetTimer, Monitor, 120000

Monitor:
	; 星期日、星期六
	if (A_WDay = 1 || A_WDay = 7)
		Return

	; 一直休眠，直到国内时间14:30，并在15:00前有效
	mh := A_Hour - TARGET_HOUR
	mm := A_Min - TARGET_MINUTE
	diff := mh*60 + mm
	if (diff < 0 || diff > 30)
		Return
	
	Stocks := Object()
	Stocks.Insert("s_sh000001")	; 上证综指
	Stocks.Insert("s_sz399006")	; 创业板指
	
	URL := "http://hq.sinajs.cn/"
	URL .= "list="
	for index, element in Stocks
	{
		URL .= element . ","
	}
	
	; 不产生错误. 当域名不能解析时，会报错造成脚本中断
	ComObjError(false)
	; 获取股票实时数据, 直至股市结束
	oHttp := ComObjCreate("WinHttp.Winhttprequest.5.1")
	oHttp.Open("GET", URL)
	oHttp.Send()
	responseText := oHttp.responseText ; Save response
	
	sshIndex := 0
	cybIndex := 0
	
	; var hq_str_s_sh000001="上证指数,2289.791,-16.065,-0.70,599419,5529858";
	;                        指数名称,当前点数,涨跌额,涨跌幅度,总手,成交金额;
	
	Loop, Parse, responseText, `;
	{
		hq_idxs := A_Index
		hq_strs := A_LoopField
	
		Loop, Parse, hq_strs, `,
		{
			if (hq_idxs=1 && A_Index=4) ; 涨跌幅
				sshIndex := A_LoopField
	
			if (hq_idxs=2 && A_Index=4)
				cybIndex := A_LoopField
		}
	}
	
	; 上证涨幅超过1%，或者创业板涨幅超过1.5%，则提醒
	if (sshIndex >= 1 || cybIndex >= 1.5)
	{
		SoundPlay, %A_WinDir%\Media\ringin.wav, WAIT
		SoundPlay, %A_WinDir%\Media\ringin.wav, WAIT
	}
	
	; 上证跌幅超过1%，或者创业板跌幅超过1.5%，则提醒
	if (sshIndex <= -1 || cybIndex <= -1.5)
	{
		SoundPlay, %A_WinDir%\Media\notify.wav, WAIT
		SoundPlay, %A_WinDir%\Media\notify.wav, WAIT
	}
Return

