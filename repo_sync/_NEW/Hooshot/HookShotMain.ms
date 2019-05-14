plugin simpleObject P3D_HookShotMain
	name:"HookShot"
	classID:#(0x31d561e, 0x483edfa8)
	category:gP3D_PluginName
(	
	local CACreated = false
	local obj, theMesh
	local target, me, mid
	local vDirect, mVy, mVz, mTm
	local delHandler
	---------------------------------------------------------------------------------------------------------------- FN
	fn SetCaParameters =
	(
		local normalV = - (me.transform.row2)
		
		this.point1X = me.pos[1]
		this.point1Y = me.pos[2]
		this.point1Z = me.pos[3]
		
		this.point2X = target.pos[1]
		this.point2Y = target.pos[2]
		this.point2Z = target.pos[3]
		
		this.normalX = normalV[1]
		this.normalY = normalV[2]
		this.normalZ = normalV[3]
		
		this.HSE_point1 	= me.pos[1] as string		+ " "+ me.pos[1] as string 	+ " "+me.pos[1] as string  
		this.HSE_point2 	= target.pos[1] as string	+ " "+ target.pos[2] as string + " "+target.pos[3] as string  
		this.HSE_normal 	= normalV[1] as string		+ " "+ normalV[2] as string 	+ " "+normalV[3] as string
		
		true
	)
	----------------------------------------------------------------------------------------------------------------
	parameters main rollout:params
	(
-- 		temp 	type:	#worldUnits ui:temp default:0
		second 	type: #node
		middle	type: #node
		delIndex	type: #integer
	)
	rollout params "HookShot(main) Parameters"
	(
-- 		spinner temp "Temp" type:#worldunits range:[-1000,1000,0]
	)
	----------------------------------------------------------------------------------------------------------------	On Build Mesh
	on buildMesh do
	(
-- 		format "- build Main \n"
		
-- 		obj = createinstance Cone radius1:0 radius2:3 height:10 sides: 10 heightsegs: 1
-- 		obj = createinstance Box width:5 length:5 height:5
		obj =  createinstance Hedra family:0 scalep:100 scaleq:100 scaler:100 mapcoords:on radius:5.0
		theMesh = obj.mesh
		mesh = theMesh
	)
	----------------------------------------------------------------------------------------------------------------	Tool Create
	tool create
	(
		on mousePoint click do (
			case click of
			(				
				1: (	
						nodeTM.translation 	= gridPoint
					--------------------------------------------------------------
						target 		= ::P3D_HookShotTarget()
						target.pos 	= gridPoint
						second 		= target
						target.mainHandle = me.inode.handle
					--------------------------------------------------------------
						mid			= ::P3D_HookShotMiddle()
						target.middleHandle = mid.inode.handle
						mid.mainHandle = me.inode.handle
						mid.targetHandle = target.inode.handle
						middle		= mid
						mid.pos		= gridPoint
					)
				2: (
						::gP3DHookShot.SetHookLayer()
						::gP3DHookShot.MoveHookSetToLayer #(target, me, mid)
-- 						::gP3DHookShot.StartTracking me -- starts callback
						deselect $*
						#stop
					
					)
			)
		)

		on mouseMove click do
		case click of
		(
			2: (
-- 					format "%\n" me.pos
					target.pos 	= gridPoint
					::gP3DHookShot.BuildHookSet gridPoint me mid target (classof me)
					SetCaParameters()
				
-- 				--------------------------------------------------------------
-- 					vDirect 	= gridPoint - me.pos
-- 					mVz		= normalize me.transform.row3
-- 					mVy		= normalize (cross (normalize mVz) (normalize vDirect))
-- 					mVz		= normalize (cross (normalize vDirect) mVy)
					--mTm = matrix3 vDirect mVy mVz me.pos
					--format "%\n"  me.transform
-- 					target.transform = matrix3 (normalize vDirect) mVy mVz target.pos
-- 				--------------------------------------------------------------
-- 					mid.pos 		= me.pos + 0.5*(vDirect)
-- 					mid.lenght	= distance me.pos target.pos
-- 					mid.transform = matrix3  mVy (normalize vDirect) mVz mid.pos
				)
				
				3: (
					
				)
		)
	)
	---------------------------------------------------------------------------------------------------------------- 	Node Created
	on attachedToNode theNode do
	(
		me = theNode
-- 		select me
-- 		theNode.wirecolor = color 217 255 7
-- 		theNode.wirecolor = color 8 110 135
		theNode.wirecolor = color 0 0 255
		
-- 		delHandler = ::gP3DHookShot.TrackingForDelete me -- starts callback
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
		when transform me changes do (
			
			local obj 			= (selection as array)[1]
			local classOfObj 	=  classof obj
			Case (classOfObj) of (
				P3D_HookShotMain : (
					::gP3DHookShot.BuildHookSet obj.second.pos obj obj.middle obj.second classOfObj
					SetCaParameters()
				)
				P3D_HookShotMiddle : (
					select #((maxOps.getNodeByHandle obj.mainHandle), obj, (maxOps.getNodeByHandle obj.targetHandle))
					SetCaParameters()
				)
				P3D_HookShotTarget : (
					::gP3DHookShot.BuildHookSet obj.pos (maxOps.getNodeByHandle obj.mainHandle) (maxOps.getNodeByHandle obj.middleHandle) obj classOfObj
					SetCaParameters()
				)
			)
		)
		
		if (not CACreated) then (
-- 			::gCAInfo.AddCustomAttributeByName this "HookShotEdge"
			if (custAttributes.add me ::gCAHookTest #unique) then (		-- creating CA with informations for export.
				CACreated = true
			) else (
				::P3DLogL("Unable to add necessary Custom Attribute to a newly created Hook Shot Object. Export for this model will probably not be available. Please check your Max Exporter installation.") level:3
				return false
			)
		)		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 		delHandler = when me deleted id:#del delNode do (
-- 			local mainDelHandl, midDelHandl, targetDelHandl
-- 				
-- 			if (selection as array).count >1 then select delNode

-- 			if (isValidNode delNode.middle) then delete delNode.middle
-- 			if (isValidNode delNode.second) then delete delNode.second
-- 		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
	)	
	
-- 	on postCreate do (
-- 		format "buf\n"
-- 	)
)