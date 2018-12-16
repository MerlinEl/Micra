Global mcPassKeeper

try destroyDialog mcPassKeeper catch ()
rollout mcPassKeeper "Pass Keeper v0.01" width:276 height:608
(
	local inidata , key_file, dynamicSubRollout, addKeyLineDialog
	
	
	GroupBox grp1 ">>>" pos:[4,4] width:268 height:600
	
	combobox cbx_list "List:" pos:[12,24] width:252 height:16

	button btn_sav "Save" pos:[96,270] width:80 height:20
	button btn_new "New" pos:[12,270] width:80 height:20
	button btn_del "Deete" pos:[180,270] width:80 height:20
	button btn_run "Run" pos:[212,16] width:52 height:20
	subRollout sub_rol "Data" pos:[8,296] width:260 height:304
	struct INI_DATA (head, keys, data)
	fn iniFileFound =
	(
		key_file = Micra.RootDir + "User\\Keys.ini"
		if not doesFileExist key_file do createFile key_file
		if not doesFileExist key_file 
		then return false
		else return true
	)
	fn collectIniData =
	(
		if not iniFileFound() do return false
		
		local heads = sort (getIniSetting key_file) 
		--if no saved data found
		if heads.count == 0 do return false
		
		inidata = #()
		for h in heads do 
		(
			local keys = getIniSetting key_file h
			local data = for k in keys collect (getIniSetting key_file h k)
			inidata += #(INI_DATA head:h keys:keys data:data )
		)
	)
	
	--functions for subRollout
	fn addKeyLine = 
	( 		
		try destroyDialog addKeyLineDialog catch ()
		rollout addKeyLineDialog "Untitled" width:256 height:108
		(
			local n = mcPassKeeper.cbx_list.selection
			groupBox grp2 "New Data:" pos:[4,4] width:248 height:100
			label lbl7 "name:" pos:[12,28] width:40 height:16
			label lbl8 "data:" pos:[12,56] width:40 height:16
			editText edt_key "" pos:[52,28] width:64 height:20
			editText edt_data "" pos:[52,52] width:192 height:20
			button btn_cancel "Cancel" pos:[8,80] width:80 height:20
			button btn_accept "Accept" pos:[168,80] width:80 height:20
			on btn_cancel pressed  do (destroyDialog addKeyLineDialog)
			on btn_accept pressed  do
			(
				local key_str = edt_key.text
				local data_str = edt_data.text
				
				if key_str == "" do return false
				
				mcPassKeeper.inidata[n].keys += #(key_str)
				mcPassKeeper.inidata[n].data += #(data_str)
				
				destroyDialog addKeyLineDialog
				mcPassKeeper.loadForm n
			)
			on addKeyLineDialog open do setFocus edt_key
		)
		createDialog addKeyLineDialog modal:true
	) 
	fn delKeyLine num itm =
	(
		if inidata[num].keys.count == 1 do return false -- restrict to remove last line
		deleteItem inidata[num].keys itm
		deleteItem inidata[num].data itm
		mcPassKeeper.loadForm num
	)
	
	fn loadForm num = --add rolout with items
	(
		if not iniFileFound() do return false
		if classOf dynamicSubRollout == RolloutClass do RemoveSubRollout sub_rol dynamicSubRollout
		
		local head = cbx_list.items[num]
		local keys = inidata[num].keys		
		local data = inidata[num].data

		if keys.count == 0 do return false
		if data.count == 0 do data = for i in keys collect ""
		
--format "data:%\n" data

		--build dynamic rollouts
		local exe = "rollout dynamicSubRollout \"<< "+head+" >>\" \n"
		exe += "( \n" --rollout begin
		local lbl_pos_y = 8 - 24
		local edt_pos_y = 4 - 24
		for i=1 to keys.count do 
		(
			lbl_pos_y += 24 
			edt_pos_y += 24
			local i_str = i as string
			
			--labels
			exe	+= "\t label lbl_"+i_str+" \""+keys[i]+":\" pos:[4,"+lbl_pos_y as string+"] width:56 height:12 \n"
			--edittexts
			exe	+= "\t edittext edt_"+i_str+" \"\" pos:[60,"+edt_pos_y as string+"] width:166 height:17 text:\""+data[i]+"\" \n"
			exe	+= "\t on edt_"+i_str+" changed text do  (mcPassKeeper.inidata["+num as string+"].data["+i_str+"] = text) \n"
			--buttons
			exe	+= "\t button btn_"+i_str+" \"-\" pos:[230,"+edt_pos_y as string+"] width:16 height:16 \n"
			exe	+= "\t on btn_"+i_str+" pressed do (mcPassKeeper.delKeyLine "+num as string+" "+i_str+") \n"
		)
		
		exe	+= "\t button btn_add \"+\" pos:[230,"+(edt_pos_y += 24) as string+"] width:16 height:16 \n"
		exe	+= "\t on btn_add pressed do (mcPassKeeper.addKeyLine () ) \n"
		
		exe += ") \n" --rollout end
--print exe
		dynamicSubRollout = execute exe
		AddSubRollout sub_rol dynamicSubRollout rolledUp:off
		setFocus cbx_list
	)
	
	fn loadList num:0 =
	(
		if num != 0 
		then
		(
			local heads = for i in inidata collect i.head
			if heads.count == 0 do return false
			cbx_list.items = heads
			cbx_list.selection = num
			loadForm num
		)
		else
		(
			if not iniFileFound() do return false
			--Get INI Data
			local heads = sort (getIniSetting key_file) 
			--if no saved data found
			--Fill Box
			if heads.count == 0 do return false
			cbx_list.items = heads
			cbx_list.selection = 1
			
			collectIniData()
			loadForm 1
		)
	)
	
	fn lowercase instring =
	(
		upper="AÁBCCDDEÉEFGHCHIÍJKLMNNOÓPQRRSŠTTUÚUVWXYÝZŽ"
		lower="abcdefghijklmnopqrstuvwxyz" 
		outstring=copy instring 
		for i = 1 to outstring.count do 
		(
			j=findString upper outstring[i]
			if (j != undefined) do outstring[i]=lower[j]
		)
		outstring
	)
	
	fn dupplicatesFound title =
	(
		local t = lowercase title
		for i in inidata do if lowercase i.head == t do return true
		return false
	)
	
	fn addToList =
	(
		local head = cbx_list.text
		if head == "" do return false
		if dupplicatesFound head do (messagebox "Already exist." title:"Dupplicated" ; return false)
		
		keys = #("web", "name", "pass")
		data = #("", "", "")
		inidata = #(INI_DATA head:head keys:keys data:data ) + inidata
--print inidata
		loadList num:1
		setfocus cbx_list
	)
	
	fn saveToIni =
	(
		--backup file
		local bk_file = (Micra.RootDir + "User\\Keys.bk")
		renameFile key_file bk_file
		createFile key_file
		--write data to new file
		for i in inidata do
		(
			--setIniSetting key_file i.head "" ""
			for y=1 to i.keys.count do  
			(
				setIniSetting key_file i.head i.keys[y] ""
				setIniSetting key_file i.head i.keys[y] i.data[y]
			)
		)
		--delete backup
		deleteFile bk_file
		collectIniData()
		loadForm cbx_list.selection
	)
	
	fn openInWeb sel = 
	(
		local web_num = findItem inidata[sel].keys "web"
		if web_num == 0 do return false
		local ilink = inidata[sel].data[web_num]
		if link == "" do return false
		shellLaunch ilink ""
	)
	
	fn deleteFromList =
	(
		if (yesNoCancelBox "You are sure?" title:"Deleting Item?" ) == #yes do
		(
			deleteItem inidata cbx_list.selection
			loadList num:1
			setfocus cbx_list
			--loadForm cbx_list.selection
		)
	)
	
	on mcPassKeeper open          do ( loadList()    )
	on cbx_list  selected sel     do ( loadForm sel  )
	on btn_new    pressed         do ( addToList()   )
	on btn_sav    pressed         do ( saveToIni()   )
	on cbx_list doubleClicked sel do ( openInWeb sel  )
	on btn_run    pressed         do ( openInWeb cbx_list.selection )
	on btn_del    pressed         do ( deleteFromList() )
)
createDialog mcPassKeeper