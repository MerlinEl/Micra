--------------------------------------------------------------------------------
/* mcMsgList by Orien 2019 */
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
struct MICRA_MESSAGE_LIST_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage list of all posible mesages
	*@Example
		if not (isValidObject obj_mesh) do return (mcMsgList.warn "not_mesh")
	*/
	fn warn msg_key = (
	
		local msg = case msg_key of (

			"call_help"		: "Something wierd was happen. Call Merlin to help you :-)"
			"not_mesh"		: "Editable Mesh must be selected."
			"not_poly"		: "Editable Poly must be selected."
			"not_mesh_or_poly": "Editable Poly or Editable Mesh must be selected."
			"not_unwrap"		: "Object must have Unwrap Modifier."
			"not_spline"		: "Spline must be selected."
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
	fn info msg_key = (
	
	
	),
	fn ask msg_key = (
	
	
	)
	/*<end>*/
)	
 --create instance
Global mcMsgList = mcStructMan.instanceStructure MICRA_MESSAGE_LIST_STRUCTURE "mcMsgList"