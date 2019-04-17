DialogMonitorOPS.unRegisterNotification id:#eyeInTheSky

fn saveLoadUVW state =  (
	
	max modify mode
	mo = 	Unwrap_UVW ()
	modPanel.addModToSelection mo ui:on
	mo.edit()
	--mo.unwrap.load() --path:"C:\\temp\\uv.uvw"
	
	WindowHandle = DialogMonitorOPS.GetWindowHandle()
	WindowName = UIAccessor.GetWindowText WindowHandle
	format "UVW > handle:% name:%\n" WindowHandle WindowName
	
	if WindowName != undefined then (
		if (findString WindowName "Load UVW") != undefined then (
			
			cWindows = UIAccessor.GetChildWindows WindowHandle
			entryField = 0
			for t = 1 to cWindows.count do (
				
				if cWindows != 0 then (
					if (UIAccessor.GetWindowClassName cWindows) == "ComboBoxEx32" then
					entryField = cWindows
				)
			)
			if entryField != 0 then (
				
				UIAccessor.SetWindowText entryField "C:\\Temp\\mp.uvw"
				UIAccessor.PressButtonByName WindowHandle "&Load"
			)
		)
	)
	true
	--macros.run "Modifier Stack" "Convert_to_Poly"
)



DialogMonitorOPS.RegisterNotification dmnotification id:#eyeInTheSky
DialogMonitorOPS.Enabled = true
$.modifiers.unwrap.Load()
DialogMonitorOPS.Enabled = false
DialogMonitorOPS.unRegisterNotification id:#eyeInTheSky