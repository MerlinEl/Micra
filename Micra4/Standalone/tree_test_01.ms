struct LAYER_DATA (key, val, children)
fn getSelectedLayer = (((SceneExplorerManager.GetActiveExplorer()).SelectedItems())[1])
fn getOrCreateLayerFromName layer_name = (
		
		local la = layermanager.getLayerFromName layer_name
		if la == undefined do la = layermanager.newLayerFromName layer_name
		la
)
fn getLayersTree main_layer &layerTree &lvl = (

	local sub_layers = #()
	layerTree[lvl] = LAYER_DATA main_layer.name main_layer sub_layers
	local cnt = main_layer.getNumChildren()
	if cnt == 0 do return false
	for i = 1 to cnt do (

		local sub_layer = main_layer.getChild i --<MixinInterface:LayerProperties>
		local sub_sub_layers = #()
		append sub_layers (LAYER_DATA sub_layer.name sub_layer sub_sub_layers) --append to sub_layers(child list)
		if sub_layer.getNumChildren() > 0 then ( --if there is more children recurse --> sub_sub_layers

			local lvl_sub = 1
			getLayersTree sub_layer &sub_sub_layers &lvl_sub
			
		) else ( --if not sub layers, simple append to sub_layers(child list)
			
			append sub_layers (LAYER_DATA sub_layer.name sub_layer #())
		)
	)
)
fn printMultiArray obj &tab = (
	
	--format "% level:% children:%\n" (tab + obj.key) tab.count obj.children.count --obj \n\tobj:%
	if obj.children.count > 0 do (
		local tab_sub = tab + "\t"
		for o in obj.children do (
			
			format "% level:%\n" (tab_sub + o.key) tab_sub.count
			if o.children.count > 0  do printMultiArray o &tab_sub
		)
	)
)
fn cloneLayerHierarchy main_layer = (

	local lvl = 1
	local layerTree = #()
	getLayersTree main_layer &layerTree &lvl
	format "get layers tree:%\n\tmax lvl:%\n" layerTree lvl
	layerTree[1]
)

main_layer = getSelectedLayer() --ReferenceTarget:BaseLayer
lt = cloneLayerHierarchy main_layer
tab = ""
printMultiArray lt &tab


/*
main_layer.name
main_layer.getNumChildren()
sub_layer = main_layer.getChild 1
sub_layer.getNumChildren()
sub_layer = sub_layer.getChild 1
classOf main_layer
superClassOf main_layer
*/
/* 
--------------------------------------------
          WANTED RESULT
--------------------------------------------
lt.key --"lh_loc_steamboat_LOD0"

lt.children.count --2
lt.children[1].key --"steamboat_deck01_LOD0"
lt.children[1].children.count --2
lt.children[1].children[1].key --exterior_01_lod0
lt.children[1].children[2].key --interior_01_lod0

lt.children[2].key --"steamboat_deck02_LOD0"
lt.children[2].children.count --2
lt.children[2].children[1].key --exterior_02_lod0
lt.children[2].children[2].key --interior_02_lod0
*/
