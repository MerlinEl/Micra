		enableSceneRedraw()
		disableSceneRedraw()
		
		with redraw off	
		()	
		
completeRedraw()
redrawViews()
		
		suspendEditing which:CommandPanel
		resumeEditing which:CommandPanel
		
		
		WM_SETREDRAW=0xB
commandHWND = windows.getChildHWND #max "Command Panel"
 
windows.sendmessage commandHWND[1]  WM_SETREDRAW 0 0
...
windows.sendmessage commandHWND[1]  WM_SETREDRAW 1 0