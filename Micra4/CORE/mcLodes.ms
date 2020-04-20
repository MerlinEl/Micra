--------------------------------------------------------------------------------
/* mcLodes by Orien 2019 */
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
*@Example --> with selected lode object
	mcStructMan.import "mcLodes" "mcLodes" dir:#Core force:false 
	mcLodes.repairLodObject()
*
*/

Global LOD_DATA
Global LOD_OBJECT
struct LOD_DATA (obj, distance = 0, infinite = true, strategy = #bbox)
struct LOD_OBJECT (
	
public 
	count = 0,	
private 
	lodes = #(),
	fn colectLodData = (
	
		count = LS3DGUP.LODU.GetNumLODs()
		lodes = for i = 0 to count-1 collect (
		
			LS3DGUP.LODU.SetSelectedLOD i
			local obj = LS3DGUP.LODU.GetNode() 
			local distance = LS3DGUP.LODU.GetDistance()
			local infinite = LS3DGUP.LODU.IsInfinite()
			local strategy = LS3DGUP.LODU.GetStrategy()
			LOD_DATA obj distance infinite strategy
		)
	),
public
	fn getLod lod_index = ( -- 0 - infinite 
	
		lodes[lod_index+1]
	),
	init = colectLodData()
)

struct MICRA_LOD_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isSelectedLod = (
	
		superClassOf selection[1] == geometryClass and LS3DGUP.LODU.GetNumLODs() > 0
	),
	fn repairLodObject = (
	
		if not (isSelectedLod()) do return (mcMsgList.warn "not_lod")
		local lod_obj = LOD_OBJECT()

		LS3DGUP.LODU.DestroySet()
		
		mcPoly.rebuildObject selection[1] --recreate lod0	

		LS3DGUP.LODU.CreateSet()
		for i = 0 to lod_obj.count-1 do (
		
			local lod_child = lod_obj.getLod i
			if i > 0 do LS3DGUP.LODU.AddNodesToSet #(lod_child.obj)
			LS3DGUP.LODU.SetSelectedLOD i
			LS3DGUP.LODU.SetDistance lod_child.distance
			LS3DGUP.LODU.SetInfinite lod_child.infinite
			LS3DGUP.LODU.SetStrategy lod_child.strategy
		)
	),
	fn getLodFromObject obj lod_index = (
	
		select obj
		local lodes_count = LS3DGUP.LODU.GetNumLODs()
		if (lodes_count == 0) do (
			format "Missing LOD% on:%\n" lod_index obj.name
			return undefined
		)
		if (lodes_count < lod_index + 1) do (
			format "Missing LOD% on:%\n" lod_index obj.name
			return undefined
		)
		LS3DGUP.LODU.SetSelectedLOD lod_index
		return LS3DGUP.LODU.GetNode()
	)
	/*<end>*/
)	
 --create instance
Global mcLodes = mcStructMan.instanceStructure MICRA_LOD_STRUCTURE "mcLodes"
