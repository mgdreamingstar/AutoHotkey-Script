SetTitleMatchMode Regex	
#SingleInstance ignore

Menu, Tray, Icon, ico.ico, , 1
Menu, tray, tip, Pdg2Pic 辅助小工具`nPDG 批量转 PDF`n( F1开始 F2退出 )
Menu, tray, NoStandard

~LButton & r::Reload

MButton::BlockInput, Off
$Esc::ExitApp
$LWin::ExitApp

#IfWinActive ahk_exe Pdg2Pic.exe
{
	F1::
		SetControlDelay -1
		BlockInput, On
		
		WinGet, dir, ProcessPath, A
		SplitPath, dir, , outdir
		FileDelete, Pdg2Pic_log.txt
		
		静止状态:
		Loop {
			ControlClick, &4、开始转换, Pdg2Pic	
			Sleep 1000
			ControlGet, ifenable, Enabled, , 转换完毕, Pdg2Pic
			if ifenable = 1
				goto 点击完成
		}
		
		点击完成:
			ControlClick, 确定, Pdg2Pic	
			ControlGet, ifenable2, Enabled, , 否, Pdg2Pic
			if ifenable2 = 1
			{
				SendInput, {Right}{Space}
			}
			
		检查日志:
			ilog = %outdir%\Pdg2Pic_log.txt
			FileRead, OutputVar, %ilog%
			if NOT ErrorLevel
			{
				FileAppend, %OutputVar%, Pdg2Pic_log.txt
			}
		
			goto 选择下一本书
			
		选择下一本书:
			Sleep 1000
				ControlClick, Button2, Pdg2Pic	
				Sleep, 1500
				SendInput, {Down}
				Sleep, 1500
				ControlClick, 确定, 选择存放PDG文件的文件夹	
				Sleep, 500
				goto 检查是否完成
			
		检查是否完成:
			ControlGet, ifenable3, Visible, , 文件夹里没有, Pdg2Pic
			if (ifenable3 = 1)
			{
				SendInput, {Space}
				MsgBox, 262144, PDG->PDF, 全部转换已完成！`n`n退出请按【ESC】或【WIN】键`n`n错误日志，参见脚本同目录下的Pdg2Pic_log.txt`n( 若没有该文件，则表示一切正常 )
			}
			else
			{
				goto 静止状态
			}
		return
}