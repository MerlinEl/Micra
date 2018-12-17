toolTip="toggle the Use Cached D3DXMeshes Viewport"
buttonText="toggle the Use Cached D3DXMeshes Viewport"
 
--start macro
 
-----------------------------------------------------------------------------------------------
--
-- toggles the "Use Cached D3DXMeshes" checkbox of the Viewport configuration
--
-----------------------------------------------------------------------------------------------
 
--diable it while
 dialogMonitorOps.enabled = false
 global prefsDialog_hwnd = undefined
 global retMessage=""
 fn toggleCachedD3DMeshes = (
 
	 --Constants for sendMessage method	
	local BM_GETSTATE = 0xF2
	local BM_CLICK = 0xF5
	local BM_SETCHECK = 0xF1
	local BST_CHECKED = 0x1	 
 
 	local hwnd = dialogMonitorOps.getWindowHandle()
 	local dialogTitle = uiAccessor.getWindowText hwnd
 	if (dialogTitle != undefined) then (
 		if (dialogTitle == "Preference Settings") then (
			prefsDialog_hwnd = hwnd
			format "We're in the preferences dialog\n" 
			local hwnd_children = uiAccessor.getChildWindows hwnd
 			for i = 1 to hwnd_children.count do (
 				local hwnd_child_title = uiAccessor.getWindowText hwnd_children[i]
				if (findString hwnd_child_title "Configure Driver..." == 1) then (
					format "found config button... pressing\n"
					local hwnd_config = hwnd_children[i]
 					uiAccessor.pressButton hwnd_config
					)
				)
			)
		else if (dialogTitle == "Configure Direct3D") then (
			local hwnd_children = uiAccessor.getChildWindows hwnd
 			for i = 1 to hwnd_children.count do (
 				local hwnd_child_title = uiAccessor.getWindowText hwnd_children[i]
				if (findString hwnd_child_title "Use Cached D3DXMeshes" == 1) then (
					format "found the cached button\n"
					local hwnd_cached = hwnd_children[i]
					local CheckState = windows.sendMessage hwnd_cached BM_GETSTATE 0 0
					local IsChecked = bit.get CheckState BST_CHECKED
					format "the checkbox was: %\n" IsChecked
					-- Uncheck it
					if IsChecked then
					(
						windows.sendMessage hwnd_cached BM_CLICK 0 0
						windows.sendMessage hwnd_cached BM_SETCHECK 0 0
						format "Cached D3DXMeshes has been disabled.\n"
						format "Pressing OK on the ConfigureD3D page\n"
						uiAccessor.sendMessageID hwnd #IDOK
						format "Pressing OK on the Preferences page\n"
						uiAccessor.sendMessageID prefsDialog_hwnd #IDOK
						retMessage="Turning the CachedD3DXMeshes *OFF*"
					)
					-- Check it
					else if not IsChecked then
					(
						windows.sendMessage hwnd_cached BM_CLICK 0 0
						windows.sendMessage hwnd_cached BM_SETCHECK 1 0
						format "Cached D3DXMeshes has been enabled.\n"
						format "Pressing OK on the ConfigureD3D page\n"
						uiAccessor.sendMessageID hwnd #IDOK
						format "Pressing OK on the Preferences page\n"
						uiAccessor.sendMessageID prefsDialog_hwnd #IDOK
						retMessage="Turning the CachedD3DXMeshes *ON*"
					)
 				)
 			)
 		)
 	)
	true
 
 )
 
fn toggleUseCache =
(
	dialogMonitorOps.interactive = false
	dialogMonitorOps.unregisterNotification id:#setD3DCache
	dialogMonitorOps.registerNotification toggleCachedD3DMeshes id:#setD3DCache
	dialogMonitorOps.enabled = true
	--run it
	max file preferences
	--disable it!
	dialogMonitorOps.enabled = false
	dialogMonitorOps.unregisterNotification id:#setD3DCache
	--messagebox retMessage
)
 
toggleUseCache()
format retMessage