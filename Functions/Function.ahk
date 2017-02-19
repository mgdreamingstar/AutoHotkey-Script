;-------------------------------------------------------------------------------

;~ 以下是使用到的函数

;-------------------------------------------------------------------------------

;~ 获取选中的文件或文件夹的路径，复制到剪贴板
GetPath(Type = "FullPath", ShowTooltipTime = 0)
    {
        Clipboard =
        Send, ^c    ;这里的 c 写成大写 C 的话就不正常了，奇怪啊。。。
        ClipWait, 1
        If !ErrorLevel
        {
            Loop, Parse, Clipboard, `r, `n  ;windows 复制的时候，剪贴板会保存“路径”，可以当成字符串处理
            {
                If (Type = "Dir")
                {
                    SplitPath, A_LoopField,, Temp
                    Temp = %Temp%\             ;加 \ 表明这是一个文件夹，不是无扩展名文件
                }

                If (Type = "Name")
                {
                    SplitPath, A_LoopField, Temp
                    If IsFolder(A_LoopField)
                    {
                        Temp = %Temp%\
                    }
                }

                If (Type = "FullPath")
                {
                    Temp = %A_LoopField%
                    If IsFolder(A_LoopField)
                    {
                        Temp = %Temp%\
                    }
                }

                FilePath = %FilePath%%Temp%`n
            }
            StringTrimRight, FilePath, FilePath, 1  ;去除后面多添加的一个换行符

            If (ShowTooltipTime > 0)                  ;控制弹出提示消息的时间长短
            {
                ToolTip, %FilePath%
                SetTimer, RemoveToolTip, 1500        ;1.5秒后移除提示信息
            }

            Clipboard = %FilePath%
            Return 1
        }
        Else
        {
            Return 0
        }
    }

;-------------------------------------------------------------------------------

;~ 判断选中的是否文件夹
IsFolder(Path)
    {
        FileGetAttrib, Attrib, %Path%   ;把 Path 指向的文件或文件夹的属性赋值给 Attrib
        IfInString, Attrib, D            ;如果在 Attrib 里有 D ,就表示这个路径代表的是文件夹，否则就是文件
        {
            Return 1
        }
        Else
        {
            Return 0
        }
    }

;-------------------------------------------------------------------------------

;~ 顾名思义，移除提示信息。
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
Return

;-------------------------------------------------------------------------------