SetTitleMatchMode Regex
#SingleInstance ignore

Pause

while(1)
{
/*
	Send, {q down}
	Sleep, 10
	Send, {q up}
	Sleep, 10
	Send, {e down}
	Sleep, 10
	Send, {e up}
	Sleep, 10
*/
	Send, {q down}
	Send, {e down}
	Sleep, 600
	Send, {q up}
	Send, {e up}
	Sleep, 600	
}
return

F12::Pause