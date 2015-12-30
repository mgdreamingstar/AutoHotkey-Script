;该脚本必须以ANSI运行

urlencode(string){
;string := Ansi2UTF8(string) ;需要GB2312注释这行
StringLen, len, string
Loop % len
{
SetFormat, IntegerFast, hex
StringMid, out, string, %A_Index%, 1
hex := Asc(out)
hex2 := hex
StringReplace, hex, hex, 0x, , All
SetFormat, IntegerFast, d
hex2 := hex2
If (hex2==33 || (hex2>=39 && hex2 <=42) || hex2==45 || hex2 ==46 || (hex2>=48 && hex2<=57) || (hex2>=65 && hex2<=90) || hex2==95 || (hex2>=97 && hex2<=122) || hex2==126)
    content .= out
Else
    content .= "`%" hex
}
Return content
}


urldecode(string){
StringReplace, string, string, +, %A_Space%, All ;去连接符
Loop, Parse, string, `%
{
asc_key := A_LoopField
if A_index = 1
    content = % content asc_key ;直接串接
Else
    {
    if RegExMatch(asc_key,"i)[0-9a-f]{2}")
        {
        StringLeft, part1, asc_key, 2 ;分成两部分 hex 和单字节字符
        StringTrimLeft, part2, asc_key, 2
        asc_var := chr("0x" part1)
        content = % content asc_var part2
        }
    Else
        content = % content asc_key ;直接串接
    }
}
return content
}

Ansi2UTF8(sString)
{
   Ansi2Unicode(sString, wString, 0)
   Unicode2Ansi(wString, zString, 65001)
   Return zString
}
UTF82Ansi(zString)
{
   Ansi2Unicode(zString, wString, 65001)
   Unicode2Ansi(wString, sString, 0)
   Return sString
}
Ansi2Unicode(ByRef sString, ByRef wString, CP = 0)
{
     nSize := DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int", -1
      , "Uint", 0
      , "int", 0)
   VarSetCapacity(wString, nSize * 2)
   DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int", -1
      , "Uint", &wString
      , "int", nSize)
}
Unicode2Ansi(ByRef wString, ByRef sString, CP = 0)
{
     nSize := DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int", -1
      , "Uint", 0
      , "int", 0
      , "Uint", 0
      , "Uint", 0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &wString
      , "int", -1
      , "str", sString
      , "int", nSize
      , "Uint", 0
      , "Uint", 0)
}

;str := "希腊精神"
;MsgBox % urlencode(str)