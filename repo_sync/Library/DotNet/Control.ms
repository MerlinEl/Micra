 	fn ShowAll ax p:true m:true e:true =
 	(
 		clearlistener()
 		format "%: %\n" ax (classof ax)
 		if p do try (format "PROPERTIES:\n"; showProperties ax) catch (format "No Properties for %\n" ax)
 		if m do try (format "METHODS:\n"; showMethods ax) catch (format "No Methods for %\n" ax)
 		if e do try (format "EVENTS:\n"; showEvents ax) catch (format "No Events for %\n" ax)
 	)


show (dotNetClass "System.Windows.Forms.Cursors")
show  (dotNetClass "System.Windows.Forms.Cursor")


theDialog = dotNetObject  "System.Windows.Forms.OpenFileDialog"  --create a OpenFileDialog
theDialog.title = "PLEASE Select One Or More Files" --set the title
theDialog.Multiselect = true --allow multiple files to be selected
theDialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*" --specify the filter
theDialog.FilterIndex = 2 --set the filter drop-down list to All Files
result = theDialog.showDialog() --display the dialog, get result into variable
result.ToString() --when closed, convert the result to string
result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
theFilenames = theDialog.fileNames --the selected filenames will be returned as an array

--Check variable and close window if it exists
if classof dotnetform == dotnetobject then dotnetform.close()


	rollout DragDropOps "LoneRobot Drag Drop" width:136 height:150
	(	

		dotNetControl btndragdrop "label" pos:[5,5] width:125 height:139 
				
		on DragDropOps open do
		(
			btndragdrop.text = "Hooray! A Drag/Drop Enabled Label!!! \n\nTo drop a Texturemap, just pass the map path string in the dataobject instead of a max file path. This will also work if draging a map to the material editor"
			btndragdrop.borderstyle = (dotNetClass "System.Windows.Forms.BorderStyle").fixedsingle	
			btndragdrop.backcolor = (dotnetclass "System.Drawing.Color").orangered	
			btndragdrop.forecolor = (dotnetclass "System.Drawing.Color").yellow
		)
		on btndragdrop mouseDown sender args do
		(
			--format  "sender:%\nargs:%\n\n"  sender args
			theIniFile = getdir #maxData  + "3dsmax.ini" 
			theKeys = getIniSetting theIniFile "FileList" 
			maxfilearray = for o in theKeys where o != "MaxFiles" collect getIniSetting theIniFIle "FileList" o 
			filenameString =  maxfilearray[1]
			dropfile = dotnetobject "System.String[]" 1
			dropfile.setvalue filenameString 0			
			DataObj = dotnetobject "DataObject" ((dotnetclass "DataFormats").filedrop) dropfile
			sender.dodragdrop Dataobj ((dotnetclass "DragDropEffects").Copy)
		)
	)
	createdialog DragDropOps style:#(#style_toolwindow, #style_sysmenu)
	
	
	
	
dotNet.loadAssembly "E:\Micra2\Experimental\TabControlEX.dll"
try(destroyDialog testR)catch()
 rollout testR "Test" width:200
 (
	 dotNetControl tabs "Dotnetrix.Controls.TabControlEx" height:300
	 
	 fn showProps tab=
	 (
		 clearListener()
		 format "Properties:\n"
		 showProperties tab
		 format "\nMethods:\n"
		 showMethods tab
		 format "\nEvents:\n"
		 showEvents tab
	 )
	 
	 on testR open do
	 (
		 showProps tabs
		 
		tabs.Alignment = tabs.Alignment.Left
		tabs.Appearance = (dotNetClass "Dotnetrix.Controls.TabAppearanceEx").FlatTab
		tabs.BackColor = (dotNetClass "System.Drawing.Color").Transparent
		 tabs.Multiline=true
		 tabs.tabStop=true
		 
		 
		 labels=#("Main", "Settings", "User", "Misc", "Extras")
		for x in labels do 
			tabs.tabPages.add x
	 )
 )
 createDialog testR
 
 
 
 
 --**************************************************  ****************************
--*
--*  extractBitmapChannel
--*  by Ofer Zelichover (c) 
--*  Started: 2008/08/20
--*  http://www.oferz.com  ; maxscripts@oferz.com
--*
--**************************************************  ****************************

(
   -- This function uses the dotNet graphics object with color matrix to extract
   -- a specific channel from a bitmap.
   -- Valid chan values: #Red, #Green, #Blue, #R, #G, #B
   fn extractBitmapChannel bm chan =
   (
	   -- Validate chan value:
	   chan = (chan as string) as name
	   local fullChanNames = #(#Red, #Green, #Blue)
	   local shortChanNames = #(#R, #G, #B)
	   local n = findItem fullChanNames chan
	   if n > 0 then
		   chan = shortChanNames[n]
	   if findItem shortChanNames chan == 0 then
		   return undefined
	   
	   -- Copy the bitmap to the clipboard to pass it to dotNet
	   setClipboardBitmap  bm
	   -- Create a dotNet clipboard object.
	   local clipboardObj = dotNetClass "System.Windows.Forms.Clipboard"
	   -- Get the image from the clipboard into a dotNet image object.
	   local imgObj = clipboardObj.GetImage()
	   -- Create a dotNet colorMatrix object.
	   local colorMatArray = #( \
		   #(if chan == #R then 1 else 0, 0, 0, 0, 0), \
		   #(0, if chan == #G then 1 else 0, 0, 0, 0), \
		   #(0, 0, if chan == #B then 1 else 0, 0, 0), \
		   #(0, 0, 0, 1, 0), \
		   #(0, 0, 0, 0, 1) 
	   )
	   local colorMatrixObj = dotNetObject "System.Drawing.Imaging.ColorMatrix" colorMatArray
	   -- Create a dotNet ImageAttributes object to assign the color matrix to the image.
	   local imageAttrsObj = dotNetObject "System.Drawing.Imaging.ImageAttributes"
	   imageAttrsObj.SetColorMatrix colorMatrixObj (dotNetClass "System.Drawing.Imaging.ColorMatrixFlag").Default (dotNetClass "System.Drawing.Imaging.ColorAdjustType").Default
	   -- Create a dotNet graphics object. This will be used to render the image using the color matrix.
	   local graphicsObj = (dotNetClass "System.Drawing.Graphics").FromImage(imgObj)
	   -- Render the image using the color matrix:
	   local rect = dotNetObject "System.Drawing.Rectangle" 0 0 imgObj.Width imgObj.Height
	   local graphicsUnit = (dotNetClass "System.Drawing.GraphicsUnit").Pixel
	   graphicsObj.DrawImage imgObj rect 0 0 imgObj.Width imgObj.Height graphicsUnit imageAttrsObj
	   -- copy the rendered image into the clipboard.
	   clipboardObj.setImage(imgObj)
	   -- Get the image from the clipboard back into maxscript
	   local newBm = getClipboardBitmap()
	   
	   --Clean up
	   clipboardObj = undefined
	   graphicsObj.Dispose(); graphicsObj = undefined
	   rect = undefined
	   graphicsUnit = undefined
	   imgObj.Dispose(); imgObj = undefined
	   imageAttrsObj.Dispose(); imageAttrsObj = undefined
	   colorMatrixObj = undefined
	   -- You may wish to comment out the GC command if it's too slow.
	   gc light:true
	   -- Return the new bitmap
	   newBM
   )
   
   -- Sample Use:
   local tex = Dent color1:red color2:blue size:5
   local bm = bitmap 200 200
   renderMap tex into:bm
   display(extractBitmapChannel bm #Red)

)




 rollout test "Test"
 (
 	dotNetControl tb "system.windows.forms.textBox" height:80
 	
 	on test open do
 	(
 		tb.multiLine=true
 		sb=dotNetClass "System.Windows.Forms.ScrollBars"
 		tb.scrollBars=sb.vertical
 		tb.acceptsReturn=true
 		tb.acceptsTab=true
 		tb.wordWrap=true
 		tb.focus()
 	)
 )
 createDialog test
 
 
 
 if (splitViewRollout != undefined) and (splitViewRollout.isDisplayed) do (destroyDialog splitViewRollout)
global splitViewRollout 
rollout splitViewRollout " Modifiers"
(
 -- TreeView
 fn initTreeView tv =
 (
  tv.checkboxes = true
  tv.sorted = true
 )
 fn addModifiers theNode theModifiers =
 (
  for m in theModifiers do
  (
   newNode = theNode.nodes.add m.name
   newNode.tag = dotNetMXSValue m
   newNode.checked = m.enabled
  )
 )
 fn addObjects theNode theObjects =
 (
  for c in theObjects do
  (
   newNode = theNode.nodes.add c.name
   newNode.tag = dotNetMXSValue c
   newNode.checked = not c.isHidden
   newNode.forecolor = (dotNetClass "System.Drawing.Color").fromARGB 200 0 0
   
   addModifiers newNode c.modifiers
  )
 )
 fn fillInTreeView tv =
 (
  theRoot = tv.nodes.add "(Objects)"
  rootNodes = for o in objects collect o
  addObjects theRoot rootNodes
 )
 -- ListView
 fn initListView lv =
 (
  lv.gridLines = true
  lv.view = (dotNetClass "System.Windows.Forms.View").Details
  lv.fullRowSelect = true
  
  layoutDef = #(#("Property", 120), #("Value", 60))
  
  for i in layoutDef do (lv.columns.add i[1] i[2])
 )
 fn fillInSpreadsheet lv =
 ( 
  lv.items.clear()
  theRange = #()
  
  if selection.count == 1 and myNode != undefined do
  (
   propNamesArray = getPropNames myNode
  
   for i = 1 to propNamesArray.count do
   (
	li = dotNetObject "System.Windows.Forms.ListViewItem" ((propNamesArray[i]) as string)
	sub_Li = li.subItems.add ((getProperty myNode propNamesArray[i]) as string)
	
	append theRange li 
   )
   lv.items.addRange theRange
  )
 )
 
 dotNetControl tv "TreeView" width:290 height:490 pos:[5,5]
 dotNetControl lv_Properties "System.Windows.Forms.Listview" width:290 height:490 pos:[305,5]
 
 on tv Click arg do
 (
  hitNode = tv.getNodeAt (dotNetObject "System.Drawing.Point" arg.x arg.y)
  
  if hitNode != undefined do
  (
   try
   (	
	if superClassOf hitNode.tag.value == modifier then (select hitNode.parent.tag.value)
	else (select hitNode.tag.value)
	
	global myNode = hitNode.tag.value
   )
   catch (max select none)
   
   fillInSpreadsheet lv_Properties
  )
 )
 on splitViewRollout open do
 (
  initTreeView tv
  fillInTreeView tv
  
  initListView lv_Properties
  fillInSpreadsheet lv_Properties
 )
)
createDialog splitViewRollout 600 525 style:#(#style_sysmenu, #style_titlebar, #style_toolwindow)
callbacks.addScript #preNodeGeneralPropChanged "splitViewRollout.fillInSpreadsheet splitViewRollout.lv_Properties"

(
 	tv = dotNetObject "System.Windows.Forms.TableLayoutPanel"
 	
 	tv.layoutSettings.RowCount = 12
 	tv.layoutSettings.ColumnCount = 6
 	tv.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").None
 	tv.CellBorderStyle = (dotNetClass "System.Windows.Forms.TableLayoutPanelCellBorderSty  le")--.Single
 	
 	tv.width = tv.layoutSettings.ColumnCount  * 32
 	tv.height = tv.layoutSettings.RowCount* 32
 	
 	for i = 0 to tv.layoutSettings.RowCount - 1 do
 		for j = 0 to tv.layoutSettings.ColumnCount - 1 do
 		(
 			btn = (dotNetObject "System.Windows.Forms.Button")
 			--dotShow 
 			btn.Width = 25
 			btn.Height = 25
 			btn.Text = (i+j) as string
 			tv.Controls.Add btn i j
 		)
 	
 
 	hForm = dotNetObject "System.Windows.Forms.Form"
 	hForm.Size = dotNetObject "System.Drawing.Size" (tv.Width + 10) (tv.Height + 30)
 	hForm.Text = ".Net TableLayoutPanel"
 	hForm.Controls.Add(tv)
 	hForm.TopMost = true
 	FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
 	hForm.FormBorderStyle = FormBorderStyle.FixedDialog
 	hForm.ShowInTaskbar = false
 	hForm.MinimizeBox = false
 	hForm.MaximizeBox = false
 
    
 	-- Show application Form
 	hApp = dotNetClass "System.Windows.Forms.Application"
 	hApp.Run hForm

 )
 
 
 
 global hForm, mCheckbox, thisTimer
 
 (
 fn whenCheckboxIsPressed a b = 
 (
 	if MCRUtils.IsCreating Box
 		then (Max Select; try((hForm.controls.item(0)).checked = false) catch())
 	else Macros.run 26615
 )
 
 fn updateUI =
 (
 	try(
 	(hForm.controls.item(0)).checked = MCRUtils.IsCreating Box
 	) catch()
 )
 
 --Create a DotNet Checkbox
 mCheckbox = dotNetObject "System.Windows.Forms.Checkbox"
 mCheckbox.appearance = (dotnetClass "System.Windows.Forms.Appearance").Button
 mCheckbox.text = "Box Button"
 mCheckbox.location = dotNetObject "System.Drawing.Point" 0 0
 
 --Create a DotNet Form
 global hForm = dotNetObject "System.Windows.Forms.Form"
 hForm.topmost = true
 hForm.controls.add mCheckbox --add the Button to the Form
 
 thisTimer = dotNetObject "System.Windows.Forms.Timer"
 thisTimer.interval = 10
 thisTimer.start()
 
 --Add an Event Handler for the click event:
 dotNet.addEventHandler mCheckbox "click" whenCheckboxIsPressed
 dotNet.addEventHandler thisTimer "tick" updateUI
 
 hForm.show() --show the Form with the Checkbox
 )
 
 Don't know how useful this is for anyone, but here's a little snippet to 
 check the status of a service on a remote server. used as part of a little 
 farm management utility that I'm updating to run with the 64bit stuff and 
 experimenting with the net framework.
 
 	fn checkService ServiceName server =
	(
		dotnet.loadassembly "System.ServiceProcess"
		sc = dotNetObject "System.ServiceProcess.ServiceController"
		if (server == "") do server = "." -- if no server is supplied, run the check on the local machine
		sc.Machinename = server
		try(scServices = sc.GetServices(server))catch(return "Timed Out")
		for scTemp in scServices do
		(
			if (scTemp.ServiceName as string == ServiceName) then
			(
				--print ( ServiceName + " - " + server + " - " +scTemp.Status.toString() )
				return scTemp.Status.ToString()
			) 
		)
		return "Service Not found"
	)
 
 
 
 
  rollout test "Test"
 (
 	dotNetControl tb "system.windows.forms.textBox" height:80
 	
 	on test open do
 	(
 		tb.multiLine=true
 		sb=dotNetClass "System.Windows.Forms.ScrollBars"
 		tb.scrollBars=sb.vertical
 		tb.acceptsReturn=true
 		tb.acceptsTab=true
 		tb.wordWrap=true
 		tb.focus()
 	)
 )
 createDialog test
 
 ---------------
 --------------
 
 
  Color = dotNetClass "System.Drawing.Color"
 ScrollBars = dotNetClass "System.Windows.Forms.ScrollBars"
 
 -- Create Tabs Container 
 tabControl1 = dotnetobject "system.windows.forms.TabControl"
 tabControl1.size = dotnetobject "system.drawing.size" 395 195
 tabControl1.Location = dotnetobject "System.Drawing.Point" 0 0 
 
 --Create Tabs
 tabPage1 = dotnetobject "System.Windows.Forms.TabPage"
 tabPage1.text = "Goodbye World"
 tabPage2 = dotnetobject "System.Windows.Forms.TabPage"
 tabPage2.text = "Hello World"
 tabPage1.backColor = color.fromArgb 200 200 200 
 tabPage2.backColor = color.fromArgb 200 200 200 
 
 -- Create Datagrid
 
 
 DGrid1 = dotnetobject "System.Windows.Forms.DataGrid"
 DGrid1.Location = dotNetObject "System.Drawing.Point" 10 10
 DGrid1.Width = 365
 DGrid1.Height = 120
 DGrid1.Visible = true
 
 
 -- Add Some Columns to the Datagrid
 dt = dotnetobject "system.data.datatable"
 Column1 = dotnetclass "System.windows.data.DataColumn"
 
 -- Create TextBox
 TB1TextBox = dotNetObject "System.Windows.Forms.TextBox"
 TB1TextBox.Location = dotNetObject "System.Drawing.Point" 10 10
 TB1TextBox.Width = 365
 TB1TextBox.Height = 120
 TB1TextBox.Visible = true
 TB1TextBox.MultiLine = true
 TB1TextBox.ScrollBars = ScrollBars.Vertical
 TB1TextBox.AcceptsReturn = true
 TB1TextBox.AcceptsTab = true
 TB1TextBox.WordWrap = true
 
 -- Create Buttons
 button01 = dotnetobject "System.Windows.Forms.button"
 button01.text = "goodbye"
 button01.Location = dotNetObject "System.Drawing.Point" 300 138
 
 -- Create Form
 TabForm = dotNetObject "System.Windows.Forms.Form"
 TabForm.Size = dotNetObject "System.Drawing.Size" 400 225
 TabForm.Text = "Title"
 TabForm.TopMost = true
 FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
 TabForm.FormBorderStyle = FormBorderStyle.FixedDialog
 TabForm.ShowInTaskbar = false
 TabForm.MinimizeBox = true
 TabForm.MaximizeBox = false
 Tabform.helpbutton = true
 
 -- Add UI elements to Tabs
 tabpage1.controls.add(TB1textbox)
 tabpage1.controls.add(button01)
 tabpage2.controls.add(DGrid1)
  
 -- Add Tabs to Tab Container
 tabcontrol1.controls.add(tabpage1)
 tabcontrol1.controls.add(tabpage2)
 -- Add Tab Container to UI Form
 TabForm.Controls.Add(tabcontrol1)
 -- Show application Form
 TTApp = dotNetClass "System.Windows.Forms.Application"
 TTApp.Run TabForm
)




rollout testRLT "List View Test" width:200 height:180
          (
          	 dotNetControl thingy "ListView" width:160 height:100
          	 on testRLT open do 
          	  (
          		thingy.View = thingy.View.Details 
          		column = thingy.Columns.Add "A"
          		column = thingy.Columns.Add "B"
          		 
          		thingy.Items.add "aaa"
          		thingy.Items.add "bbb"
          		thingy.Items.add "ccc"
          		 
          		thingy.Columns.Item[0].width= 30
          		thingy.Columns.item[1].width= 30
          
          		thingy.Invalidate true
          	  ) 	
          ) 
          rollout testRLT2 "stuff" width:200 height:180
          (
          	-- Adding a second rollout blows out the column headers
          )
            
          floaterInstance= newRolloutFloater "Test" 200 200
          addRollout testRLT floaterInstance
          addRollout testRLT2 floaterInstance