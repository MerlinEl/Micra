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
	fn close = (form.close()),
	fn onOpenForm s a = (format "form was opened:%\n" s),
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
	fn onLblTMouseMove s a = ( if a.Button == a.Button.left do  mcDialog.snapForm dia netDmPos), --drag form
	fn onLblTMouseDown s a = ( --start drag
			
		form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
			mcs.netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top]  
		)
	),
	fn onLblTMouseUp s a = (if a.Button == a.Button.right then close()) --stop drag or close
	-- Custom  Functions
)
-------------------------------------------------------------------------------------------------------------------------------
Global mcTemplateDialog = DOTNET_FORM_STRUCT() --Make structure instance to have access all components
-------------------------------------------------------------------------------------------------------------------------------
fn initForm mcs form_name = (
	
	local form_size		= mcs.form_size 
	local bar_height		= mcs.bar_height 
	local border_offset	= mcs.border_offset 
	local btn_size		= mcs.btn_size 
	
	format "init form:%\n" form_name
	local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" form_name 2) --pick custom fpos
	if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" form_name 2) --pick default fpos
	if fpos == undefined do ( --register new fpos
	
		fpos = [0, 0]
		mcFile.setIniDataToArray Micra.TempProfileIni "Properties_2" form_name 2 fpos 	
		mcFile.setIniDataToArray Micra.DefaultProfileIni "Properties_2" form_name 2 fpos 
	)
	mcs.form.name = form_name
	mcs.form.ControlBox  = false --hide main bar
	mcs.form.ShowInTaskbar = false
	mcs.form.StartPosition = mcs.form.StartPosition.Manual
	mcs.form.bounds = mcDotnet.dRect fpos form_size
	mcs.form.FormBorderStyle = mcs.form.FormBorderStyle.none
	mcs.form.BackColor = mcDotnet.dColor (mcUIColors.get #fore)
	mcs.form.opacity = mcUIColors.get #opacity
	
	--toolbar
	mcs.lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
	mcs.lblT.BackColor = mcDotnet.dColor (mcUIColors.get #back)
	mcs.lblT.ForeColor = mcDotnet.dColor (mcUIColors.get #text)
	mcs.lblT.Text = "Dialog Template v" + (Micra.getScriptVersion "Dialog_Template") --update script title with version
	
	--min max button
	mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
	mcs.btnMin.BackColor = mcDotnet.dColor (mcUIColors.get #btn)
	mcs.btnMin.ForeColor = mcDotnet.dColor (mcUIColors.get #text)
	mcs.btnMin.text = "-"
	mcs.btnMin.Bounds = mcDotnet.dRect [form_size.x - (mcs.btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
	
	--Componnts Layout
	mcs.tlp.Bounds  = mcDotnet.dRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
	mcs.tlp.backColor = mcDotnet.dColor(mcUIColors.get #btn)
	
	--Custom Components
	--
	
	-- Default Events
	dotnet.addEventHandler mcs.form		"Shown"				mcs.onOpenForm
	dotnet.addEventHandler mcs.form		"Closed"				mcs.onCloseForm
	dotnet.AddEventHandler mcs.form		"BackColorChanged"	mcs.changeBackcolor --override backcolorchanged event (without this form color is default)
	dotNet.addEventHandler mcs.btnMin	"MouseClick"			mcs.minMaxForm
	dotNet.addEventHandler mcs.lblT		"MouseMove"			mcs.onLblTMouseMove
	dotNet.addEventHandler mcs.lblT		"MouseDown"			mcs.onLblTMouseDown 
	dotNet.addEventHandler mcs.lblT		"MouseUp"			mcs.onLblTMouseUp
	--Custom Events
	--
	
	--Add Controls
	mcs.form.controls.addRange ( #(mcs.tlp, mcs.btnMin, mcs.lblT)  )
	mcDotnet.dShow mcs.form
	OK
)
--initialize form
initForm mcTemplateDialog "mcTemplateDialog" 
--clear temp data
DOTNET_FORM_STRUCT = undefined
initForm = undefined 

/*

DOTNET_FORM_STRUCT = undefined
format "mcTemplateDialog:%\n" mcTemplateDialog.btn_size
format "DOTNET_FORM_STRUCT:%\n" DOTNET_FORM_STRUCT
clearListener()
*/
