-------------------------------------------------------------------------------------------------------------------------------
if ::mcTemplateDialog != undefined do try(mcTemplateDialog.Close())catch()
-------------------------------------------------------------------------------------------------------------------------------	
--Form interface and functions Structure
struct DOTNET_FORM_STRUCT (
public
	-- Default Properties
	form = dotNetObject "MaxCustomControls.Maxform",
	lblT = dotNetObject "label",
	btnMin = dotNetObject "button",
	tlp = dotNetObject "TableLayoutPanel",
	old_height,  
	netDmPos, --mouse pos on dialog
	form_size        = [746, 516],
	bar_height      = 14,
	border_offset  = 2,
	btn_size         = 24,
	debug = 0,
	-- Custom Properties
	
	-- Default Functions
	on clone do (
	
		format "Struct Cloned: %\n" this
	),
	fn close = (form.close()),
	fn onOpenForm s a = (
		
		--this.form = mcTemplateDialog -- instance
		format "form was opened:%\n" s
	),
	fn onCloseForm s a = (mcFile.saveIniDialog s.name "Properties_2"),
	fn changeBackcolor s a = (s.backColor = mcDotnet.dColor (mcUIColors.get #fore)),
	fn minMaxForm s a = ( -- s = Button, a = MouseEventArgs
		
		local minimized = old_height > form.height 
		if minimized then (
			
			btnMin.text = "+"
			old_height = form.height 
			form.height = bar_height + border_offset*2
		) else (
			
			btnMin.text = "-"
			form.height = old_height
		)
	),
	--Move / Snap Dialog
	fn onLblTMouseMove s a = ( if a.Button == a.Button.left do  mcDialog.snapForm form netDmPos), --drag form
	fn onLblTMouseDown s a = ( --start drag
			
		form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
			netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top]  
		)
	),
	fn onLblTMouseUp s a = (if a.Button == a.Button.right then close()), --stop drag or close
	-- Custom  Functions
	
	
	-- Initialize Form Function
	fn init  form_name = (

		format "init form:%\n" form_name
		local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" form_name 2) --pick custom fpos
		if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" form_name 2) --pick default fpos
		if fpos == undefined do ( --register new fpos
		
			fpos = [0, 0]
			mcFile.setIniDataToArray Micra.TempProfileIni "Properties_2" form_name 2 fpos 	
			mcFile.setIniDataToArray Micra.DefaultProfileIni "Properties_2" form_name 2 fpos 
		)
		form.name = form_name
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.dColor (mcUIColors.get #fore)
		form.opacity = mcUIColors.get #opacity
		
		--toolbar
		lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
		lblT.BackColor = mcDotnet.dColor (mcUIColors.get #back)
		lblT.ForeColor = mcDotnet.dColor (mcUIColors.get #text)
		lblT.Text = "Dialog Template v" + (Micra.getScriptVersion "Dialog_Template") --update script title with version
		
		--min max button
		btnMin.FlatStyle = btnMin.FlatStyle.flat
		btnMin.BackColor = mcDotnet.dColor (mcUIColors.get #btn)
		btnMin.ForeColor = mcDotnet.dColor (mcUIColors.get #text)
		btnMin.text = "-"
		btnMin.Bounds = mcDotnet.dRect [form_size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
		
		--Componnts Layout
		tlp.Bounds  = mcDotnet.dRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
		tlp.backColor = mcDotnet.dColor(mcUIColors.get #btn)
		
		--Custom Components
		--
		
		--Add Controls
		form.controls.addRange ( #(tlp, btnMin, lblT)  )
		mcDotnet.dShow form
		form
	)
)
-------------------------------------------------------------------------------------------------------------------------------
Global mcTemplateDialog = DOTNET_FORM_STRUCT() --Make structure instance to have access all components
-------------------------------------------------------------------------------------------------------------------------------
--init form
(
	local mcs = mcTemplateDialog
	local dia = mcs.form
	-- Default Events
	dotnet.addEventHandler dia	"Shown"						mcs.onOpenForm
	dotnet.addEventHandler dia	"Closed"						mcs.onCloseForm
	dotnet.AddEventHandler dia	"BackColorChanged"	mcs.changeBackcolor --override backcolorchanged event (without this form color is default)
	dotNet.addEventHandler mcs.btnMin	"MouseClick"	mcs.minMaxForm
	dotNet.addEventHandler mcs.lblT		"MouseMove"	mcs.onLblTMouseMove
	dotNet.addEventHandler mcs.lblT		"MouseDown"	mcs.onLblTMouseDown 
	dotNet.addEventHandler mcs.lblT		"MouseUp"		mcs.onLblTMouseUp
	--Custom Events
	--
	mcTemplateDialog.init  "mcTemplateDialog" 
	--clear temp data
	DOTNET_FORM_STRUCT = undefined
	initForm = undefined 
)
/*
mcTemplateDialog.form
DOTNET_FORM_STRUCT = undefined
format "mcTemplateDialog:%\n" mcTemplateDialog.btn_size
format "DOTNET_FORM_STRUCT:%\n" DOTNET_FORM_STRUCT
clearListener()
*/
