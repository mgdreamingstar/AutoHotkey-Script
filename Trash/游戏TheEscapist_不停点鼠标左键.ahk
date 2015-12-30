SetTitleMatchMode Regex
#SingleInstance ignore

Pause

;F1::Reload

while(1)
{
	
	Send, {LButton Down}
	Sleep, 2
	Send, {LButton up}
	Sleep, 2
	/*
	Send, {q Down}
	Send, {q up}
	Sleep, 600
	*/
}
return

F11::Pause