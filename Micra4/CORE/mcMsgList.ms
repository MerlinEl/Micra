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
		msg_key	key shortcut for message
		pre		string which will be added to message prefix
		suf		string which will be added to message suffix
		mbox	if true then show messagebox else print message to listener
	*@Example
		if not (isValidObject obj_mesh) do return (mcMsgList.warn "not_mesh")
	*/
	fn warn msg_key pre:"" suf:"" mbox:true = (
	
		local msg = case msg_key of (

			"wait_todo"		: "This function is under construction.\nPlese wait. Will be finished soon :-)"
			"call_help"		: "Something wierd was happen. Call Merlin to help you :-)"
			"not_osel"		: "Selected an Object to progress."
			"not_osel_x"		: "Selected some Objects to progress."
			"not_osel_xa"		: "Selected some Object(s) to progress."
			"not_lod"			: "Selected Object must have lods."
			"not_mesh"		: "Editable Mesh must be selected."
			"not_poly"		: "Editable Poly must be selected."
			"not_poly_src"		: "Source Editable Poly must be defined."
			"not_poly_trgt"	: "Target Editable Poly must be defined."
			"not_poly_2"		: "Both Object must be Editable Poly."
			"not_geo"			: "Editable Poly or Editable Mesh must be selected."
			"not_geo_trgt"		: "Target Editable Poly or Editable Mesh must be defined."
			"not_unwrap"		: "Object must have Unwrap Modifier."
			"not_map"		: "Object must have some UVW Channels."
			"not_spline"		: "Spline must be selected."
			"not_sel"			: "Select some object(s) to progress."
			"not_vsel"		: "Select some vertices to progress."
			"not_vsel_1"		: "Select one vertex to progress."
			"not_vsel_2"		: "Select two vertices to progress."
			"not_esel"		: "Select some edges to progress."
			"not_esel_1"		: "Select one edge to progress."
			"not_esel_2"		: "Select two edges to progress."
			"not_fseluv_1"		: "Select one UV face to progress."
			"not_fseluv_x"		: "Select  UV face(s) to progress."
			"not_fsel"			: "Select some faces to progress."
			"not_fsel_1"		: "Select one face to progress."
			"not_vsel_esel"	: "Select some vertices or edges to progress."
			"not_termat"		: "Missing terrain material."
			"not_semat"		: "Missing sementic material."
			"no_profile"		: "Missing spline profile.\nFirst create one spline(profile) with name curb_"
			"not_edge_level"	: "Subobject level must be in Edges."
			"not_sweep"		: "Must be Spline with sweep Modifier applyed."
			"im_idiot"		: "I'm an Idiot"
			default			: "Unknown Error...."
		)
		if mbox then (
		
			-- messageBox (pre + msg + suf) title:"Warning:"
			::mcPopUp.show (pre + msg + suf) type:#Warning
			
		) else (
		
			format "Warning > \n\t%\n" (pre + msg + suf)
		)
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


/*
Jiří Hajný joke Error msg
	 "!!!Stop right there, criminal scum!!!\n !!!Do not put non-float values into Ratio text field!!!"
	  "!!!Would you kindly… select an Object?!!!"
	  "!!!Wait... I know you! How can one apply Texel Ratio on 0 Objects?!!!"
*/