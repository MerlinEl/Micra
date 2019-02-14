--------------------------------------------------------------------------------
/* mcStructMan by Orien 2019 */ ---Nod used experimenal
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
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
struct MICRA_STRUCTURE_MANAGER	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage
		import a sturcture(class) from CoreDir(file) as Global
	*@Example 
		mcStructMan.import "mcMsxInterface" --force:true
	*/
	fn import struct_name force:false = (
		
		--check if structure is already loaded
		if execute struct_name != undefined and not force do return OK
		--find structure file and load it as global variable
		local file = CoreDir + struct_name + ".ms"
		if doesFileExist file then (
		
			try (
				fileIn file
				format "mcStructMan > import > structure [  %  ]  was success!\n" struct_name
			
			) catch (
			
				format "mcStructMan > import > structure [  %  ]  was failed!\n\tError:%\n" struct_name (getCurrentException())
			)
		) else (
		
			format "mcStructMan > import > structure [  %  ]  was failed!\n\tUnable locate file [ % ]\n" struct_name file
		)
 	),
	fn importAll = (/*not need yet*/),
	/*
	*	@example
	*	struct test1 (a, b)
	*	Global mcTest = mcStructMan.instanceStructure test1
	*/
	fn instanceStructure struct_object instance_name = (

		local structure_instance
		try (
			structure_instance = struct_object()
			--format"mcStructMan > instance structure > [  %  ] was success!\n" instance_name
		) catch (

			format"mcStructMan > instance structure > [  %  ] was failed!\n\tError:%\n" instance_name (getCurrentException())
		)
		structure_instance
	)
	/*<end>*/
)	
 --create instance
Global mcStructMan = MICRA_STRUCTURE_MANAGER()
