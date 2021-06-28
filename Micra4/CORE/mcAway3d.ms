--------------------------------------------------------------------------------
/* mcAway3d by Orien 2021 */
--------------------------------------------------------------------------------
/*
*@Usage > Save vertex animation to file
*@Used Structures
*
*@Used Objects
*
*/
struct MICRA_AWAY3D
(
	private
	assets_dir = "E:/Work/NováŠkola/@ASSETS",
	init_positions,
	-- e.g. centimeter in max -> meter in away3D => scale = ????
	unit_scale = 0.01, --must check it
	public
	fn getSource = getSourceFileName(), --get path of this script
	fn readVertexAnimationAtFirstFrame poly_obj = (
		
		init_positions = #()
		local mesh_tri = snapshotAsMesh poly_obj
		for i = 1 to mesh_tri.numverts do (
			
			local pos = meshop.getVert mesh_tri i
			append init_positions pos
		)
	),
	--Exports vertex data to file
	fn exportVertices frame mesh_tri out_file = (
	
-- 		format "exporting frame:% vetrs:%\n" frame mesh_tri.numverts
		for i = 1 to mesh_tri.numverts do (
			local pos = getVert mesh_tri i
			-- get vert pos difference from 1 frame (local transform)
			local offset = pos - init_positions[i]
-- 			offset *= unit_scale
			-- write offets in to file (way have waped blue(z) and green(y) axis)
			format "%,%,%" offset.x offset.z offset.y to:out_file
			if i < mesh_tri.numverts do format "," to:out_file
		) 
	),
	fn exportVertexAnimation poly_obj  fpath = (
		
		local out_file = createfile fpath
		--Create a text file for receiving the data
		local anim_start = int(animationRange.start)
		local anim_end = int(animationRange.end)
		readVertexAnimationAtFirstFrame poly_obj
		--format "anim_start:%,anim_end:%,verts_count:%" anim_start anim_end mesh_tri.numverts to:out_file
		--get the mesh data from the selected node at time t.
		for frame = anim_start to anim_end do ( --anim_end
		  
			at time frame 
			local mesh_tri = snapshotAsMesh poly_obj
			--Exports mesh data from a node 'n' at time 't' to file 'f'	
			exportVertices frame mesh_tri out_file
			if frame < anim_end do format ";" to:out_file
			delete mesh_tri
		)
		--Close the text file
		close out_file
	),
	fn export3DsObject poly_obj fpath = (
		
		local mesh_tri = snapshotAsMesh poly_obj
		local mesh_obj = Editable_mesh() --create an empty EMesh
		mesh_obj.mesh = mesh_tri --assign TriMesh value to the EMesh
		convertTo mesh_obj Editable_Poly --collapse to EPoly
		select mesh_obj
		delete mesh_tri --free up memory
		
		local theClasses = exporterPlugin.classes
		local _3dsIdx = 1 --findItem theClasses 3D_StudioExporterPlugin
		print export_fpath
		exportFile fpath #noprompt selectedOnly:on using:theClasses[_3dsIdx]
			
		select poly_obj
		delete mesh_obj
	),
	fn export3DsObjectAndVertexAnimation = (
		
		at time 0 
		if selection.count != 1 do return false
		local poly_obj = selection[1]

		local export_3ds_file = assets_dir + "/models/objects/flag.3ds"
		local export_ani_file = assets_dir + "/anims/vertex/flag/flag.ani"
		
		export3DsObject poly_obj export_3ds_file
		exportVertexAnimation poly_obj export_ani_file
	)
	/*<end>*/
)
 --create instance
Global mcAway3d = mcStructMan.instanceStructure MICRA_AWAY3D "mcAway3d"
mcAway3d.export3DsObjectAndVertexAnimation()