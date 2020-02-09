--------------------------------------------------------------------------------
/* mcSecurity by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcDotnet
	mcFile
*
*@Used Objects

*
*@Example
	mcSecurity.progeressbar a.ProgressPercentage msg:"Downoading Update:"
	if a.ProgressPercentage >= 100 do mcSecurity.progeressbar 100 msg:"Downoad Finished:" close:true 
*/
Struct MICRA_SECURITY_POPUP (

	_drag_pos = [0,0,0], --form mouse pos
	_typed_text = "",
	_invalid_characters = "^[]()\\/*{}-+><=;:,.%@#&?!$ ",
	_form_name = "MaxCenter",
	_btn_size   = 24,
	_border_offset  = 2,
	_bar_height     = 14,
	fn getSource = getSourceFileName(), --get path of this script
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	),
	fn getMaxPos = (
		
		return windows.getWindowPos (windows.getMAXHWND())
	),
	fn getMaxCenter = (
	
		local max_pos = getMaxPos()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	),
	fn closeForm form = (
		
		form.close()
		if _form_name != "MaxCenter" do mcFile.saveDialogSettings _form_name "Properties_2" 
	),
	fn removeInvalidChars str =	(
		
			if str.count == 0 do return str
			local new_str = ""
			for i=1 to str.count do (
				
				local char = str[i]
				if findString _invalid_characters char != undefined do continue
				new_str += char
			)
			return new_str
	),
	/**
	*@example 
		typed_text = mcSecurity.textBox title:"New Profile Name:" saved_pos:"Micra_TextBox"
		format "typed_text:%\n" typed_text
	*@Warning 
		this code can't be executed by enter (he would close immediately). For call, use  menu, buttons, etc...
	*/
	fn textBox title:"Type a text here:" form_name:"MaxCenter" crypt:false = ( --if form_name is not "MaxCenter" save - load  pos at defined Name
	
		local form = dotNetObject "MaxCustomControls.Maxform"
		local lblT = dotNetObject "label"
		local edtBox = dotNetObject "textbox"
		
		local border_offset = mcSecurity._border_offset
		local bar_height = mcSecurity._bar_height
		local btn_size = mcSecurity._btn_size
		
		local form_size = [320, 60]
		_form_name = form_name
		local max_center = getMaxCenter() - (form_size/2)
		local form_rect = mcDotnet.dRect max_center form_size
		--load pos from ini
		if form_name != "MaxCenter" then (
			
			local fpos = execute (mcFile.readSettings Micra.UserProfile ("Properties_2/"+form_name) type:"pos")
			if classOf fpos == Point2 do form_rect = mcDotnet.dRect fpos form_size
		) 
		fn textBoxKeyDown s a = (
		
			case a.Keycode.toString() of (
				
				"Return":( --when pressed Enter
				
					mcSecurity._typed_text = s.text
					mcSecurity.closeForm s.parent
				)
				default:( --while typing words
				
					if s.text.count > 0 do (
						
						s.text = mcSecurity.removeInvalidChars s.text --remove invalid characters
						s.SelectionStart = s.text.count --move cursor at end
					)
				)
			)
		)
		fn textBoxKeyUp s a  = ( --Escape close must be on key up to avoid error
		
			if a.Keycode.toString() == "Escape" do ( --when pressed Escape

				mcSecurity._typed_text = ""
				mcSecurity.closeForm s.parent
			)
		)
		--Move / Snap Dialog
		fn onLblTMouseMove s a = ( if a.Button == a.Button.left do mcDialog.snapForm s.parent mcSecurity._drag_pos ) --dragForm
		fn onLblTMouseDown s a = (
				
			local form = s.parent
			form.cursor.current = mcDotnet.cursors.Hand
			if a.Button == a.Button.left do ( --enable drag
				mcSecurity._drag_pos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			)
		)
		--RC close form
		fn onLblTMouseUp s a = ( if a.Button == a.Button.right then mcSecurity.closeForm s.parent ) --drop form

		form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.bounds = form_rect
		--form.BackColor =mcDotnet.uiColor #fore
		form.ShowInTaskbar = false
		form.FormBorderStyle = form.FormBorderStyle.none
		form.opacity = 1--(mcUIColors.get #opacity)
		--form.TopMost=true
		
		--toolbar
		lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [form.width - border_offset*2 , bar_height]
		lblT.BackColor = mcDotnet.uiColor #back
		lblT.ForeColor = mcDotnet.uiColor #text
		lblT.TextAlign = lblT.TextAlign.MiddleCenter
		lblT.Text = title
		
		edtBox.bounds = mcDotnet.dRect [ border_offset ,bar_height+border_offset*2] [300, 22]
		edtBox.Multiline = true
		edtBox.BackColor= mcDotnet.uiColor #edtback
		edtBox.ForeColor= mcDotnet.uiColor #edtfore
		local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 12 ((dotNetClass "System.Drawing.FontStyle").bold)
		edtBox.font = dnfontlarge
		if crypt do ( --switch to enter text or stars

			edtBox.PasswordChar = "*"
			edtBox.MaxLength = 8
		)
		
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		dotnet.addEventHandler edtBox "KeyUp" textBoxKeyUp
		dotnet.addEventHandler edtBox "KeyDown" textBoxKeyDown

		form.controls.addRange ( #(lblT, edtBox)  )
		form.ShowModal() 
		return _typed_text
	),
	fn progeressBar val color:(color 255 200 18) msg:"Progress..." image:"default" close:false = (
	
		if mcProgressBarDialog == undefined do
		(
			rollout mcProgressBarDialog " Inicialize Gallery3D Database:" width:332 height:132
			(
				GroupBox grp_info "Progress...0%" pos:[8,4] width:316 height:120
				bitmap bmpPop1 "Bitmap" pos:[16,20] width:300 height:80 fileName:(Micra.RootDir+"Img\\3DGall_Loader_01.bmp")
				progressBar pBar "ProgressBar" pos:[16,104] width:300 height:13
				button btn_close "*" pos:[312,4] width:12 height:12
				on btn_close pressed do destroyDialog mcProgressBarDialog
			)
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		if not mcProgressBarDialog.isDisplayed then
		(
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		mcProgressBarDialog.pBar.value    = val
		mcProgressBarDialog.grp_info.text = msg +"( "+ ((val as integer) as string) + " )%"
		if close do (sleep 0.3; destroyDialog mcProgressBarDialog)
	)
	/*<end>*/
)
 --create instance
Global mcSecurity = mcStructMan.instanceStructure MICRA_SECURITY_POPUP "mcSecurity"

/*
	--TODO Remake it in Dotnet
	
	fn progeressbar val close:false color:(color 255 200 18) =
	(
		if mcProgressBarDialog == undefined do
		(
			rollout mcProgressBarDialog " Inicialize Gallery3D Database:" width:332 height:132
			(
				GroupBox grp_info "Progress...0%" pos:[8,4] width:316 height:120
				bitmap bmpPop1 "Bitmap" pos:[16,20] width:300 height:80 fileName:(Micra.RootDir+"Img\\3DGall_Loader_01.bmp")
				progressBar pBar "ProgressBar" pos:[16,104] width:300 height:13
				button btn_close "*" pos:[312,4] width:12 height:12
				on btn_close pressed do destroyDialog mcProgressBarDialog
			)
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		if not mcProgressBarDialog.isDisplayed then
		(
			createDialog mcProgressBarDialog style:#(#style_border) --modal:true
			mcProgressBarDialog.pBar.color = color
		)
		mcProgressBarDialog.pBar.value    = val
		mcProgressBarDialog.grp_info.text = "Progress..."+ ((val as integer) as string) + "%"
		if close do (sleep 0.3; destroyDialog mcProgressBarDialog)
	),
*/