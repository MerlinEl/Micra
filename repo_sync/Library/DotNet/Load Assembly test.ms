assemblyFileName = "E:\\Micra2\\App\\test\\AIButton.dll"
-- Load the class library created 
a= dotnet.LoadAssembly assemblyFileName 
a.GetTypes()

rollout unnamedRollout "Untitled" width:162 height:300
(
	--button btn1 "Button" pos:[22,59] width:99 height:54
	dotNetControl btn1 "AcceleratedIdeas.AIButton" pos:[19,19] width:80 height:52
	on unnamedRollout open do 
	(
		btn1.AllowDrop = true
		--btn1.BackColor
		--mc2system.show btn1.StyleType
		btn1.StyleType = btn1.StyleType._XP--_MODERN--_CLASSIC__VISTA_XP
		--mc2system.show btn1
	)
)
createdialog unnamedRollout




