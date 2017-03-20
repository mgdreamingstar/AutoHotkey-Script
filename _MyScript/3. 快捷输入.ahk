;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; 由于快捷输入部分，总是莫名其妙、间歇性的失效，所以从主脚本，独立出来试试
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance ignore	;决定当脚本已经运行时是否允许它再次运行。
#Hotstring EndChars  `n				;编辑热字串的终止符
Menu, Tray, Icon, %A_LineFile%\..\Icon\keyboard_128px.ico, , 1

;Unicode发送函数,避免触发输入法,也不受全角影响
	;from [辅助Send 发送ASCII字符 V1.7.2](http://ahk8.com/thread-5385.html)
	SendL(ByRef string) {
		static Ord:=("Asc","Ord")
		inputString:=("string",string)
		Loop, Parse, %inputString%
			ascString.=(_:=%Ord%(A_LoopField))<0x100?"{ASC " _ "}":A_LoopField
		SendInput, % ascString
	}
	
::tc::TotalCommander
::sof::stackoverflow
:*:b\::
:*:bo\::
	sendL("bootislands")		;放弃unicode难读的方式，用sendL()，来避免触发输入法
	return
:*:b@\::
	sendL("bootislands@163.com")
	return
:*:bg\::
	sendL("bootislands@gmail.com")
	return
:*:vg\::
	sendL("VeryNginx@gmail.com")
	return
:*:rg\::
	sendL("riverno@gmail.com")
	return
:*:q@\::
	sendL("1755381995@qq.com")
	return
:*:js\::
	sendL("JavaScript")
	return
::ahk::AutoHotkey
::mlo::MyLifeOrganized
:*:yjt\:: ?{Space}					;	右箭头