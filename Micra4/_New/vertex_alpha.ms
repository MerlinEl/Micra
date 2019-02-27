fn displayAlpha obj = (

	obj.vertexColorType = #alpha
	obj.showVertexColors = true
)
fn growVertSel obj sel iterations = (
	
	for i = 1 to iterations do sel = polyop.getVertsUsingFace obj (polyop.getFacesUsingVert obj sel)
	return sel
)
fn blendVertexAlpha val_a val_b iterations:1 = (

	obj = (selection as array)[1]
	if obj == undefined do return false
	if classOf obj != Editable_Poly do convertToPoly obj	
	vsel_1 = polyOp.getVertSelection obj
	if (vsel_1 as array).count == 0 do return false
	suspendEditing()
	vsel_2 = growVertSel obj vsel_1 1
	vsel_intersection = vsel_2 - vsel_1
	convertToMesh obj
	meshop.setVertAlpha obj -2 vsel_1 val_a
	meshop.setVertAlpha obj -2 vsel_intersection val_b
	update obj
	convertToPoly obj
	resumeEditing()
	subobjectLevel = 1
	displayAlpha obj
	--polyOp.setVertSelection obj vsel_intersection
)
blendVertexAlpha 0.2 0.5





/*

fn setVertAlpha obj val = ( --val 0.0 - 1.0
	
	max modify mode
	subobjectLevel = 1
	local mesh_obj  = case (classOf obj)  of (
		
		Editable_Poly: (--obj.mesh
				
			local mod_emesh = Edit_Mesh()
			addModifier obj mod_emesh
		--	mod_emesh
		--	obj.mesh
			modpanel.getCurrentObject()
		)
		Editable_Mesh:obj
	)
	local vertlist = mesh_obj.selectedverts
	--for v in vertlist do meshop.setVertAlpha mesh_obj -2 #(4) 0.3
	meshop.setVertAlpha mesh_obj -2 vertlist val
	--meshop.setVertAlpha $.mesh -2 #{1..50} 0.6 --must be editable mesh
	update mesh_obj
)
obj = $
val = 0.5
displayAlpha $
setVertAlpha $ 0.5
*/


/*
gco = modPanel.getCurrentObject()
gco.getSelection #Vertex


verts = case (classOf obj) of
(
	Editable_Poly: polyOp.getVertSelection obj
	Edit_Poly: obj.getSelection #Vertex
obj.selectedverts
	default: #{}
)



		max modify mode
		editPolyMod = Edit_Poly()
		addModifier o editPolyMod
		convertToPoly myBox
		editPolyMod.setSelection #Vertex #{1..editPolyMod.GetNumVertices()}
		editPolyMod.ButtonOp #DeleteVertex
		editPolyMod.Attach myBox
		max create mode
*/


/*
struct VERTEX_CHANNEL (
	Soft_Selection	= 1,
	Vertex_weights	= 2, --for NURMS MeshSmooth
	Vertex_Alpha	= 3,
	Cornering		= 4  --values for subdivision use
)
mcVertChannel = VERTEX_CHANNEL()
mcVertChannel.Vertex_Alpha


$.vertexColorType = #alpha
$.showVertexColors = true
meshop.supportVAlphas $.Mesh
meshop.getVDataChannelSupport $.Mesh mcVertChannel.Vertex_Alpha
meshop.setNumVDataChannels $.Mesh mcVertChannel.Vertex_Alpha keep:true --false discard other channels data
meshop.setVDataChannelSupport $.Mesh mcVertChannel.Vertex_Alpha true
meshop.setVAlpha $.Mesh #{1..5} 0.5

meshop.supportVAlphas $
meshop.getVDataChannelSupport $ mcVertChannel.Vertex_Alpha
meshop.setNumVDataChannels $ mcVertChannel.Vertex_Alpha keep:true --false discard other channels data
meshop.setVDataChannelSupport $ mcVertChannel.Vertex_Alpha true
meshop.setVAlpha $ #{1..10} 0.5
update $
meshop.freeVData $ 3

vertlist = $.selectedverts
polyop.setVertColor $ -2 vertlist [0.2, 0.2, 0.2]
polyop.setVertColor $ -2 vertlist [0.1, 0.1, 0.1]
polyop.setVertColor $ -2 vertlist [0, 0, 0]
polyop.setVertColor $ -2 vertlist [0, 0, 0]
*/

/**
*@Usage
	local col0 = [1,1,1] --100% alpha
	local col1 = [0.5,0.5,0.5] --50% alpha
	local col2 = [0.2,0.2,0.2] --20% alpha
	--min = 0.0 max = 1.0

fn setRandomVertexAlpha float_min float_max = ( 
	
	local obj = (selection as array)[1]
	if obj == undefined do return false
	local channel_index = polyOp.getNumVDataChannels obj
	if channel_index == 0 do (
		
		polyOp.setNumVDataChannels obj 2 keep:true
		polyOp.setVDataChannelSupport obj 2 true
	)
	local sel_verts = polyop.getVertSelection obj as array
	for v in sel_verts do (
		
		local random_float = random float_min float_max
		--format "random float:%\n" random_float
		local p2 = [random_float, random_float, random_float] 
		polyOp.setMapVert obj -2 v p2
	)
	--update
	$.vertexColorType = #color
	update $
	$.vertexColorType = #alpha
	$.showVertexColors = true
	update $
	
)*/

/**
*@Usage
	COLORS:
	local col0 = [1,1,1] --100% alpha
	local col1 = [0.5,0.5,0.5] --50% alpha
	local col2 = [0.2,0.2,0.2] --20% alpha
	--min = 0.0 max = 1.0
	CHANNELS:
	-2 - alpha 
	-1 - illum 
	0 - diffuse 
	1..1000 -maping coordinates

fn setRandomVertexAlpha float_min float_max = ( 
	
	local obj = (selection as array)[1]
	if obj == undefined do return false
	obj.vertexColorType = #alpha
	obj.showVertexColors = true
	local channel_index = polyOp.getNumVDataChannels obj
	if channel_index != 2 do (
		
		polyOp.setNumVDataChannels obj 2 keep:true
		polyOp.setVDataChannelSupport obj 2 true
	)
	local sel_verts = (getVertSelection obj.mesh) as array
	for v in sel_verts do (
		
		local random_float = random float_min float_max
		local p2 = [random_float, random_float, random_float] 
		meshop.setMapVert obj.mesh -2 v p2
	)
	update obj
)

obj = $
fn updateAlpha obj = (
	
	suspendEditing()
	convertToMesh obj
	convertToPoly obj
	resumeEditing()
	subobjectlevel = 1
	obj.vertexColorType = #color
	update obj
	obj.vertexColorType = #alpha
	update obj
)
*/
/*
setRandomVertexAlpha 0.1 0.4
setRandomVertexAlpha 0.7 1.0
setRandomVertexAlpha 0.8 1.0
update $

polyOp.setNumVDataChannels $ 2 keep:true
polyOp.setVDataChannelSupport $ 2 true
*/




/*
s = sphere segs:4 --create a sphere
convertToMesh s --collapse to Editable Mesh
s.showVertexColors = true --enable Vertex Colors in Viewport
s.vertexColorType = #alpha --set Vertex Color type to Alpha
mesh_verts = s.numverts
meshop.setVertAlpha s -2 #(1, mesh_verts) 0.0
meshop.setVertAlpha s -2 #(4) 0.3



s = $
mesh_verts = s.mesh.numverts
meshop.setVertAlpha s -2 #(1, mesh_verts) 0.0
meshop.setVertAlpha s -2 #(83) 0.3
*/