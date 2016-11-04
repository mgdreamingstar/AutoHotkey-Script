MsgBox, 262144, Pdg2Pic 批量转换辅助工具, 使用说明：`n`n1）先运行本工具。等待转换的各PDG文件夹，放置于同一父文件夹下`n2）正常打开Pdg2Pic，选择需要转换的【从上往下数第一个】PDG子文件夹`n3）本来应该点击Pdg2Pic的【4、开始转换】，但是*不要*点击，转而按下键盘的【F1】键`n4）批量转换开始……`n5）任何时候，按下【ESC】或【WIN】键，退出`n`n　　　　　　　　　　　　　　　　　　　—— bootislands@eshuyuan

SetTitleMatchMode Regex	
#SingleInstance ignore

Menu, tray, tip, Pdg2Pic 批量转换辅助工具`nPDG 批量转 PDF`n( F1开始 Esc退出 )
Menu, tray, NoStandard

$Esc::ExitApp
$LWin::ExitApp

#IfWinActive ahk_exe Pdg2Pic.exe
{
	F1::
		SetControlDelay -1
		
		WinGet, dir, ProcessPath, A
		;MsgBox %OutputVar%
		SplitPath, dir, , outdir
		;MsgBox %outdir%
		FileDelete, Pdg2Pic_log.txt
		
		静止状态:		;等待按 开始转换
		Loop {
			ControlClick, &4、开始转换, Pdg2Pic, , , , NA		;点击开始转换
			Sleep 1000
			ControlGet, ifenable, Enabled, , 转换完毕, Pdg2Pic	;如果没出错，转换成功
			if ifenable = 1
				goto 点击完成									;则点击
		}
			
		点击完成:
			ControlClick, 确定, Pdg2Pic, , , , NA		;点击转换完成的确定
			ControlGet, ifenable2, Enabled, , 否, Pdg2Pic
			if ifenable2 = 1
			{
				ControlSend, Button1, n, Pdg2Pic
			}
			
		检查日志:
			;检查是否有日志，如果有则copy
			ilog = %outdir%\Pdg2Pic_log.txt
			FileRead, OutputVar, %ilog%
			if NOT ErrorLevel
			{
				;如果文件不存在，则为1，如果成功读取到了，则为0
				FileAppend, %OutputVar%, Pdg2Pic_log.txt
			}
		
			goto 选择下一本书
			
		选择下一本书:
			Sleep 1000
			ControlClick, Button2, Pdg2Pic, , , , NA	;点击选书
			Sleep, 1500
			ControlSend, SysTreeView321, {Down}, 选择存放PDG文件的文件夹
			Sleep, 1500
			ControlClick, 确定, 选择存放PDG文件的文件夹	;点击确定，完成选书
			Sleep, 500
			goto 检查是否完成
			
		检查是否完成:
			ControlGet, ifenable3, Visible, , 文件夹里没有, Pdg2Pic
			if (ifenable3 = 1)
			{
				ControlSend, Button1, {Space}, Pdg2Pic
				;最前端弹窗
				MsgBox, 262144, Pdg2Pic 批量转换辅助工具, 全部PDG文件，转换完成！`n`n如果转换中出现错误，请参见脚本同目录下的Pdg2Pic_log.txt`n（若没有该文件，则说明一切正常）`n`n按下【ESC】或【WIN】键，退出
			}
			else
			{
				goto 静止状态
			}
		return
}