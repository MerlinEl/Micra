--------------------------------------------------------------------------------
/* gLs3dQuickMaterials by Orien 2019 */
--------------------------------------------------------------------------------
/*
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
struct sLs3dQuickMaterials	(
	
	--variables
	mcCurbCreatorDialog = undefined,
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn warningMsg msg_key = (
	
		local msg = case msg_key of (

			"call_help"		: "Something wierd was happen. Call Merlin to help you :-)"
			"not_poly"		: "Editable Poly object must be selected."
			"not_spline"		: "Spline object must be selected."
			"not_vsel"		: "Select some vertices to progress."
			"not_esel"		: "Select some edges to progress."
			"not_fsel"			: "Select some faces to progress."
			"not_termat"		: "Missing terrain material."
			"no_profile"		: "Missing spline profile.\nFirst create one spline(profile) with name curb_"
			"not_edge_level"	: "Subobject level must be in Edges."
			"not_sweep"		: "Must be Spline with sweep Modifier applyed."
			default			: "Unknown Error...."
		)
		messageBox msg title:"Warning:"
		false
	),
	fn closeAllComponents = (
	
		if mcCurbCreatorDialog != undefined do destroyDialog mcCurbCreatorDialog
	),
	fn createCurbProfile sp_name = (

		local points_array = #([9,-3.90039,-0.0650024], [9,3.80273,0.0650024], [-9,3.90039,0.0650024], [-9,-3.90039,-0.0650024])
		local sps = SplineShape pos:points_array[1]
		sps.name = sp_name
		mcSpline.splineFromPoints sps 1 points_array type:#corner
		updateShape sps
		sps.wirecolor = green
		sps.pivot = (sps.min+sps.max)/2
		return sps
	),
	fn addSweepMod sp_path sp_profile = (

		local sweep_mod = sweep ()
		modPanel.addModToSelection sweep_mod ui:on
		sweep_mod.CustomShape = 1
		sweep_mod.shapes[1] = sp_profile.baseObject
		--sweep_mod.CustomShapeName = "curb_01_profile_test"
		sweep_mod.GenerateMappingCoords = on
		sweep_mod.realWorldMapSize = on
	),
	fn fixTextureStretch terrain_mat mat_id = (

		--TODO 
		-- calculate stretch X- Y of mapping by texture propotion
		-- calculate mapping size from pixel density (or from polygon area)

		local mod_uvw = Unwrap_UVW () 
		modPanel.addModToSelection mod_uvw ui:on
		mod_uvw.unwrap2.setTVSubObjectMode 3
		mod_uvw.selectByMatID mat_id	
		mod_uvw.ScaleSelectedCenter .06 1 --fix Y stretch
		mod_uvw.ScaleSelectedCenter 0.03 0	--fix scale x y
		mod_uvw.MoveSelected (0.5 - (mod_uvw.getSelCenter())) --move to center
	),
	fn createSplineFromEdges obj selected:true = (
		
		local curb_name = uniqueName "curb_"
		obj.createShape curb_name off obj
		if subobjectlevel != undefined do subobjectlevel = 0
		local curb_spline = getNodeByName curb_name
		if selected do select curb_spline
		curb_spline.pivot = (curb_spline.min+curb_spline.max)/2 --move pivot to center
		curb_spline
	),
	fn mapCurb obj mat_id collapsed:false = (
	
		if (classOf (modPanel.getCurrentObject()) != sweep)  do return (warningMsg "not_sweep")
		local terrain_mat = currentMaterialLibrary["bc_terrain_main"]
		if terrain_mat == undefined do return return (warningMsg "not_termat")
		obj.material = terrain_mat
		local mat_mod = Materialmodifier()
		modPanel.addModToSelection mat_mod ui:on
		mat_mod.materialID = mat_id
		--add unwrap modifier and fix texure stretch
		fixTextureStretch terrain_mat mat_id
		if collapsed do convertToPoly obj
	),
	fn createCurb obj mat_id collapsed:true customSpline:false profileObj:undefined mapping:true = (
		
		undo "Create Curb" on (
		
			local curb_spline = undefined
			if customSpline then (
				
				--validation check
				if classOf obj != SplineShape and classOf obj != Line  do return (warningMsg "not_spline")
				curb_spline = obj
				
			) else (
			
				--validation check
				if classOf obj != Editable_Poly do return (warningMsg "not_poly")
				local esel = polyOp.getEdgeSelection obj 
				if esel.numberset == 0 do return (warningMsg "not_esel")
				--create spline from selected edges
				curb_spline = createSplineFromEdges obj
			)
			--create curb profile if not exists
			local curb_profile = if profileObj != undefined then (profileObj) else (getNodeByName "curb_01_profile")
			if curb_profile == undefined do curb_profile = createCurbProfile "curb_01_profile"
			--add sweep and convert to poly
			addSweepMod curb_spline curb_profile
			--add terrain material with wanted id
			if mapping do mapCurb curb_spline mat_id collapsed:collapsed
		)
	),
	fn redrawSplineAtZero sp = (
	
		if classOf sp != SplineShape and classOf sp != Line do return (warningMsg "not_spline")
		local shape_name = sp.name
		local points_array = mcSpline.pointsFromSpline sp
		local new_sp = mcSpline.splinesFromPoints points_array type:#corner color:green centerPivot:false
		--new_sp.pos = sp.pos
		delete sp
		select new_sp
		new_sp.name = shape_name
		messageBox "Spline has been redrawn." title:"Warning:"
		new_sp
	),
	fn createCustomCurb = ( --mat_id
	
		if mcCurbCreatorDialog != undefined do destroyDialog mcCurbCreatorDialog
		rollout mcCurbCreatorDialog "Curb Creator" width:228 height:304
		(
			GroupBox 'grp1' "1 ) Select Edges or Spline:" pos:[4,4] width:220 height:20 align:#left
			listbox 'lbx_profiles' "" pos:[8,48] width:208 height:10 align:#left
			GroupBox 'grp2' "2 ) Chosse a Profile:" pos:[4,28] width:220 height:164 align:#left
			button 'btn_create_curb' "SWEEP            and            MAP  " pos:[8,276] width:216 height:24 align:#left
			GroupBox 'grp3' "3 ) Type Material ID:" pos:[4,196] width:220 height:48 align:#left
			label 'lbl2' "ID:" pos:[12,220] width:20 height:16 align:#left
			spinner 'spn_mat_id' "" pos:[132,220] width:84 height:16 range:[0,1000,442] type:#integer scale:1 align:#left
			button 'btn_focus' "Focus" pos:[168,8] width:56 height:16 align:#left
			button 'btn_sweep_curb' "SWEEP" pos:[8,248] width:96 height:24 align:#left
			label 'lbl3' "and" pos:[108,252] width:20 height:16 align:#left
			button 'btn_map_curb' "MAP" pos:[128,248] width:96 height:24 align:#left
			local spline_path = undefined
			local spline_profile = undefined
			local poly_object = undefined
			local old_sel = undefined
			fn warningMsg msg_key = (::gLs3dQuickMaterials.warningMsg msg_key)
			fn isSpline obj = (classOf obj == SplineShape or classOf obj == Line)
			fn isCurbProfile obj = (
				
				isSpline obj and findString obj.name "curb" != undefined
			)
			fn focusToOldSel = (
			
				if old_sel != undefined then (
				
					select old_sel; max zoomext sel
				)  
			)
			fn getSplinePath obj = (
				
				case classOf selection[1] of (
				
					Editable_Poly : (
			
						if (subobjectlevel != 2 and subobjectlevel != 3) do return (warningMsg "not_edge_level")
						poly_object = obj
					)
					SplineShape : (
								
						if not (isSpline obj) do return (warningMsg "not_spline")
						spline_path = obj
					) 
				)
			)
			fn getSplineProfile = (
				
				if lbx_profiles.items.count == 0 do return (warningMsg "no_profile")
				spline_profile = (getNodeByName lbx_profiles.selected)
				if not (isSpline spline_profile) do return (warningMsg "not_spline")
			)
			fn focusSplineProfile = (
			
				if lbx_profiles.items.count == 0 do return (warningMsg "no_profile")
				local sp = (getNodeByName lbx_profiles.selected)
				if not (isSpline sp) do return (warningMsg "not_spline")
				if subobjectlevel != undefined do subobjectlevel = 0 --exit from any subobject level before select another obj
				if old_sel == undefined do old_sel = selection as Array --keep old selection in memory
				select sp
				sp.isHidden = false
				max zoomext sel
			)
			fn createCurb mapping:true = (
			
								
				getSplinePath selection[1]
				getSplineProfile()
			
				format "createCurb >\n\tspline_profile:%\n\tspline_path:%\n\tpoly_object:%\n" spline_profile spline_path poly_object
				if spline_path != undefined then ( --path from custom spline
					
					if not (isSpline spline_path) or not (isSpline spline_profile) do return (warningMsg "call_help")
					::gLs3dQuickMaterials.createCurb spline_path spn_mat_id.value customSpline:true profileObj:spline_profile mapping:mapping 
				
				) else ( --path from edges
	
					if not (isSpline spline_profile) do  return (warningMsg "no_profile")
					::gLs3dQuickMaterials.createCurb poly_object spn_mat_id.value customSpline:false profileObj:spline_profile mapping:mapping 
				)
			)
			fn init = (
				
				lbx_profiles.items = for o in objects where isCurbProfile o collect o.name 
			)
			on mcCurbCreatorDialog open do init()
			-- on lbx_profiles selected sel do ()
			on lbx_profiles doubleClicked sel do (focusSplineProfile())
			on btn_create_curb pressed do (createCurb())
			on btn_map_curb pressed do ( undo "Map Curb" on (::gLs3dQuickMaterials.mapCurb selection[1] spn_mat_id.value collapsed:true) )
			on btn_sweep_curb pressed do (createCurb mapping:false)
			on btn_focus pressed do (focusToOldSel())
		)
		createDialog mcCurbCreatorDialog
	)
	/*<end>*/
)	
 --create instance
Global gLs3dQuickMaterials = sLs3dQuickMaterials()
