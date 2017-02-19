;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 一键启动办公必备程序
; 
; gaochao.morgen@gmail.com
; 2013/7/2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoEnv

; 设置 ErrorLevel 为这个正在运行脚本的 PID
Process, Exist

ExeList := Object()
ExeList.Insert("E:\系统工具\DeskWidget\DeskWidget.exe", 2)
ExeList.Insert("E:\系统工具\Yz Dock 0.83\YzDock.exe", 5)
ExeList.Insert("C:\Program Files\Microsoft Office\OFFICE11\OUTLOOK.EXE", 4)
ExeList.Insert("C:\Program Files\DeskTask\DeskTask.exe", 5)
ExeList.Insert("C:\Program Files\Microsoft Office Communicator\communicator.exe", 30)
ExeList.Insert("E:\Program Files\QQ2012\Bin\QQ.exe", 5)

for Target, Seconds in ExeList
{
	SplitPath, Target, ProcName

	CoordMode, ToolTip, Screen  ; 把ToolTips放置在相对于屏幕坐标的位置
	ToolTip, Launching %ProcName%, 640, 400
	Sleep, 500

	; 若进程未启动则启动，若已启动则不作任何改动
	Process, Exist, %ProcName%
	if (ErrorLevel = 0)
	{
		Run, %Target%
		Seconds *= 1000
		Sleep, %Seconds%
	}
}

ExitApp	

