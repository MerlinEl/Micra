fn stopRedraw=
 (
 WM_SETREDRAW=0xB
 commandHWND = (windows.getChildHWND #max "Command Panel")
 if commandHWND != undefined and classOf commandHWND==Array then commandHWND=commandHWND[1]
 else commandHWND = windows.getmaxhwnd()
 if commandHWND !=undefined do windows.sendmessage commandHWND WM_SETREDRAW 0 0
 )
 fn resumeRedraw=
 (
 WM_SETREDRAW=0xB
 commandHWND = (windows.getChildHWND #max "Command Panel")
 if commandHWND != undefined and classOf commandHWND==Array then commandHWND=commandHWND[1]
 else commandHWND = windows.getmaxhwnd()
 if commandHWND !=undefined do windows.sendmessage commandHWND WM_SETREDRAW 1 0
 )