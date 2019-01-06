Global mcTemplateDialog 

struct MICRA_CORE_STRUCT (
			
	--local variables
	form_size		= [746, 516],
	form_pos		=[200, 200],
	bar_height		= 14,
	border_offset	= 2,
	btn_size        	= 24,
	--Interface components
	form	= dotNetObject "MaxCustomControls.Maxform",
	lblT		= dotNetObject "label",
	fn  close = (form.hide())
)
		
struct DOTNET_MAIN_STRUCT (
	
public
	name,
	mcs = MICRA_CORE_STRUCT(),
	inst = "123",
private	
	fn init = (
		
		mcs.form.name = name
		mcs.form.ControlBox  = false --hide main bar
		mcs.form.ShowInTaskbar = false
		mcs.form.StartPosition = mcs.form.StartPosition.Manual
		mcs.form.bounds = mcDotnet.dRect mcs.form_pos mcs.form_size
		mcs.form.FormBorderStyle = mcs.form.FormBorderStyle.none
		mcs.form.BackColor = mcDotnet.uiColor #fore
		mcs.form.opacity = 1 ---mcUIColors.get #opacity
		
		--toolbar
		mcs.lblT.bounds = mcDotnet.dRect [mcs.border_offset, mcs.border_offset] [mcs.form_size.x - mcs.border_offset*10 , mcs.bar_height]
		mcs.lblT.BackColor = mcDotnet.uiColor #back
		mcs.lblT.ForeColor = mcDotnet.uiColor #text
		mcs.lblT.Text = "Dialog Template v" + (Micra.getScriptVersion "Dialog_Template") --update script title with version
		
		--dia = mcs.form
		fn onLblTMouseUp s a = ( if a.Button == a.Button.right then format "mouse up:%\n" inst) --stop drag or close  s.parent.mcs.close()
		dotNet.addEventHandler mcs.lblT	"MouseUp"	onLblTMouseUp
		
		--Add Controls
		mcs.form.controls.addRange ( #(mcs.lblT)  )
		mcs --return interface struct
	),
	-- Default Functions
private	
	fn onOpenForm s a = (),
	/*fn onCreate = (
		
		format "form hass beeen created!\n"
		init()
	),*/
	--mcs = onCreate(),
public
	fn open = (

		init()
		format "open form:% class mcs:%\n" name mcs
		mcs.form.show()
	)
)
mcTemplateDialog = DOTNET_MAIN_STRUCT "mcTemplateDialog"
cr = mcTemplateDialog.open()

/*
if ::mcTemplateDialog != undefined do try(mcTemplateDialog.Close())catch()
struct DOTNET_MAIN_STRUCT (

	-- Default Properties
	form = dotNetObject "MaxCustomControls.Maxform",
	lblT      = dotNetObject "label",
	btnMin  = dotNetObject "button",
	tlp        = dotNetObject "TableLayoutPanel",
	old_height, 
	minimized = false, 
	netDmPos, --mouse pos on dialog
	form_size        = [746, 516],
	bar_height      = 14,
	border_offset  = 2,
	btn_size         = 24,
	debug = 0,
	mcs,
	dia,
	-- Custom Properties
	
	-- Default Functions
	fn close = (dia.close()),
	fn onOpenForm s a = (),
	fn onCloseForm s a = (mcFile.saveIniDialog s.name "Properties_2"),
	fn changeBackcolor = (dia.backColor = netDrColor (mcUIColors.get #fore)),
	fn minMaxForm s a = ( -- s = Button, a = MouseEventArgs
		
		mcs.minimized = not mcs.minimized
		if mcs.minimized then (
			
			mcs.btnMin.text = "+"
			mcs.old_height = dia.height 
			dia.height = mcs.bar_height + mcs.border_offset*2
		) else (
			
			mcs.btnMin.text = "-"
			dia.height = mcs.old_height
		)
	),
	--Move / Snap Dialog
	fn onLblTMouseMove s a = ( if a.Button == a.Button.left do  mcDialog.snapForm dia mcs.netDmPos), --drag form
	fn onLblTMouseDown s a = ( --start drag
			
		dia.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
			mcs.netDmPos = [dia.MousePosition.x, dia.MousePosition.y] - [dia.left, dia.top]  
		)
	),
	fn onLblTMouseUp s a = (if a.Button == a.Button.right then mcs.close()), --stop drag or close
	-- Custom  Functions
	
	-- SetUp Interface
	fn init form_name = (


		form.name = form_name
		local fpos = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" "mcTemplateDialog" 2) --pick custom fpos
		if fpos == undefined do fpos = (mcFile.getIniDataFromArray Micra.DefaultProfileIni "Properties_2" "mcTemplateDialog" 2) --pick default fpos
		if fpos == undefined do ( --register new fpos
		
			fpos = [0, 0]
			mcFile.setIniDataToArray Micra.TempProfileIni "Properties_2" "mcTemplateDialog" 2 fpos 	
			mcFile.setIniDataToArray Micra.DefaultProfileIni "Properties_2" "mcTemplateDialog" 2 fpos 
		)
		
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = netDrRect fpos form_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor (mcUIColors.get #fore)
		form.opacity = 1--(mcUIColors.get #opacity)
		--form.TopMost=true
		
		--toolbar
		lblT.bounds = netDrRect [border_offset, border_offset] [form_size.x - border_offset*10 , bar_height]
		lblT.BackColor = netDrColor (mcUIColors.get #back)
		lblT.ForeColor = netDrColor (mcUIColors.get #text)
		lblT.Text = "Dialog Template v" + (Micra.getScriptVersion "Dialog_Template") --update script title with version
		
		--min max button
		btnMin.FlatStyle = btnMin.FlatStyle.flat
		btnMin.BackColor = netDrColor (mcUIColors.get #btn)
		btnMin.ForeColor = netDrColor (mcUIColors.get #text)
		btnMin.text = "-"
		btnMin.Bounds = netDrRect [form_size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
		
		--Componnts Layout
		tlp.Bounds  = netDrRect [border_offset, bar_height + border_offset * 2] [form_size.x - 20, form_size.y - 36]
		tlp.backColor = netDrColor(mcUIColors.get #btn)
		
		--Custom Components
		--
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onOpenForm
		dotnet.addEventHandler form "Closed" onCloseForm
		dotNet.addEventHandler btnMin "MouseClick" minMaxForm
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override backcolorchanged event (without this form color is default)
		
		--Custom Events
		--
		
		--Add Controls
		form.controls.addRange ( #(tlp, btnMin, lblT)  )
		mcDotnet.dShow form
		OK
	),
	initIt = init "mcTemplateDialog" 
)
mcTemplateDialog.clone DOTNET_MAIN_STRUCT --structure shortcut
*/