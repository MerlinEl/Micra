--Created by Rene Baca 20.06.2011

if RenderBySetDialog != undefined do destroyDialog RenderBySetDialog

rollout RenderBySetDialog "Render by Set" width:668 height:96
(
	--local wasCancelled = true
	local iniFile = Micra.UserDir + "Render by Set.ini"
	GroupBox grp1 "Set:" pos:[4,4] width:660 height:88
	spinner spn_w "" pos:[60,48] width:60 height:16 range:[4,10000,256] type:#integer scale:1
	label lbl1 "Width:" pos:[16,48] width:44 height:16
	spinner spn_h "" pos:[60,68] width:60 height:16 range:[4,10000,256] type:#integer scale:1
	label lbl2 "Height:" pos:[16,68] width:44 height:16
	button btn_render "Render" pos:[124,44] width:536 height:44
	--button btn_render "Render" pos:[172,64] width:112 height:24
	--button btn_cancel "Clancel" pos:[288,64] width:72 height:24
	button btn_dir "dir..." pos:[564,20] width:28 height:20
	dropdownList ddl_path "" pos:[8,20] width:552 height:21
	dropdownList ddl_ftype "" pos:[596,20] width:64 height:21 items:#("*.jpg","*.tga","*.bmp","*.tif","*.png")
	fn inicializeInterface =
	(
		spn_w.value = renderWidth
		spn_h.value = renderHeight
		if doesFileExist iniFile do
		(
			ddl_path.items = mcFile.readSettings iniFile "RecentPaths"
		)
		--ddl_path.items = #("c:\\temp\\render\\")
		--escapeEnable=true
	)
	fn msg num =
	(
		messageBox \
		(
			case num of
			(
				1:"Set not found."
				2:"Invalid Path."
				3:""
			)
		) title:"Render by Set:"
	)
	fn bulidFoldersTreeFor sets =
	(
		local dir = ddl_path.selected
		for s in sets do makeDir (dir + s.name)
	)
	fn renderSets =
	(	
		local sets_count = selectionSets.count
		if sets_count == 0 do ((msg 1); return false)
		local w = spn_w.value 
		local h = spn_h.value
		local dir = ddl_path.selected
		if not doesFileExist dir do ((msg 2); return false)
		local anim_strat = animationRange.start
		local anim_end  = animationRange.end
		local ftype = case ddl_ftype.selected of
		(
			"*.jpg":".jpg"
			"*.tga":".tga"
			"*.bmp":".bmp"
			"*.tif":".tif"
			"*.png":".png"
		)
		bulidFoldersTreeFor selectionSets
		
		RenderBySetDialog.title = "Rendering... press escape to abort."
		local wasCancelled = false
		for s in selectionSets while not wasCancelled do
		(
			select s
			max hide inv

			local fpath = dir + s.name + "\\" + s.name +"_"+ftype
			format "filename:%\n" fpath
			local pic = render outputwidth:w outputheight:h outputFile:fpath framerange:(interval anim_strat anim_end) cancelled:&wasCancelled vfb:on
			max undo
			try (unDisplay pic) catch()
			print s
		)
		/*
		for s in selectionSets while not keyboard.escPressed do
		(
			select s
			max hide inv

			local fpath = dir + s.name + "\\" + s.name +"_"+ftype
			format "filename:%\n" fpath
			--render outputwidth:w outputheight:h outputFile:fpath framerange:(interval anim_strat anim_end) cancelled:&wasCancelled vfb:on
			local pic = render outputwidth:w outputheight:h outputFile:fpath framerange:(interval anim_strat anim_end) vfb:on
			max undo
			try (unDisplay pic) catch()
			print s
		)
		*/
		
		RenderBySetDialog.title = "Render by Set"
		
	)
	fn getDirectory =
	(
		local dir = getSavePath caption:" Chose Dir..." initialDir:(getDir #maxroot)
		if dir == undefined do return false
		ddl_path.items = #(dir+"\\") + ddl_path.items
		if not doesFileExist iniFile do (local f = createFile iniFile; close f)
		mcFile.saveSettings iniFile "RecentPaths" (dir+"\\")
	)
	on RenderBySetDialog open do inicializeInterface()
	on btn_render pressed do( renderSets() )
	on btn_dir pressed do ( getDirectory() )
	on btn_close pressed do (destroyDialog RenderBySetDialog)
	--on btn_cancel pressed do (wasCancelled = false)
)
createDialog RenderBySetDialog
