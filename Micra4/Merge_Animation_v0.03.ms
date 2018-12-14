if mergeanimDialog2 != undefined do destroyDialog mergeanimDialog2
rollout mergeanimDialog2 "Animation Merge v0.03" width:200 height:324
(
	local dir 
	GroupBox grp_path "path: /undefined" pos:[4,4] width:192 height:316
	button btn_br "Browse..." pos:[124,20] width:64 height:20 toolTip:"Browse Animations"
	button btn2 "Merge Animation" pos:[12,284] width:176 height:28
	listbox lbx_anims "Anims:" pos:[12,24] width:176 height:18
	fn getChain obj =
	(
		if obj == undefined do return #()
		local nodes = #(obj)
		for o in obj.children do 
		(
			nodes += o
			getChain o
		)
		return nodes
	)
	fn getLastKeyFromSelection selArr =
	(
		local times = #()
		for i in selArr do
		(
			local keys = i.pos.controller.keys
			if keys.count != 0 then times += #(i.pos.controller.keys[keys.count].time) else times += #(0)
			keys = i.rotation.controller.keys
			if keys.count != 0 then times += #(i.rotation.controller.keys[keys.count].time) else times += #(0)
		)
		return (sort times)[times.count]
	)	

	on btn_br pressed do
	(
	   dir = getSavePath()
	   if dir != undefined do 
	   (
	   		grp_path.text = "path: "+ dir
			local f = getFiles (dir+"\\*.xaf")
			if f.count != 0 do 
			(
				names = for i in f collect filenameFromPath i
				lbx_anims.items += names 
			)
	   )
	)
	on btn2 pressed do
	(
		local obj  = selection[1]
		local sel = getChain obj
		local itm = lbx_anims.selected
		if dir != undefined and sel.count != 0 and itm != undefined do 
		(
			local f       = dir +"\\"+itm
			local maxTime = getLastKeyFromSelection sel
			--format "loading anim:%\n" f
			if sel.count != 0 do
			(
				LoadSaveAnimation.loadAnimation f &sel relative:true insert:true insertTime:(maxTime+1)
			)
		)
	)
)
createDialog mergeanimDialog2