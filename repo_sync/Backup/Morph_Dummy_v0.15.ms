Global morphCollectorRingData
/*
--reset variables
		$.pose_names =#()
		$.rings_data =#()
*/

plugin Helper MorphDummy
name:"Morph Dummy" 
classID:#(1702251725, -251349223) 
category:"Standard" 
extends:dummy 
( 
	local lastSize, meshObj
	parameters pblock rollout:params 
	(
		size type:#float animatable:true ui:amount default:4.0
		pose_names type:#stringTab tabSize:0 tabSizeVariable:true 
		ring_names type:#stringTab tabSize:0 tabSizeVariable:true
		
		ring_positions_1 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_1 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_1 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_2 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_2 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_2 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_3 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_3 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_3 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_4 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_4 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_4 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_5 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_5 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_5 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_6 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_6 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_6 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_7 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_7 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_7 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_8 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_8 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_8 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_9 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_9 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_9 type:#indexTab tabSize:0 tabSizeVariable:true
		
		ring_positions_10 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations_10 type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius_10 type:#indexTab tabSize:0 tabSizeVariable:true
	)
	rollout params "Parameters:"
	(
		Spinner amount "Size:" range:[1, 1e9, 40]
		group "Poses:"
		(
			listBox pose_list "" pos:[7,44] width:147 height:8 
			editText edt "" pos:[4,156] width:150 height:20 
			button btn_add "Assing Pose" pos:[7,180] width:73 height:24 tooltip:"Add New Pose"
			button btn_del "Clear Pose" pos:[81,180] width:73 height:24 tooltip:"Delete Selected Pose"
			button btn_cop "Copy Pose" pos:[7,206] width:73 height:24 tooltip:"Copy Pose To Clipboard"
			button btn_pas "Paste Pose" pos:[81,206] width:73 height:24 tooltip:"Paste Pose To current Selection"
		)
		fn elementData param_name num data:unsupplied=
		(
			local itm =case param_name of
			(
				#pos:# (
					&ring_positions_1,&ring_positions_2,&ring_positions_3,&ring_positions_4,&ring_positions_5,
					&ring_positions_6,&ring_positions_7,&ring_positions_8,&ring_positions_9,&ring_positions_10
				)[num]
				#rot:# (
					&ring_rotations_1,&ring_rotations_2,&ring_rotations_3,&ring_rotations_4,&ring_rotations_5,
					&ring_rotations_6,&ring_rotations_7,&ring_rotations_8,&ring_rotations_9,&ring_rotations_10
				)[num]
				#rad:# (
					&ring_radius_1,&ring_radius_2,&ring_radius_3,&ring_radius_4,&ring_radius_5,
					&ring_radius_6,&ring_radius_7,&ring_radius_8,&ring_radius_9,&ring_radius_10
				)[num]
			)
			
			if data == unsupplied
				then (*itm) --get data
				else --set data
				(
					*itm = data
				)
		)
		fn findItemString arr str  ignoreCase:true =
		(
			if  ignoreCase then 
			(
				local lower_arr = for i in arr collect toLower i
				local lower_str = toLower str
				return ( findItem lower_arr lower_str != 0 )
			)
			else return ( findItem arr str != 0 )
		)
		fn dupplicatesFound items txt =(if findItemString items txt then return true else return false)
		fn renameSelectedItem=
		(
			local n = edt.text
			if n != "" do --rename
			(
				if not dupplicatesFound pose_list.items n 
				then 
				(
					pose_names[pose_list.selection] = n
					pose_list.items = pose_names as array
				)
				else (messageBox ("Name: [ "+ n +" ] is used. Try something else." ) title:"Dupplicate Found!")
			)
			edt.text=""
		)
		fn copyRingsPose=
		(
			local this_node = (refs.dependentNodes this)[1]
			struct RING_DATA (nam,pos,rot,rad)
			local RD = #()
			for o in this_node.children do
			(
				local nam = o.name
				local pos =  o.pos
				local rot =  [o.rotation.x_rotation, o.rotation.y_rotation, o.rotation.z_rotation]
				local rad = o.circle_radius
				RD += #(RING_DATA nam pos rot rad)
			)
			morphCollectorRingData=RD
		)
		fn pasteRingsPose =
		(
			if morphCollectorRingData == undefined do return false
			local nam=#()
			local pos=#()
			local rot=#()
			local rad=#()
			for d in morphCollectorRingData do
			(
				local ring = getNodeByName (d.nam as string)
				if ring != undefined do
				(
					ring.pos = d.pos; ring.circle_radius = d.rad; ring.delegate.radius=d.rad;
					ring.rotation.x_rotation = d.rot.x
					ring.rotation.y_rotation = d.rot.y
					ring.rotation.z_rotation = d.rot.z
					
					append nam d.nam
					append pos d.pos
					append rot  d.rot
					append rad d.rad
				)
			)
			local sel  = pose_list.selection
			elementData #pos sel data:pos
			elementData #rot sel data:rot
			elementData #rad sel data:rad
			renameSelectedItem()
		)
		fn assingPose=
		(
			local sel  = pose_list.selection
			renameSelectedItem()
			--get rings data and fill param tabs
			local this_node = (refs.dependentNodes this)[1]
			local nam=#()
			local pos=#()
			local rot=#()
			local rad=#()
			for o in this_node.children do
			(
				append nam o.name
				append pos o.pos
				append rot  [o.rotation.x_rotation, o.rotation.y_rotation, o.rotation.z_rotation]
				append rad o.circle_radius
			)
			ring_names=nam
			--assing arrays to param tab holders
			elementData #pos sel data:pos
			elementData #rot sel data:rot
			elementData #rad sel data:rad
		)
		fn clearPose=
		(
			local sel  = pose_list.selection
			pose_names[sel] ="empty"
			pose_list.items = pose_names as array
			--clear tab holders
			elementData #pos sel data:#()
			elementData #rot sel data:#()
			elementData #rad sel data:#()
		)
		fn loadPose sel=
		(
			local this_node = (refs.dependentNodes this)[1]
			if classOf this_node != MorphDummy do return false
			local pos=elementData #pos sel
			local rot=elementData #rot sel
			local rad=elementData #rad sel
			if pos.count == 0 do return false
			for i=1 to ring_names.count do 
			(
				local ring = getNodeByName ring_names[i]
				if classOf ring == MorphTagger do
				(
					ring.pos = pos[i]
					ring.circle_radius = rad[i]; ring.delegate.radius=rad[i];
					ring.rotation.x_rotation = rot[i].x; ring.rotation.y_rotation = rot[i].y; ring.rotation.z_rotation = rot[i].z
				)
			)
		)
		fn collectPoseNames=
		(
			local items=#("empty","empty","empty","empty","empty","empty","empty","empty","empty","empty")
			for i=1 to items.count where pose_names[i] != undefined do items[i] = pose_names[i]
			pose_list.items = items
			pose_names = items
		)
		on params open do (collectPoseNames())
		on btn_add pressed do (assingPose())
		on btn_del pressed do (clearPose())
		--on pose_list selected sel do (edt.text = pose_list.selected)
		on pose_list doubleClicked sel do (loadPose sel)
		on btn_cop pressed do (copyRingsPose())
		on btn_pas pressed do (pasteRingsPose())
	)
	on getDisplayMesh do  
	(
		if (meshObj == undefined) do 
		(
			meshObj = createInstance box length:size width:size height:size mapCoords:false --wirecolor:green name:(uniqueName "Morph_Collector_")
			lastSize = size
		)
		if size != lastSize do  
		(
			meshObj.length=size
			meshObj.width=size
			meshObj.height=size
			lastSize = size
		)
		meshObj.mesh
	)
	on attachedToNode obj do
    (
		print "attached node to obj"
		obj.renderable = off
		obj.wirecolor = green
		obj.name=(uniqueName "Morph_Collector_")
    )
	tool create 
	( 
		on mousePoint click do 
		(
			viewTM = getCPTM()
			nodeTM = (transMatrix worldPoint) * (inverse viewTM)
			#stop 
		)
	) 
)