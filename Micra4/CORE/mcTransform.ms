--------------------------------------------------------------------------------
/* mcTransform by Orien 2019 */
--------------------------------------------------------------------------------
Global mcTransform 
struct TM (name, pos, rot);
Global OBJ_TM
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct mcTransform (

	fn getSource = getSourceFileName(), --get path of this script
	fn getRotation obj = 
	(
		local x = obj.rotation.x_rotation
		local y = obj.rotation.y_rotation
		local z = obj.rotation.z_rotation
		return [x,y,z]
	),
	fn setRotation obj rot = 
	(
		obj.rotation.x_rotation = rot.x
		obj.rotation.y_rotation = rot.y
		obj.rotation.z_rotation = rot.z
	),
	fn copyTM =
	(
		if (selection.count > 0) do OBJ_TM = mcTransform.getTM selection[1]
	),
	fn pasteTM =
	(
		if (OBJ_TM != undefined) do mcTransform.setTM selection[1] OBJ_TM
	),
	fn getTM obj = 
	(
		return TM obj.name obj.pos (mcTransform.getRotation obj)
	),
	fn setTM obj tm = 
	(
		mcTransform.setRotation obj tm.rot
		obj.pos = tm.pos
	),
	fn round val num =
	(
		((val*num) as integer) as float / num
	), 
	fn round3Matrix val num =  
	(
		for i=1 to 3 do val[i]= mcTransform.round val[i] num
		return val
	),
	fn getNodeSize obj =
	(
		obj.min - obj.max
	),
	fn getLocalSize obj type =
	(
	 	/*
		in coordsys local 
		(
			min = obj.min
	 		max = obj.max
		)
		*/
		addModifier Obj (theBend = Bend()) --add a bend to the object
		classof Obj								 --this is a hack causing a fast reevaluation of the stack!
		min = getModContextBBoxMin Obj theBend --get the min. of the modifier's BBox
		max = getModContextBBoxMax Obj theBend --get the max. of the modifier's BBox
		deleteModifier Obj theBend	--delete the modifier
		case type of
		(
			#width:max.x-min.x
			#lenght:max.y-min.y
			#height:max.z-min.z
		)
	)
	/*<end>*/
)
 --create instance caused error (unable find function in this struct)
--Global mcTransform = Micra.instanceStructure MICRA_TRANSFORM "mcTransform"

