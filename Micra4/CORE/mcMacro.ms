--------------------------------------------------------------------------------
/* mcMacro by Orien 2019 */
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
struct MICRA_NEW_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getMSTable = (

		for i=1 to actionMan.numActionTables where (ata = actionMan.getActionTable i).name == "Macro Scripts" do exit with ata
	),
	/**
	*@Example
		mcMacro.isExist "Micra" "Exit Editing"
	*/
	fn isExists macro_cat macro_btn_text = (
	
		local main_table = getMSTable()
		for i=1 to main_table.numActionItems do (
			
			local itm = main_table.getActionItem i
			local btn, cat
			itm.getButtonText &btn
			itm.getCategory &cat
			-- format "\t(%) cat:% btn:%\n" i cat btn
			if cat == macro_cat and btn == macro_btn_text do return true
		)
		false
	),
	/**
	*@Example
		mcMacro.run "Micra" "Exit Editing"
	*/
	fn run macro_cat macro_btn_text silent:false = (
	
		if isExists macro_cat macro_btn_text then (
		
			macros.run macro_cat macro_btn_text 
			
		) else if not silent do (
		
			MessageBox ("Macro [ "+macro_btn_text+" ] not found in catalog [ "+macro_cat+" ].") title:"Macro:"
		)
	),
	fn printAll = (
		for i=1 to actionMan.numActionTables do (

			local ata = actionMan.getActionTable i
			format "Action Table name:% context:%\n" ata.name ata.contextName
			for y=1 to ata.numActionItems do (
				
				local itm = ata.getActionItem y
				local btn, cat
				itm.getButtonText &btn
				itm.getCategory &cat
				format "\tcat:% btn:%\n" cat btn
			)
		) 
	)
	/*<end>*/
)	
 --create instance
Global mcMacro = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcMacro"
