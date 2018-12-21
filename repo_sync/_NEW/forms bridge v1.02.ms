
Global mcTemp1Dialog
Global mcTemp2Dialog

(  --> local space
	local mcs, dia
	Struct FORM1_STRUCT (
		
		form, btn1,
		fn callbacksFunction s a = (

			format "mcTemp1Dialog > callbacksFunction > pressed button in  form 2:%\n" s
		),			
		fn onMouseUp s a = (
	
			 format "mcTemp1Dialog > onMouseUp s:% a:% \n" s  a
			mcTemp2Dialog.show()
			format "mcTemp1Dialog > onMouseUp > form2 button:% \n" mcTemp2Dialog.btn1
--can't add event to other form GRRRRRRR
--dotnet.addEventHandler mcTemp2Dialog.btn1 "MouseUp" callbacksFunction 
		),
		fn init = (
			--Define Interface Components
			form = dotNetObject "MaxCustomControls.Maxform"
			btn1	= dotNetObject "Button"
			--Setup Interface Components 
			form.name = "F1"
			form.StartPosition = form.StartPosition.Manual
			form.bounds = netDrRect [200,200] [240,100]
			btn1.bounds = netDrRect [4,4] [200,24]
			btn1.text = "Register Event"
			dotnet.addEventHandler btn1 "MouseUp" onMouseUp
			form.controls.add btn1
		),
		fn show = (
			if form == undefined or form.IsDisposed do init()
			mcDotnet.dShow form
		),
		fn hide = (form.hide()),
		fn close = (form.close()),
		initIt = init()
	)
	--instance form
	mcTemp1Dialog = FORM1_STRUCT()
	mcs = mcTemp1Dialog --structure shortcut (simplest use)
	dia = mcTemp1Dialog.form --form instance
) --< local space

(  --> local space
	local mcs, dia
	Struct FORM2_STRUCT (
		
		form, btn1,
		fn init = (
			--Define Interface Components
			form = dotNetObject "MaxCustomControls.Maxform"
			btn1	= dotNetObject "Button"
			--Setup Interface Components 
			form.name = "F2"
			form.StartPosition = form.StartPosition.Manual
			form.bounds = netDrRect [440,200] [240,100]
			btn1.bounds = netDrRect [4,4] [200,24]
			btn1.text = "No Event"
			form.controls.add btn1
		),
		fn show = (
			if form == undefined or form.IsDisposed do init()
			mcDotnet.dShow form
		),
		fn hide = (form.hide()),
		fn close = (form.close()),
		initIt = init()
	)
	--instance form
	mcTemp2Dialog = FORM2_STRUCT()
	mcs = mcTemp2Dialog --structure shortcut (simplest use)
	dia = mcTemp2Dialog.form --form instance
) --< local space

mcTemp1Dialog.show()
gc() --check that life time controls is OK