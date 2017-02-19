/*
===========================================
  【快捷抓取、查找屏幕文字/图像字符串】v5.3  By FeiYue
===========================================

  更新历史：

  v5.3 改进：容差增加为两个，分别是0_字符的容许减少百分比。
       采用新的算法，提高了带容差参数时的查找速度。
       容差为默认值0时，找不到会自动使用 5% 的容差再找一次。

  v5.2 改进：新增后台查找，相当于把指定ID的窗口搬到前台再查找。
       因此用于前台操作的找字找图代码不用修改就可以转到后台模式。
       注：Win7以上系统因PrintWindow不太好用，因此许多窗口不支持。

  v5.0 改进：新增了第三种查找模式：边缘灰差模式。

  v4.6 改进：增加对多显示器扩展显示的支持。

  v4.5 改进：修正了Win10-64位系统的一些兼容性问题。
       提高了抓字窗口中二值化、删除操作的反应速度。

  v4.3 改进：文字参数中，每个字库文字可以添加用中括号括起来
       的容差值，没有中括号才用“查找文字”函数中的容差参数。

  v4.2 改进：新增了64位系统的机器码，可用于AHK 64位版。

  v4.1 改进：不再使用GDI+获取屏幕图像，直接用GDI实现。

  v4.0 改进：文字参数增加竖线分隔的字库形式，可以进行
       OCR识别。这种形式也可用于同时查找多幅文字或图片。

  v3.5 改进：采用自写的机器码实现图内找字，极大的提高了速度。

  使用说明：

      1、先抓取文字图像字符串，然后全屏查找测试，测试成功后，
         点击复制代码，并粘贴到自己的脚本中，最后将最下面的
         “查找文字”函数及后面的函数复制到自己的脚本中就行了。

      2、自动灰度二值化的图像如果不满意，可以手动输入阀值试试。
         字库输入框可以一次生成多个文字的模板。如果左右结构
         的字被分开，可以单独裁剪出这一个字，然后点击插入。

      3、由于许多因素会影响屏幕图像，所以换一台电脑一般就要
         重新抓字/图。建议使用颜色模式抓字，这样通用性强些。

      4、建立字库或进行两个图像差值比较时，都要统一阀值才行。
         第一次抓图得到的阀值，后面的采集要手动输入这个阀值。

===========================================

  是否成功 := 查找文字( 中心点X, 中心点Y, 文字, 颜色
       , 左右偏移W, 上下偏移H, 返回X, 返回Y, 返回OCR结果
       , 0字符减少百分比, _字符减少百分比, 后台窗口ID )

  其中：颜色带*号的为灰度阀值模式，对于非单色的文字比较好用。
       容差参数允许有几个点不同，这对于灰度阀值模式很有用。

===========================================
*/

#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse
CoordMode, Pixel
CoordMode, ToolTip
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
;----------------------------
Menu, Tray, Icon, Shell32.dll, 23
Menu, Tray, Add
Menu, Tray, Add, 显示主窗口
Menu, Tray, Default, 显示主窗口
Menu, Tray, Click, 1
;----------------------------
  ww:=35, hh:=12    ; 左右上下抓字抓图的范围
  nW:=2*ww+1, nH:=2*hh+1
;----------------------------
Gosub, 生成抓字窗口
Gosub, 生成主窗口
OnExit, savescr
Gosub, readscr
Return

F12::    ; 按【F12】保存修改并重启脚本
SetTitleMatchMode, 2
SplitPath, A_ScriptName,,,, name
IfWinExist, %name%
{
  ControlSend, ahk_parent, {Ctrl Down}s{Ctrl Up}
  Sleep, 500
}
Reload
Return

readscr:
f=%A_Temp%\~scr1.tmp
FileRead, s, %f%
GuiControl, Main:, Edit1, %s%
s=
Return

savescr:
f=%A_Temp%\~scr1.tmp
GuiControlGet, s, Main:, Edit1
FileDelete, %f%
FileAppend, %s%, %f%
ExitApp

显示主窗口:
Gui, Main:Show, Center
Return

生成主窗口:
Gui, Main:Default
Gui, +AlwaysOnTop +HwndMain_ID
Gui, Margin, 15, 15
Gui, Font, s12 cBlue, Verdana
Gui, Color, EEFFFF, EEFFFF
Gui, Add, Button, w250 gMainRun, 抓取文字图像
Gui, Add, Button, x+0 wp gMainRun, 全屏查找测试
Gui, Add, Button, x+0 wp gMainRun, 复制代码
Gui, Add, Edit, xm w750 h400 -Wrap HScroll Hwndhscr
Gui, Add, Button, xm wp g计算差值, 计算两图差值
Gui, Show, NA, 文字/图像字符串生成工具
Return

MainRun:
k:=A_GuiControl
WinMinimize
Gui, Hide
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Main_ID%
if IsLabel(k)
  Gosub, %k%
Gui, Main:Show
GuiControl, Main:Focus, Edit1
Return

; 用于验证码识别时比较模板与新抓的图像的差值
; 注意抓取用于比较的图时要点插入而非分割/确定

计算差值:
Gui, +OwnDialogs
GuiControl, Focus, Edit1
ControlGet, s, Selected,, Edit1
if !RegExMatch(s,"\(([\s0_]+)\)[\s\S]*?\(([\s0_]+)\)",r)
{
  MsgBox, 4096,, 请先用鼠标选择相邻的两个图像字符串。
  Return
}
if StrLen(r1)<StrLen(r2)
  r:=r1, r1:=r2, r2:=r
;---------------------------------
r1:=Trim(StrReplace(r1,"`r"),"`n ")
tmp1:=[], w:=InStr(r1 "`n","`n")-1, h:=0
Loop, Parse, r1, `n, %A_Space%
  tmp1[++h]:=StrSplit(A_LoopField)
;---------------------------------
r2:=Trim(StrReplace(r2,"`r"),"`n ")
tmp2:=[], w2:=InStr(r2 "`n","`n")-1, h2:=0
Loop, Parse, r2, `n, %A_Space%
  tmp2[++h2]:=StrSplit(A_LoopField)
;---------------------------------
cha:=StrLen(r2)
Loop, % Abs(h-h2)+5 {
  y:=A_Index-3
  Loop, % Abs(w-w2)+5 {
    x:=A_Index-3
    n:=0
    Loop, %h2% {
      j:=A_Index
      Loop, %w2%
        i:=A_Index, n+=(tmp1[y+j][x+i]!=tmp2[j][i])
    }
    if (n<cha)
      cha:=n
  }
}
tmp1:=tmp2:=r:=r1:=r2:=""
MsgBox, 4096,, 所选的两图差值为：%cha%。
Return

复制代码:
GuiControlGet, s,, Edit1
Clipboard:=StrReplace(s,"`n","`r`n")
s=
Return

抓取文字图像:
;------------------------------
; 先用一个微型GUI提示抓字范围
Gui, Mini:Default
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow
  +E0x08000000 -DPIScale
WinSet, Transparent, 100
Gui, Color, Red
Gui, Show, Hide w%nW% h%nH%
;------------------------------
ListLines, Off
Loop {
  MouseGetPos, px, py
  if GetKeyState("LButton","P")
    Break
  Gui, Show, % "NA x" (px-ww) " y" (py-hh)
  ToolTip, % "当前鼠标位置：" px "," py
    . "`n请移到目标位置后点击左键"
  Sleep, 20
}
KeyWait, LButton
Gui, Color, White
Loop {
  MouseGetPos, x, y
  if Abs(px-x)+Abs(py-y)>100
    Break
  Gui, Show, % "NA x" (x-ww) " y" (y-hh)
  ToolTip, 请把鼠标移开100像素以上
  Sleep, 20
}
ToolTip
ListLines, On
Gui, Destroy
WinWaitClose
cors:=getc(px,py)
;---------------------------------
MouseMove, px, py, 0
MouseGetPos,,, zhua_id
MouseMove, x, y, 0
;---------------------------------
Gui, Catch:Default
Loop, 4
  GuiControl,, Edit%A_Index%
GuiControl,, 后台, % houtai:=0
GuiControl,, 修改, % xiugai:=0
Gosub, 重读
Gui, Show, Center
OnMessage(0x201,"WM_LBUTTONDOWN")
DetectHiddenWindows, Off
WinWaitClose, ahk_id %Catch_ID%
OnMessage(0x201,"")
Return

WM_LBUTTONDOWN() {
  global
  ListLines, Off
  MouseGetPos,,,, mclass
  if !InStr(mclass,"progress")
    Return
  MouseGetPos,,,, mid, 2
  For k,v in C_
    if (v=mid)
    {
      if (xiugai and bg!="")
      {
        c:=cc[k], cc[k]:=c="0" ? "_" : c="_" ? "0" : c
        c:=c="0" ? "White" : c="_" ? "Black" : "0xDDEEFF"
        Gosub, SetColor
      }
      else
      {
        c:=cors[k]
        GuiControl, Catch:, Edit1, %c%
        c:=((c>>16&0xFF)*38+(c>>8&0xFF)*75+(c&0xFF)*15)>>7
        GuiControl, Catch:, Edit4, %c%
      }
      Return
    }
}

getc(px, py, id="") {
  global ww, hh, nW, nH
  bch:=A_BatchLines
  SetBatchLines, -1
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=px-ww, right:=px+ww, up:=py-hh, down:=py+hh
  left:=left<zx ? zx:left
  right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
  if (w<1 or h<1)
    Return, 0
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits,id)
  ;--------------------------------------
  cors:=[], k:=0
  ListLines, Off
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, H
  Loop, %nH% {
    j:=py-hh-y+A_Index-1
    Loop, %nW% {
      i:=px-ww-x+A_Index-1, k++
      if (i>=0 and i<w and j>=0 and j<h)
        c:=NumGet(Scan0+0,i*4+j*Stride,"uint")
          , cors[k]:="0x" . SubStr(0x1000000|c,-5)
      else
        cors[k]:="0xFFFFFF"
    }
  }
  SetFormat, IntegerFast, %fmt%
  ListLines, On
  ; 左右上下超出屏幕边界的值
  cors.left:=Abs(px-ww-left)
  cors.right:=Abs(px+ww-right)
  cors.up:=Abs(py-hh-up)
  cors.down:=Abs(py+hh-down)
  SetBatchLines, %bch%
  Return, cors
}

全屏查找测试:
GuiControlGet, s, Main:, Edit1
id=
if RegExMatch(s,"i)WinExist\(([^\n]*)\)",r)
{
  s:=StrReplace(s,r), tt:=Trim(r1,""" ")
  tt:=StrReplace(tt,"""""","""")
  tt:=StrReplace(tt,"``;",";")
  tt:=StrReplace(tt,"````","``")
  id:=WinExist(tt)
}
s:=StrReplace(s,"ahk_class")
if !RegExMatch(s,"查找文字\(([^\n]+)\)",r)
  Return
s:=StrReplace(s,r)
StringSplit, r, r1, `,, ""
if r0<6
  Return
t1:=A_TickCount
ok:=查找文字(r1,r2,s,r4,r5,r6,X,Y,OCR,r10,r11,id)
t1:=A_TickCount-t1
MsgBox, 4096,, % "查找结果：" (ok ? "成功":"失败")
  . "`n`n文字识别结果：" OCR
  . "`n`n耗时：" t1 " 毫秒，找到的位置：" (ok ? X "," Y:"")
if ok
{
  MouseMove, X, Y
  Sleep, 1000
}
else if id=0
  MsgBox, 4096,, 后台窗口没有找到（建议修改标题）：`n`n%tt%
Return


生成抓字窗口:
Gui, Catch:Default
Gui, +LastFound +AlwaysOnTop +ToolWindow +HwndCatch_ID
Gui, Margin, 15, 15
Gui, Color, DDEEFF
Gui, Font, s16, Verdana
ListLines, Off
Loop, % nH*nW {
  j:=A_Index=1 ? "" : Mod(A_Index,nW)=1 ? "xm y+-1" : "x+-1"
  Gui, Add, Progress, w15 h15 %j% -Theme
}
ListLines, On
Gui, Add, Text,   xm y+21   w50 Center, 选色
Gui, Add, Edit,   x+2       w130
Gui, Add, Button, x+2 yp-6  w140 gRun, 颜色二值化
;-------------------------
Gui, Add, Text,   x+10 yp+6 w50 Center, 阀值
Gui, Add, Edit,   x+2       w70
Gui, Add, Button, x+2 yp-6  w140 gRun Default, 灰度二值化
;-------------------------
Gui, Add, Text,   x+10 yp+6 w50 Center, 字库
Gui, Add, Edit,   x+2       w90
Gui, Add, Checkbox, x+4 yp+6 w80 gRun, 修改
Gui, Add, Button, x+0 yp-6  wp gRun Section, 分割
Gui, Add, Button, x+0       wp gRun, 确定
;-------------------------
Gui, Add, Text,   xm y+10   w50 Center, 灰度
Gui, Add, Edit,   x+2       w130
Gui, Add, Text,   x+2       w140 Center, 边缘灰度差
Gui, Add, Edit,   x+2       w100, 50
Gui, Add, Button, x+2 yp-6  w140 gRun, 灰差二值化
Gui, Add, Checkbox, x+25 yp+6 w80 gRun, 后台
Gui, Add, Button, x+5 yp-6  wp gRun, 反色
Gui, Add, Button, xs yp     wp gRun, 插入
Gui, Add, Button, x+0       wp gCancel, 关闭
;-------------------------
Gui, Add, Button, xm        w80 gRun, 左删
Gui, Add, Button, x+0       wp gRun, 左3删
Gui, Add, Button, x+25      wp gRun, 右删
Gui, Add, Button, x+0       wp gRun, 右3删
Gui, Add, Button, x+25      wp gRun, 上删
Gui, Add, Button, x+0       wp gRun, 上3删
Gui, Add, Button, x+25      wp gRun, 下删
Gui, Add, Button, x+0       wp gRun, 下3删
Gui, Add, Button, x+25      wp gRun, 智删
Gui, Add, Button, x+25      wp gRun, 重读
Gui, Show, Hide, 抓字生成二值化字符串
WinGet, s, ControlListHwnd
C_:=StrSplit(s,"`n"), s:=""
Return

Run:
Critical
k:=A_GuiControl
if IsLabel(k)
  Goto, %k%
Return

后台:
GuiControlGet, houtai,, %A_GuiControl%
if houtai
{
  ToolTip, % "【后台】抓取——"
    . "`n相当于把指定ID的窗口搬到前台再抓取"
  cors:=getc(px,py,zhua_id)
}
else
{
  ToolTip, 【前台】抓取——
  cors:=getc(px,py)
}
Gui, Catch:Default
Gosub, 重读
SetTimer, tipOff, -3000
Return
tipOff:
ToolTip
Return

修改:
GuiControlGet, xiugai,, %A_GuiControl%
Return

SetColor:
c:=c="White" ? 0xFFFFFF : c="Black" ? 0x000000
  : ((c&0xFF)<<16)|(c&0xFF00)|((c&0xFF0000)>>16)
SendMessage, 0x2001, 0, c,, % "ahk_id " . C_[k]
Return

重读:
if !IsObject(cc)
  cc:=[], gg:=[], pp:=[]
left:=right:=up:=down:=k:=0, bg:=""
Loop, % nH*nW {
  cc[++k]:=1, c:=cors[k]
  gg[k]:=((c>>16&0xFF)*38+(c>>8&0xFF)*75+(c&0xFF)*15)>>7
  Gosub, SetColor
}
; 裁剪抓字范围超过屏幕边界的部分
Loop, % cors.left
  Gosub, 左删
Loop, % cors.right
  Gosub, 右删
Loop, % cors.up
  Gosub, 上删
Loop, % cors.down
  Gosub, 下删
Return

颜色二值化:
GuiControlGet, r,, Edit1
if r=
{
  MsgBox, 4096,, `n    请先进行选色！    `n, 1
  Return
}
color:=r, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  if (cors[k]=color)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

灰度二值化:  ; 可以多次手动输入阀值或清空阀值再次二值化
GuiControl, Focus, Edit2
GuiControlGet, fazhi,, Edit2
if fazhi=
{
  Loop, 256    ; 统计灰度直方图
    pp[A_Index-1]:=0
  Loop, % nH*nW
    if (cc[A_Index]!="")
      pp[gg[A_Index]]++
  ; 迭代法求二值化阈值，最多迭代20次，这个算法非常快速
  IP:=IS:=0
  Loop, 256
    k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
  Newfazhi:=Floor(IP/IS)
  Loop, 20 {
    fazhi:=Newfazhi
    IP1:=IS1:=0
    Loop, % fazhi+1
      k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
    IP2:=IP-IP1, IS2:=IS-IS1
    if (IS1!=0 and IS2!=0)
      Newfazhi:=Floor((IP1/IS1+IP2/IS2)/2)
    if (Newfazhi=fazhi)
      Break
  }
  GuiControl,, Edit2, %fazhi%
}
color:="*" fazhi, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  if (gg[k]<fazhi+1)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

灰差二值化:
GuiControlGet, r,, Edit5
if r=
{
  MsgBox, 4096,, `n  请先设置边缘灰度差（比如50）！  `n, 1
  Return
}
fazhi:=Round(r)
if (left=cors.left)
  Gosub, 左删
if (right=cors.right)
  Gosub, 右删
if (up=cors.up)
  Gosub, 上删
if (down=cors.down)
  Gosub, 下删
color:="**" fazhi, k:=i:=0
Loop, % nH*nW {
  if (cc[++k]="")
    Continue
  c:=gg[k]+fazhi
  if (gg[k-1]>c or gg[k+1]>c or gg[k-nW]>c or gg[k+nW]>c)
    cc[k]:="0", c:="Black", i++
  else
    cc[k]:="_", c:="White", i--
  Gosub, SetColor
}
bg:=i>0 ? "0":"_"  ; 背景色
Return

gui_del:
cc[k]:="", c:="0xDDEEFF"
Gosub, SetColor
Return

左3删:
Loop, 3
  Gosub, 左删
Return

左删:
if (left+right>=nW)
  Return
left++, k:=left
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

右3删:
Loop, 3
  Gosub, 右删
Return

右删:
if (left+right>=nW)
  Return
right++, k:=nW+1-right
Loop, %nH% {
  Gosub, gui_del
  k+=nW
}
Return

上3删:
Loop, 3
  Gosub, 上删
Return

上删:
if (up+down>=nH)
  Return
up++, k:=(up-1)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

下3删:
Loop, 3
  Gosub, 下删
Return

下删:
if (up+down>=nH)
  Return
down++, k:=(nH-down)*nW
Loop, %nW% {
  k++
  Gosub, gui_del
}
Return

getwz:
wz=
if bg=
  Return
ListLines, Off
k:=0
Loop, %nH% {
  v=
  Loop, %nW%
    v.=cc[++k]
  wz.=v="" ? "" : v "`n"
}
ListLines, On
Return

智删:
Gosub, getwz
if wz=
{
  MsgBox, 4096, 提示, `n请先进行一种二值化！, 1
  Return
}
While InStr(wz,bg) {
  if (wz~="^" bg "+\n")
  {
    wz:=RegExReplace(wz,"^" bg "+\n")
    Gosub, 上删
  }
  else if !(wz~="m`n)[^\n" bg "]$")
  {
    wz:=RegExReplace(wz,"m`n)" bg "$")
    Gosub, 右删
  }
  else if (wz~="\n" bg "+\n$")
  {
    wz:=RegExReplace(wz,"\n\K" bg "+\n$")
    Gosub, 下删
  }
  else if !(wz~="m`n)^[^\n" bg "]")
  {
    wz:=RegExReplace(wz,"m`n)^" bg)
    Gosub, 左删
  }
  else Break
}
wz=
Return

确定:
分割:
反色:
Gosub, getwz
if wz=
{
  MsgBox, 4096, 提示, `n请先进行一种二值化！, 1
  Return
}
if A_ThisLabel=反色
{
  wz:="", k:=0, bg:=bg="0" ? "_":"0"
  color:=InStr(color,"-") ? StrReplace(color,"-"):"-" color
  Loop, % nH*nW
    if (c:=cc[++k])!=""
    {
      cc[k]:=c="0" ? "_":"0", c:=c="0" ? "White":"Black"
      Gosub, SetColor
    }
  Return
}
Gui, Hide
; 生成代码中的坐标为裁剪后整体文字的中心位置
px1:=px-ww+left+(nW-left-right)//2
py1:=py-hh+up+(nH-up-down)//2
GuiControlGet, ziku,, Edit3
ziku:=Trim(ziku), s:="`n文字=`n"
if A_ThisLabel=分割
{
  SetFormat, IntegerFast, d  ; 正则表达式中数字需要十进制
  Loop {
    While InStr(wz,bg) and !(wz~="m`n)^[^\n" bg "]")
      wz:=RegExReplace(wz,"m`n)^.")
    Loop, % InStr(wz,"`n")-1 {
      i:=A_Index
      if !(wz~="m`n)^.{" i "}[^\n" bg "]")
      {
        ; 自动分割会裁边，小数点等的字库要手动制作
        v:=RegExReplace(wz,"m`n)^(.{" i "}).*","$1")
        v:=RegExReplace(v,"^(" bg "+\n)+")
        v:=RegExReplace(v,"\n\K(" bg "+\n)+$")
        k:=SubStr(ziku,1,1), ziku:=SubStr(ziku,2)
        s.="`n文字=%文字%|< " k " >`n(`n" v ")`n"
        wz:=RegExReplace(wz,"m`n)^.{" i "}")
        Continue, 2
      }
    }
    Break
  }
}
else
  s.="`n文字=%文字%|< " ziku " >`n(`n" wz ")`n"
if (houtai=1) and WinExist("ahk_id " zhua_id)
{
  WinGetTitle, tt
  WinGetClass, tc
  tt:=InStr(tt,"`n") ? "" : SubStr(tt,1,50)
  if !A_IsUnicode
  {
    GuiControl, Main:, Edit1, %tt%
    GuiControlGet, r, Main:, Edit1
    if (r!=tt)
      tt:=SubStr(tt,1,-1)
  }
  tt:=StrReplace(tt,"``","````")
  tt:=StrReplace(tt,";","``;")
  tt:=StrReplace(tt,"""","""""")
  tt:=Trim(tc="" ? tt : tt " ahk_class " tc)
  s.="`nSetTitleMatchMode, 2  `; ahk_class 前面"
    . "部分的标题可以只保留部分字符或不要`n"
    . "`nid:=WinExist(""" tt """)`n", r:=",id"
} else r=
s.="`nif 查找文字(" px1 "," py1 ",文字,"""
  . color """,150000,150000,X,Y,OCR,0,0" r ")`n"
  . "{`n  CoordMode, Mouse`n  MouseMove, X, Y`n}`n"
GuiControl, Main:, Edit1, %s%
s:=wz:=""
Return

插入:
Gosub, getwz
if wz=
{
  MsgBox, 4096, 提示, `n请先进行一种二值化！, 1
  Return
}
Gui, Hide
GuiControlGet, ziku,, Edit3
s:="`r`n文字=%文字%|< " ziku " >`r`n(`r`n"
  . StrReplace(wz,"`n","`r`n") . ")`r`n"
Control, EditPaste, %s%,, ahk_id %hscr%
Return


;---- 将后面的函数附加到自己的脚本中 ----


;-----------------------------------------
; 查找屏幕文字/图像字符串及OCR识别
; 注意：参数中的x、y为中心点坐标，w、h为左右上下偏移
; cha1、cha0分别为0、_字符的容许减少百分比
;-----------------------------------------
查找文字(x,y,wz,c,w=150,h=150,ByRef rx="",ByRef ry=""
  ,ByRef ocr="",cha1=0,cha0=0,id="")
{
  ; 获取包含所有显示器的虚拟屏幕范围
  SysGet, zx, 76
  SysGet, zy, 77
  SysGet, zw, 78
  SysGet, zh, 79
  left:=x-w, right:=x+w, up:=y-h, down:=y+h
  left:=left<zx ? zx:left
  right:=right>zx+zw-1 ? zx+zw-1:right
  up:=up<zy ? zy:up, down:=down>zy+zh-1 ? zy+zh-1:down
  x:=left, y:=up, w:=right-left+1, h:=down-up+1
  if (w<1 or h<1)
    Return, 0
  bch:=A_BatchLines
  SetBatchLines, -1
  ;--------------------------------------
  GetBitsFromScreen(x,y,w,h,Scan0,Stride,bits,id)
  ;--------------------------------------
  ; 设定图内查找范围，注意不要越界
  sx:=0, sy:=0, sw:=w, sh:=h
  if PicOCR(Scan0,Stride,sx,sy,sw,sh,wz,c
    ,rx,ry,ocr,cha1,cha0)
  {
    rx+=x, ry+=y
    SetBatchLines, %bch%
    Return, 1
  }
  ; 容差为0的若失败则使用 5% 的容差再找一次
  if (cha1=0 and cha0=0)
    and PicOCR(Scan0,Stride,sx,sy,sw,sh,wz,c
      ,rx,ry,ocr,0.05,0.05)
  {
    rx+=x, ry+=y
    SetBatchLines, %bch%
    Return, 1
  }
  SetBatchLines, %bch%
  Return, 0
}

;------------------------------
; 获取虚拟屏幕的图像数据
;------------------------------
GetBitsFromScreen(x,y,w,h,ByRef Scan0,ByRef Stride
  ,ByRef bits,id="")
{
  VarSetCapacity(bits, w*h*4, 0)
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  ; 桌面窗口对应包含所有显示器的虚拟屏幕
  win:=DllCall("GetDesktopWindow", Ptr)
  hDC:=DllCall("GetDC", Ptr,win, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  hBM:=DllCall("CreateCompatibleBitmap", Ptr,hDC
    , "int",w, "int",h, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  DllCall("BitBlt", Ptr,mDC, "int",0, "int",0, "int",w
    , "int",h, Ptr,hDC, "int",x, "int",y, "uint",0xCC0020)
  DllCall("ReleaseDC", Ptr,win, Ptr,hDC)
  ; 将指定ID的后台窗口图像叠加到拷贝好的屏幕选择图像上
  ; 由于 PrintWindow 的限制，暂不支持最小化的窗口
  if (id)
    WinGet, id, ID, ahk_id %id%
  if (id)
  {
    WinGetPos, zx, zy, zw, zh, ahk_id %id%
    x1:=x>zx ? x:zx, y1:=y>zy ? y:zy
    x2:=(x+w-1)<(zx+zw-1) ? (x+w-1):(zx+zw-1)
    y2:=(y+h-1)<(zy+zh-1) ? (y+h-1):(zy+zh-1)
    sw:=x2-x1+1, sh:=y2-y1+1
  }
  if (id) and (sw>0 and sh>0)
  {
    hDC2:=DllCall("GetWindowDC", Ptr,id, Ptr)
    mDC2:=DllCall("CreateCompatibleDC", Ptr,hDC2, Ptr)
    hBM2:=DllCall("CreateCompatibleBitmap", Ptr,hDC2
      , "int",zw, "int",zh, Ptr)
    oBM2:=DllCall("SelectObject", Ptr,mDC2, Ptr,hBM2, Ptr)
    DllCall("PrintWindow", Ptr,id, Ptr,mDC2, "int",0)
    DllCall("BitBlt", Ptr,mDC
      , "int",x1-x, "int",y1-y, "int",sw, "int",sh, Ptr,mDC2
      , "int",x1-zx, "int",y1-zy, "uint",0x00CC0020)
    DllCall("SelectObject", Ptr,mDC2, Ptr,oBM2)
    DllCall("DeleteObject", Ptr,hBM2)
    DllCall("DeleteDC", Ptr,mDC2)
    DllCall("ReleaseDC", Ptr,id, Ptr,hDC2)
  }
  VarSetCapacity(bi, 40, 0)
  NumPut(40, bi, 0, "int"), NumPut(w, bi, 4, "int")
  NumPut(-h, bi, 8, "int"), NumPut(1, bi, 12, "short")
  NumPut(bpp:=32, bi, 14, "short"), NumPut(0, bi, 16, "int")
  DllCall("GetDIBits", Ptr,mDC, Ptr,hBM
    , "int",0, "int",h, Ptr,&bits, Ptr,&bi, "int",0)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteObject", Ptr,hBM)
  DllCall("DeleteDC", Ptr,mDC)
  Scan0:=&bits, Stride:=((w*bpp+31)//32)*4
}

;-----------------------------------------
; 图像内查找文字/图像字符串及OCR函数
;-----------------------------------------
PicOCR(Scan0, Stride, sx, sy, sw, sh, wenzi, c
  , ByRef rx, ByRef ry, ByRef ocr, cha1, cha0)
{
  static MyFunc
  if !MyFunc
  {
    x32:="5589E55383EC608B45200FAF45188B551CC1E20201D0894"
    . "5F08B5524B80000000029D0C1E00289C28B451801D08945ECC"
    . "745E800000000C745D400000000C745D0000000008B4524894"
    . "5CC8B45288945C8C745C400000000837D08000F85B20000008"
    . "B450CC1E81025FF0000008945C08B450CC1E80825FF0000008"
    . "945BC8B450C25FF0000008945B8C745F400000000EB75C745F"
    . "800000000EB5A8B45F083C00289C28B451401D00FB6000FB6C"
    . "03B45C075368B45F083C00189C28B451401D00FB6000FB6C03"
    . "B45BC751E8B55F08B451401D00FB6000FB6C03B45B8750B8B5"
    . "5E88B453001D0C600318345F8018345F0048345E8018B45F83"
    . "B45247C9E8345F4018B45EC0145F08B45F43B45287C83E9170"
    . "20000837D08010F85A30000008B450C83C001C1E00789450CC"
    . "745F400000000EB7DC745F800000000EB628B45F083C00289C"
    . "28B451401D00FB6000FB6C06BD0268B45F083C00189C18B451"
    . "401C80FB6000FB6C06BC04B8D0C028B55F08B451401D00FB60"
    . "00FB6D089D0C1E00429D001C83B450C730B8B55E88B453001D"
    . "0C600318345F8018345F0048345E8018B45F83B45247C96834"
    . "5F4018B45EC0145F08B45F43B45280F8C77FFFFFFE96A01000"
    . "0C745F400000000EB7BC745F800000000EB608B55E88B452C8"
    . "D0C028B45F083C00289C28B451401D00FB6000FB6C06BD0268"
    . "B45F083C00189C38B451401D80FB6000FB6C06BC04B8D1C028"
    . "B55F08B451401D00FB6000FB6D089D0C1E00429D001D8C1F80"
    . "788018345F8018345F0048345E8018B45F83B45247C988345F"
    . "4018B45EC0145F08B45F43B45280F8C79FFFFFF8B452483E80"
    . "18945B48B452883E8018945B0C745F401000000E9B0000000C"
    . "745F801000000E9940000008B45F40FAF452489C28B45F801D"
    . "08945E88B55E88B452C01D00FB6000FB6D08B450C01D08945E"
    . "C8B45E88D50FF8B452C01D00FB6000FB6C03B45EC7F488B45E"
    . "88D50018B452C01D00FB6000FB6C03B45EC7F328B45E82B452"
    . "489C28B452C01D00FB6000FB6C03B45EC7F1A8B55E88B45240"
    . "1D089C28B452C01D00FB6000FB6C03B45EC7E0B8B55E88B453"
    . "001D0C600318345F8018B45F83B45B40F8C60FFFFFF8345F40"
    . "18B45F43B45B00F8C44FFFFFFC745E800000000E9E30000008"
    . "B45E88D1485000000008B454001D08B008945E08B45E08945E"
    . "48B45E48945F08B45E883C0018D1485000000008B454001D08"
    . "B008945B48B45E883C0028D1485000000008B454001D08B008"
    . "945B0C745F400000000EB7CC745F800000000EB678B45F08D5"
    . "0018955F089C28B453401D00FB6003C3175278B45E48D50018"
    . "955E48D1485000000008B453801C28B45F40FAF452489C18B4"
    . "5F801C88902EB258B45E08D50018955E08D1485000000008B4"
    . "53C01C28B45F40FAF452489C18B45F801C889028345F8018B4"
    . "5F83B45B47C918345F4018B45F43B45B00F8C78FFFFFF8345E"
    . "8078B45E83B45440F8C11FFFFFF8B45D00FAF452489C28B45D"
    . "401D08945F08B45240FAF45C8BA0100000029C289D08945E4C"
    . "745F800000000E9B5020000C745F400000000E993020000C74"
    . "5E800000000E9710200008B45E883C0018D1485000000008B4"
    . "54001D08B008945B48B45E883C0028D1485000000008B45400"
    . "1D08B008945B08B55F88B45B401D03B45CC0F8F2D0200008B5"
    . "5F48B45B001D03B45C80F8F1C0200008B45E88D14850000000"
    . "08B454001D08B008945E08B45E883C0038D1485000000008B4"
    . "54001D08B008945AC8B45E883C0048D1485000000008B45400"
    . "1D08B008945A88B45E883C0058D1485000000008B454001D08"
    . "B008945DC8B45E883C0068D1485000000008B454001D08B008"
    . "945D88B45AC3945A80F4D45A88945A4C745EC00000000E9820"
    . "000008B45EC3B45AC7D378B55E08B45EC01D08D14850000000"
    . "08B453801D08B108B45F001D089C28B453001D00FB6003C317"
    . "40E836DDC01837DDC000F884E0100008B45EC3B45A87D378B5"
    . "5E08B45EC01D08D1485000000008B453C01D08B108B45F001D"
    . "089C28B453001D00FB6003C30740E836DD801837DD8000F881"
    . "20100008345EC018B45EC3B45A40F8C72FFFFFF837DC4000F8"
    . "5840000008B551C8B45F801C28B454889108B454883C0048B4"
    . "D208B55F401CA89108B45488D50088B45B489028B45488D500"
    . "C8B45B08902C745C4040000008B45F42B45B08945D08B55B08"
    . "9D001C001D08945C88B55B089D0C1E00201D001C083C064894"
    . "5CC837DD0007907C745D0000000008B45282B45D03B45C87D2"
    . "E8B45282B45D08945C8EB238B45F83B45107E1B8B45C48D500"
    . "18955C48D1485000000008B454801D0C700FFFFFFFF8B45C48"
    . "D50018955C48D1485000000008B454801D08B55E883C207891"
    . "0817DC4FD0300007F788B55F88B45B401D00145D48B45242B4"
    . "5D43B45CC0F8D60FDFFFF8B45242B45D48945CCE952FDFFFF9"
    . "0EB0490EB01908345E8078B45E83B45440F8C83FDFFFF8345F"
    . "4018B45240145F08B45F43B45C80F8C61FDFFFF8345F8018B4"
    . "5E40145F08B45F83B45CC0F8C3FFDFFFF837DC4007508B8000"
    . "00000EB1B908B45C48D1485000000008B454801D0C70000000"
    . "000B80100000083C4605B5DC2440090"
    x64:="554889E54883EC60894D10895518448945204C894D288B4"
    . "5400FAF45308B5538C1E20201D08945F48B5548B8000000002"
    . "9D0C1E00289C28B453001D08945F0C745EC00000000C745D80"
    . "0000000C745D4000000008B45488945D08B45508945CCC745C"
    . "800000000837D10000F85C90000008B4518C1E81025FF00000"
    . "08945C48B4518C1E80825FF0000008945C08B451825FF00000"
    . "08945BCC745F800000000E985000000C745FC00000000EB6A8"
    . "B45F483C0024863D0488B45284801D00FB6000FB6C03B45C47"
    . "5438B45F483C0014863D0488B45284801D00FB6000FB6C03B4"
    . "5C075288B45F44863D0488B45284801D00FB6000FB6C03B45B"
    . "C75108B45EC4863D0488B45604801D0C600318345FC018345F"
    . "4048345EC018B45FC3B45487C8E8345F8018B45F00145F48B4"
    . "5F83B45500F8C6FFFFFFFE959020000837D10010F85B600000"
    . "08B451883C001C1E007894518C745F800000000E98D000000C"
    . "745FC00000000EB728B45F483C0024863D0488B45284801D00"
    . "FB6000FB6C06BD0268B45F483C0014863C8488B45284801C80"
    . "FB6000FB6C06BC04B8D0C028B45F44863D0488B45284801D00"
    . "FB6000FB6D089D0C1E00429D001C83B451873108B45EC4863D"
    . "0488B45604801D0C600318345FC018345F4048345EC018B45F"
    . "C3B45487C868345F8018B45F00145F48B45F83B45500F8C67F"
    . "FFFFFE999010000C745F800000000E98D000000C745FC00000"
    . "000EB728B45EC4863D0488B4558488D0C028B45F483C002486"
    . "3D0488B45284801D00FB6000FB6C06BD0268B45F483C0014C6"
    . "3C0488B45284C01C00FB6000FB6C06BC04B448D04028B45F44"
    . "863D0488B45284801D00FB6000FB6D089D0C1E00429D04401C"
    . "0C1F80788018345FC018345F4048345EC018B45FC3B45487C8"
    . "68345F8018B45F00145F48B45F83B45500F8C67FFFFFF8B454"
    . "883E8018945B88B455083E8018945B4C745F801000000E9CA0"
    . "00000C745FC01000000E9AE0000008B45F80FAF454889C28B4"
    . "5FC01D08945EC8B45EC4863D0488B45584801D00FB6000FB6D"
    . "08B451801D08945F08B45EC4898488D50FF488B45584801D00"
    . "FB6000FB6C03B45F07F538B45EC4898488D5001488B4558480"
    . "1D00FB6000FB6C03B45F07F388B45EC2B45484863D0488B455"
    . "84801D00FB6000FB6C03B45F07F1D8B55EC8B454801D04863D"
    . "0488B45584801D00FB6000FB6C03B45F07E108B45EC4863D04"
    . "88B45604801D0C600318345FC018B45FC3B45B80F8C46FFFFF"
    . "F8345F8018B45F83B45B40F8C2AFFFFFFC745EC00000000E90"
    . "D0100008B45EC4898488D148500000000488B8580000000480"
    . "1D08B008945E48B45E48945E88B45E88945F48B45EC4898488"
    . "3C001488D148500000000488B85800000004801D08B008945B"
    . "88B45EC48984883C002488D148500000000488B85800000004"
    . "801D08B008945B4C745F800000000E989000000C745FC00000"
    . "000EB748B45F48D50018955F44863D0488B45684801D00FB60"
    . "03C31752C8B45E88D50018955E84898488D148500000000488"
    . "B45704801C28B45F80FAF454889C18B45FC01C88902EB2A8B4"
    . "5E48D50018955E44898488D148500000000488B45784801C28"
    . "B45F80FAF454889C18B45FC01C889028345FC018B45FC3B45B"
    . "87C848345F8018B45F83B45B40F8C6BFFFFFF8345EC078B45E"
    . "C3B85880000000F8CE4FEFFFF8B45D40FAF454889C28B45D80"
    . "1D08945F48B45480FAF45CCBA0100000029C289D08945E8C74"
    . "5FC00000000E929030000C745F800000000E907030000C745E"
    . "C00000000E9E20200008B45EC48984883C001488D148500000"
    . "000488B85800000004801D08B008945B88B45EC48984883C00"
    . "2488D148500000000488B85800000004801D08B008945B48B5"
    . "5FC8B45B801D03B45D00F8F8C0200008B55F88B45B401D03B4"
    . "5CC0F8F7B0200008B45EC4898488D148500000000488B85800"
    . "000004801D08B008945E48B45EC48984883C003488D1485000"
    . "00000488B85800000004801D08B008945B08B45EC48984883C"
    . "004488D148500000000488B85800000004801D08B008945AC8"
    . "B45EC48984883C005488D148500000000488B8580000000480"
    . "1D08B008945E08B45EC48984883C006488D148500000000488"
    . "B85800000004801D08B008945DC8B45B03945AC0F4D45AC894"
    . "5A8C745F000000000E9920000008B45F03B45B07D3F8B55E48"
    . "B45F001D04898488D148500000000488B45704801D08B108B4"
    . "5F401D04863D0488B45604801D00FB6003C31740E836DE0018"
    . "37DE0000F88790100008B45F03B45AC7D3F8B55E48B45F001D"
    . "04898488D148500000000488B45784801D08B108B45F401D04"
    . "863D0488B45604801D00FB6003C30740E836DDC01837DDC000"
    . "F88350100008345F0018B45F03B45A80F8C62FFFFFF837DC80"
    . "00F85970000008B55388B45FC01C2488B85900000008910488"
    . "B85900000004883C0048B4D408B55F801CA8910488B8590000"
    . "000488D50088B45B88902488B8590000000488D500C8B45B48"
    . "902C745C8040000008B45F82B45B48945D48B55B489D001C00"
    . "1D08945CC8B55B489D0C1E00201D001C083C0648945D0837DD"
    . "4007907C745D4000000008B45502B45D43B45CC7D368B45502"
    . "B45D48945CCEB2B8B45FC3B45207E238B45C88D50018955C84"
    . "898488D148500000000488B85900000004801D0C700FFFFFFF"
    . "F8B45C88D50018955C84898488D148500000000488B8590000"
    . "0004801D08B55EC83C2078910817DC8FD0300007F7B8B55FC8"
    . "B45B801D00145D88B45482B45D83B45D00F8DEFFCFFFF8B454"
    . "82B45D88945D0E9E1FCFFFF90EB0490EB01908345EC078B45E"
    . "C3B85880000000F8C0FFDFFFF8345F8018B45480145F48B45F"
    . "83B45CC0F8CEDFCFFFF8345FC018B45E80145F48B45FC3B45D"
    . "00F8CCBFCFFFF837DC8007508B800000000EB23908B45C8489"
    . "8488D148500000000488B85900000004801D0C70000000000B"
    . "8010000004883C4605DC390909090909090909090"
    MCode(MyFunc, A_PtrSize=8 ? x64:x32)
  }
  ;--------------------------------------
  ; 统计字库文字的个数和宽高，将解释文字存入数组并删除<>
  ;--------------------------------------
  wenzitab:=[], num:=0, wz:="", j:=""
  fmt:=A_FormatInteger
  SetFormat, IntegerFast, d    ; 正则表达式中要用十进制
  Loop, Parse, wenzi, |
  {
    v:=A_LoopField, txt:=""
    e1:=cha1, e0:=cha0
    ; 用角括号输入每个字库字符串的识别结果文字
    if RegExMatch(v,"<([^>]*)>",r)
      v:=StrReplace(v,r), txt:=r1
    ; 可以用中括号输入每个文字的两个容差，以逗号分隔
    if RegExMatch(v,"\[([^\]]*)]",r)
    {
      v:=StrReplace(v,r), r2:=""
      StringSplit, r, r1, `,
      e1:=r1, e0:=r2
    }
    ; 记录每个文字的起始位置、宽、高、10字符的数量和容差
    v:=Trim(RegExReplace(v,"[^_0\n]+"),"`n") . "`n"
    w:=InStr(v,"`n")-1, h:=StrLen(v)//(w+1)
    re:="[0_]{" w "}\n"
    if (w>sw or h>sh or w<1 or RegExReplace(v,re)!="")
      Continue
    v:=StrReplace(v,"`n")
    if InStr(c,"-")
      v:=StrReplace(v,"_","1"), r:=e1, e1:=e0, e0:=r
    else
      v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    len1:=StrLen(StrReplace(v,"0"))
    len0:=StrLen(StrReplace(v,"1"))
    e1:=Round(len1*e1), e0:=Round(len0*e0)
    j.=StrLen(wz) "|" w "|" h
      . "|" len1 "|" len0 "|" e1 "|" e0 "|"
    wz.=v, wenzitab[++num]:=Trim(txt)
  }
  SetFormat, IntegerFast, %fmt%
  if wz=
    Return, 0
  ;--------------------------------------
  ; wz 使用Astr参数类型可以自动转为ANSI版字符串
  ; in 输入各文字的起始位置等信息，out 返回结果
  ; ss 等为临时内存，jiange 超过间隔就会加入*号
  ;--------------------------------------
  mode:=InStr(c,"**") ? 2 : InStr(c,"*") ? 1 : 0
  c:=RegExReplace(c,"[*\-]"), jiange:=5, num*=7
  VarSetCapacity(in,num*4,0), i:=-4
  Loop, Parse, j, |
    if (A_Index<=num)
      NumPut(A_LoopField, in, i+=4, "int")
  VarSetCapacity(gs, sw*sh)
  VarSetCapacity(ss, sw*sh, Asc("0"))
  k:=StrLen(wz)*4
  VarSetCapacity(s1, k, 0), VarSetCapacity(s0, k, 0)
  VarSetCapacity(out, 1024*4, 0)
  if DllCall(&MyFunc, "int",mode, "uint",c
    , "int",jiange, "ptr",Scan0, "int",Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "ptr",&gs, "ptr",&ss
    , "Astr",wz, "ptr",&s1, "ptr",&s0
    , "ptr",&in, "int",num, "ptr",&out)
  {
    ocr:="", i:=-4  ; 返回第一个文字的中心位置
    x:=NumGet(out,i+=4,"int"), y:=NumGet(out,i+=4,"int")
    w:=NumGet(out,i+=4,"int"), h:=NumGet(out,i+=4,"int")
    rx:=x+w//2, ry:=y+h//2
    While (k:=NumGet(out,i+=4,"int"))
      v:=wenzitab[k//7], ocr.=v="" ? "*" : v
    Return, 1
  }
  Return, 0
}

MCode(ByRef code, hex)
{
  ListLines, Off
  bch:=A_BatchLines
  SetBatchLines, -1
  VarSetCapacity(code, StrLen(hex)//2)
  Loop, % StrLen(hex)//2
    NumPut("0x" . SubStr(hex,2*A_Index-1,2)
      , code, A_Index-1, "char")
  Ptr:=A_PtrSize ? "Ptr" : "UInt"
  DllCall("VirtualProtect", Ptr,&code, Ptr
    ,VarSetCapacity(code), "uint",0x40, Ptr . "*",0)
  SetBatchLines, %bch%
  ListLines, On
}


/************  机器码的C源码 ************

int __attribute__((__stdcall__)) OCR( int mode
  , unsigned int c, int jiange, unsigned char * Bmp
  , int Stride, int sx, int sy, int sw, int sh
  , unsigned char * gs, char * ss
  , char * wz, int * s1, int * s0
  , int * in, int num, int * out )
{
  int x, y, o=sy*Stride+sx*4, j=Stride-4*sw, i=0;
  int o1, o2, w, h, max, len1, len0, e1, e0;
  int sx1=0, sy1=0, sw1=sw, sh1=sh, Ptr=0;

  //准备工作一：先将图像各点在ss中转化为01字符
  if (mode==0)    //颜色模式
  {
    int R=(c>>16)&0xFF, G=(c>>8)&0xFF, B=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]==R && Bmp[1+o]==G && Bmp[o]==B)
          ss[i]='1';
  }
  else if (mode==1)    //灰度阀值模式
  {
    c=(c+1)*128;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        if (Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c)
          ss[i]='1';
  }
  else    //mode==2，边缘灰差模式
  {
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    w=sw-1; h=sh-1;
    for (y=1; y<h; y++)
    {
      for (x=1; x<w; x++)
      {
        i=y*sw+x; j=gs[i]+c;
        if (gs[i-1]>j || gs[i+1]>j
          || gs[i-sw]>j || gs[i+sw]>j)
            ss[i]='1';
      }
    }
  }

  //准备工作二：生成s1、s0查表数组
  for (i=0; i<num; i+=7)
  {
    o=o1=o2=in[i]; w=in[i+1]; h=in[i+2];
    for (y=0; y<h; y++)
    {
      for (x=0; x<w; x++)
      {
        if (wz[o++]=='1')
          s1[o1++]=y*sw+x;
        else
          s0[o2++]=y*sw+x;
      }
    }
  }

  //正式工作：ss中每一点都进行一次全字库匹配
  NextWenzi:
  o=sy1*sw+sx1; o1=1-sw*sh1;
  for (x=0; x<sw1; x++, o+=o1)
  {
    for (y=0; y<sh1; y++, o+=sw)
    {
      for (i=0; i<num; i+=7)
      {
        w=in[i+1]; h=in[i+2];
        if (x+w>sw1 || y+h>sh1)
          continue;
        o2=in[i]; len1=in[i+3]; len0=in[i+4];
        e1=in[i+5]; e0=in[i+6];
        max=len1>len0 ? len1 : len0;
        for (j=0; j<max; j++)
        {
          if (j<len1 && ss[o+s1[o2+j]]!='1' && (--e1)<0)
            goto NoMatch;
          if (j<len0 && ss[o+s0[o2+j]]!='0' && (--e0)<0)
            goto NoMatch;
        }
        //成功找到文字或图像
        if (Ptr==0)
        {
          out[0]=sx+x; out[1]=sy+y;
          out[2]=w; out[3]=h; Ptr=4;
          //找到第一个字就确定后续查找的上下范围和右边范围
          sy1=y-h; sh1=h*3; sw1=h*10+100;
          if (sy1<0)
            sy1=0;
          if (sh1>sh-sy1)
            sh1=sh-sy1;
        }
        else if (x>jiange)  //与前一字间隔较远就添加*号
          out[Ptr++]=-1;
        out[Ptr++]=i+7;
        if (Ptr>1021)    //返回的int数组中元素个数不超过1024
          goto ReturnOK;
        //继续从当前文字右边再次查找
        sx1+=x+w;
        if (sw1>sw-sx1)
          sw1=sw-sx1;
        goto NextWenzi;
        //------------
        NoMatch:
        continue;
      }
    }
  }
  if (Ptr==0)
    return 0;
  ReturnOK:
  out[Ptr]=0;
  return 1;
}

*/


;============ 脚本结束 =================

;