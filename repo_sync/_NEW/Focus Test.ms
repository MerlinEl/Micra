--Max Interface
rollout focusTestDialog "Max Focus Test" width:196 height:124
(
	button btn1 "create point" pos:[80,44] width:88 height:32
	on btn1 pressed  do
	(
		tool create (on mousePoint click do point pos:gridPoint wirecolor:green) 
		startTool create
	)
)
createDialog focusTestDialog


--DotNet Interface
(
	local form = dotNetObject "MaxCustomControls.Maxform"
	local btn   = dotNetObject "button"
	form.Text  = "Dotnet Focus Test"
	btn.text    = "create point"
	form.bounds = dotnetObject "Drawing.Rectangle" 200 400 196 124
	fn onMouseUp s a = 
	(
		max move
		tool create (on mousePoint click do point pos:gridPoint wirecolor:green) 
		startTool create
	)
	dotNet.addEventHandler btn "MouseUp" onMouseUp
	form.controls.add btn
	form.showModeless()
)
