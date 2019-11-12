--------------------------------------------------------------------------------
/* mcUvToMesh by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Author	Jorge Rodríguez | jorge@polytools3d.com	
*@Modify	MerlinEl 2019

*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_UV_TO_MESH_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn buildUvMesh obj channel:1 fixelements:false size:1.0 realscale:true = (
	
  		local m1 = snapshotasmesh obj
		local uv_mesh = undefined
		local mapping_support = (meshop.getnummaps m1 > 0 and meshop.getmapsupport m1 channel)
		if not mapping_support do (
		
			delete m1
			return (mcMsgList.warn "not_map" pre:(obj.name+"_") mbox:false)
		)
  		local numtverts = meshop.getnummapverts m1 channel
  		local getmapvert = meshop.getmapvert
  		local getmapface = meshop.getmapface
  		local verts = for j = 1 to numtverts collect (getmapvert m1 channel j)*[size,size,0]
  		local geoarea = meshop.getfacearea m1 #{1..m1.numfaces}
  		
  		meshop.setnumverts m1 numtverts
  		meshop.setvert m1 #{1..numtverts} verts
  		
  		for j = 1 to m1.numfaces do (
		
  			face = getmapface m1 channel j
  			setface m1 j face[1] face[2] face[3]
  		)

  		if fixelements == true do
  		(
  			local m2 = snapshotasmesh obj
  			local m3 = copy m1
  			
  			for j = 1 to m1.numfaces do
  			(
  				f1 = getface m1 j; f2 = getface m2 j
  				
  				setvert m3 (f1[1]) (getvert m2 f2[1])
  				setvert m3 (f1[2]) (getvert m2 f2[2])
  				setvert m3 (f1[3]) (getvert m2 f2[3])
  			)
  			
  			uv_mesh = mesh mesh:m3 pos:obj.pos
  			delete m2
  			delete m3
  		)

  		if realscale  == true do (
		
  			local uvwarea = meshop.getfacearea m1 #{1..m1.numfaces}
  			local factor = sqrt (geoarea/uvwarea)
  			scale m1 [factor,factor,0]
  		)	
		
		uv_mesh = mesh mesh:m1 pos:obj.pos
		delete m1
		gc light:true	
		--add morpher modifier
		local morph_mod = Morpher ()
		select uv_mesh
		modPanel.addModToSelection morph_mod ui:on
		WM3_MC_BuildFromNode morph_mod 1 obj
		uv_mesh
  	),
	fn morpSelectedObjectsToUvs uv_channel:1 = undo "Extract Geometry UVs" on (
	
		if selection.count == 0 do return (mcMsgList.warn "not_sel")
		setwaitcursor()
		local fix_elements = false
		local real_scale = true
		local sel_max_x = selection.max.x
		for o in selection do (
		
			--progress only with geomtry objects
			if superClassOf o != GeometryClass do (
			
				mcMsgList.warn "not_geo" pre:(o.name+"_") mbox:false
				continue
			)
			--clone all selected object 
			local obj_clone = mcPolyMap.splitObjectByUVElements o Expand:false
			obj_clone.pos.x = sel_max_x + (sel_max_x / 3) -- move clone to right from original
			--build uvs meshes
			buildUvMesh obj_clone channel:uv_channel fixelements:fix size:100.0 realscale:real_scale
			if fix_elements do (hide obj_clone)
		) 
		setarrowcursor()
	)
	
	/*<end>*/
)	
 --create instance
Global mcUvToMesh = mcStructMan.instanceStructure MICRA_UV_TO_MESH_STRUCTURE "mcUvToMesh"

/*
mcUvToMesh.morpSelectedObjectsToUvs()
*/
