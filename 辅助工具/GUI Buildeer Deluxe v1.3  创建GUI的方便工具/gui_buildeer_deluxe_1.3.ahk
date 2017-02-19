/*
Name: GUI Buildeer Deluxe
Version 1.3 (Thursday, February 04, 2016)
Created: Saturday, January 02, 2016
Author: tidbit
Credit: 
	Family Dollar, For "providing" the delicious snacks (at discount prices) needed for making this program.
	Bugz000      , A currently unused function that may get added in eventually.

Hotkeys:
	esc   --- Quit
	enter --- Generate! but not Generate?
	maybe others
	
Description:
	Generate a gui with the press of a key. No more slaving away at trying to
	build a gui in a "Gui builder" or trying to figure out the code yourself, learning
	is overrated anyways.
	For the visually impaired or those who cannot read, there is also a Speak option.
	If you want some control, there's advanced settings for you to do stuff with.
	
Other info:
	Avalable controls (specify the number in the GUI)
	1=edit, 2=button, 3=checkbox, 4=radio, 5=ddl, 6=combobox
	7=hotkey, 8=datetime, 9=Listview, 10=slider, 11=progress

To-do:
	- groupbox, treeview, tabs, possibly activex (ie)
	- new positioning system to reduce the chance of oversized 90% empty guis
    
*/
#SingleInstance, force
_name_:="GUI Buildeer Deluxe"
_ver_:="1.3"

texts:=["","Settings","Width","Height","Color","Domains","Qualification"
,"Dock","IPR","ACSC's","Submit","OK","Okay","Send","Forward","Back","button"
,"add","remove","delete","...",A_DDDD,"Reports","Open","Easy","Size","Brand"
,"Rank","Polar bear pelts","QTY","Quality","Quantity","Material"
,"Hotkey","Macro: ","Operation","GHz","MHz","pudding","Select one: "]
lists:=["aaa||bbb|ccc|ddd|eee", "Car|Truck||Suv|Van|Boat", "1||2|3|4|5|6", "LDL||ISPS|QTR|AXTDs", "Goat|Pig|Cow|Crow|Ostrich|Alpaca||Gazelle"]



gui, settings: margin, 6, 6
gui, settings: +resize
; gui, settings: color, 0x8FBC8F
; gui, settings: font, s12
gui, settings: add, button, xm ym w200 default vgenbtn1 gdoTheStuff, Generate!
gui, settings: add, checkbox, xm y+m cgreen vspeak, Speak the controls
gui, settings: add, text, xm y+m cblue vtxt1, Controls* to add:
gui, settings: add, edit, x+m yp-3 w100 section number cblue vcCount, 7
gui, settings: add, updown, vud1, 7
gui, settings: add, text, xm y+m vtxt2, Gui name:
gui, settings: add, edit, xs yp-3 w100 vguiName,
gui, settings: add, text, xm y+-1 cgray vtxt3, *(control groups, such as a text+edit`nor three checkboxes)
GroupBox2("Settings", "speak,txt1,cCount,ud1,txt2,txt3,guiName", "settings")

gui, settings: add, checkbox, xm y+10 checked cgreen vaddvVars, Add vVariables?
gui, settings: add, checkbox, xm y+m  checked cgreen vaddgLabels, Add gLabels?
gui, settings: add, radio, xm y+m r3 cred section checked vmode1 gmode, Odds mode
gui, settings: add, radio, xp y+m r3 cred  vmode2 gmode, Order mode
gui, settings: add, edit, x+m ys w150 hp -wantreturn vodds, 1 1 1 1 2 2 2 2 3 3 4 5 5 6 6 7 8 9 10 10 11 11
gui, settings: add, edit, xp y+m w150 hp -wantreturn vorder, 1 1 2 10 11 9 5
gui, settings: add, text, xm y+-1 cgray vtxt4, *(1=edit, 2=button, 3=checkbox, 4=radio, 5=ddl,`n6=combobox, 7=hotkey, 8=datetime, 9=Listview,`n10=slider, 11=progress)

gui, settings: add, button, xs ys w100 r1 vdefaults gdefaults, Defaults

guiControlGet, pos, settings: pos, order
guiControl, settings: move, odds, % "x" posx
guiControlGet, pos2, settings: pos, addvVars
guiControl, settings: move, defaults, % "x" (posx+posw)//2 " y" pos2y+pos2h//2
; guiControl, settings: move, reset, % "x" pos2x+pos2w+6 " y" pos2y+pos2h//2

GroupBox2("Advanced settings", "mode1,mode2,odds,order,txt4,addvVars,addgLabels,defaults", "settings")

gui, settings: add, button, xm y+m w200 vgenbtn2 gdoTheStuff, Generate?

gui, settings: add, text, ym section, Output:
gui, settings: add, button, x+m ys-3 ghelp, What does this stuff mean?
gui, settings: add, button, x+m yp ghelp2, More help please!

gui, settings: font, s10, courier new
gui, settings: add, edit, xs y+m w430 r22 -wrap +hScroll vdisp

guiControlGet, pos, settings: pos, disp
guiControlGet, pos2, settings: pos, genbtn2
guiControl, settings: move, disp, % "h" pos2y+pos2h-posy

; Since your memory is poor, save some default values.
gui, settings: submit, nohide
dOdds:=odds
dOrder:=order
dVars:=addvVars
dLabels:=addgLabels

gosub, mode
gui, settings: show, x100 autoSize, % _name_ " - v" _ver_
return


; esc:: ; we don't need you either.
; 	critical
; 	exitapp
; return


settingsGuiClose:  ; you don't like me
settingsGuiEscape: ; you don't like me and you're too lazy to move the mouse
gennedGuiEscape:
	exitapp
return


settingsGuiSize: ; big, small, big, small
	guiControlGet, pos, settings: pos, disp
	guiControl, settings: move, disp, % "w" A_GuiWidth-posx-6 " h" A_GuiHeight-posy-6
return


mode: ; you pressed a radio button, probably
	gui, settings: default
	gui, settings: submit, nohide
	if (mode1=1)
		guiControl, settings: enable, cCount
	else if (mode2=1)
		guiControl, settings: disable, cCount
return


defaults:
	gui, settings: default
	guiControl, settings:, odds, %dOdds%
	guiControl, settings:, order, %dOrder%
	guiControl, settings:, addvVars, %dVars%
	guiControl, settings:, addgLabels, %dLabels%
return


help2:
	splitPath, A_AhkPath,, dur
	if (fileExist(dur "\AutoHotkey.chm"))
		run, hh mk:@MSITStore:%dur%\AutoHotkey.chm::/docs/commands/Gui.htm
	else
		msgBox, 48, Dang, You seem to be lacking something here... probably the help file.
return


help: ; because you need it
	help=
	(ltrim join`n
	OPTIONS:`tInformation for: gui, add, control, OPTIONS, text
	---
	x30`tx coordinates (coords) for the control, in pixels
	xm`tPosition the control to the GUIs "margin" (the default spacing)
	x+3`tPosition the control 3 pixels to the right of the previously added control
	xs`tPosition the control at the last controls x-coord that used the keyword "section"
	xp`tPosition the control at the previous added controls x-coord
	xp+3`tPosition the control at the previous added controls x-coord and indent 3 pixels
	y...`tHas all the same options as X, but for Y, obviously
	---
	w100`tWidth of the control, in pixels
	wp`tUse the previous controls width
	h100`tHeight of the control, in pixels
	hp`tUse the previous controls height
	r1`tSet the control to this many "text rows" tall. 1=1 line, 2=2 lines, etc.
	---
	vBanana`tControls output variable. This usually contains its value.
	`tYou DO NOT use the "v". Only use "Banana". "Banana" is the variable name.
	`t"v" only tells AHK that "banana is the variable for this control".
	gLabel`tThe label (section of code) to go to when the control is triggered.
	)
	help:=st_columnize(help, "`t")
	msgBox2(help, _name_ " - help", "r20 -wrap +hscroll readonly")
return


doTheStuff: ; did I stutter?
	critical ; prevent button spamming, because why not.
	gui, genned: destroy ; we don't need that old crap in our gui.
	gui, genned: default
	gui, settings: submit, nohide
	
	; !!! do not touch !!!
	codeArr:=[] ; raw code and settings
	cArr:=[]    ; the final control strings.
	vList:={}   ; used to generate variable names like banana1, banana2, ...
	gList:={}   ; is this label already in existence?
	odds:=strReplace(odds, ",", " ")   ; repace commas with spaces. lets users use , or space
	order:=strReplace(order, ",", " ") ; repace commas with spaces. lets users use , or space
	odds:=regExReplace(odds, "(\h){2,}", "$1")   ; remove excessive blanks
	order:=regExReplace(order, "(\h){2,}", "$1") ; remove excessive blanks

	guiName:=(guiName="") ? "" : guiName ": "

	if (speak=1) ; creative variable names at their finest.
	{
		guiControl, settings: disable, genbtn1
		guiControl, settings: disable, genbtn2
		lemons:=ComObjCreate("SAPI.SpVoice")
		lemons.rate:=3
	}
	
	if (mode1=1)
	{
		list:=strSplit(odds, " ")
		count:=cCount
	}
	else if (mode2=1)
	{
		list:=strSplit(order, " ")
		count:=list.maxIndex()
	}
	
	if (count<=0)
	{
		msgBox, Pretty sure you cannot do that.
		return
	}
	; generate the controls and their settings.
	; c... = control...
	loop, %count%
	{
		ctext:=texts[rand(texts.maxIndex())]
		clist:=lists[rand(lists.maxIndex())]
		cont:=list[(mode2=1) ? A_Index : rand(list.maxIndex())]
		
		cVar:=genLabelN(ctext)
		cVar:=(cVar="") ? "dummy" : cVar
		cPos:=genPos()
		cwidth:=rand(200,40)
		; cwidth:=(cwidth<30) ? "" : cwidth
		cRange1:=rand(30)       ; min for sliders/progress
		cRange2:=rand(300, 100) ; max for sliders/progress
		
		guiOptions:=cPos " w" cwidth " v" cVar
		guiOptions2:=guiOptions " g" cVar
		
		if (cont=1)
			codeArr.push(addEdit(ctext, 1, guiOptions))
		else if (cont=2)
			codeArr.push(addButton(ctext, 1, guiOptions2))
		else if (cont=3)
			codeArr.push(addCheckbox(ctext, 1, guiOptions2, rand(4,2)))
		else if (cont=4)
			codeArr.push(addCheckbox(ctext, 2, guiOptions2, rand(4,2)))
		else if (cont=5)
			codeArr.push(addEdit(clist, 2, guiOptions2))
		else if (cont=6)
			codeArr.push(addEdit(clist, 3, guiOptions2))
		else if (cont=7)
			codeArr.push(addEdit(ctext, 4, guiOptions))
		else if (cont=8)
			codeArr.push(addEdit(ctext, 5, guiOptions2))
		else if (cont=9)
			codeArr.push(addListview(clist, cPos " w" rand(400,100) 
			. " r" rand(15, 5) " vLV" cVar " g" cVar))
		else if (cont=10)
			codeArr.push(addButton(rand(cRange2, cRange1), 2, cPos " w" cwidth 
			. " tooltip range" cRange1 "-" cRange2 " v" cVar " g" cVar))
		else if (cont=11)
			codeArr.push(addButton(rand(cRange2, cRange1), 3, cPos " w" cwidth 
			. " range" cRange1 "-" cRange2
			. " c0x" format("{:x}{:x}{:x}", rand(255), rand(255), rand(255))
			. " background0xdeb887 v" cVar))
	}
	; msgBox % st_printArr(codeArr)
	; do some re-formatting to build the gui a bit easier.
	; probably not needed, but w/e.
	for key, arr in codeArr ; 'split' by the total number of items
	{
		loop, % arr["opts"].maxIndex()
		{
			options:="" ; never forget.
			ctype:=arr["sets", A_Index, "t"] ; control type
			clabel:=arr["sets", A_Index, "l"] ; control label (text)
			for bbb, arr2 in arr["opts", A_Index] ; I really hate doing this 2-for thingy
				for k, v in arr2
					if (k="v")
					{
						vvar:=trim(v)
						break, 2
					}
			if (vList.hasKey(vvar) && vvar!="") ; if this variable aready exists, add 1
				vList[vvar]+=1
			else if (vvar!="") ; otherwise it's new, set to 1
				vList[vvar]:=1
			arr["opts", A_Index, bbb, "v"].=vList[vvar] ; because
			
			; fileAppend, % st_printArr(arr["opts", A_Index]) "`n", * 
			for k, arr2 in arr["opts", A_Index] ; I really hate doing this 2-for thingy
				for k, v in arr2
					options.=" " k "" v
			cArr.push({"t":ctype, "l": clabel, "opts":options})
		}
	}

	; build the gui and generate the code
	codeOut:=""
	; msgBox, % st_printArr(codeArr)
	for k, v in cArr
	{
		t1:=trim(v.t), t2:=trim(v.opts), t3:=trim(v.l) ; the main gui sections.
		; msgBox % t2
		if (addvVars=0)
			t2:=regExReplace(t2, "i)\s?\b[v]\S+")
		if (addgLabels=0)
			t2:=regExReplace(t2, "i)\s?\b[g]\S+")
			
		t22:=regExReplace(t2, "i)\b[vg]\S+") ; don't create it with a glabel. it'll toss an error. v also isn't needed.
		gui, genned: add, %t1%, %t22%, %t3% 
		if (speak=1) ; you figure this out yourself
		{
			gui, genned: show, center autoSize
			lemons.speak((rand(5)=1) ? texts[rand(texts.maxIndex())] : t1)
		}
		
		if (t1="Listview") ; listviews need things inside them.
		{
			loop, % rand(10, 3) ; random amount of things.
			{
				temp:=A_Index ; the row of the listview
				LV_Add() ; probably adds a row?
				loop, % LV_GetCount("column") ; that many.
					LV_Modify(temp, "col" A_Index, texts[rand(texts.maxIndex())])
			}
			LV_ModifyCol() ; make the columns not tiny.
		}
		codeOut.="gui, " guiName "add, " t1 ", " t2 ", " t3 "`n"
	}

	; sloppy stuff below.
	codeOut:=st_columnize(codeOut, ",", [1,3][rand(2)], " ", ",")
	codeOut.="`n`ngui, " guiName "show,, " _name_ " - v" rand(200) ".0`nreturn"
	guiName2:=strReplace(guiName, ": ")
	temp=
	(ltrim join`n
	`n`n
	`; When you press escape or the [x] button, exit the program
	%guiName2%GuiEscape:
	%guiName2%GuiClose:
	`texitApp
	return
	)
	codeOut.=temp

	; add in the g-labels:
	; msgBox % "...ggg`n" st_printArr(vList)
	if (addgLabels=1)
	{
		for key, val in cArr
		{
			regExMatch(val["opts"], "i)\b[g](\S+)", o) ; o1 contains the glabel
			if (o1="" || gList.hasKey(o1))
				continue
					
			codeSample:=""
			if (val["t"]="button")
			{
				temp:=rand(vList.GetCapacity()-1)
				temp2:=texts[rand(texts.maxIndex())]
				for k, v in vList
					if (A_Index=temp)
						temp:=k rand(v)
				if (SubStr(temp, 1, 2)="LV") ; listviews. they suck.
					codeSample:="`n`tLV_Add("""", """ temp2 """, """ texts[rand(texts.maxIndex())] """)"
				else
				{
					codeSample:="`n`tguiControl, " guiName ", " temp ", " temp2
					if (rand(2)=1) ; move the control.
					{
						codeSample:="`n`tguiControlGet, moveIt, " guiName "pos, " temp
						codeSample.="`n`tguiControl, " guiName "movedraw, " temp
						. ", `% ""x"" moveItX+5 "" y"" moveItY+2"
						codeSample.="`n`t; guiControl, " guiName "movedraw, " temp ", x5 y2"
					}
				}
			}
			gList[o1]:=1 ; this label has now been used. do not add another.
			temp=
			(ltrim join`n
			`n`n
			%o1%:
			`tgui, %guiName%submit, noHide
			`t`; Your code here%codeSample%
			return
			)
			codeOut.=temp
		}
	}

	if (speak=1) ; I hope you understand what this means by now...
		lemons.rate:=0, lemons.speak("Your ""G. u. i."" is complete")
	
	guiControl, settings:, disp, %codeOut%
	; gui, genned: +ownersettings
	gui, genned: show, autoSize NA, % _name_ " - v" rand(200) ".0"
	
	if (speak=1) ; I give up.
	{
		lemons.speak("Copy the code, and study it well, " texts[rand(texts.maxIndex())])
		soundBeep, 750, 345
		if (rand(3)=1)
			lemons.speak("don't forget to thank tidbit!")
		guiControl, settings: enable, genbtn1
		guiControl, settings: enable, genbtn2
	}
	; msgBox % st_printArr(vList) "`n---`n" st_printArr(codeArr)
	; msgBox % st_printArr(cArr)
return


; 3 1 1 5 3 16 135 1 5 5 8 2 53
rand(max=100, min=1)
{
	random, r, %min%, %max%
	return r
}

; supid position stuff
genPos()
{
	aaa:=rand(100, 1)
	return (aaa<=60) ? "xm"
	     : (aaa<=70) ? "x+3 yp"
	     : (aaa<=95) ? "xp y+3"
	     :             "ym"
}
; old supid position stuff
; genPos()
; {
; 	aaa:=rand(100, 1)
; 	return (aaa<=60) ? {"x":"m" , "y":" "}
; 	     : (aaa<=70) ? {"x":"+3", "y":"p"}
; 	     : (aaa<=95) ? {"x":"p" , "y":"+3"}
; 	     :             {"x":" " , "y":"m"}
; }

; generate a name for vVar or whatever. remove anything not in the ABCs. Poor ampersand.
genLabelN(N)
{
	if (N="")
		return "Banana"
	return regExReplace(N, "[\W- ]", "")
}

; very sloppy stuff below. I won't bother explaining.
addEdit(labelT="", ctype=1, options="x14 y13 w200 r1")
{
	opts:={}
	opts["opts"]:={}  ; gui options, x, y, w, h, etc
	opts["sets"]:={}  ; gui settings, such as type and display text
	ctype:=(ctype=1) ? "edit" 
	: (ctype=2) ? "ddl" 
	: (ctype=3) ? "comboBox" 
	: (ctype=4) ? "hotkey" 
	: "dateTime"
	
	if (ctype="hotkey")
		modifiers:=["!","+","^","!+","^!","!^+","^+"]
		, special:=modifiers[rand(modifiers.maxIndex())] chr(rand(90, 65))
	if (ctype="dateTime")
		modifiers:=["","LongDate","Time","yyyy-MMM-dd","yyyy-dd-MMM"]
		, special:=modifiers[rand(modifiers.maxIndex())]
	; control 1. the label/text control.
	if (labelT!=""        ; if the label is blank don't create it.
	&& ctype!="ddl"       ; ddls don't need a label.
	&& ctype!="datetime") ; datetime don't need a label.
	{
		temp:=opts["opts"].push({})
		options2:=RegExReplace(options, "i)\b[wrhg]\S+")
		options2:=RegExReplace(options2, "i)(v\S+)", "vtext")
		for k,v in strSplit(trim(RegExReplace(options2, "(\h)+", "$1")), " ")
			regExMatch(v, "i)\b(hwnd|[xywhrcvg])(\S+)", o) ; these are the GUI options
			, opts["opts", temp].push({"" o1:o2})
			
		opts["sets"].push({"l":(ctype="combobox") ? "List" : labelT, "t":"text"})

		; control 2. the input control to the right
		temp:=opts["opts"].push({})
		options:="x+3 yp-3 " RegExReplace(options, "i)\b[xy]\S+")
		for k,v in strSplit(trim(RegExReplace(options, "(\h)+", "$1")), " ")
			regExMatch(v, "i)\b(hwnd|[xywhrcvg])(\S+)", o) ; these are the GUI options
			, opts["opts", temp].push({"" o1:o2})
		
		opts["sets"].push({"l":(ctype="Edit") ? "" 
		: (ctype="Hotkey") ? special 
		: labelT
		, "t":ctype})
	}
	else
	{
		temp:=opts["opts"].push({})
		for k,v in strSplit(trim(RegExReplace(options, "(\h)+", "$1")), " ")
			regExMatch(v, "i)\b(hwnd|[xywhrcvg])(\S+)", o) ; these are the GUI options
			, opts["opts", temp].push({"" o1:o2})
	
		opts["sets"].push({"l":(ctype="edit") ? "List" 
		: (ctype="dateTime") ? special
		: labelT
		, "t":ctype})
	}
	; msgBox % st_printArr(opts)
	return opts
}

; use your imagination. Also supports sliders and progresses. big boring rectangles.
addButton(labelT="Button", ctype=1, options="x14 y13 w200 r1")
{
	opts:={}
	opts["opts"]:={}  ; gui options, x, y, w, h, etc
	opts["sets"]:={}  ; gui settings, such as type and display text
	ctype:=(ctype=3) ? "progress" 
	: (ctype=2) ? "slider"
	: "button"

	temp:=opts["opts"].push({})
	for k,v in strSplit(trim(RegExReplace(options, "(\h)+", "$1")), " ")
		regExMatch(v, "i)\b(hwnd|background|tooltip|range|[xywhrcvg])(\S*)", o) ; these are the GUI options
		, opts["opts", temp].push({"" o1:o2})
	opts["sets"].push({"l":labelT, "t":ctype})

	; msgBox, % st_printArr(opts)
	return opts
}

; checkbox, radio
addCheckbox(labelT="aaa", ctype=1, options="x14 y13 w200 r1", count=3)
{
	opts:={}
	opts["opts"]:={}  ; gui options, x, y, w, h, etc
	opts["sets"]:={}  ; gui settings, such as type and display text
	labelT:=(trim(labelT)="") ? "dummy" : labelT
	ctype:=(ctype=1) ? "checkbox" : "radio"
	aaa:=rand(3,1)=1
	
	loop, %count%
	{
		bbb:=A_Index ; super usful variable name. atleast it's easy to identify
		options:=RegExReplace(options, "i)\b[wrh]\S+") ; just let them auto-size themselves.
		
		 ; first control of the group dictates the starting position
		 ; which is the initial Options. we don't need to modify them.
		temp:=opts["opts"].push({}) ; this var name isn't so helpful. deal with it
		if (bbb!=1)
		{
			if  (aaa=1) ; horizontal list, less chance
				options:=" x+3 yp " RegExReplace(options, "i)\b[xy]\S+")
			else ; vertical list
				options:=" xp y+3 " RegExReplace(options, "i)\b[xy]\S+")
		}
		options:=trim(RegExReplace(options, "(\h)+", "$1"))
		for k,v in strSplit(options, " ")
			regExMatch(v, "i)\b(hwnd|[xywhrcvg])(\S+)", o)
			, opts["opts", temp].push({"" o1:o2})
		opts["sets"].push({"l":labelT " " bbb, "t":ctype})
	}	
	; msgBox % st_printArr(opts)
	return opts
}

; Listview. pretty much identical code to Button. should have just combined them. boohoo.
addListview(labelT="Header1|Header2|Header3", options="x14 y13 w200 r15")
{
	opts:={}
	opts["opts"]:={}  ; gui options, x, y, w, h, etc
	opts["sets"]:={}  ; gui settings, such as type and display text

	temp:=opts["opts"].push({})
	for k,v in strSplit(trim(RegExReplace(options, "(\h)+", "$1")), " ")
		regExMatch(v, "i)\b(hwnd|[xywhrcvg])(\S+)", o) ; these are the GUI options
		, opts["opts", temp].push({"" o1:o2})
	
	opts["sets"].push({"l":labelT, "t":"listView"})
	return opts
}

; really old function made by tidbit.
msgbox2(text="", title="Msgbox", options="readonly -wrap w300 r12", ctrl="edit")
{
	static
	Gui, msgbox: New
	Gui, font,, Courier New
	Gui, +OwnDialogs +hwndMBHWND
	Gui, add, %ctrl%, %options% -wantReturn, %text%
	GuiControlGet, x, Pos, %ctrl%1
	xw:=xw-70+xx
	Gui, add, button, x%xw% y+10 w70 Default vbtn gMB2OK, OK
	GuiControl, focus, btn
	Gui, show,, %title%
	WinWaitClose, ahk_id %MBHWND%

	msgboxGUIEscape:
	msgboxGUIClose:
	MB2OK:
		gui,  Destroy
	Return
}

; really really old function made by tidbit.
GroupBox2(Text, Controls, GuiName=1, Offset="0,0", Padding="3,3,3,3", TitleHeight=15)
{
   static
   xx:=yy:=ww:=hh:=PosX:=PosY:=PosW:=PosH:=0
   StringSplit, Padding, Padding, `,
   StringSplit, Offset, Offset, `,
   loop, parse, Controls, `,
   {
      LoopField:=trim(A_LoopField)
      guiControlGet, Pos, %GuiName%: Pos, %LoopField%
      if (A_Index=1)
         xx:=PosX, yy:=PosY, ww:=PosX+PosW, hh:=PosY+PosH
      xx:=((xx<PosX) ? xx : PosX)
      yy:=((yy<PosY) ? yy : PosY)
      ww:=((ww>PosX+PosW) ? ww : PosX+PosW)
      hh:=((hh>PosY+PosH) ? hh : PosY+PosH)
      guiControl, %GuiName%: Move, %LoopField%, % "x" PosX+Padding1+Offset1 " y" PosY+Padding3+Offset2+titleHeight
   }
   xx+=Offset1
   yy+=Offset2
   ww+=Padding1+Padding2+Offset1-xx
   hh+=Padding3+Padding4+titleHeight+Offset2-yy
   counter+=1
   UID:="GB" GUIName counter xx yy ww hh
   status := GroupBox2_Add(guiname, xx, yy, ww, hh, uid, text)
   Return (status == true ? [uid,xx,yy,ww,hh] : false)
}
GroupBox2_Add(guiname, xx, yy, ww, hh, uid, text) {
	Global
	Gui, %GuiName%: add, GroupBox, x%xx% y%yy% w%ww% h%hh% v%UID%, %Text%
	return (errorlevel == 0 ? true : false)
}

; used for debugging. it's a major life-saver
; Lexikos or someone needs to add something like this built-in to ahk :P
st_printArr(array, depth=5, indentLevel="")
{
   for k,v in Array
   {
      list.= indentLevel "[" k "]"
      if (IsObject(v) && depth>1)
         list.="`n" st_printArr(v, depth-1, indentLevel . "    ")
      Else
         list.=" => " v
      list.="`n"
   }
   return rtrim(list, "`r`n `t")
}

; ; old function made by tidbit. pretty helpful. quite long. probably not the best.
st_columnize(data, delim="csv", justify=1, pad=" ", colsep=" | ")
{		
	widths:=[]
	dataArr:=[]
	
	if (instr(justify, "|"))
		colMode:=strsplit(justify, "|")
	else
		colMode:=justify
	; make the arrays and get the total rows and columns
	loop, parse, data, `n, `r
	{
		if (A_LoopField="")
			continue
		row:=A_Index
		
		if (delim="csv")
		{
			loop, parse, A_LoopField, csv
			{
				dataArr[row, A_Index]:=A_LoopField
				if (dataArr.maxindex()>maxr)
					maxr:=dataArr.maxindex()
				if (dataArr[A_Index].maxindex()>maxc)
					maxc:=dataArr[A_Index].maxindex()
			}
		}
		else
		{
			dataArr[A_Index]:=strsplit(A_LoopField, delim)
			if (dataArr.maxindex()>maxr)
				maxr:=dataArr.maxindex()
			if (dataArr[A_Index].maxindex()>maxc)
				maxc:=dataArr[A_Index].maxindex()
		}
	}
	; get the longest item in each column and store its length
	loop, %maxc%
	{
		col:=A_Index
		loop, %maxr%
			if (strLen(dataArr[A_Index, col])>widths[col])
				widths[col]:=strLen(dataArr[A_Index, col])
	}
	; the main goodies.
	loop, %maxr%
	{
		row:=A_Index
		loop, %maxc%
		{
			col:=A_Index
			stuff:=dataArr[row,col]
			len:=strlen(stuff)
			difference:=abs(strlen(stuff)-widths[col])

			; generate a repeating string about the length of the longest item
			; in the column.
			loop, % ceil(widths[col]/((strlen(pad)<1) ? 1 : strlen(pad)))
    			padSymbol.=pad

			if (isObject(colMode))
				justify:=colMode[col]
			; justify everything correctly.
			; 3 = center, 2= right, 1=left.
			if (strlen(stuff)<widths[col])
			{
				if (justify=3)
					stuff:=SubStr(padSymbol, 1, floor(difference/2)) . stuff
					. SubStr(padSymbol, 1, ceil(difference/2))
				else
				{
					if (justify=2)
						stuff:=SubStr(padSymbol, 1, difference) stuff
					else ; left justify by default.
						stuff:= stuff SubStr(padSymbol, 1, difference) 
				}
			}
			out.=stuff ((col!=maxc) ? colsep : "")
		}
		out:=trim(out) "`r`n"
		; out.="`r`n"
	}
	stringTrimRight, out, out, 2 ; remove the last blank newline
	return out
}


; hope you enjoyed the random babbling.
; enjoy.