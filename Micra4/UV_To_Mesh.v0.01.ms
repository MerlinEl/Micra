 
 
 /**
 *@Author   Jorge Rodríguez | jorge@polytools3d.com	
 *@Modify MerlinEl
 */
 try (destroydialog ::RO_UVW_MESH) catch()
  rollout RO_UVW_MESH "UVW Mesh v0.5" width:136 height:180
  (
  	local sourcenode
  	
  	pickbutton bt_pick "Pick Object" pos:[8,8] width:120 height:24
  	dropDownList ddl_channel "UVW Channel:" pos:[8,35] width:120 height:40 enabled:false
  
  	checkbox chk_rs "Use Real Scale" pos:[8,78] width:120 height:16 checked:true enabled:false
  	spinner spn_size "Size: " pos:[8,100] fieldwidth:81 range:[0.1,1e5,100.0] type:#worldunits enabled:false
  	
  	checkbox chk_fix "Fix Elements" pos:[8,120] width:120 height:16 checked:true enabled:false
  	button bt_build "Build" pos:[8,140] width:120 height:32 enabled:false
  	
  	fn BuildUvMesh node channel:1 fixelements:false size:1.0 realscale:true = 
  	(
  		local m1 = snapshotasmesh node
  		local numtverts = meshop.getnummapverts m1 channel
  		local getmapvert = meshop.getmapvert
  		local getmapface = meshop.getmapface
  		local verts = for j = 1 to numtverts collect (getmapvert m1 channel j)*[size,size,0]
  		local geoarea = meshop.getfacearea m1 #{1..m1.numfaces}
  		
  		meshop.setnumverts m1 numtverts
  		meshop.setvert m1 #{1..numtverts} verts
  		
  		for j = 1 to m1.numfaces do
  		(
  			face = getmapface m1 channel j
  			setface m1 j face[1] face[2] face[3]
  		)
  
  		if fixelements do
  		(
  			local m2 = snapshotasmesh node
  			local m3 = copy m1
  			
  			for j = 1 to m1.numfaces do
  			(
  				f1 = getface m1 j; f2 = getface m2 j
  				
  				setvert m3 (f1[1]) (getvert m2 f2[1])
  				setvert m3 (f1[2]) (getvert m2 f2[2])
  				setvert m3 (f1[3]) (getvert m2 f2[3])
  			)
  			
  			mesh mesh:m3
  			delete m2
  			delete m3
  		)
  		
  		if realscale == true do
  		(
  			uvwarea = meshop.getfacearea m1 #{1..m1.numfaces}
  			factor = sqrt (geoarea/uvwarea)
  			scale m1 [factor,factor,0]
  		)
  		
  		mesh mesh:m1
  		delete m1
  		gc light:true		
  		
  	)
  	
  	fn UpdateUI flag arg items:#() =
  	(
  		ddl_channel.enabled = flag
  		chk_fix.enabled = flag
  		bt_build.enabled = flag
  		chk_rs.enabled = flag
  		spn_size.enabled = flag
  		
  		bt_pick.caption = arg
  		ddl_channel.items = items
  		
  		if flag do spn_size.enabled = not chk_rs.checked
  	)
  	
  	on chk_rs changed state do spn_size.enabled = not state
  	
  	on bt_pick picked node do
  	(
  		if isKindOf node GeometryClass do
  		(
  			m = snapshotasmesh node
  			channels = for j = 1 to meshop.getnummaps m where (meshop.getmapsupport m j) collect j
  			
  			if channels.count > 0 then
  			(
  				UpdateUI true node.name items:(for j in channels collect j as string)
  				sourcenode = node
  			)else(
  				messagebox (node.name + " has no UVW channels.") title:"UVW Channels Not Found"
  				UpdateUI false "Pick Object"
  			)
  		)
  	)
  	
  	on bt_build pressed do
  	(
  		if isdeleted sourcenode == false then
  		(
  			setwaitcursor()
  			uvwchannel = ddl_channel.selected as integer
  			fix = chk_fix.checked
  			rs = chk_rs.checked
  			size = spn_size.value
  			BuildUvMesh sourcenode channel:uvwchannel fixelements:fix size:size realscale:rs
  			if fix do hide sourcenode
  			setarrowcursor()
  		)else(
  			messagebox (bt_pick.caption + " was deleted") title:"Node Deleted"
  			UpdateUI false "Pick Object"
  			sourcenode = undefined
  		)
  	)
  	
  )
  createdialog RO_UVW_MESH style:#(#style_toolwindow, #style_sysmenu)
  )