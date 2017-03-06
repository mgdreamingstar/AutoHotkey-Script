;提升性能相关的配置
#NoEnv						;不检查空变量是否为环境变量
;#KeyHistory 0				;不记录击键log
;ListLines Off				;不记录击键log
SetBatchLines, -1			;行之间运行不留时间空隙,默认是有10ms的间隔
SetKeyDelay, -1, -1			;发送按键不留时间空隙
SetMouseDelay, -1			;每次鼠标移动或点击后自动的延时=0   
SetDefaultMouseSpeed, 0		;设置在 Click 和 MouseMove/Click/Drag 中没有指定鼠标速度时使用的速度 = 瞬间移动.
SetWinDelay, 0
SetControlDelay, 0
SendMode Input				;据说SendInput is the fastest send method.

;-------------------------------------------------------------------------------
;~ 开机自启程序
;-------------------------------------------------------------------------------
{
	;备份Sandboxie配置
	FileCopy, C:\Windows\Sandboxie.ini, d:\BaiduYun\@\Software\Sandboxie.ini.bak, 1

	Run, "D:\TechnicalSupport\ProgramFiles\cow-win64-0.9.6 不要用0.9.8版本，有连接reset的bug\cow-taskbar.exe"
	Run, "D:\BaiduYun\@\Software\shadowsocks-qt5 因为cow只提供http，无socks5和https接口，故专开一下客户端。不用了，可以用privoxy模拟socks5\ss-qt5.exe"
	Run, "D:\TechnicalSupport\ProgramFiles\AutoHotkey\AutoHotkeyU32.exe" "D:\BaiduYun\@\Software\AHKScript\_MyScript\2. 自定义快捷操作.ahk"
	
	;如果是星期天，则更新host
	if ( A_WDay = 1 ) {
		Run, "d:\BaiduYun\Technical Backup\ProgramFiles.Trust\SwitchHosts  各种host的工具，不止SwitchHosts，都统一放在这里了\Hosts tool for racaljk／hosts  可自动更新racaljk／hosts\tool_silent.exe"
	}
}


;-------------------------------------------------------------------------------
;~ 备份Firefox
;-------------------------------------------------------------------------------
{
	SetWorkingDir, d:\BaiduYun\@\Software\Firefox Backup
	backupdir := "Firefox_Backup_7days.zip"
	firefoxdir := "d:\TechnicalSupport\ProgramFiles\Firefox-pcxFirefox\Profiles\"
	7zdir := "d:\BaiduYun\Technical Backup\ProgramFiles.Trust\7z1604-extra  7zip的单独命令行版本\7za.exe"
	
	FileGetTime, timestamp, %backupdir%, C
	FormatTime, date, timestamp, yyyyMMdd
	xData := A_YYYY * 10000 + A_MM * 100 + A_DD - date
	
	;如果备份是7天前的
	if ( xData > 7 ) {
		FileMove, %backupdir%, %date% Use.zip
		Run, %7zdir% a -tzip %backupdir% %firefoxdir%
	}
}

ExitApp


