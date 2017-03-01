; 更新记录: v1.03 - 增加：支持已编译的脚本
;           v1.02 - 修复：多次“重启”无效问题
;           v1.01 - 增加：双击执行“退出”菜单

#NoEnv
#NoTrayIcon
#SingleInstance Force
SetBatchLines -1
DetectHiddenWindows On

global HLV

CreateGUI()
CreateMenu()
RefreshList()
return

GuiClose:
GuiEscape:
ExitApp

CreateGUI() {
	Gui, Font, s10, 微软雅黑
	Gui, Add, ListView, w700 r10 Grid HwndHLV gLvEvent, 文件名|文件路径|PID
	Gui, Add, Button, xm gRefreshList, 刷新列表
	Gui, Show,, AHK 进程管理 v1.03
}

CreateMenu() {
	Loop, Parse, % "退出|重启|暂停|暂停热键||结束进程", |
		Menu, lvMenu, Add, % A_LoopField, MenuHandler

	Menu, lvMenu, Default, 退出
}

RefreshList() {
	LV_Delete()

	WinGet, id, List, ahk_class AutoHotkey
	Loop, %id% {
		this_id := id%A_Index%
		WinGet, this_pid, PID, ahk_id %this_id%

		WinGetTitle, this_title, ahk_id %this_id%
		fPath := RegExReplace(this_title, " - AutoHotkey v[\d.]+$")
		SplitPath, fPath, fName
		
		LV_Add("", fName, fPath, this_pid)
	}

	LV_ModifyCol()
}

GuiContextMenu(GuiHwnd, CtrlHwnd) {
	if (CtrlHwnd = HLV) && LV_GetNext() {
		Menu, lvMenu, Show
	}
}

MenuHandler(ItemName) {
	static cmd := {重启: 65303, 暂停热键: 65305, 暂停: 65306, 退出: 65307}
	static WM_COMMAND := 0x111

	if (ItemName = "结束进程") {
		for i, obj in GetSelectedInfo()
			Process, Close, % obj.pid
	} else {
		for i, obj in GetSelectedInfo()
			PostMessage, WM_COMMAND, % cmd[ItemName],,, % obj.path " ahk_pid " obj.pid
	}

	if (ItemName ~= "退出|结束|重启")
		SetTimer, RefreshList, -300
}

GetSelectedInfo() {
	RowNum := 0, arr := []
	while, RowNum := LV_GetNext(RowNum) {
		LV_GetText(path, RowNum, 2)
		LV_GetText(pid, RowNum, 3)
		arr.push( {pid: pid, path: path} )
	}
	return arr
}

LvEvent() {
	if (A_GuiEvent = "DoubleClick" && A_EventInfo)
		MenuHandler("退出")
}