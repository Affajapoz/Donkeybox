;ANSI
/*
;realmofthemadgod.ahk
Donke-box RotMG player,
do what you want with it!
No Flash install necessary!
Always up-to-date. Hopefully!
Its key feature is Flash cookie
isolation to distinct mule boxes.
Supports Windows 7; isolation may fail with other OS?

Requires AutoHotkey Basic; AutoHotkey_L; AutoHotkey_H
Recommended binaries here http://l.autohotkey.net/
Unsupported is the script with IronAHK sans surprise.

Script downloads and saves the following files to
same directory as you keep "realmofthemadgod.ahk"
.\com_adobe_www.html
    .\flashplayer.exe
.\com_realmofthemadgod_www.htm
.\com_realmofthemadgod_www.gif
.\com_realmofthemadgod_testing.htm
.\com_realmofthemadgod_testing.gif
.\CacheBox\AppData\Local
    <SYMLINKD>    .\DonkeBox\MuleName\AppData\Local
.\DonkeBox\MuleName\AppData\Roaming

todo them Regular Expressions on a tag basis. I lazy.
*/

#SingleInstance force
#Persistent
#NoTrayIcon
#NoEnv

if A_AhkVersion<=1.0.48.05
    AHkBasic:=true

Ptr:=A_PtrSize ? "Ptr":"UInt"
Str:=AHkBasic ? "Str":"A" "Str"

;Windows Data Types    http://msdn.microsoft.com/en-us/library/aa383751(v=vs.85).aspx

LPVOID:=Ptr
PVOID:=Ptr
BOOLEAN:=BYTE:="U" "Char"
BOOL:="Int"
INT:="Int"
LONG:=HRESULT:="Int"
DWORD:="U" "Int"
LPDWORD:=DWORD "P"

LPCTSTR:=LPTSTR:=Str

;

HANDLE:=HMENU:=HWND:=PVOID
HTHUMBNAIL:=PHTHUMBNAIL:=HANDLE

;

RotMG:="Realm of the Mad God"

;

DONKEBOX:="DonkeBox"
CACHEBOX:="CacheBox"

;

ProjectorPID:=0
ProjectorHwnd:=NULL

SetWorkingDir,%A_ScriptDir%

FileDelete,com_adobe_www.html
FileDelete,com_realmofthemadgod_www.htm
FileDelete,com_realmofthemadgod_testing.htm

Gosub,Tray

OnExit,OnExit
return

OnExit:
;Menu,Tray,NoIcon
ExitApp
return

CrabFile:
Loop,parse,MuleList,`n
{
    if(A_LoopField)
        realmofthemadgod(A_ThisMenu,A_LoopField)
}
return

MuleFile:
realmofthemadgod(A_ThisMenu,A_ThisMenuItem)
return

Production:
realmofthemadgod("www")
return

Testing:
realmofthemadgod("testing")
return

realmofthemadgod(subdomain,MuleFile="")
{
    global
    
    static recursive:=0
    
    if(recursive>0)
    {
        TrayTip("Recursive")
        return
    }
    
    recursive++
    
    ;IfNotExist,.\flashplayer_11_sa_32bit.exe
    IfNotExist,.\flashplayer.exe
    {
        Progress("Waiting for`t" "www.adobe.com")
        UrlDownloadToFile,http://www.adobe.com/support/flashplayer/downloads.html,.\com_adobe_www.html
        
        Progress("Processing`t" "com_adobe_www.html")
        FileRead,OutputVar3,.\com_adobe_www.html
        Loop
        {
            RegExMatch(OutputVar3,"is).*?<\ba\b.+?\bhref\b[\s=]+[""'][\s]*(.*?)[\s]*[""'].*?>(.*?)</[\s]*\ba\b[\s]*>(.*)",OutputVar)
            
            if(RegExMatch(OutputVar2,"is)(?!.*?debug)Windows.*?Flash.*?Projector"))
                break
            
            if(!OutputVar3)
                break
        }
        
        Progress("Downloading`t" OutputVar1)
        UrlDownloadToFile,%OutputVar1%,.\flashplayer.exe
    }
    
    IfNotExist,.\com_realmofthemadgod_%subdomain%.htm
    {
        Progress("Waiting for`t" subdomain ".realmofthemadgod.com")
        UrlDownloadToFile,http://%subdomain%.realmofthemadgod.com/,.\com_realmofthemadgod_%subdomain%.htm
    }
    
    Progress("Processing`t" "com_realmofthemadgod_" subdomain ".htm")
    FileRead,OutputVar,.\com_realmofthemadgod_%subdomain%.htm
    RegExMatch(OutputVar,"is)<\bparam\b.+?\bname\b[\s=]+[""'][\s]*\bmovie\b[\s]*[""'].*?\bvalue\b[\s=]+[""'][\s]*(.*?)(?:\.swf)?[\s]*[""'].*?>",OutputVar)
    
    IfNotExist,.\com_realmofthemadgod_%subdomain%.gif
    {
        Progress("Waiting for`t" subdomain ".realmofthemadgod.com")
        UrlDownloadToFile,http://%subdomain%.realmofthemadgod.com/favicon.ico,.\com_realmofthemadgod_%subdomain%.gif
        ; todo Gdiplus stuff to convert favicon.ico what is really .gif to .ico
    }
    
    Tray()
    
    Progress()
    
    if(!MuleFile)
    {
        FormatTime,TimeString,,yyyyMMdd_HH_mm_ss
        MuleFile:=TimeString
    }
    
    USERNAME:=DONKEBOX
    _USERPROFILE:=A_ScriptDir "\" USERNAME
    USERPROFILE:=_USERPROFILE "\" MuleFile
    
    EnvGet,APPDATA,APPDATA
    if APPDATA contains \AppData
    {
        APPDATA_:="AppData\Roaming"
        LOCALAPPDATA_:="AppData\Local"
    }
    else
    {
        APPDATA_:="Application Data"
        LOCALAPPDATA_:="Local Settings" ; Internet Cache
        ;LOCALAPPDATA_:="Local Settings\Application Data" ; Which path is it Flash has populated in XP?
    }
    
    _LOCALAPPDATA_:=A_ScriptDir "\" CACHEBOX "\" LOCALAPPDATA_
    
    APPDATA:=USERPROFILE "\" APPDATA_
    LOCALAPPDATA:=USERPROFILE "\" LOCALAPPDATA_
    
    FileCreateDir,%_USERPROFILE%
    FileCreateDir,%USERPROFILE%
    
    ; Need explicitly create Roaming path otherwise Flash encounters problems
    FileCreateDir,%APPDATA%
    
    if(!FileExist(LOCALAPPDATA))
    {
        if(!DllCall("CreateSymbolicLinkA",LPTSTR,LOCALAPPDATA,LPTSTR,_LOCALAPPDATA_,DWORD,SYMBOLIC_LINK_FLAG_DIRECTORY:=0x1,BOOLEAN))
            TrayTip("Not using CacheBox.`nA_LastError=" A_LastError "`nErrorLevel=" ErrorLevel)
        else
            FileCreateDir,%_LOCALAPPDATA_%
    }
    
    EnvSet,USERNAME,%USERNAME%
    EnvSet,USERPROFILE,%USERPROFILE%
    
    Run,".\flashplayer.exe" http://%subdomain%.realmofthemadgod.com/%OutputVar1%.swf,.,,ProjectorPID
    
    GroupAdd,Projector,ahk_pid %ProjectorPID%
    WinWait,ahk_pid %ProjectorPID%
    ProjectorHwnd:=WinExist()
    
    WinSetTitle,%MuleFile%
    
    Process,Priority,%ProjectorPID%,High
    
    recursive--
}

Progress(SubText="",MainText="")
{
    global
    
    if(!SubText)
    {
        SetTimer,Progress,off
        Progress,off
        Hotkey,Esc,off
        return
    }
    
    if(!MainText)
        MainText:=RotMG
    
    Hotkey,Esc,OnExit
    Options:=StrLen(SubText)>30 ? "W800":""
    Progress,B1 %Options% CB363636 CTFFFFFF CW545454,%SubText%,%MainText%
    Sleep,-1
    Progress:=0
    Progress,%Progress%
    SetTimer,Progress,250
    Sleep,1250
}

Progress:
Progress+=25
Progress,%Progress%
if(Progress>=100)
    Progress:=0
return

Tray()
{
    global
    
    MuleList:=""
    Loop,.\%DONKEBOX%\*,2,0
        MuleList.=A_LoopFileName "`n"
    Sort,MuleList
    
    Menu,Tray,UseErrorLevel
    Menu,Tray,DeleteAll
    
    Menu,www,Add
    Menu,www,DeleteAll
    
    Menu,testing,Add
    Menu,testing,DeleteAll
    
    Menu,www,Add,.realmofthemadgod.com`t&New "mule",Production
    Menu,testing,Add,.realmofthemadgod.com`t&New "mule",Testing
    
    if(MuleList)
    {
        Menu,www,Add
        Menu,www,Add,as many heads follow . . .`t&Open "crab",CrabFile
        Menu,www,Add
        Menu,testing,Add
        Menu,testing,Add,as many heads follow . . .`t&Open "crab",CrabFile
        Menu,testing,Add
        
        Loop,parse,MuleList,`n
        {
            if(A_LoopField)
            {
                Menu,www,Add,%A_LoopField%,MuleFile
                Menu,testing,Add,%A_LoopField%,MuleFile
                
                if(!AHkBasic)
                {
                    IfExist,.\flashplayer.exe
                    {
                        Icon=Icon
                        Menu,www,%Icon%,%A_LoopField%,.\flashplayer.exe
                        Menu,testing,%Icon%,%A_LoopField%,.\flashplayer.exe
                    }
                }
            }
        }
    }
    
    Menu,Tray,NoStandard
    Menu,Tray,Click,1
    Menu,Tray,Add,%RotMG%`tE&xit,OnExit
    Menu,Tray,Add
    Menu,Tray,Add,Production`twww,:www
    Menu,Tray,Add,Testing`ttesting,:testing
    if(!AHkBasic)
    {
        IfExist,.\com_realmofthemadgod_www.gif
            Menu,Tray,Icon,Production`twww,.\com_realmofthemadgod_www.gif
        IfExist,.\com_realmofthemadgod_testing.gif
            Menu,Tray,Icon,Testing`ttesting,.\com_realmofthemadgod_testing.gif
    }
    Menu,Tray,Add
    Menu,Tray,Add,Donke-boxing script by Hydr493n,Tray
    Menu,Tray,Default,Donke-boxing script by Hydr493n
    Menu,Tray,Disable,Donke-boxing script by Hydr493n
    Menu,Tray,Add,> because we thought it up!,OnExit
    Menu,Tray,Check,> because we thought it up!
    Menu,Tray,Disable,> because we thought it up!
    
    if(A_IsCompiled)
        Menu,Tray,Icon,%A_ScriptFullPath%,6
    else
        Menu,Tray,Icon,%A_AhkPath%,6
    
    Menu,Tray,Tip,%RotMG%
    Menu,Tray,Icon
}

Tray:
Tray()
Menu,Tray,Show
return

ToolTip(Text,Period=1000)
{
    ToolTip,%Text%
    SetTimer,RemoveToolTip,% Period>0 ? "-" . Period:!Period ? -1:Period
}

RemoveToolTip:
ToolTip
return

TrayTip(Text,Period=5000,Options=0)
{
    TrayTip,%RotMG%,%Text%
    SetTimer,RemoveTrayTip,% Period>0 ? "-" . Period:!Period ? -1:Period
}

RemoveTrayTip:
TrayTip
return

#IfWinActive ahk_group Projector

RButton::return

/*
RButton::
Send {Shift Down}
if(GetKeyState("LButton","P"))
    Send {Space}
return

RButton Up::Send {Shift Up}
*/
#IfWinActive
