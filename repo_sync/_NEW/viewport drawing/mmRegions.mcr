/*-------------------------------------------------------
mmRegions (c) Rotem Shiffman 2012
http://www.monotoneminimal.com
------------------------------------------------------*/
	
macroScript mmRegionsMacro \
category:"Monotone Minimal" \
toolTip:"mmRegions: A render region management tool" \
buttonText:"mmRegions" \
(
	global mmRegions
	
	struct mmRegionData 
	(
		x,
		y,
		w,
		h,
		originalImageW,
		originalImageH,
		enabled = "0",
		name = "Untitled",
		
		fn round val =
		(
			(dotnetClass "System.Math").Round val
		),
		
		--get pixel coordinates for a specific frame size
		fn getIntBox2 imgW imgH =
		(
			box2 (round (x * imgW)) (round (y * imgH)) (round (w * imgW)) (round (h * imgH))
		),
		
		--convert all the data of the region to a string for serialization
		fn serialize =
		(
			local c = ","
			return ( \
				(((x as string) + c + (y as string) + c) + \
				((w as string) + c + (h as string) + c)) + \
				((originalImageW as string + c) + \
				originalImageH as string) + c + enabled + c + name + "|")
		),
		
		--get an export string for exporting to plain text
		fn serializeExportPlain imgW imgH =
		(
			local b2 = getIntBox2 imgW imgH
			local ss = stringStream ""
			format "Region: \"%\"\r\n" name to:ss
			format "X:\t%\t(%\%)\r\n" b2.x (x*100) to:ss
			format "Y:\t%\t(%\%)\r\n" b2.y (y*100) to:ss
			format "Width:\t%\t(%\%)\r\n" b2.w (w*100) to:ss
			format "Height:\t%\t(%\%)\r\n" b2.h (h*100) to:ss
			format "\r\n" to:ss
			ss as string
		),
		
		--get an export string for exporting to After Effects position data
		fn serializeExportAE imgW imgH =
		(
			local b2 = getIntBox2 imgW imgH
			local ss = stringStream ""
			--format "========= % =========\r\n" name to:ss
			format "Adobe After Effects 8.0 Keyframe Data\r\n\r\n" to:ss
			format "Transform\tAnchor Point\r\n" to:ss
			format "\tFrame\tX Pixels\tY Pixels\tZ Pixels\t\r\n" to:ss
			format "\t0\t0\t0\t0\t\r\n\r\n" to:ss
			format "Transform\tPosition\r\n" to:ss
			format "\tFrame\tX Pixels\tY Pixels\tZ Pixels\t\r\n" to:ss
			format "\t0\t%\t%\t0\t\r\n\r\n" b2.x b2.y to:ss
			format "\r\n\r\nEnd of Keyframe Data\r\n" to:ss
			ss as string
		),
		
		--parse a string imported from file into region data
		fn deserializeImportPlain str =
		(
			local region = mmRegionData()
			local nameStr = (filterString str "\r\n")[1]
			nameStr = substituteString nameStr "\"" ""
			nameStr = trimRight (trimLeft nameStr)
			region.name = nameStr
			
			local parts = filterString str "("
			while parts.count > 4 do parts = deleteItem parts 1
			parts = for p in parts collect
			(
				local n = (filterString p "%)")[1] as float
			)
			region.x = parts[1] / 100.
			region.y = parts[2] / 100.
			region.w = parts[3] / 100.
			region.h = parts[4] / 100.
			region.enabled = "1"
			region
		),
		
		--parse a string from internal save into region data
		fn deserialize str =
		(
			local parts = filterString str "|"
			for p in parts collect 
			(
				local r = filterString p ","
				mmRegionData \
					(r[1] as float) (r[2] as float) \
					(r[3] as float) (r[4] as float) \
					(r[5] as integer) (r[6] as integer) \
					(r[7]) (if r[8] == undefined then "" else r[8])
			)
		)
	)

	rollout mmRegions "mmRegions" width:240 height:310
	(
		--A random number to store appdata for this tool
		local appDataNumber = 29833892
		
		local regions = #()
		local dgv = dotNetObject "DataGridView"
		local regionPenOn = (dotNetClass "System.Drawing.Pens").red
		local regionPenOff = (dotNetClass "System.Drawing.Pens").lightGray
		
		local icons 
		local iconsPath = ((getFileNamePath (getSourceFilename())) + "\\mmRegions.png")
			
		local lastKnownRenderSize = [-1, -1]
		local imgPnlCanvasSize = dotNetObject "System.Drawing.Rectangle" 0 0 100 100
			
		--serialize all our data and save it into the appdata of the root node
		fn saveRegionData =
		(
			local ss = stringStream ""
			local data = for r in regions do format (r.serialize()) to:ss
			setAppData rootNode appDataNumber (ss as string)
		)
		
		--try to read data from the rootnode and if found, load into the UI
		fn loadRegionData =
		(
			local data = getAppData rootNode appDataNumber
			if (data == undefined) do return undefined
			regions = mmRegionData.deserialize data
			dgv.rows.clear()
			for r in regions do dgv.Rows.Add()
		)
		
		--get a string for all regions for exporting to plain text
		fn getPlainTextExportString targetRegions =
		(
			local ss = stringStream ""
			for r in targetRegions do format "%" (r.serializeExportPlain renderWidth renderHeight) to:ss
			ss as string
		)
		
		--get a string for all regions for exporting After Effects position data
		fn getAEExportString targetRegions =
		(
			local ss = stringStream ""
			for r in targetRegions do format "%" (r.serializeExportAE renderWidth renderHeight) to:ss
			ss as string
		)
		
		--open the export dialog
		fn exportRegionData =
		(
			rollout mmRegionsExport "Export mmRegions Data" width:330 height:300
			(
				radioButtons radFormat "Format" pos:[6,6] width:204 height:30 labels:#("Plain Text", "After Effects Layer Positions") columns:2
				dotNetControl txt "TextBox" pos:[5,50] width:320 height:190
				dropDownList ddlSection "" pos:[5,240] width:120 height:20 toolTip:"Highlight a single region"
				button btnClip "Copy to Clipboard" pos:[125,240] width:100 height:20 toolTip:"Copy the current text to the clipboard"
				button btnSaveFile "Save to File..." pos:[225,240] width:100 height:20 toolTip:"Copy the current text to the clipboard"
				button btnClose "Close" pos:[255,270] width:70 height:25 toolTip:"Copy the current text to the clipboard"
				
				on mmRegionsExport open do
				(
					txt.readOnly = on
					txt.multiLine = on
					txt.scrollBars = txt.scrollBars.vertical
					txt.text = if radFormat.state == 1 then getPlainTextExportString regions else getAEExportString regions
					ddlSection.items = join #("All") (for r in regions collect r.name)
				)

				on radFormat changed state do
				(
					local targetRegions = if ddlSection.selection == 1 then regions else #(regions[ddlSection.selection-1])
					txt.text = if radFormat.state == 1 then getPlainTextExportString targetRegions else getAEExportString targetRegions
				)
				
				on ddlSection selected val do radFormat.changed radFormat.state
				
				on btnClip pressed do setClipboardText txt.text
					
				on btnSaveFile pressed do
				(
					local fName = getSaveFileName types:"Regions Data(*.txt)|*.txt" history:"mmRegions"
					if fName != undefined do
					(
						(dotNetClass "System.IO.File").writeAllText fName txt.text
					)
				)
				
				on btnClose pressed do destroyDialog mmRegionsExport
			)
			createDialog mmRegionsExport modal:on
		)
		
		--select plain text file for importing region data from
		fn importRegionData =
		(
			local fName = getOpenFileName types:"Regions Data(*.txt)|*.txt" history:"mmRegions"
			if fName != undefined and doesFileExist fName do
			(
				local txt = (dotNetClass "System.IO.File").readAllText fName
				local dnStr = dotnetObject "System.String" txt
				local splitOptions = (dotnetClass "System.StringSplitOptions").removeEmptyEntries
				local newRegions = dnStr.split #("Region:") splitOptions
				for r in newRegions do
				(
					local newRegion = mmRegionData.deserializeImportPlain r
					append regions newRegion
					dgv.Rows.Add()
				)
				saveRegionData()
			)
			
		)
		
		--check if the vray VFB region mode is active
		fn isVrayVFBRegionActive forRender:off =
		(
			return vrayVFBGetRegionEnabled != undefined and vrayVFBGetRegionEnabled() == true and \
			(not forRender or renderers.current.output_on)
		)
		
		--Capture the region from the viewport to the list of stored regions
		fn storeRegion =
		(
			local regB2
			if isVrayVFBRegionActive() then
			(
				local coords = vrayVFBGetRegion()
				regB2 = box2 coords[1] coords[2] (coords[3] - coords[1]) (coords[4] - coords[2])
			)
			else regB2 = viewport.getRegionRect viewport.activeViewport
			local rW = renderWidth
			local rH = renderHeight
			
			local x = regB2.x as float / rW
			local y = regB2.y as float / rH
			local w = regB2.w as float / rW
			local h = regB2.h as float / rH
		
			local reg = mmRegionData x y w h rW rH "1"
			
			append regions reg
			saveRegionData()
			dgv.Rows.Add()
		)
		
		--Make the stored region the currently active region in the viewport
		fn restoreRegion region =
		(
			local rW = renderWidth
			local rH = renderHeight
			
			local x = region.x * rW
			local y = region.y * rH
			local w = region.w * rW
			local h = region.h * rH
			
			if isVrayVFBRegionActive() then
			(
				vrayVFBSetRegion x y (x + w) (y + h)
			)
			else
			(
				if not EditRenderRegion.isEditing do EditRenderRegion.EditRegion()
				viewport.setRegionRect viewport.activeViewport (box2 x y w h)
				EditRenderRegion.UpdateRegion()
			)
		)
		
		fn doBatchRender =
		(
			--Collect only the enabled regions
			local activeRegions = (for r in regions where r.enabled != "0" collect r)
			
			local regBmp = bitmap renderWidth renderHeight
			local img = undefined
			local renderType = if isVrayVFBRegionActive forRender:on then #view else #region
			setRenderType renderType

			--If it's only one, do a straight render
			if (activeRegions.count == 1) then
			(
				restoreRegion activeRegions[1]
				max quick render
			)
			else
			(
				--Go over all enabled regions and render them
				for r in activeRegions do
				(
					restoreRegion r
					max quick render
					img = getLastRenderedImage copy:on --Ironically, specifying copy:on results in getting a direct reference, not a copy.
					local b2 = r.getIntBox2 renderWidth renderHeight
					pasteBitmap img regBmp b2 [b2.x, b2.y] type:#paste
				)
			
				--Paste our bitmap back to the LastRenderedImage
				pasteBitmap regBmp img [0,0] [0,0] type:#paste
					
				--Refresh the VFB image
				for w in uiaccessor.getPopupDialogs() do
				(
					local firstChild = uiaccessor.getFirstChildWindow w
					if (uiaccessor.getWindowClassName firstChild) == "BitmapWindow" do
					(
						windows.sendMessage firstChild 0x5 0 0 --WM_SIZE
						windows.sendMessage firstChild 0xf 0 0 --WM_PAINT
					)
				)
			)
			
			--Clean up
			close regBmp
			free regBmp
		)
		
		button btnNew "N" 		width:20 height:20 pos:[0,0] toolTip:"Store current render region"
		button btnDel "D" 		width:20 height:20 pos:[20,0] toolTip:"Delete selected region"
		button btnRestore "R" width:20 height:20 pos:[40,0] toolTip:"Set selected region as current render region"
		button btnBatch "B"	width:20 height:20 pos:[60,0] toolTip:"Batch render all enabled regions"
		button btnExport "E"	width:20 height:20 pos:[80,0] toolTip:"Export region data to file or clipboard"
		button btnImport "I"	width:20 height:20 pos:[100,0] toolTip:"Import region data from file"
		
		button btnAbout "?"		width:20 height:20 pos:[220,0] toolTip:"About..."
		
		spinner spnX "X" range:[0,65535,0] type:#integer enabled:off width:50 pos:[10,20]
		spinner spnY "Y" range:[0,65535,0] type:#integer enabled:off width:50 pos:[70,20]
		spinner spnW "W" range:[1,65535,1] type:#integer enabled:off width:50 pos:[130,20]
		spinner spnH "H" range:[1,65535,1] type:#integer enabled:off width:50 pos:[190,20]
		
		dotnetControl dgvPnl "Panel" width:240 height:100 pos:[0,40]
		dotnetControl imgPnl "Panel" width:240 height:170 pos:[0,140]
		
		--Update enabled state of UI buttons
		fn updateButtons =
		(
			btnRestore.enabled = btnDel.enabled = dgv.SelectedRows.count > 0
			btnBatch.enabled = (for r in regions where r.enabled != "0" collect ok).count > 0
			imgPnl.invalidate()
		)

		--When render size changes, output the size column of all regions	
		fn updateSizeStrings =
		(
			for i = 1 to dgv.rowcount do
			(
				local row = dgv.rows.item[i-1]
				
				local b2 = regions[i].getIntBox2 renderWidth renderHeight
				local sizeStr = "["+ b2.x as string+", "+b2.y as string+", "+b2.w as string+", "+b2.h as string+"]"
				row.cells.item[2].value = sizeStr
			)
		)
		
		--Format a region row
		fn dgvRowsAdded s e =
		(
			local row = s.rows.item[e.rowIndex]
			local data = regions[e.rowIndex+1]
			row.tag = dotNetMxsValue data
			row.cells.item[0].value = data.enabled == "1"
			row.cells.item[1].value = data.name
			
			local b2 = data.getIntBox2 renderWidth renderHeight
			local sizeStr = "["+ b2.x as string+", "+b2.y as string+", "+b2.w as string+", "+b2.h as string+"]"
			row.cells.item[2].value = sizeStr
		)
		
		--User clicked a cell
		fn dgvValueChanged s e =
		(
			local row = s.rows.item[e.rowIndex]
			local data = regions[e.rowIndex+1]
			if (e.columnIndex == 0) then
			(
				data.enabled = if row.cells.item[0].value then "1" else "0"
				updateButtons()
				saveRegionData()
			)
			else if (e.columnIndex == 1) do
			(
				data.name = row.cells.item[1].value
				saveRegionData()
			)
			imgPnl.invalidate()		
		)
		
		--User double-clicked a cell, restore the selected region
		fn dgvCellDoubleClick s e =
		(
			if (e.columnIndex != 0) do
			(
				local row = s.rows.item[e.rowIndex]
				local data = regions[e.rowIndex+1]
				restoreRegion data
			)
		)
		
		--When user finished editing name, commit the changes
		fn dgvCellDirty s e =
		(
			if (s.currentCell.columnIndex == 0) do
			(
				s.endEdit (dotnetClass "DataGridViewDataErrorContexts").commit
				local cell = s.currentCell
				s.currentCell = undefined
				s.currentCell = cell
			)
		)	
		
		--Disable keyboard accelerators so user can type in name
		fn dgvCellEdit s e =
		(
			if (s.currentCell.columnIndex == 1) do
			(
				enableAccelerators = off
			)
		)
		
		fn dgvSelectionChanged s e =
		(
			local singleSelection = dgv.selectedRows.count == 1
			spnX.enabled = spnY.enabled = spnW.enabled = spnH.enabled = singleSelection
			if singleSelection then
			(
				local data = regions[dgv.selectedRows.item[0].index + 1]
				local b2 = data.getIntBox2 renderWidth renderHeight
				spnX.value = b2.x
				spnY.value = b2.y
				spnW.value = b2.w
				spnH.value = b2.h
			)
			else
			(
				spnX.indeterminate = on
				spnY.indeterminate = on
				spnW.indeterminate = on
				spnH.indeterminate = on
			)
		)
		
		--Initialize the DataGridView control
		fn initDGV =
		(
			local onC = dotNetObject "DataGridViewCheckBoxColumn"
			local nameC = dotNetObject "DataGridViewTextBoxColumn"
			local sizeC = dotNetObject "DataGridViewTextBoxColumn"
			sizeC.readOnly = on
			onC.name = "On"
			nameC.name = "Name"
			sizeC.name = "Size"
			onC.width = 25
			nameC.width = 80
			sizeC.autoSizeMode = sizeC.autoSizeMode.fill
			dgv.columns.addRange #(onC, nameC, sizeC)
			dgv.RowHeadersVisible = dgv.AllowUserToAddRows = dgv.AllowUserToDeleteRows = off
			dgv.AllowUserToResizeRows = dgv.ShowEditingIcon = off
			dgv.EditMode = dgv.EditMode.EditOnEnter
			dgv.SelectionMode = dgv.SelectionMode.FullRowSelect
			dgv.Dock = dgv.Dock.Fill
			dgv.RowCount = 0
			dgv.RowTemplate.Height = 20
			dotnet.AddEventHandler dgv "RowsAdded" dgvRowsAdded
			dotnet.AddEventHandler dgv "CellValueChanged" dgvValueChanged
			dotnet.AddEventHandler dgv "CellContentDoubleClick" dgvCellDoubleClick
			dotnet.AddEventHandler dgv "CurrentCellDirtyStateChanged" dgvCellDirty
			dotnet.AddEventHandler dgv "CellBeginEdit" dgvCellEdit
			dotnet.AddEventHandler dgv "SelectionChanged" dgvSelectionChanged
			dgvPnl.controls.add dgv
		)
		
		--Extract the icons and save them to mmRegions.png in same folder as script
		fn extractIcons =
		(
			local iconsString = "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"
			local bytes = (dotNetClass "System.Convert").FromBase64String iconsString
			local stream = dotNetObject "System.IO.MemoryStream" bytes
			local image = (dotNetClass "System.Drawing.Image").FromStream stream
			stream.close()
			image.save iconsPath
		)
		
		--Load the icons file and paste it onto the 3dsmax background color for better alpha blending
		fn initIcons =
		(
			if not doesFileExist iconsPath or getFileSize iconsPath != 7124	 do extractIcons()
			local rawIcons = openBitmap iconsPath
			local uiColor = colorMan.getColor #backGround * 255
			local bgColor = color uiColor[1] uiColor[2] uiColor[3]
			icons = bitmap rawIcons.width rawIcons.height color:bgColor
			pasteBitmap rawIcons icons [0,0] [0,0] type:#blend
			close rawIcons
			free rawIcons
			btnNew.images = #(icons, undefined, 10, 1, 1, 1, 1)
			btnDel.images = #(icons, undefined, 10, 3, 3, 6, 6)
			btnRestore.images = #(icons, undefined, 10, 2, 2, 5, 5)
			btnBatch.images = #(icons, undefined, 10, 4, 4, 7, 7)
			btnExport.images = #(icons, undefined, 10, 8, 8, 9, 9)
			btnImport.images = #(icons, undefined, 10, 10, 10, 10, 10)
		)
		
		fn renderSizeChangedCallback =
		(
			if ([renderWidth, renderHeight] != lastKnownRenderSize) do
			(
				lastKnownRenderSize = [renderWidth, renderHeight]
				imgPnl.width+= 1
				imgPnl.width -= 1
				updateSizeStrings()
			)
		)
		
		fn sceneChangedCallback =
		(
			loadRegionData()
			lastKnownRenderSize = [-1, -1]
			renderSizeChangedCallback()
			updateButtons()
		)
		
		fn registerCallbacks =
		(
			local sceneChangedCallbackStr = "mmRegions.sceneChangedCallback()"
			callbacks.addScript #filePostOpen sceneChangedCallbackStr id:#mmRegions
			callbacks.addScript #systemPostNew sceneChangedCallbackStr id:#mmRegions
			callbacks.addScript #systemPostReset sceneChangedCallbackStr id:#mmRegions
			callbacks.addScript #renderParamsChanged "mmRegions.renderSizeChangedCallback()" id:#mmRegions
		)
		
		fn unregisterCallbacks =
		(
			callbacks.removeScripts id:#mmRegions
		)
		
		on mmRegions open do
		(
			initIcons()
			initDGV()
			imgPnl.borderStyle = imgPnl.borderStyle.fixedsingle
			registerCallbacks()
			sceneChangedCallback()
		)
		
		on mmRegions close do
		(
			saveRegionData()
			unregisterCallbacks()
			close icons
			free icons
		)
		
		on mmRegions resized val do
		(
			if val[1] < 240 do mmRegions.width = 240
			if val[2] < 260 do mmRegions.height = 260
			val = [mmRegions.width, mmRegions.height]
			btnAbout.pos = [val[1]-20, 0]
			dgvPnl.width = val[1]
			imgPnl.width = val[1]
			dgvPnl.height = val[2] - 210
			imgPnl.pos = [0, dgvPnl.pos[2] + dgvPnl.height]
		)
		
		on imgPnl resize s e do
		(
			local rendAspect = renderWidth as float / renderHeight
			local pnlSize = [s.width as float - 2, s.height as float - 2]
			local pnlAspect = pnlSize[1] / pnlSize[2]
			
			local cX, cY, cW, cH
			
			if rendAspect > pnlAspect then
			(
				cW = pnlSize[1] as integer
				local wRatio = pnlSize[1] / renderWidth
				cH = (renderHeight * wRatio) as integer
				cX = 0
				cY = ((pnlSize[2] - cH) / 2.) as integer
			)
			else
			(
				cH = pnlSize[2] as integer
				local hRatio = pnlSize[2] / renderHeight
				cW = (renderWidth * hRatio) as integer
				cY = 0
				cX = ((pnlSize[1] - cW) / 2.) as integer
			)
			imgPnlCanvasSize = dotNetObject "System.Drawing.Rectangle" cX cY cW cH
		)
		
		local grayBG = (dotnetClass "System.Drawing.Color").gray
		local blackBrush = (dotnetClass "System.Drawing.Brushes").black
		local rectClass = dotNetClass "System.Drawing.Rectangle"
		
		on imgPnl paint s e do
		(
			e.graphics.clear grayBG
			
			e.graphics.fillRectangle blackBrush imgPnlCanvasSize
			
			for r in regions do
			(
				local b2 = r.getIntBox2 imgPnlCanvasSize.width imgPnlCanvasSize.height
				local rect = dotnetObject rectClass (b2.x + imgPnlCanvasSize.x) (b2.y + imgPnlCanvasSize.y) b2.w b2.h
				local pen = if r.enabled == "1" then regionPenOn else regionPenOff
				e.graphics.DrawRectangle pen rect
			)
		)
		
		on btnNew pressed do
		(
			storeRegion()
			updateButtons()
		)
		
		on btnDel pressed do
		(
			if not queryBox "Delete selected regions?" do return undefined
			for i = dgv.selectedRows.count to 1 by -1 do
			(
				local rowInd = dgv.selectedRows.item[i - 1].index
				dgv.rows.removeAt rowInd
				deleteItem regions (rowInd + 1)
			)
			updateButtons()
		)
		
		on btnRestore pressed do
		(
			local rowInd = dgv.selectedRows.item[0].index
			local data = regions[rowInd + 1]
			restoreRegion data
			updateButtons()
		)
		
		on btnBatch pressed do
		(
			doBatchRender()
		)
		
		on btnExport pressed do
		(
			exportRegionData()
		)
		
		on btnImport pressed do
		(
			importRegionData()
		)
		
		on btnAbout pressed do
		(
			rollout mmRegionsAbout "About mmRegions" width:200 height:150
			(
				groupBox grpAbout pos:[5,5] width:190 height:110 
				label labAbout1 "mmRegions v1.1" pos:[33,20]
				label labAbout2 "(c)2012 Rotem Shiffman" pos:[33,40]
				hyperLink hlMM "www.monotoneminimal.com" pos:[33,80] address:"http://www.monotoneminimal.com" 
				button btnClose "Close" pos:[130,120] width:60 height:25
				
				on btnClose pressed do destroyDialog mmRegionsAbout
			)
			createDialog mmRegionsAbout modal:on
		)
	
		--Spinner logic
		
		local WidthAtSpnXStart
		local HeightAtSpnYStart
		
		on spnX buttonDown do
		(
			WidthAtSpnXStart = spnW.value
			spnX.range = [0, renderWidth - 1, spnX.value]
		)
		
		on spnY buttonDown do
		(
			HeightAtSpnYStart = spnH.value
			spnY.range = [0, renderHeight - 1, spnY.value]
		)
		
		on spnX buttonUp do spnX.range = [0, 65535, spnX.value]
		on spnY buttonUp do spnY.range = [0, 65535, spnY.value]
		
		on spnX changed val inSpin do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			local validX = amin val (renderWidth - 1)
			local validW = amin (renderWidth - validX) (if inSpin then WidthAtSpnXStart else spnW.value)
			
			if val != validX do spnX.value = validX			
			if spnW.value != validW do spnW.value = validW
			data.x = validX as float / renderWidth
			data.w = validW as float / renderWidth
			imgPnl.invalidate()
			UpdateSizeStrings()
		)
		
		on spnY changed val inSpin do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			local validY = amin val (renderHeight - 1)
			local validH = amin (renderHeight - validY) (if inSpin then HeightAtSpnYStart else spnH.value)
			
			if val != validY do spnY.value = validY			
			if spnH.value != validH do spnH.value = validH
			data.y = validY as float / renderHeight
			data.h = validH as float / renderHeight
			imgPnl.invalidate()
			UpdateSizeStrings()
		)

		on spnW buttondown do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			spnW.range = [1, (1 - data.x) * renderWidth, spnW.value]
		)		
		on spnW buttonUp do spnW.range = [1, 65535, spnW.value]
		
		on spnW changed val do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			local maxW = (1-data.x) * renderWidth
			local validW = amin val maxW
			if val != validW do spnW.value = validW
			data.w = validW as float / renderWidth
			imgPnl.invalidate()
			UpdateSizeStrings()
		)
		
		on spnH buttondown do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			spnH.range = [1, (1 - data.y) * renderHeight, spnH.value]
		)		
		on spnW buttonUp do spnW.range = [1, 65535, spnW.value]

		on spnH changed val do
		(
			local data = regions[dgv.selectedRows.item[0].index + 1]
			local maxH = (1-data.y) * renderHeight
			local validH = amin val maxH
			if val != validH do spnH.value = validH
			data.h = validH as float / renderHeight
			imgPnl.invalidate()
			UpdateSizeStrings()
		)

	)

	on execute do 
	(
		try (destroyDialog mmRegions) catch ()
		createDialog mmRegions \ 
			style:#(#style_titlebar, #style_border, #style_sysmenu, #style_resizing, #style_toolwindow)
	)
)
