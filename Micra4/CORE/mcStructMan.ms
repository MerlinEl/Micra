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
	*@Usage > import structure(class) from RootDir(file) or CoreDir(file) as Global --if is not inicialized
	*@Example
		mcStructMan.import "mcMsxInterface" "mcMsxInterface" dir:#Core force:true 
		mcStructMan.import "mcLS3DMaterialManagerStruct" "LS3D_Material_Manager_Struct" dir:#Root debug:true
	*/
	fn import struct_name file_name dir:#Core force:false debug:false = (
		
		--check if structure is already loaded
		local struct_object = execute struct_name
		if isStruct struct_object and not force do (
		
			if debug do format "mcStructMan > import > [  %  ]  was already loaded!\n" struct_name
			return OK
		)
		--find file and load his structure as global variable
		local file = case dir of (
		
			#Core : (
			
				micra.CoreDir + struct_name + ".ms"
			)
			#Root : (
			
				local file_versions = getFiles (micra.RootDir + file_name + "*.ms")
				file_versions[file_versions.count] --get latest file version
			)
		)
		if doesFileExist (file as string) then (
		
			try (
				fileIn file
				if debug do format "mcStructMan > import > structure [  %  ]  was success!\n" struct_name
			
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
	*	struct MC_TEST (a, b)
	*	Global mcTest = mcStructMan.instanceStructure MC_TEST "mcTest"
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
