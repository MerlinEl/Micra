fn giveBackMyDialogs = (

	local last_profile_index = mcFile.readSettings Micra.UserSettings "Settings/CurrentProfile"
	local last_profile_name = "Profile_"+ last_profile_index + ".xml"
	local user_xml = Micra.UserDir + last_profile_name
	local dialogs_names_1 = mcFile.readSettings user_xml "Properties_1" type:"keys"
	local dialogs_names_2 = mcFile.readSettings user_xml "Properties_2" type:"keys"
	local max_size = getMaxWindowSize() -500
	fn restorePos dname dpath user_xml max_size = (
		
		local dpos = execute (mcFile.readSettings user_xml dpath type:"pos")
		if dpos.x > max_size.x or dpos.x < 0  then (

			format "MOVE > dialog% from:% to:%\n" dname dpos.x max_size.x
			dpos.x = max_size.x
		) else (

			format "SKIP > dialog:% pos:%\n" dname dpos
		)
		mcFile.saveSettings user_xml dpath (dpos as string) type:"pos"
	)
	for n in dialogs_names_1 do restorePos n ("Properties_1/"+n) user_xml max_size
	for n in dialogs_names_2 do restorePos n ("Properties_2/"+n) user_xml max_size
	if mcMicraDialog.location.x  > max_size.x or mcMicraDialog.location.x < 0 do  mcMicraDialog.location.x = max_size.x
	Micra.load()
	messageBox "Done!" title:"Micra:"
)
giveBackMyDialogs()