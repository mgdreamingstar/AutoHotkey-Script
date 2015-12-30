/*
不少编辑器没有定时保存，一旦软件意外关闭，编辑很久的文档就可能丢了。这个脚本旨在解决这个问题
该脚本在指定软件中（自定义添加）：
1. 一旦（没操作键盘和鼠标超过5秒钟）或者（失去焦点，即程序被切入后台），就自动保存，然后计时等待半分钟。半分钟后再次进入前面两个判断，一旦满足就再次保存。一直这样?循环下去
2. 每7分钟检查1的过程中是否进行过保存，没的话激活窗口，强制保存。
*/

SetTitleMatchMode Regex
#SingleInstance ignore
#Persistent

Menu, tray, tip, 自动保存常用软件
Menu, Tray, Icon, %A_LineFile%\..\icon\GlobalAutoSavev2.ico, , 1

窗口1上次保存时间:=A_TickCount-30*1000    ;使下面立即开始检测
窗口2上次保存时间:=A_TickCount-30*1000

SetTimer, 自动保存, 5000  ;5秒钟检测一次，刚好可检测5秒内有没有键盘和鼠标操作
Return


自动保存:

当前时间:=A_TickCount

if WinExist("ahk_class AcrobatSDIWindow") and (当前时间-窗口1上次保存时间>120*1000)
{
    if !WinActive()
    {
        ;-------------------------------------------------------------
        ;  后台保存方式1：发送按键到编辑控件，通过AU3_Spy获取控件名称
        ;-------------------------------------------------------------
        ;ControlSend, Edit1, {Control Down}s{Control Up}
        ControlSend, ahk_parent, {Control Down}s{Control Up}, ahk_class DSUI:PDFXCViewer
        ;-------------------------------------------------------------
        ;  后台保存方式2：发送点击到窗口保存图标的位置，通过AU3_Spy获取位置
        ;-------------------------------------------------------------
        ;SetControlDelay, -1
        ;ControlClick, x64 y16,,,,, NA Pos
        ;-------------------------------------------------------------
        ;  后台保存方式3：发送命令消息到窗口，通过Winspector Spy获取消息值
        ;  使用方法可在帮助文件中搜索Winspector Spy，这个比较高级
        ;-------------------------------------------------------------
        ;PostMessage, 0x111, 3    ;例如这是记事本保存的消息值
        窗口1上次保存时间:=当前时间
    }

    ;下面的保存也最好采用上面的后台方式
    if WinActive() and (A_TimeIdlePhysical>5000)
    {
        ControlSend, ahk_parent, {Control Down}s{Control Up}, ahk_class DSUI:PDFXCViewer
        ;ControlSend, Edit1, {Control Down}s{Control Up}
        ;ControlSend, ahk_parent, {Control Down}s{Control Up}, ahk_exe, PDFXCview.exe
        ;blockinput, On
        ;send, {Control Down}s{Control Up}  ;保存
        ;Blockinput, off
        窗口1上次保存时间:=当前时间
    }

    ;这个基本上没用了，窗口失去焦点必然半分钟保存一次，
    ;窗口没失去焦点，也没有谁会老在操作，连5秒的空闲都没有
/*
    if (当前时间-窗口1上次保存时间>7*60*1000)
    {
        blockinput, On
        WinActivate
        WinWaitActive,,, 3
        send, {Control Down}s{Control Up}  ;保存
        Blockinput, off
        窗口1上次保存时间:=当前时间
    }
*/
}


;后面添加的窗口同上面的类似

if WinExist("ahk_class TfrmMyLifeMain") and (当前时间-窗口2上次保存时间>60*1000)
{
    if !WinActive()
    {
        ControlSend, TActionMainMenuBar1, {Control Down}s{Control Up}, ahk_class, TfrmMyLifeMain
        窗口2上次保存时间:=当前时间
    }
    if WinActive() and (A_TimeIdlePhysical>5000)
    {
        ControlSend, TActionMainMenuBar1, {Control Down}s{Control Up}, ahk_class, TfrmMyLifeMain
        窗口2上次保存时间:=当前时间
    }
}
Return