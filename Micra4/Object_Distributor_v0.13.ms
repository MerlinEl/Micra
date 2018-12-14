global mcDistributorActiveObject = undefined
global mcDistributorAngle = undefined
global mcDistributorSel = #()


--Object Distributor
(
	local OBJECT_DISTRIBUTOR
	struct OBJECT_DISTRIBUTOR
	(
		obj, SnapshotMeshObj, debug = false, click_step = 1, active_obj, 
		build_up = false, active_clone = false, obj_rotation = 0, last_angle = 0,
		fn round val num =
		(
			((val*num) as integer) as float / num
		), 
		fn roundInteger val step:10 = --10 , 100, 1000
		(
			local num = val as integer -- throw away the decimal part
			if val >0 then num += step/2 else num -= step/2 -- add half of step
			num /= step -- divide by step, (division of ints throws away the decimal part)
			num *= step -- multiply by step
			return num
		),
		fn showmarkers =
		(	
			gw.setTransform(Matrix3 1)
			for n=1 to mcDistributorSel.count do
			(
				local o = mcDistributorSel[n]
				local pos =o.min - [0,1,0] 
				gw.text pos ("("+n as string+ ") "+o.name) color:yellow
			)
			
			local mouse_pos = [mouse.pos.x, mouse.pos.y, 0]
			if mcDistributorActiveObject != undefined do
			(
				local center_pos = gw.TransPoint mcDistributorActiveObject.pos 
				center_pos.x = center_pos.x as integer --throw decimal
				local left_pos = center_pos-[180,0,0]
				local right_pos = center_pos+[180,0,0]
				gw.wMarker center_pos #circle color:red 
				gw.wMarker left_pos #circle color:red
				gw.wMarker right_pos #circle color:red
				gw.wPolyline #(left_pos, right_pos) on rgb:#(orange,orange)
				
				mouse_pos.y = center_pos.y
				mouse_pos.x = roundInteger mouse_pos.x step:10
				
				if mouse_pos.x <= left_pos.x then mouse_pos.x = left_pos.x -- if mouse X is too left set to -200
				else if mouse_pos.x >= right_pos.x do mouse_pos.x = right_pos.x -- if mouse X is too right set to 200

				gw.wMarker mouse_pos #bigBox color:green
				mcDistributorAngle = (roundInteger (mouse_pos.x - center_pos.x) step:10)
				--gw.wText right_pos ("(mat:"+mcDistributorAngle as string+")") color:white
				gw.wText left_pos ("(Angle:"+mcDistributorActiveObject.rotation.z_rotation as string+")") color:yellow
			)
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		) ,
		fn appendSnapshotToMeshObj =
		(
			local snap_obj = snapshot active_obj
			attach SnapshotMeshObj snap_obj
		),
		fn find3DPoint msg ir obj faceNum shift ctrl alt =
		(	
			case msg of
			(
				#mouseMove: --second aaction
				(
					--print "mouseMove"
					if ctrl then
					(
						mcDistributorActiveObject = active_obj
						if mcDistributorAngle != undefined and mcDistributorAngle != last_angle do
						(
							in coordsys local active_obj .rotation.z_rotation = mcDistributorAngle - last_angle
							last_angle = mcDistributorAngle	
							obj_rotation = active_obj.rotation.z_rotation
						)
						completeredraw()
					)
					else if ir != undefined do 
					(
						if active_obj != undefined and not ctrl do --first aaction , placing object
						(
							obj_rotation = active_obj.rotation.z_rotation  --store Z rotation
							last_angle = 0
							active_obj.pos = ir.pos
							active_obj.dir = ir.dir
							if obj_rotation != undefined do in coordsys local active_obj.rotation.z_rotation = obj_rotation
						)
						--if shift do active_clone = true
					)
				)
				#freeMove: () --first action
				#mousePoint: --thrid action
				(
					--print "mousePoint"
					if ctrl then --rotate active_object 
					(
						mcDistributorActiveObject = undefined
					)
					else if ir != undefined do --alignObjToface
					(
						if mcDistributorSel.count != 0 and click_step == 0 do --remove next obj from array, but not the last one
						(
							active_obj = mcDistributorSel[1] --assing next object to be active
							deleteItem mcDistributorSel 1 
							click_step = 1
						)
						
						if shift then --clone active_obj
						(
							if build_up do undo off appendSnapshotToMeshObj()
							active_obj = copy active_obj
						)

						if not ctrl do
						(
							active_obj.pos = ir.pos
							active_obj.dir = ir.dir
							if obj_rotation != undefined do in coordsys local active_obj.rotation.z_rotation = obj_rotation
						)
						--format "obj_rotation:%\n" obj_rotation
					)
				)
				#mouseAbort:		
				(
					--print "mouseAbort"
					if click_step == 0 do return #stop
					click_step = 0
					if build_up do undo off appendSnapshotToMeshObj()
					active_obj = mcDistributorSel[1]
					if active_obj != undefined do undo off active_obj.xray = false
				)
			)
			#continue
		),
		fn distributeSelectedObject =  --select two or more geometry objects
		(
			mcDistributorSel = selection as array
			if mcDistributorSel.count < 2 do return false
			obj = mcDistributorSel[1]
			if superClassOf obj != GeometryClass do return false
			
			local old_sel = deepCopy mcDistributorSel
			deleteItem mcDistributorSel 1 --remove first obj from array
			active_obj = mcDistributorSel[1] --assing next object to be active
			deleteItem mcDistributorSel 1 --remove next obj from array
			SnapshotMeshObj = snapshot obj
			hide SnapshotMeshObj

			unregisterRedrawViewsCallback showmarkers
			registerRedrawViewsCallback showmarkers
			
			undo "Distribute" on 
			(
				for i in mcDistributorSel do i.xray = true
				select obj
				mouseTrack on:SnapshotMeshObj snap:#3D trackCallback:find3DPoint
			)
			if isValidNode SnapshotMeshObj  do delete SnapshotMeshObj
			unregisterRedrawViewsCallback showmarkers	
			undo off (for i in old_sel do i.xray = false)
		)
	)
	--execute
	local od = OBJECT_DISTRIBUTOR() 
	od.build_up = true
	od.distributeSelectedObject() 
)