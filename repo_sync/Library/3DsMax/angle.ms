if lookAtTestDialog != undefined do DestroyDialog lookAtTestDialog
rollout lookAtTestDialog "LensTest" width:104 height:56
(
	local planes = ($plane*), cam = $camera01
	local active = #(0, 0, 0, 0, 0, 0)	
	local times  = #(0, 0, 0, 0, 0, 0)	
	timer tmr_1 "Timer" pos:[4,4] width:24 height:24 enabled:true interval:1 active:true
	button btn1 "Start" pos:[4,4] width:96 height:20
	button btn2 "Stop" pos:[4,28] width:96 height:20
	fn getVectorsAngle v1 v2 = acos (dot (normalize v1) (normalize v2))
	fn scalePlanes = for i in planes do i.scale = [0.1, 0.1, 0.1]
	fn revertPlanes = for i in planes do i.scale = [1,1,1]
	fn manipPlanes = --switch off
	(
		for i = 1 to 6 do if active[i] == 1 do 
		(
			   times[i] += 1
		 planes[i].scale -= [0.05, 0.05, 0.05]
			if times[i] == 10 do planes[i].scale =  [0.1, 0.1, 0.1]
			if times[i] == 10 do 
			(
				times[i] = 0
				active[i] = 0
			)
		)
--tmr_1.active=true
--tmr_1.active=false
	)
	fn getPlanesAngle =
	(
		--format "time:%\n" currentTime
		for i = 1 to 6 do
		(
			local v1 = cam.pos - planes[i].pos
			local v2 = planes[i].dir
			local a = getVectorsAngle v1 v2
			--format "plane:%\tthe angle:%\n" planes[i].name  a
			--if a < 10 do format "time:%\tplane:%\n" currentTime planes[i].name
			if a < 25 do if active[i] == 0 do 
			(
				planes[i].scale =  [1,1,1]
				active[i] = 1
			)
		)
	)
	on lookAtTestDialog open do 
	(
		clearListener()
		scalePlanes()
		registerTimeCallback getPlanesAngle
	)
	on lookAtTestDialog close do 
	(
		revertPlanes()
		unRegisterTimeCallback getPlanesAngle
		stopAnimation()
	)
	on tmr_1 tick     do manipPlanes()
	on btn1  pressed  do (playAnimation())
	on btn2  pressed  do (stopAnimation())
)
createDialog lookAtTestDialog