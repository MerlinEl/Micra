--------------------------------------------------------------------------------
/* mcInfo by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_INFO (

	fn getSource = getSourceFileName(), --get path of this script
	fn all obj = 
	(
		show obj	
	),
	
	fn who obj = 
	(
		format "class:% superClass:%\t" (classOf obj) (superClassOf obj)
	),

	/*fn isGeometry obj = 
	(
		superClassOf obj == GeometryClass
	),
	
	fn isShape obj = 
	(
		superClassOf obj == shape
	),*/
	
	fn is arg obj =
	(
		--isKindOf o SplineShape1
		local type = case (classOf obj) of
		(
			Editable_Poly: #poly
			Editable_Mesh: #mesh
			Line: #spline
			BoneGeometry: #bone
			--Edit_Poly:
			--Edit_Mesh:
			--Unwrap_UVW:
			--SplineShape:
			--Edit_Spline:
		)
		if type == undefined do type = case (superClassOf obj) of
		(
			GeometryClass: #geometry	
			shape: #shape
		)
		return type == arg
	) 
)
--create instance
Global mcInfo = Micra.instanceStructure MICRA_INFO "mcInfo"