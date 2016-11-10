# DockWin
Autohotkey(https://autohotkey.com/) Script to save and restore positions of windows.

Used to replace windows after switching monitor arrangement, un/docking a notebook etc.

## Hotkeys

- **[Win]+0** = Restore window positions from ./WinPos.txt
- **[Win]+[Shift]+0** = Save window positions to ./WinPos.txt

## Menu
DockWin sits quietly in the tool tray and can be right clicked to edit WinPos.txt or initiate a capture or restore.

### WinPos.txt

```
SECTION: Monitors=2,MonitorPrimary=1; Desktop size:0,0,4480,1440
Title="Sublime Text",x=-8,y=-8,width=2576,height=1416,maximized=1,path=""
Title="sshsession@server:Default",x=3520,y=18,width=960,height=1062,maximized=0,path=""
```

## Saved

## Original Source
https://autohotkey.com/board/topic/112113-dockwin-storerecall-window-positions/page-3
