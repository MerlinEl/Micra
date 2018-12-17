try destroyDialog dotnetIconTestDialog catch()
rollout dotnetIconTestDialog "Icons List" width:160 height:324
(
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local transparent_color = color 185 185 185
	local icon_file, icn_count
	GroupBox grp1 "DotNet TreeView Icons:" pos:[4,4] width:152 height:316
	button btn1 "Load Max UI Icons..." pos:[12,288] width:136 height:24
	dotNetControl tv "treeView" pos:[12,24] width:136 height:260
	fn netDrColor clr  = ((dotNetClass "System.drawing.color").fromArgb clr.r clr.g clr.b)
	fn getIconDotNet img h icn_num =
	(
		local x = (h * icn_num)

		local icon = (dotNetObject "Drawing.Bitmap" h h) --Create new bitmap object
		local gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
		local newRect = dotnetObject "Drawing.rectangle" 0 0  h  h
		gra.DrawImage img newRect x 0 h h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		icon
	)
	fn getIconList =
	(
		
		local img = (dotNetClass "Drawing.Image").FromFile icon_file --get the saved image from file as bitmap
		local w = img.width
		local h = img.height
		icn_count = (w / h) as integer
		
		local img_list = dotNetObject "ImageList"
		img_list.ImageSize = dotNetObject "Drawing.Size" h h
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.transparentColor = netDrColor transparent_color
		
		for i = 1 to icn_count do img_list.images.add (getIconDotNet img h i)
		img.dispose()
		
		return img_list
	)
	fn loadIconset =
	(
		local icons_path = (GetDir #ui)+"Icons\\"
		getOpenFileName caption:"Select Icon Set"  \ 
		filename:icons_path \
		types:"BMP image file (*.bmp)"
	)
	fn fillTreeView = 
	(
		for i = 1 to icn_count do 
		(
			local d = (dotNetObject "TreeNode" ("icon" + i as string)) 
			d.ImageIndex = i
			tv.nodes.add d
		)
		tv.SelectedNode = tv.Nodes.Item[ 0 ] -- select the first Item
		return true
	)
	on dotnetIconTestDialog open  do
	(
		tv.BackColor= netDrColor winColor
		tv.ForeColor= netDrColor textColor
		tv.HideSelection=false -- When this ListView loses the focus, it will still show what's selected
		tv.HotTracking = true 
		
		start_lib = (GetDir #ui)+"Icons\\Maintoolbar_24i.bmp"
		if doesfileexist start_lib do
		(
			icon_file = start_lib
			print icon_file
			tv.nodes.Clear()
			tv.ImageList = getIconList()
			fillTreeView()
		)
	)
	on dotnetIconTestDialog close  do
	(
		
	)
	on btn1 pressed  do
	(
		icon_file = loadIconset()
		if icon_file != udefined do 
		(
			print icon_file
			tv.nodes.Clear()
			tv.ImageList = getIconList()
			fillTreeView()
		)
	)
)
createDialog  dotnetIconTestDialog