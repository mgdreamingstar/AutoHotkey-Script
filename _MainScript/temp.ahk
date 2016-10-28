SetTitleMatchMode Regex	;更改进程匹配模式为正则

{
	;关闭烦人的about snagit
	Loop
	{
		WinWait, About Snagit
		WinClose
	}
	return
}