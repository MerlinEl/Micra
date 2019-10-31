fn warningMsg msg_key = (
	
	local msg = "" 
	case msg_key of (

		"not_poly"		: "Editable Poly object must be selected"
		"not_vsel"		: "Select some vertices to progress"
		"not_esel"		: "Select some edges to progress"
		"not_fsel"		: "Select some faces to progress"
		"not_termat"	: "Missing terrain material"
		default			: "Unknown Error...."
	)
	messageBox msg title:"Warning:"
	false
)


fn createCrubProfile sp_name = (

	local points_array = #([9,-3.90039,-0.0650024], [9,3.80273,0.0650024], [-9,3.90039,0.0650024], [-9,-3.90039,-0.0650024])
	local sps = SplineShape pos:points_array[1]
	sps.name = sp_name
	mcSpline.splineFromPoints sps 1 points_array type:#corner
	updateShape sps
	sps.wirecolor = green
	sps.pivot = (sps.min+sps.max)/2
	return sps
)

fn addSweepMod sp_path sp_profile = (

	local sweep_mod = sweep ()
	modPanel.addModToSelection sweep_mod ui:on
	sweep_mod.CustomShape = 1
	sweep_mod.shapes[1] = sp_profile.baseObject
	--sweep_mod.CustomShapeName = "crub_01_profile_test"
	sweep_mod.GenerateMappingCoords = on
	sweep_mod.realWorldMapSize = on
)

fn fixTextureStretch mat_id = (

	local mod_uvw = Unwrap_UVW () 
	modPanel.addModToSelection mod_uvw ui:on
	mod_uvw.unwrap2.setTVSubObjectMode 3
	mod_uvw.selectByMatID mat_id	
    mod_uvw.ScaleSelectedCenter .06 1 --fix Y stretch
	mod_uvw.ScaleSelectedCenter 0.03 0	--fix scale x y
	mod_uvw.MoveSelected (0.5 - (mod_uvw.getSelCenter())) --move to center
)

fn createSplineFromEdges obj selected:true = (
	
	local crub_name = uniqueName "crub_"
	obj.createShape crub_name off obj
	subobjectlevel = 0
	local crub_spline = getNodeByName crub_name
	if selected do select crub_spline
	crub_spline
)

fn createCrub obj mat_id = (
	
	--validation check
	if classOf obj != Editable_Poly do return (warningMsg "not_poly")
	local esel = polyOp.getEdgeSelection obj 
	if esel.numberset == 0 do return (warningMsg "not_esel")
	--create spline from selected edges
	local crub_spline = createSplineFromEdges obj
	--create crub profile if not exists
	local crub_profile = getNodeByName "crub_01_profile"
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
	--convertToPoly crub_spline
	--crub_profile = $ --pick current selected Poly object
)
/*
sp = $
mat_id = 442
obj = selection[1]
*/

undo "Create Crub" on (createCrub selection[1] 442)
