--------------------------------------------------
  ----------------------------------------------------
   ----------------------------------------------------
    ---------- Micra III DOTNET DIALOG CREATOR ----------
   ----------------------------------------------------
  ---------------------------------------------------
--------------------------------------------------

Global mc_Dialog_Default
Global mcFormSnap
Global getIconDotNet
Global mcCreateNetDinamicDialog

(
	--------------------------------------
	
	--Local Variables (Inicializes at Once)
	
	--------------------------------------
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local count_limit     = 40
	local clr_back     = execute (mcFile.saveLoadIniSetings head:head_str key:"backcolor" action:#load)
	local clr_fore     = execute (mcFile.saveLoadIniSetings head:head_str key:"forecolor" action:#load)
	local clr_sel      = execute (mcFile.saveLoadIniSetings head:head_str key:"selected"  action:#load)
	local clr_mark     = execute (mcFile.saveLoadIniSetings head:head_str key:"marked"  action:#load)
	local clr_btn      = execute (mcFile.saveLoadIniSetings head:head_str key:"button"   action:#load)
	local clr_inact    = execute (mcFile.saveLoadIniSetings head:head_str key:"inactive"  action:#load)
	local clr_text     = execute (mcFile.saveLoadIniSetings head:head_str key:"textcolor"  action:#load)
	local clr_seltext  = execute (mcFile.saveLoadIniSetings head:head_str key:"seltext"  action:#load)
	local form_opacity = execute (mcFile.saveLoadIniSetings head:head_str key:"opacity"  action:#load)
	local debug = 0
	local dataformats    = dotnetclass "dataformats"
	-----------------------------------------
	
	--Local scope function (Inicializes many times)
	
	-----------------------------------------
	fn createFormInstance dname = (execute ( dname + "= dotNetObject \"form\" " ) ) --none time for each new dialog
	fn getHandles components =
	(
		for i = 0 to components.count-1 do 
		try(format "Item:%\t Item_Handle:%\n" components.item[i] components.item[i].handle)catch (print "no handle")
	)
	--------------------------------------

	--Standalone Functions (Inicializes at Once)
	
	--------------------------------------
--|	--Button Gen
	fn isMouseOnButton s a =
	(
		
	)
	fn onBtnMouseClick s a = --execute action
	(
		--if mouse is not on button return false
		local tlp = s.parent
		local picked_node = (tlp.GetChildAtPoint a.location)

		if picked_node == undefined do return false
		
if debug == 5 do format "name:%\t tag:%\n" s.name s.tag	
		if s.parent.parent.tag.value.edit_mode do return false
		if a.Button == a.Button.left do (
			--if action is assinged in this button progress
			if s.tag != undefined do mcFile.runAction s.tag 
		)
	)
--| --DragAndDrop	
	fn onMousedown s a = --drag start
	(
		local btn_a = s
		local btn_b
		local mcsA = btn_a.parent.parent.tag.value --form tag struct

		if mcsA.edit_mode and btn_a.image != undefined do  --Enabled only in Edit Mode
		(
			btn_a.DoDragDrop (netString "Micra Form DragAndDrop") netDragDropEffect.copy --modal
			
			--final draAndDrop sequence
			btn_b = mc_Form_Drop_Data

			if btn_b != undefined then --if button A draged in to button B
			(
				local mcsB = btn_b.parent.parent.tag.value
				if btn_b.tag != undefined 
				then --swap actions and icons
				(
					--swap tooltips
					local tltA = (mcsA.ToolTip.GetToolTip btn_a)--get tooltipA
					local tltB = (mcsB.ToolTip.GetToolTip btn_b)--get tooltipB

					mcsA.ToolTip.SetToolTip btn_a tltB
					mcsB.ToolTip.SetToolTip btn_b tltA
					--swap images
					local img = btn_a.Image --get imageA
					btn_a.Image = btn_b.Image 
					btn_b.Image = img
					--swap tags
					local tag = btn_a.tag --get tagA
					btn_a.Tag = btn_b.Tag
					btn_b.Tag = tag
					--save Settings
					setINISetting Micra.TempProfileIni "Buttons" btn_a.name btn_a.tag
					setINISetting Micra.TempProfileIni "Buttons" btn_b.name btn_b.tag
					local icn_numA = getINISetting Micra.TempProfileIni "Icons" btn_a.name
					local icn_numB = getINISetting Micra.TempProfileIni "Icons" btn_b.name			
					setINISetting Micra.TempProfileIni "Icons" btn_a.name icn_numB
					setINISetting Micra.TempProfileIni "Icons" btn_b.name icn_numA
				)
				else --copy if buttonB is empty
				(
					mcsB.ToolTip.SetToolTip btn_b (mcsA.ToolTip.GetToolTip btn_a) --copy tooltip
					btn_b.Image = btn_a.Image --copy image
					btn_b.Tag = btn_a.tag --copy tag
					--save Settings
					local icn_numA = getINISetting Micra.TempProfileIni "Icons" btn_a.name
					setINISetting Micra.TempProfileIni "Buttons" btn_b.name btn_b.tag
					setINISetting Micra.TempProfileIni "Icons"   btn_b.name icn_numA
					
					btn_a.image = undefined
					btn_a.tag = undefined
					mcsA.ToolTip.SetToolTip btn_a ""
					delINISetting Micra.TempProfileIni "Buttons" btn_a.name
					delINISetting Micra.TempProfileIni "Icons" btn_a.name
				)
			)
			else --remove button action (if button A draget out, in to free space)
			(
				btn_a.image = undefined
				btn_a.tag = undefined
				mcsA.ToolTip.SetToolTip btn_a ""
				delINISetting Micra.TempProfileIni "Buttons" btn_a.name
				delINISetting Micra.TempProfileIni "Icons" btn_a.name
			)
			mc_Form_Drop_Data = undefined
		)
	)
	fn onDragenter s a = --draging ower interface
	(
		local mcs = s.parent.parent.tag.value --form tag struct
		if not mcs.edit_mode do return false --Enabled only in Edit Mode
		if a.Data.GetDataPresent(DataFormats.text) and (a.data.GetData(DataFormats.text)) == "Micra Form DragAndDrop" do
		(
			a.Effect = netDragDropEffect.copy --enable drag mouse effect
		)
	)
	fn onDragdrop  s a = --drag end
	(
		local mcs = s.parent.parent.tag.value --form tag struct
		if not mcs.edit_mode do return false  --Enabled only in Edit Mode
		mc_Form_Drop_Data = s --store hited element
	)
--||
	fn generateButtons form style:undefined =
	(
		local mcs   = form.tag.value
		local bmask = form.name[form.name.count]
		mcs.tlp.controls.clear()
		mcs.tlp.ColumnCount = mcs.columns
		mcs.tlp.RowCount = mcs.rows
		mcs.tlp.InitializeLifetimeService()
		--prepare buttons data
		mcs.bobjects = #()
		--create buttons and assing them actions, icons, tooltips and names 
		for i = 1 to (mcs.rows * mcs.columns) do
		(
			--gather data from ini
			local bname = ("btn_"+bmask+ (i as integer) as string) 
			local baction  = (getIniSetting Micra.TempProfileIni "Buttons" bname    )
			local btooltip = (mcString.replaceCharInString (copy baction) "_" " ")
			local biconnum = (getIniSetting Micra.TempProfileIni "Icons" bname      ) as integer
			local bicn     = getIconDotNet biconnum
			--store data in struct
			--mcs.bnames    [ i ] = bname
			--mcs.bactions  [ i ] = baction
			--mcs.bicons    [ i ] = bicn
			--mcs.btooltips [ i ] = btooltip				
			--create button
			local btn   = dotNetObject "Button"
			btn.size   = netDrSize [btn_size, btn_size]
			btn.flatstyle = btn.flatstyle.flat
			btn.FlatAppearance.BorderColor = netDrColor clr_back
			btn.AllowDrop = true
			btn.FlatAppearance.BorderSize = 1
			--btn.cursor = btn.cursor.Current
			btn.margin =  dotnetobject "padding" 0
			btn.name   = bname
			btn.tag    = baction
			if btooltip != undefined do mcs.ToolTip.SetToolTip btn btooltip
			if bicn != undefined do btn.Image  = bicn
			
			dotNet.addEventHandler btn "MouseClick"   onBtnMouseClick --"MouseClick" 
			dotNet.addEventHandler btn "MouseDown" onMousedown
			dotNet.addEventHandler btn "DragEnter"  onDragenter
			dotNet.addEventHandler btn "DragDrop"  onDragdrop
			mcs.bobjects += #(btn)
		)
		mcs.tlp.Controls.AddRange mcs.bobjects
	)
--||
	fn minMaxForm s a form: =
	(
		if form == unsupplied do form = s.parent
		local mcs = form.tag.value
		mcs.minimized = not mcs.minimized

		if mcs.minimized
		then 
		(
			mcs.btnMin.text = "+"
			mcs.old_height = form.height 
			form.height = bar_height + form_bounds*2
			mcs.tlp.hide()
		)
		else
		(
			mcs.btnMin.text = "-"
			form.height = mcs.old_height
			mcs.tlp.show()
		)
	)
	fn resizeInterface form style:#extended =
	(
		local mcs = form.tag.value
		local table_size = [btn_size, btn_size] * [mcs.columns, mcs.rows]

		case style of
		(
			#extended:
			(
				local table_size  = [btn_size, btn_size] * [mcs.columns, mcs.rows]
				local form_size   = table_size + bar_height + form_offset + [0, bar_height]
				form.size        = netDrSize form_size
				mcs.lblT.Bounds  = netDrRect [form_bounds, form_bounds] [table_size.x , bar_height]
				mcs.tlp.Bounds   = netDrRect [form_bounds, bar_height + form_bounds] table_size
				mcs.btnHL.Bounds = netDrRect [form_bounds  , mcs.tlp.height + bar_height + form_bounds] [btn_size, bar_height]
				mcs.btnHR.Bounds = netDrRect [form_bounds + btn_size, mcs.tlp.height + bar_height + form_bounds] [btn_size, bar_height]
				mcs.btnVU.Bounds = netDrRect [mcs.tlp.width + form_bounds, form_bounds] [bar_height, btn_size]
				mcs.btnVD.Bounds = netDrRect [mcs.tlp.width + form_bounds , form_bounds + btn_size] [bar_height, btn_size]
				mcs.lblH.Bounds  = netDrRect [form_bounds, form_size.y - bar_height - form_bounds] [form_size.x - form_bounds*2, bar_height]
				mcs.lblV.Bounds  = netDrRect [mcs.tlp.width + form_bounds, form_bounds] [bar_height, form_size.y - form_bounds*2]
			)
			#compact:
			(
				local form_size    = table_size + form_offset + [0, bar_height]
				form.size         = netDrSize form_size
				mcs.lblT.Bounds   = netDrRect [form_bounds, form_bounds] [table_size.x - btn_size, bar_height]
				mcs.btnMin.Bounds = netDrRect [table_size.x - btn_size + form_bounds, form_bounds] [btn_size, bar_height]
				mcs.tlp.Bounds    = netDrRect [form_bounds, bar_height + form_bounds] table_size
			)
		)
	)
	fn manageInterface s a =
	(
		--incremental
		local mcs = s.parent.tag.value
		
		case s.tag of
		(
			"HL":(if mcs.columns > 2           do mcs.columns -= 1)
			"HR":(if mcs.columns < count_limit do mcs.columns += 1)
			"VU":(if mcs.rows    > 1           do mcs.rows    -= 1)
			"VD":(if mcs.rows    < count_limit do mcs.rows    += 1)	
		)
		

		
		--resize interface move button
		if mcs.columns > 1 and mcs.columns < count_limit and 
		   mcs.rows    > 0 and mcs.rows    < count_limit do
		(
			mcs.lblH.text = (mcs.columns as integer) as string
			mcs.lblV.text = (mcs.rows as integer) as string
			
			generateButtons ( s.parent )
			resizeInterface ( s.parent )
		)
		--reset limits
		if mcs.columns == 0           do mcs.columns  = 1
		if mcs.columns == count_limit do mcs.columns -= 1
		if mcs.rows    == 0           do mcs.rows     = 1
		if mcs.rows    == count_limit do mcs.rows    -= 1
		--save in to temp profile
		mcFile.setIniDataToArray Micra.TempProfileIni "Properties_1" s.parent.name 5 [mcs.columns, mcs.rows]
	)
--|	--Form move
	fn onLblTMouseMove s a = 
	(
		local form = s.parent
		if form.tag.value.netDMove do (mcDialog.snapForm form form.tag.value.netDmPos) --dragForm
	)
	fn onLblTMouseDown s a = 
	(
		if a.Button == a.Button.left do --enableDrag
		(
			local form = s.parent
			form.cursor.current = netCursors.Hand
			form.tag.value.netDmPos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top] 
			form.tag.value.netDMove = true 
		)
	)
	fn onLblTMouseUp s a = 
	(
		--mcSystem.show s
		--mcSystem.show a
		--mcSystem.show a.Button
		
		local form = s.parent
		form.tag.value.netDMove = false --disableDrag
		
		case a.button of
		(
			(a.button.right)  : 
			(
				form.tag.value.mnu.tag = form
				form.tag.value.mnu.Show ( s.PointToScreen a.location ) --show menu
			)
			(a.button.left )  : 
			(
				
			)
			(a.button.middle) : ()--(form.hide())
		)
	)
--||
	--Set UP
	fn setupInterface form =
	(
		local mcs = form.tag.value

		mcs.btnHL.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnHL.text = "-"
		mcs.btnHL.tag = "HL"
		mcs.btnHL.BackColor = netDrColor clr_btn --(color 124 196 22)
		
		mcs.btnHR.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnHR.text = "+"
		mcs.btnHR.tag = "HR"
		mcs.btnHR.BackColor = netDrColor clr_btn --(color 124 196 22)
		
		mcs.btnVU.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnVU.text = "-"
		mcs.btnVU.tag = "VU"
		mcs.btnVU.BackColor = netDrColor clr_btn --(color 124 196 22)
	
		mcs.btnVD.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnVD.text = "+"
		mcs.btnVD.tag = "VD"
		mcs.btnVD.BackColor = netDrColor clr_btn --(color 124 196 22)
		
		mcs.lblH.TextAlign = mcs.lblH.TextAlign.MiddleCenter
		mcs.lblH.BackColor = netDrColor clr_back --(color 84 132 15)
		mcs.lblH.text = ( mcs.columns as integer) as string
		mcs.lblH.tag = "LH"
		
		mcs.lblV.TextAlign = mcs.lblH.TextAlign.MiddleCenter
		mcs.lblV.BackColor = netDrColor clr_back --(color 84 132 15)
		mcs.lblV.tag = "LV"
		mcs.lblV.text = (mcs.rows as integer) as string
				
		dotNet.addEventHandler mcs.btnHL "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnHR "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnVU "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnVD "MouseClick" manageInterface
	)
	fn onCloseForm s a = (mcFile.saveIniDialog s.name "Properties_1") --mabe add: if not s.visible do ()
--|	--Menu
	fn hideForm s a = ((s.GetCurrentParent()).tag.hide())
	fn editForm s a form: =
	(
		if form == unsupplied do form  =  (s.GetCurrentParent()).tag
		local mcs = form.tag.value
		if mcs.minimized do minMaxForm s a form:form
		
		if mcs.edit_mode do return false --prevents to enable edit multiple times
		mcs.edit_mode = true

		setupInterface ( form )
		
		form.controls.remove ( mcs.btnMin )
		form.controls.add    ( mcs.btnHL  )
		form.controls.add    ( mcs.btnHR  )
		form.controls.add    ( mcs.btnVU  )
		form.controls.add    ( mcs.btnVD  )
		form.controls.add    ( mcs.lblH   )
		form.controls.add    ( mcs.lblV   )
		
		resizeInterface ( form ) style:#extended
	)
	fn lockForm s a form: =
	(
		if form == unsupplied do form  =  (s.GetCurrentParent()).tag
		local mcs = form.tag.value
		if not mcs.edit_mode do return false --prevents to enable lock multiple times
		mcs.edit_mode = false

		dotNet.removeEventHandler mcs.btnHL "MouseClick" manageInterface
		dotNet.removeEventHandler mcs.btnHR "MouseClick" manageInterface
		dotNet.removeEventHandler mcs.btnVU "MouseClick" manageInterface
		dotNet.removeEventHandler mcs.btnVD "MouseClick" manageInterface
		
		form.controls.remove ( mcs.btnHL  )
		form.controls.remove ( mcs.btnHR  )
		form.controls.remove ( mcs.btnVU  )
		form.controls.remove ( mcs.btnVD  )
		form.controls.remove ( mcs.lblH   )
		form.controls.remove ( mcs.lblV   )
		form.controls.add    ( mcs.btnMin )
		
		resizeInterface ( form ) style:#compact
	)
	fn onGotFocus s a = (enableAccelerators = false)
	fn onLostFocus s a = (enableAccelerators = true; s.clear(); s.hide())
	fn onRename s a =
	(
		if a.KeyValue == 13 --Enter
		then 
		(
			if s.text != "" do 
			(
				s.parent.text = s.text
				mcFile.setIniDataToArray Micra.TempProfileIni "Properties_1" s.parent.parent.name 4 s.text
			)
			s.clear()
			s.hide()
		)
		else if a.KeyValue == 27 then -- Ecape
		(
			s.clear()
			s.hide()
		) 
	)
	fn renameForm s a =
	(
		local form = (s.GetCurrentParent()).tag
		local mcs = form.tag.value
		mcs.edit_box.text = mcs.lblT.text
		if mcs.lblT.controls.count == 0 do
		(
			dotNet.addEventHandler mcs.edit_box "KeyUp" onRename
			dotNet.addEventHandler mcs.edit_box "GotFocus" onGotFocus
			dotNet.addEventHandler mcs.edit_box "LostFocus" onLostFocus
			mcs.lblT.controls.add (mcs.edit_box)
		)
		mcs.edit_box.show()
		mcs.edit_box.focus()
	)
--||
	fn onLblTDoubleClick s a =
	(
		local form  =  s.parent
		form.tag.value.netDMove = false 
		if form.tag.value.minimized do minMaxForm s a form:form
		if form.tag.value.edit_mode 
		then lockForm s a form:form
		else editForm s a form:form
	)
	--Inicialize
	fn inicializeInterface form  style:#compact title:"undefined" pos:undefined =
	(
		local mcs = form.tag.value
		--Interface Setup
		form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.Location = netDrPoint pos
		--form.Bounds = netDrRect [200, 100] [form_size.x, form_size.y]
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = netDrColor clr_fore --yellow
		form.MinimumSize = netDrSize [btn_size, bar_height]
		form.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
		form.ShowInTaskbar = false
		form.opacity = form_opacity
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor clr_back
		mcs.ToolTip.ForeColor = netDrColor clr_text
		mcs.ToolTip.AutoPopDelay = 5000
		mcs.ToolTip.InitialDelay = 400
		mcs.ToolTip.ReshowDelay = 100
		mcs.ToolTip.ShowAlways = true
		
		mcs.mnu.BackColor = netDrColor clr_back
		mcs.mnu.ForeColor = netDrColor clr_text
		mcs.mnu.ShowImageMargin = false
		
		mcs.lblT.BackColor = netDrColor clr_back --(color 84 132 15)
		mcs.lblT.ForeColor = netDrColor clr_text
		mcs.lblT.text = title
		--.ContextMenu : 	undefined
		--.ContextMenuStrip : undefined
		--.Parent : 	undefined
		
		mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
		mcs.btnMin.BackColor = netDrColor clr_btn --(color 124 196 22)
		mcs.btnMin.text = "-"

		mcs.tlp.backColor = netDrColor clr_btn --( green )
		
		mcs.edit_box.BackColor= netDrColor clr_back
		mcs.edit_box.ForeColor= netDrColor clr_text
		mcs.edit_box.size = netDrSize [form.width - form_offset, btn_size]
		mcs.edit_box.BorderStyle = mcs.edit_box.BorderStyle.FixedSingle

		dotNet.addEventHandler mcs.btnMin "MouseClick"   minMaxForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp --"MouseClick" 
		dotNet.addEventHandler mcs.lblT   "DoubleClick" onLblTDoubleClick
		
		dotNet.addeventhandler mcs.mnu_close "Click" hideForm
		dotNet.addeventhandler mcs.mnu_edit  "Click" editForm
		dotNet.addeventhandler mcs.mnu_lock  "Click" lockForm
		dotNet.addeventhandler mcs.mnu_ren  "Click" renameForm
		
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		
		form.controls.addRange(#(mcs.tlp, mcs.lblT, mcs.btnMin))
	)
	--START BUILDING
	fn mcCreateNetDinamicDialog dname = 
	(
		try (execute ( dname+".close()" )) catch()
		
		-->Components---------------------------------------------------------------------
		local form  = createFormInstance dname
		local cr = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" dname 5)
		struct MICRA_COMPONENTS_STRUCT 
		( 
			ToolTip   = dotNetObject "ToolTip",
			mnu       = dotNetObject "ContextMenuStrip",
			mnu_close = mnu.Items.Add "Close...",
			mnu_edit  = mnu.Items.Add "Edit..." , 
			mnu_lock  = mnu.Items.Add "Lock..." , 
			mnu_ren  = mnu.Items.Add "Rename..." , 
			tlp       = dotNetObject "TableLayoutPanel",
			btnMin    = dotNetObject "button"  ,
			btnHL     = dotNetObject "button",
			btnHR     = dotNetObject "button" ,
			btnVU     = dotNetObject "button" ,
			btnVD     = dotNetObject "button" ,
			lblT      = dotNetObject "label" ,
			lblH      = dotNetObject "label"  ,
			lblV      = dotNetObject "label" ,
			edit_box  = dotNetObject "textBox",
			columns,
			rows,
			old_height, 
			minimized = false, 
			edit_mode = false, 
			bobjects=#(), 
			netDMove = false,
			netDmPos
			--bnames=#(), 
			--bactions=#(), 
			--bicons=#(), 
			--btooltips=#() 
		)
		
		form.name = dname
		form.tag  = dotNetMXSValue (MICRA_COMPONENTS_STRUCT columns:cr.x rows:cr.y) --Manual Lifetime
		
		--ini data
		local dpos   = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" dname 2)
		local dtitle = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_1" dname 4)
		
		inicializeInterface ( form ) style:#compact title:dtitle pos:dpos
		generateButtons     ( form  ) style:#start
		resizeInterface     ( form  ) style:#compact
	
		mcDotnet.dShow form
	)
)

/*
mcCreateNetDinamicDialog "mc_Dialog_F"
mcCreateNetDinamicDialog "mc_Dialog_G"
mcCreateNetDinamicDialog "mc_Dialog_H"
mcCreateNetDinamicDialog "mc_Dialog_I"
mc_Dialog_F.hide()
mc_Dialog_F.show()
*/
