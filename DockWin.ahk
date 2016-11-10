;DockWin v0.5 - Save and Restore window positions when docking/undocking (using hotkeys)
; Paul Troiano, 6/2014
; Updated by Ashley Dawson 7/2015
; Updated by Carlo Costanzo 11/2016
;
; Hotkeys: ^ = Control; ! = Alt; + = Shift; # = Windows key; * = Wildcard;
;          & = Combo keys; Others include ~, $, UP (see "Hotkeys" in Help)

;#InstallKeybdHook
#SingleInstance, Force
SetTitleMatchMode, 2		; 2: A window's title can contain WinTitle anywhere inside it to be a match. 
SetTitleMatchMode, Fast		;Fast is default
DetectHiddenWindows, off	;Off is default
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CrLf=`r`n
FileName:="WinPos.txt"

FileInstall, DockWin.ico, %A_ScriptDir%\DockWin.ico
Menu, Tray, Icon, %A_ScriptDir%\DockWin.ico,, 1

WinTitle = DockWin v0.5
Menu, Tray, Icon
Menu, Tray, Tip, %WinTitle%:`nCapture and Restore Screens ; `n is a line break.
Menu, Tray, NoStandard

Menu, Tray, Add, %WinTitle%, mDoNothing
Menu, Tray, Default, %WinTitle%
Menu, Tray, Disable, %WinTitle%
Menu, Tray, Add      ; time for a nice separator
Menu, Tray, Add, Edit WinPos.txt, mEdit
Menu, Tray, Add, Capture Screens - Shift+Win+0, mCapture
Menu, Tray, Add, Restore Screens - Win+0, mRestore
Menu, Tray, Add      ; time for a nice separator
Menu, Tray, Add, Exit %WinTitle%, mExit

Return

; =======
mEdit:
; =======

Run, Notepad %A_WorkingDir%\%FileName%, %A_WorkingDir%, UseErrorLevel

Return     ; failsafe / probably never hits this line

; ====
mExit:
; ====

ExitApp, 0


;Win-0 (Restore window positions from file)

#0::
mRestore:
  WinGetActiveTitle, SavedActiveWindow
  ParmVals:="Title x y height width maximized path"
  SectionToFind:= SectionHeader()
  SectionFound:= 0
 
  Loop, Read, %FileName%
  {
    if !SectionFound
    {
      ;Read through file until correct section found
      If (A_LoopReadLine<>SectionToFind) 
		Continue
    }	  

		;Exit if another section reached
		If ( SectionFound and SubStr(A_LoopReadLine,1,8)="SECTION:")
			Break

		SectionFound:=1
		
		Win_Title:="", Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0, Win_maximized:=0

		Loop, Parse, A_LoopReadLine, CSV 
		{
			EqualPos:=InStr(A_LoopField,"=")
			Var:=SubStr(A_LoopField,1,EqualPos-1)
			Val:=SubStr(A_LoopField,EqualPos+1)
			IfInString, ParmVals, %Var%
			{
				;Remove any surrounding double quotes (")
				If (SubStr(Val,1,1)=Chr(34)) 
				{
					StringMid, Val, Val, 2, StrLen(Val)-2
				}
				Win_%Var%:=Val  
			}
		}
		
		;Check if program is already running, if not, start it
		If  (!WinExist(Win_Title) and (Win_path<>""))
		{
			Try
			{
				Run %Win_path%	
				sleep 1000		;Give some time for the program to launch.	
			}
		}

		If ( (Win_maximized = 1) and WinExist(Win_Title) )
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
			WinMaximize, A
		} Else If ((Win_maximized = -1) and (StrLen(Win_Title) > 0) and WinExist(Win_Title) )		; Value of -1 means Window is minimised
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
			WinMinimize, A
		} Else If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
		{	
			WinRestore
			WinActivate
			WinMove, A,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
		}
  }

  if !SectionFound
  {
    msgbox,,Dock Windows, Section does not exist in %FileName% `nLooking for: %SectionToFind%`n`nTo save a new section, use Win-Shift-0 (zero key above letter P on keyboard)
  }

  ;Restore window that was active at beginning of script
  WinActivate, %SavedActiveWindow%
RETURN


;Win-Shift-0 (Save current windows to file)
#+0::
mCapture:

 MsgBox, 4,Dock Windows,Save window positions?
 IfMsgBox, NO, Return

 WinGetActiveTitle, SavedActiveWindow

 file := FileOpen(FileName, "a")
 if !IsObject(file)
 {
	MsgBox, Can't open "%FileName%" for writing.
	Return
 }

  line:= SectionHeader() . CrLf
  file.Write(line)

  ; Loop through all windows on the entire system
  WinGet, id, list,,, Program Manager
  Loop, %id%
  {
    this_id := id%A_Index%
    WinActivate, ahk_id %this_id%
    WinGetPos, x, y, Width, Height, A ;Wintitle
    WinGetClass, this_class, ahk_id %this_id%
    WinGetTitle, this_title, ahk_id %this_id%
    WinGet, win_maximized, minmax, %this_title%

	if ( (StrLen(this_title)>0) and (this_title<>"Start") )
	{
		line=Title="%this_title%"`,x=%x%`,y=%y%`,width=%width%`,height=%height%`,maximized=%win_maximized%,path=""`r`n
		file.Write(line)
   	}
	
	if(win_maximized = -1)		;Re-minimize any windows that were minimised before we started.
	{
		WinMinimize, A
	}
  }

  file.write(CrLf)  ;Add blank line after section
  file.Close()

  ;Restore active window
  WinActivate, %SavedActiveWindow%
RETURN

; -------

;Create standardized section header for later retrieval
SectionHeader()
{
	SysGet, MonitorCount, MonitorCount
	SysGet, MonitorPrimary, MonitorPrimary
	line=SECTION: Monitors=%MonitorCount%,MonitorPrimary=%MonitorPrimary%

        WinGetPos, x, y, Width, Height, Program Manager
	line:= line . "; Desktop size:" . x . "," . y . "," . width . "," . height

	Return %line%
}

; =====
mDoNothing: ; for labels.
; =====