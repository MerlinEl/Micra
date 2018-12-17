So I'm just going to leave this here, in case anyone is interested. It should get rid of the InfoCenter and the QuickAccessToolbar.

ComponentManager = (dotnetclass "Autodesk.Windows.ComponentManager")
ComponentManager.QuickAccessToolBar.IsVisible = false
ComponentManager.InfoCenterToolBar.MaxWidth = 0
ComponentManager.InfoCenterToolBar.MinWidth = 0


qatbar = (dotnetclass "Autodesk.Windows.ComponentManager").QuickAccessToolBar
qatbar.IsVisible = false
qatbar.IsMenuBarVisible = false
qatbar.IsVisible = true
qatbar.IsMenuBarVisible = true


cui.commandPanelOpen=true
cui.expertModeOn()
cui.commandPanelOpen = false
cui.getExpertMode()
cui.expertModeOff()


--The following will list all of the core interfaces
core_interfaces = getcoreinterfaces() 
for i in core_interfaces do (showinterface i; format "\n")




print utilityplugin.classes


  Interface: UtilityPanel
   Properties:
   Methods:
    <integer>OpenUtility <class>ClassName
    <integer>CloseUtility()
   Actions:
   
 Interface: UIAccessor
   Properties:
   Methods:
    <string>GetWindowText <HWND>hwnd
       GetWindowText - no automatic redraw after invoked
    <string>GetWindowClassName <HWND>hwnd
       GetWindowClassName - no automatic redraw after invoked
    <integer>GetWindowResourceID <HWND>hwnd
       GetWindowResourceID - no automatic redraw after invoked
    <HWND by value array>GetChildWindows <HWND>hwnd
       GetChildWindows - no automatic redraw after invoked
    <HWND by value array>GetPopupDialogs()
       GetPopupDialogs - no automatic redraw after invoked
    <HWND>GetParentWindow <HWND>hwnd
       GetParentWindow - no automatic redraw after invoked
    <HWND>GetFirstChildWindow <HWND>hwnd
       GetFirstChildWindow - no automatic redraw after invoked
    <HWND>GetPrevWindow <HWND>hwnd
       GetPrevWindow - no automatic redraw after invoked
    <HWND>GetNextWindow <HWND>hwnd
       GetNextWindow - no automatic redraw after invoked
    <bool>IsWindow <HWND>hwnd
       IsWindow - no automatic redraw after invoked
    <string>GetWindowDllFileName <HWND>hwnd
       GetWindowDllFileName - no automatic redraw after invoked
    <string>GetWindowDllDescription <HWND>hwnd
       GetWindowDllDescription - no automatic redraw after invoked
    <void>CloseDialog <HWND>hwnd
       CloseDialog - no automatic redraw after invoked
    <void>PressDefaultButton()
       PressDefaultButton - no automatic redraw after invoked
    <void>PressButton <HWND>hwnd
       PressButton - no automatic redraw after invoked
    <bool>PressButtonByName <HWND>hwnd <string>name
       PressButtonByName - no automatic redraw after invoked
    <bool>SetWindowText <HWND>hwnd <string>text
       SetWindowText - no automatic redraw after invoked
    <bool>SendMessageID <HWND>hwndDlg <enum>ID
       SendMessageID - no automatic redraw after invoked
       ID enums: {#IDOK|#IDCANCEL|#IDABORT|#IDRETRY|#IDIGNORE|#IDYES|#IDNO|#IDCLOSE}
    <bool>SendMessage <HWND>hwndDlg <integer>MessageID <integer>wParam <integer>lParam
       SendMessage - no automatic redraw after invoked
   Actions:

 