--------------------------------------------------
  ----------------------------------------------------
   ----------------------------------------------------
    ---------- Micra III DOTNET DIALOG CREATOR ----------
   ----------------------------------------------------
  ---------------------------------------------------
--------------------------------------------------

Global mcGM
Global mc_Dialog_A
Global mc_Dialog_B
Global mc_Dialog_C
Global mc_Dialog_D
Global mc_Dialog_E
Global mc_Dialog_F
Global mc_Dialog_G
Global mc_Dialog_H
Global mc_Dialog_I
Global mc_Dialog_J
Global mcFormSnap
Global getIconDotNet
Global mcCreateNetDynamicDialog

(
	--------------------------------------
	
	--Local Variables (Inicializes at Once)
	
	--------------------------------------
	local bar_height      = 14
	local form_bounds     = 2
	local form_offset     = 4
	local btn_size        = 24
	local count_limit     = 40
	local debug = 0
	local dataformats    = dotnetclass "dataformats"
	local dnd_id = "Micra Form DragAndDrop" --Drag and drop ID. Defines where is allowed drop.
	-----------------------------------------
	
	--Local scope function (Inicializes many times)
	
	-----------------------------------------
	--fn createFormInstance dname = (execute ( dname + "= dotNetObject \"form\" " ) ) --none time for each new dialog
	fn createFormInstance dname = (execute ( dname + "= dotNetObject \"MaxCustomControls.Maxform\" " ) ) --none time for each new dialog
	fn getHandles components =
	(
		for i = 0 to components.count-1 do 
		try(format "Item:%\t Item_Handle:%\n" components.item[i] components.item[i].handle)catch (print "no handle")
	)
	fn defNWin = (
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		return nw
	)
	--------------------------------------

	--Standalone Functions (Inicializes at Once)
	
	--------------------------------------
--|	--Button Gen
	fn isMouseOnButton s a =
	(
		
	)
	--fn onBtnMouseUp s a = (enableAccelerators = true; print "mouse up") --set focus to viewport
	fn onBtnMouseClick s a = --execute action
	(
		--if mouse is not on button return false
		local tlp = s.parent
		local picked_node = (tlp.GetChildAtPoint a.location)

		if picked_node == undefined do return false
		
if debug == 5 do format "name:%\t tag:%\n" s.name s.tag	
		if s.parent.parent.tag.value.edit_mode do return false
		if a.Button == a.Button.left do mcActionsEditor.runAction s.tag	
	)
--| --DragAndDrop
	--btn:dotNetObject:System.Windows.Forms.ToolStripMenuItem args:dotNetObject:System.EventArgs
	/*fn actionAddRemoveModify s a = (
		
		--Send parameter > Depends on choice
		local action_mode = case s.Text of (
			
			"Add Action...":"add"
			"Edit Action...":"edit"
			"Create Action...":"create"
			"Remove Action...":(
			
				local btn = mcGM.getParam "active_button"
				if btn == undefined do return false
				format "Remove Action in btn:%\n" btn.tag
				local mcs = btn.parent.parent.tag.value
				mcs.ToolTip.SetToolTip btn ""
				btn.image = undefined
				btn.tag = undefined
				mcActionsEditor.deleteButton btn_a.name --unregister button A
				undefined
			)		
		)
		--Send parameter > Open Customize Dialog
		--format "set action mode to:%\n" action_mode
		if action_mode != undefined do (
			
			mcGM.setParam "action_editor_switch" action_mode
			mcFile.fileInVersion "Customize"
		)
	)*/
	fn onMousedown s a = --drag start
	(
		local btn_a = s
		local btn_b
		local formA = btn_a.parent.parent
		local mcsA = formA.tag.value --Form tag struct
		if not mcsA.edit_mode do return false  --Enabled only in Edit Mode
		
		case a.Button.ToString() of
		(
			"Left": --DragAndDrop 
			(		
				if  btn_a.image != undefined do
				(
					-- this actually starts the drag and drop process
					-- simultaneously copy dnd_id to clipboard
					btn_a.DoDragDrop (netString dnd_id) netDragDropEffect.copy -- (modal)
					
					--final draAndDrop sequence
					btn_b = mcGM.getParam "form_drop_data" --get drop data from memory

					if btn_b != undefined then --if button A draged in to button B
					(
						local mcsB = btn_b.parent.parent.tag.value
						if btn_b.tag != undefined 
						then --swap two actions
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
							--swap xml settings
							mcFile.swapSettings Micra.UserProfile ("Buttons/"+btn_a.name) ("Buttons/"+btn_a.name)
						)
						else --copy if buttonB is empty
						(
							mcsB.ToolTip.SetToolTip btn_b (mcsA.ToolTip.GetToolTip btn_a) --copy tooltip
							--btn_b.Cat = btn_a.name
							btn_b.Image = btn_a.Image --copy image
							btn_b.Tag = btn_a.tag --copy tag
							--save Settings
							local data_a = mcFile.readSettings Micra.UserProfile ("Buttons/"+btn_a.name) type:"attribs" --get buton A data (action, icon)
							mcActionsEditor.saveButton btn_b.name (data_a.get "action") (data_a.get "icon")
							
							btn_a.image = undefined
							btn_a.tag = undefined
							mcsA.ToolTip.SetToolTip btn_a ""
							mcActionsEditor.deleteButton btn_a.name --unregister button A
						)
					)
					else --remove button action (if button A draget out, in to free space)
					(
						btn_a.image = undefined
						btn_a.tag = undefined
						mcsA.ToolTip.SetToolTip btn_a ""
						mcActionsEditor.deleteButton btn_a.name --unregister button A
					)
					mcGM.setParam "form_drop_data" undefined --clear dorop data memory
				)
			)
			"Middle":
			(
				
			)
			"Right": --RC Menu
			(
				--Removed for now 
				--TODO Focus on method transfer button info
				--if button mode edit > set customize SaveAction to true else false
				--if button mode add > set all to false (only drag and drop is allowed)
				--if button mode create > set customize AddAction to true else false
				--if button mode create > do not open customize
				/*local mco = mcObject()
				mco.addMore #(

					mcItem "dialog" formA,
					mcItem "button" btn_a,
					mcItem "action_category" (substring mcsA.lblT.text 1 (mcsA.lblT.text.count-1)),
					mcItem "action_name" btn_a.tag,
					mcItem "button_id" btn_a.name
				)
				mcGM.setParam "action_editor_data" mco
		
				---format "active dialog:% button:% category:% action:% id:%\n" active_dialog active_button category_name action_name button_id
				
				mcGM.setParam "active_button" btn_a --keep button in memeory

				
				--local dtitle = 
				
				local action_exists = (btn_a.Image != undefined) 
				mcsA.mnu2_add_action.enabled = not action_exists
				mcsA.mnu2_edit_action.enabled = action_exists
				mcsA.mnu2_create_action.enabled = not action_exists
				mcsA.mnu2_remove_action.enabled = action_exists

				mcsA.mnu2.Show ( s.PointToScreen a.location ) --show menu*/
			)
		)
	)
	fn onDragenter s a = --draging item ower interface
	(
		--format "Dialog Creator > onDragenter > s:% a%:\n" s a
		local mcs = s.parent.parent.tag.value --form tag struct
		if not mcs.edit_mode do return false --Enabled only in Edit Mode
		if not a.Data.GetDataPresent(DataFormats.text) do return false --check if ID string  is in clipboard
		local clipboard_text = a.data.GetData(DataFormats.text) --catch ID string from clipboard
		if clipboard_text == dnd_id do
		(
			a.Effect = netDragDropEffect.copy --enable drag mouse effect
		)
	)
	fn onDragdrop  s a = --drag end
	(
		--format "Dialog Creator > onDragdrop > s:% a%:\n" s a
		local mcs = s.parent.parent.tag.value --form tag struct
		if not mcs.edit_mode do return false  --Enabled only in Edit Mode
		mcGM.setParam "form_drop_data" s --store hited element
	)
	/*fn onMouseEnter s a = (
	
		--local char_str = a.KeyChar  --a.button --a.Keycode.toString()
		format "Mouse enter on button button tag:% name:%\n" s.tag s.name
	)*/
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
			local bname		= ("btn_"+bmask+ (i as integer) as string) 
			local bdata		= mcFile.readSettings Micra.UserProfile ("Buttons/"+bname) type:"attribs"
			local baction, btooltip, biconnum, bicn
			if bdata == "" then (  -- create empty button (this button id is not registred)
				
				baction		= ""
				btooltip	= ""
				biconnum	= 1
				bicn		= getIconDotNet biconnum
			) else ( --create button with action, icon and tooltip
				
				baction		= bdata.get "action"
				btooltip	= (mcString.replaceAll (copy baction) "_" " ")
				biconnum	= (bdata.get "icon") as integer
				bicn		= getIconDotNet biconnum
			)
			--store data in struct
			--mcs.bnames    [ i ] = bname
			--mcs.bactions  [ i ] = baction
			--mcs.bicons    [ i ] = bicn
			--mcs.btooltips [ i ] = btooltip				
			--create button
			local btn   = dotNetObject "Button"
			btn.size   = netDrSize [btn_size, btn_size]
			btn.flatstyle = btn.flatstyle.flat
			btn.FlatAppearance.BorderColor = netDrColor (mcUIColors.get #back)
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
			--dotNet.addEventHandler btn "MouseUp" onBtnMouseUp
--dotNet.addEventHandler btn "MouseEnter" onMouseEnter  --test mouse enter
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
		--save button count in to xml profile
		mcFile.saveSettings Micra.UserProfile ("Properties_1/"+s.parent.name) ([mcs.columns, mcs.rows] as String) type:"btnCount"
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
				form.tag.value.mnu1.tag = form
				form.tag.value.mnu1.Show ( s.PointToScreen a.location ) --show menu
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
		mcs.btnHL.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
		
		mcs.btnHR.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnHR.text = "+"
		mcs.btnHR.tag = "HR"
		mcs.btnHR.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
		
		mcs.btnVU.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnVU.text = "-"
		mcs.btnVU.tag = "VU"
		mcs.btnVU.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
	
		mcs.btnVD.FlatStyle = mcs.btnHR.FlatStyle.flat
		mcs.btnVD.text = "+"
		mcs.btnVD.tag = "VD"
		mcs.btnVD.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
		
		mcs.lblH.TextAlign = mcs.lblH.TextAlign.MiddleCenter
		mcs.lblH.BackColor = netDrColor (mcUIColors.get #back) --(color 84 132 15)
		mcs.lblH.text = ( mcs.columns as integer) as string
		mcs.lblH.tag = "LH"
		
		mcs.lblV.TextAlign = mcs.lblH.TextAlign.MiddleCenter
		mcs.lblV.BackColor = netDrColor (mcUIColors.get #back) --(color 84 132 15)
		mcs.lblV.tag = "LV"
		mcs.lblV.text = (mcs.rows as integer) as string
				
		dotNet.addEventHandler mcs.btnHL "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnHR "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnVU "MouseClick" manageInterface
		dotNet.addEventHandler mcs.btnVD "MouseClick" manageInterface
	)
	fn onCloseForm s a = (mcFile.saveDialogSettings s.name "Properties_1") --mabe add: if not s.visible do ()
	fn changeBackcolor s a = (s.backColor = netDrColor (mcUIColors.get #fore))
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
			if s.text != "" do (
			
				s.parent.text = s.text
				mcFile.saveSettings Micra.UserProfile ("Properties_1/"+s.parent.parent.name) s.text type:"title"
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
--|| edit switch
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
		form.BackColor = netDrColor (mcUIColors.get #fore) --yellow
		form.MinimumSize = netDrSize [btn_size, bar_height]
		form.MaximumSize = netDrSize [btn_size*count_limit, btn_size*count_limit]
		form.ShowInTaskbar = false
		form.opacity = (mcUIColors.get #opacity)
		
		mcs.ToolTip.IsBalloon = true
		mcs.ToolTip.BackColor = netDrColor (mcUIColors.get #back)
		mcs.ToolTip.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.ToolTip.AutoPopDelay = 5000
		mcs.ToolTip.InitialDelay = 400
		mcs.ToolTip.ReshowDelay = 100
		mcs.ToolTip.ShowAlways = true
		
		mcs.mnu1.BackColor = netDrColor (mcUIColors.get #back)
		mcs.mnu1.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.mnu1.ShowImageMargin = false
		
		/*mcs.mnu2.BackColor = netDrColor (mcUIColors.get #back)
		mcs.mnu2.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.mnu2.ShowImageMargin = false*/
		
		mcs.lblT.BackColor = netDrColor (mcUIColors.get #back) --(color 84 132 15)
		mcs.lblT.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.lblT.text = title --Dialog Title 
		--.ContextMenu : 	undefined
		--.ContextMenuStrip : undefined
		--.Parent : 	undefined
		
		mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
		mcs.btnMin.BackColor = netDrColor (mcUIColors.get #btn) --(color 124 196 22)
		mcs.btnMin.ForeColor = netDrColor (mcUIColors.get #text)
		mcs.btnMin.text = "-"

		mcs.tlp.backColor = netDrColor (mcUIColors.get #btn) --( green )
		
		mcs.edit_box.BackColor= netDrColor (mcUIColors.get #back)
		mcs.edit_box.ForeColor= netDrColor (mcUIColors.get #text)
		mcs.edit_box.size = netDrSize [form.width - form_offset, btn_size]
		mcs.edit_box.BorderStyle = mcs.edit_box.BorderStyle.FixedSingle
	
		dotNet.addEventHandler mcs.btnMin "MouseClick"   minMaxForm
		dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp --"MouseClick" 
		dotNet.addEventHandler mcs.lblT   "DoubleClick" onLblTDoubleClick
		
		dotNet.addeventhandler mcs.mnu1_close "Click" hideForm
		dotNet.addeventhandler mcs.mnu1_edit  "Click" editForm
		dotNet.addeventhandler mcs.mnu1_lock  "Click" lockForm
		dotNet.addeventhandler mcs.mnu1_ren  "Click" renameForm
		
		/*dotNet.addeventhandler mcs.mnu2_add_action "Click" actionAddRemoveModify
		dotNet.addeventhandler mcs.mnu2_edit_action  "Click" actionAddRemoveModify
		dotNet.addeventhandler mcs.mnu2_create_action  "Click" actionAddRemoveModify
		dotNet.addeventhandler mcs.mnu2_remove_action  "Click" actionAddRemoveModify*/
		
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.addEventHandler form "VisibleChanged" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --thanks cyfer
	
		form.controls.addRange(#(mcs.tlp, mcs.lblT, mcs.btnMin))
	)
	--START BUILDING
	fn mcCreateNetDynamicDialog dname = 
	(
		try (execute ( dname+".close()" )) catch()
		
		-->Components---------------------------------------------------------------------
		local form  = createFormInstance dname
		local cr = execute (mcFile.readSettings Micra.UserProfile ("Properties_1/" + dname) type:"btnCount")
		struct MICRA_COMPONENTS_STRUCT 
		( 
			ToolTip   = dotNetObject "ToolTip",
			mnu1       = dotNetObject "ContextMenuStrip",
			mnu1_close = mnu1.Items.Add "Close...",
			mnu1_edit  = mnu1.Items.Add "Edit..." , 
			mnu1_lock  = mnu1.Items.Add "Lock..." , 
			mnu1_ren  = mnu1.Items.Add "Rename..." , 
			/*mnu2   	   = dotNetObject "ContextMenuStrip",
			mnu2_add_action = mnu2.Items.Add "Add Action...",
			mnu2_edit_action  = mnu2.Items.Add "Edit Action..." , 
			mnu2_create_action  = mnu2.Items.Add "Create Action...",
			mnu2_remove_action  = mnu2.Items.Add "Remove Action...",*/
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
		
		--xml data
		local data =  (mcFile.readSettings Micra.UserProfile ("Properties_1/" + dname) type:"attribs")
		local dpos = execute (data.get "pos")
		local dtitle = data.get "title"
		
		inicializeInterface form style:#compact title:dtitle pos:dpos
		generateButtons  form style:#start
		resizeInterface    form style:#compact
		
		-- Shows the form with the specified owner (MAX) to the user (creatd by lo)
		local nw = defNWin()
		form.show(nw) 
		nw.ReleaseHandle()
		--form.showModeless()
	)
)

/*
mcCreateNetDynamicDialog "mc_Dialog_F"
mcCreateNetDynamicDialog "mc_Dialog_G"
mcCreateNetDynamicDialog "mc_Dialog_H"
mcCreateNetDynamicDialog "mc_Dialog_I"
mc_Dialog_F.hide()
mc_Dialog_F.show()
*/
