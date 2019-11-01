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
	mcCrubCreatorDialog = undefined,
	
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
			"no_profile"		: "Missing spline profile."
			default			: "Unknown Error...."
		)
		messageBox msg title:"Warning:"
		false
	),
	fn closeAllComponents = (
	
		if mcCrubCreatorDialog != undefined do destroyDialog mcCrubCreatorDialog
	),
	fn createCrubProfile sp_name = (

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
		--sweep_mod.CustomShapeName = "crub_01_profile_test"
		sweep_mod.GenerateMappingCoords = on
		sweep_mod.realWorldMapSize = on
	),
	fn fixTextureStretch mat_id = (

		local mod_uvw = Unwrap_UVW () 
		modPanel.addModToSelection mod_uvw ui:on
		mod_uvw.unwrap2.setTVSubObjectMode 3
		mod_uvw.selectByMatID mat_id	
		mod_uvw.ScaleSelectedCenter .06 1 --fix Y stretch
		mod_uvw.ScaleSelectedCenter 0.03 0	--fix scale x y
		mod_uvw.MoveSelected (0.5 - (mod_uvw.getSelCenter())) --move to center
	),
	fn createSplineFromEdges obj selected:true = (
		
		local crub_name = uniqueName "crub_"
		obj.createShape crub_name off obj
		if subobjectlevel != undefined do subobjectlevel = 0
		local crub_spline = getNodeByName crub_name
		if selected do select crub_spline
		crub_spline.pivot = (crub_spline.min+crub_spline.max)/2 --move pivot to center
		crub_spline
	),
	fn createCrub obj mat_id collapsed:true customSpline:false profileObj: undefined = (
		
		undo "Create Crub" on (
		
			local crub_spline = undefined
			if customSpline then (
				
				--validation check
				if classOf obj != SplineShape and classOf obj != Line  do return (warningMsg "not_spline")
				crub_spline = obj
				
			) else (
			
				--validation check
				if classOf obj != Editable_Poly do return (warningMsg "not_poly")
				local esel = polyOp.getEdgeSelection obj 
				if esel.numberset == 0 do return (warningMsg "not_esel")
				--create spline from selected edges
				crub_spline = createSplineFromEdges obj
			)
			--create crub profile if not exists
			local crub_profile = if profileObj != undefined then (profileObj) else (getNodeByName "crub_01_profile")
			if crub_profile == undefined do crub_profile = createCrubProfile "crub_01_profile"
			--add sweep and convert to poly
			addSweepMod crub_spline crub_profile
			--add terrain material with wanted id
			local terrain_mat = currentMaterialLibrary["bc_terrain_main"]
			if terrain_mat == undefined do return return (warningMsg "not_termat")
			crub_profile.material = terrain_mat
			local mat_mod = Materialmodifier()
			modPanel.addModToSelection mat_mod ui:on
			mat_mod.materialID = mat_id
			--add unwrap modifier and fix texure stretch
			fixTextureStretch mat_id
			if collapsed do convertToPoly crub_spline
			--crub_profile = $ --pick current selected Poly object
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
	fn createCustomCrub = ( --mat_id
	
		if mcCrubCreatorDialog != undefined do destroyDialog mcCrubCreatorDialog
		rollout mcCrubCreatorDialog "Crub Creator" width:228 height:332
		(
			GroupBox 'grp1' "Path:" pos:[4,4] width:220 height:72 align:#left
			radiobuttons 'rdo_path_type' "" pos:[12,24] width:202 height:16 labels:#("From Edges", "From Spline") default:1 columns:2 align:#left
			listbox 'lbx_profiles' "" pos:[8,104] width:208 height:10 align:#left
			button 'btn_get_spline' "Get Spline Path" pos:[12,44] width:204 height:24 enabled:false align:#left
			GroupBox 'grp2' "Profiles:" pos:[4,84] width:220 height:164 align:#left
			button 'btn_create_crub' "CREATE" pos:[8,304] width:216 height:24 align:#left
			GroupBox 'grp3' "Material:" pos:[4,252] width:220 height:48 align:#left
			label 'lbl2' "ID:" pos:[12,276] width:20 height:16 align:#left
			spinner 'spn_mat_id' "" pos:[132,276] width:84 height:16 range:[0,1000,442] type:#integer scale:1 align:#left
			local spline_path = undefined
			local spline_profile = undefined
			local poly_object = undefined
			fn warningMsg msg_key = (::gLs3dQuickMaterials.warningMsg msg_key)
			fn isSpline obj = (classOf obj == SplineShape or classOf obj == Line)
			fn isCrubProfile obj = (
				
				isSpline obj and findString obj.name "crub" != undefined
			)
			fn createCrub = (
			
				format "createCrub >\n\tspline_profile:%\n\tspline_path:%\n\tpoly_object:%\n" spline_profile spline_path poly_object
				if spline_path != undefined then ( --path from custom spline
					
					if not (isSpline spline_path) or not (isSpline spline_profile) do return (warningMsg "call_help")
					::gLs3dQuickMaterials.createCrub spline_path spn_mat_id.value customSpline:true profileObj:spline_profile
				
				) else ( --path from edges
	
					if not (isSpline spline_profile) do  return (warningMsg "no_profile")
					::gLs3dQuickMaterials.createCrub poly_object spn_mat_id.value customSpline:false profileObj:spline_profile
				)
			)
			fn getSplinePath obj = (
				
				case rdo_path_type.state of (
				
					1 : (
			
						poly_object = obj
					)
					2 : (
								
						if not (isSpline obj) do return (warningMsg "not_spline")
						btn_get_spline.text = obj.name
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
				if subobjectlevel != undefined do subobjectlevel = 0
				select sp
				max zoomext sel
			)
			fn setupUi type state = (
				--format "type:% state:%\n" type state
				case type of (
					
					#path :  btn_get_spline.enabled = (state == 2)
				) 
			)
			fn init = (
				
				lbx_profiles.items = for o in objects where isCrubProfile o collect o.name 
				getSplinePath selection[1]
				getSplineProfile()
			)
			on mcCrubCreatorDialog open do init()
			on rdo_path_type changed state do (setupUi #path state)
			on btn_get_spline pressed do (getSplinePath selection[1])
			on lbx_profiles selected sel do (getSplineProfile())
			on lbx_profiles doubleClicked sel do (focusSplineProfile())
			on btn_create_crub pressed do (createCrub())
		)
		createDialog mcCrubCreatorDialog
	)
	/*<end>*/
)	
 --create instance
Global gLs3dQuickMaterials = sLs3dQuickMaterials()
