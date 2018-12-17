global dotNetForm
( 
	struct dotNetFormStruct
	(	 
		-- Functions
		fn testButton c a =
		(
			print c.text
			dotNetForm.close()
		),
		-- Interface
		fn init =
		(   
			testfrm= dotNetObject "Form"
			testfrm.Size = dotNetObject "System.Drawing.Size" 100 100	  

			-- Init Button
			btnTest = dotNetObject "System.Windows.Forms.Button"
			btnTest.location = dotNetobject "System.drawing.point" 2 2
			btnTest.text = "test button"
			btnStored = btnTest

			testfrm.controls.addRange(#(btnTest))

			-- Init Events
			dotNet.addEventHandler btnTest "click" testButton

			-- Show Form
			testfrm.show()
			return testfrm
		)
	)
	local netStrInstance = dotNetFormStruct() 
	dotNetForm = netStrInstance.init()
)

-------------------------------
-----------------------------


try(destroyDialog listtest)catch()

struct dotNetListStruct
(
	Lv,fillFn,
	objectList ,
	ClickedObject = Undefined,
	myIndex=0,
	mySubIndex=0,
	myChkBx = True,
	fn DotNetColorFromMax col =
	(
		netColor = dotNetClass "System.Drawing.Color"
		netcolor.fromArgb col.r col.g col.b
	),
	ForeCol = DotNetColorFromMax ( color 225 215 210 ),
	BackCol = DotNetColorFromMax ( color 80 80 80 ),
	HighCol = DotNetColorFromMax (color 23 23 130),
	AltCol = DotNetColorFromMax ( red ),
	
	fn checkRange = 
	(
		if myIndex >= lv.items.count do myIndex = lv.items.count
		myIndex > 0
	),

	fn refreshHighlight arg =
	(
		if arg != myIndex then 
		(
			if checkRange()  do lv.items.item[myIndex-1].backcolor = BackCol
			myIndex = arg
		)
		if checkRange() do lv.items.item[myIndex-1].backcolor = highCol
	),
	fn refreshIndex =
	(
		if lv.selectedindices.count > 0 do refreshHighlight (lv.selectedindices.item[0] +1)
	),
	fn setIndex i = 
	( 
		if i>0 do refreshHighlight i
		if MyIndex>0 do ClickedObject = (*ObjectList)[MyIndex]
	),
	fn setSubIndex i = 
	(
		mySubIndex = i
	),
	fn subItemAtMousePos =
	(
		pos = lv.mousePosition
		pos = lv.PointToClient pos
		li = lv.getItemAt pos.x pos.y
		if li!= undefined then
		(
			si = li.getSubItemAt pos.x pos.y
			i = li.index+1
			j = (li.subitems.indexof si) +1

			#(i,j) -- index + 1 because listview array starts at 0 whereas max array starts at 1
		)else undefined
	),
	fn setItemAtMousePos =
	(
		theIndex = subItemAtMousePos()
		if theIndex!=undefined do
		(
			setIndex theIndex[1]
			setSubIndex theIndex[2]
		)
	),
	fn init layout_def chkBx:True =
	(
		lv.allowdrop = true
		lv.gridLines = true  
		lv.View = (dotNetClass "System.Windows.Forms.View").Details
		lv.LabelEdit = false
		lv.fullRowSelect = true 
		lv.multiselect = false
		lv.ForeColor = ForeCol
		lv.backColor = BackCol
		lv.checkboxes = myChkBx = chkBx
		
		for i in layout_def do
		(
			lv.Columns.add i[1] i[2] --add column with name and optional width
		)
		--lv.refresh()
	),
	
	fn fill =
	(
		lv.items.clear()
		theRange = #()
		for obj in *objectList do
		(
			li = dotNetObject "System.Windows.Forms.ListViewItem" ""
			mysubItems = Fillfn obj
			if myChkBx then li.checked = mysubItems[1] else li.text = mysubItems[1]
			for i = 2 to mysubItems.count do 
			(
				sub_li = li.SubItems.add mysubItems[i]
				--sub_li.tag = i
			)
			append theRange li --we add the list item to the array
		)
		lv.Items.AddRange theRange --when done, we populate the ListView
		lv.refresh()
		refreshHighlight myindex
		
	)
)

struct DotNetDragDropStruct
(
	DragObj= Undefined,
	DnList = Undefined,
	
	fn DragOver arg=
	(
		if (DragObj != undefined)  do
		(
			local dragDropEffect = dotNetclass "System.Windows.Forms.DragDropEffects"
			arg.effect = dragDropEffect.move
		)
	),
	
	fn ItemDrag arg D =
	(
		DnList = D
		DragObj = (*DnList.ObjectList)[DnList.myIndex]
		if DragObj != undefined do 
		(
				local effect = dotNetclass "System.Windows.Forms.DragDropEffects"	
				DnList.lv.DoDragDrop arg.item effect.move
		)
	),
	
	fn ItemDrop arg DnTargetList =
	(
		if DragObj != undefined do 
		(
			NewIndex = undefined
			oldList = *DnList.ObjectList
			NewList = *DnTargetList.ObjectList
			
			DeleteItem oldList DnList.myIndex
			targ = DnTargetList.subItemAtMousePos()
			if targ  != undefined then
			(
				insertItem DragObj NewList targ[1]
				NewIndex = targ[1]
			)else
			(
				append NewList DragObj
				DnTargetList.fill()
				NewIndex = NewList.count
			)
			DnTargetList.fill()
			DnTargetList.setIndex NewIndex
			DnList.fill()
		)
	)

)
Struct TestStruct
(
	List = #()
)
rollout ListTest "Object List Drag and drop Test"
(
	
	dotNetControl dnListObjectL  "System.Windows.Forms.ListView"  width:110 height:260 align:#Left Offset:[0,0]
	dotNetControl dnListObjectR  "System.Windows.Forms.ListView"  width:110 height:260 align:#right Offset:[0,-266]

	fn myFillfn obj= #(obj.name)
	
	local left = TestStruct (objects as array)
	local right = TestStruct()
	
	Local DnListLeft = dotNetListStruct dnListObjectL myFillfn &Left.list
	Local DnListRight = dotNetListStruct dnListObjectR myFillfn &Right.list
	local mouseState = #up
	
	local DragNode = undefined
	local DragDrop = DotNetDragDropStruct()
	
	fn refresh =
	(
		DnListLeft.fill()
		DnListRight.fill()
	)
	
	on ListTest open do
	(
		dnListLeft.init  #(#("Name",100)) chkBx:false
		dnListRight.init  #(#("Name",100)) chkBx:false
		refresh()
	)
	

	------------------------------------------------------------------------------------------------------- left Side
	
	on dnListObjectL mouseDown arg do DnListLeft.setItemAtMousePos() 
	on dnListObjectL DragDrop arg do DragDrop.ItemDrop Arg DnListLeft
	
	on dnListObjectL DragOver Arg do  DragDrop.dragOver arg
	on dnListObjectL ItemDrag arg do DragDrop.itemDrag arg DnListLeft

	------------------------------------------------------------------------------------------------------- Right Side
	
	on dnListObjectR mouseDown arg do DnListRight.setItemAtMousePos() 
	on dnListObjectR DragDrop arg do  DragDrop.ItemDrop Arg DnListRight
	
	on dnListObjectR DragOver Arg do DragDrop.dragOver arg
	on dnListObjectR ItemDrag arg do DragDrop.itemDrag arg DnListRight

	-------------------------------------------------------------------------------------- possibly useful events
	--on dnListObjectL mouseLeave do--
	--on dnListObjectL mouseEnter do--
	--on dnListObjectL mouseUp arg do --
	--on dnListObjectL DragLeave arg do ---
	--on dnListObjectL DragEnter arg do ---	
)


createdialog listtest 300 300