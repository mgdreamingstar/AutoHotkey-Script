SetTitleMatchMode Regex
#SingleInstance ignore



;while(1)
{
	SendPlay, {q Down}
	Sleep, 10
	SendPlay, {q up}
	Sleep, 600
}
return

F9::ExitApp