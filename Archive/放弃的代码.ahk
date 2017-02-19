;防止删除的代码

~AppsKey::
	if (A_ThisHotKey = A_PriorHotKey and A_TimeSincePriorHotkey < 500)
		Send, h{Right}
	return

;老板键
;按下capslock键，隐藏当前程序，切换到指定程序（word）；再按一下，恢复上一次隐藏的程序，并激活。
;20140718 修改版：按下capslock键，检查当前是否在指定程序（word），不在的话，隐藏当前程序，切换到指定程序（word）；在的话，恢复上一次隐藏的程序，并激活。
/*以下是20140718修改前的旧版代码
bsKeyFlag := false	;true==正在被隐藏状态  false==常规状态，没处理时状态
Capslock::
	if !bsKeyFlag
	{
		WinGetClass, crntWinClass, A
		WinActivate, ahk_class OpusApp
		bsKeyFlag := !bsKeyFlag
	}
	else
	{
		WinActivate, ahk_class %crntWinClass%
		bsKeyFlag := !bsKeyFlag
	}
	return
*/
;;Capslock::send {Esc}   这是为“追音小匠”听写提供的临时快捷键
Capslock::
{
	IfWinNotActive ahk_class OpusApp
	{
		WinGetClass, crntWinClass, A
		WinActivate, ahk_class OpusApp
	}
	else
	{
		WinActivate, ahk_class %crntWinClass%
	}
	return
}
