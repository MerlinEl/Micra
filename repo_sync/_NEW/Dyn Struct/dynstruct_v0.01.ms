Struct DYNAMIC_DIALOG_BASE (

	_w,
	_h,
	_x,
	_y,
	_form,
	fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn netDrColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b),
	fn maxHW = (
	
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return hv
	),
	fn buildForm pos size title:"Maxform"= (
	
		_w = size.x
		_h = size.y
		_x = pos.x
		_y = pos.y
		local form = dotNetObject "MaxCustomControls.Maxform"
		form.text = title
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect [pos.x, pos.y] [size.x, size.y]
		form.ShowInTaskbar = false
		
		_form = form --instance
		local hv = maxHW ()
		form.show(hv) -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
		hv.ReleaseHandle()
	)
)
my_form_1 = DYNAMIC_DIALOG_BASE()
my_form_1.buildForm [400, 350] [350, 250] title:"My Form 1 v0.01"


Struct DYNAMIC_DIALOG_COMPACT (

	_w,
	_h,
	_x,
	_y,
	_form,
	fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn netDrColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b),
	fn maxHW = (
	
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return hv
	),
	fn buildForm pos size title:"Maxform" back_color:undefined = (
	
		_w = size.x
		_h = size.y
		_x = pos.x
		_y = pos.y
		local form = dotNetObject "MaxCustomControls.Maxform"
		form.text = title
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect [pos.x, pos.y] [size.x, size.y]
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.FormBorderStyle = form.FormBorderStyle.none
		if back_color != undefined do form.BackColor = netDrColor back_color
		form.ShowInTaskbar = false
		form.opacity = 0.9
		
		mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_width - form_offset*5 , bar_height]
		mcs.lblT.BackColor = netDrColor clr_back
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.Text = "Customize:"
		
		_form = form --instance
		local hv = maxHW ()
		form.show(hv) -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
		hv.ReleaseHandle()
	)
)
my_form_2 = DYNAMIC_DIALOG_COMPACT()
my_form_2.buildForm [800, 350] [350, 250] title:"My Form 2 v0.01" yellow

