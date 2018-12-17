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
	struct RING_DATA (nam,pos,rot,rad)
	parameters pblock rollout:params 
	(
		size type:#float animatable:true ui:amount default:4.0
		pose_names type:#stringTab tabSize:0 tabSizeVariable:true
		rings_data type:#stringTab tabSize:0 tabSizeVariable:true --size limit wont work
	)
	rollout params "Parameters:"
	(
		Spinner amount "Size:" range:[1, 1e9, 40]
		group "Poses:"
		(
			listBox pose_list "" pos:[7,44] width:147 height:8  items:#()
			editText edt "" pos:[4,156] width:150 height:20 
			button btn_add "Add Pose" pos:[7,180] width:73 height:24 tooltip:"Add New Pose"
			button btn_del "Delete Pose" pos:[81,180] width:73 height:24 tooltip:"Delete Selected Pose"
			button btn_cop "Copy Pose" pos:[7,206] width:73 height:24 tooltip:"Copy Pose To Clipboard"
			button btn_pas "Paste Pose" pos:[81,206] width:73 height:24 tooltip:"Paste Pose To current Selection"
		)
		fn getRingsPose=
		(
			local this_node = (refs.dependentNodes this)[1]
			local RD = #()
			for o in this_node.children do
			(
				local nam = (o.name as name)
				local pos =  o.pos
				local rot =  [o.rotation.x_rotation, o.rotation.y_rotation, o.rotation.z_rotation]
				local rad = o.circle_radius
				RD += #(RING_DATA nam pos rot rad)
			)
			append rings_data (RD as string)
		)
		fn copyRingsPose=
		(
			local this_node = (refs.dependentNodes this)[1]
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
			/*
			morphCollectorRingData = if pose_list.items.count == 0 
				then getRingPose()
				else
				(
					ring_data_array[pose_list.selection]
				)
			*/
		)
		fn pasteRingsPose =
		(
			if morphCollectorRingData == undefined do return false
			local data = morphCollectorRingData
			local parent_dummy = selection[1]
			if classOf parent_dummy != MorphDummy do return false
			for d in data do
			(
				local ring = getNodeByName (d.nam as string)
				if ring != undefined do
				(
					ring.pos = d.pos; ring.circle_radius = d.rad; ring.delegate.radius=d.rad;
					ring.rotation.x_rotation = d.rot.x
					ring.rotation.y_rotation = d.rot.y
					ring.rotation.z_rotation = d.rot.z
				)
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
		fn dupplicatesFound items txt =
		(
			if findItemString items txt then
			(
				messageBox ("Name: [ "+ txt +" ] is used. Try something else." ) title:"Dupplicate Found!"
				return true
			)
			else return false
		)
		fn addPose=
		(
			local n = edt.text
			if n == "" or dupplicatesFound pose_list.items n do return false
			append pose_names n
			pose_list.items+=#(n)
			getRingsPose()
		)
		fn delPose=
		(
			if pose_list.items.count == 0 do return false
			local itm  = pose_list.selection
			deleteItem pose_names itm		
			deleteItem rings_data itm
			pose_list.items = pose_names as array
		)
		fn loadPose sel=
		(
			local this_node = (refs.dependentNodes this)[1]
			if classOf this_node != MorphDummy do return false
			local data = rings_data[sel]
			arr= filterstring data ","
			for i in  arr do format "data:%\n" i
			/*
			for i=1 to data.count do
			(
				local RD = execute data[i]
				
				local nam = RD.nam as string
				local pos = RD.pos
				local rot = RD.rot
				local rad = RD.rad
				local ring = getNodeByName nam
				if ring != undefined do
				(
					ring.pos = pos 
					ring.circle_radius = rad; ring.delegate.radius=rad;
					ring.rotation.x_rotation = rot.x; ring.rotation.y_rotation = rot.y; ring.rotation.z_rotation = rot.z
				)
				
			)
			*/
		)
		on params open do (pose_list.items = pose_names as array)
		on btn_add pressed do (addPose())
		on btn_del pressed do (delPose())
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