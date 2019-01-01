Struct STRUCTURE_COLLECTION_MANAGER (
	
public
	app_dir = "",
private
	ini_file = app_dir + "Struct_List.ini",
	struct_names = #(), --collect structure names here
	fn loadMyStructures = (

		if not doesFileExist ini_file do return false
		local struct_files = getINISetting ini_file "STRUCTURES"
		for file_name in struct_files do (

			local struct_name  = getINISetting ini_file "STRUCTURES" file_name
			struct_names += #(struct_name)
			fileIn (app_dir + file_name + ".ms")
		)
		OK
	),
	on create do (loadMyStructures()),
public
	fn run fn_str params:#() = (
		
		format "SCM > Run > fn:% params:% cnt:%\n" fn_str params params.count
		if classOf fn_str != String or classOf params != Array do  return false
		for s in struct_names do (
			
			local struct_instance = execute s
			if not (hasProperty struct_instance fn_str) do continue --skip structures without desired function
			local prop = getProperty struct_instance fn_str
			local result  = case params.count of (

				0: prop ()
				1: prop params[1]
				2: prop params[1] params[2]
				3: prop params[1] params[2] params[3]
				4: prop params[1] params[2] params[3] params[4]
			)
			return result
		)
		false
	)
)
GLOBAL scm = STRUCTURE_COLLECTION_MANAGER app_dir:"C:\\temp\\msx_app\\"

/*
	--first load all structures and collect struct instance names
	--second run any of you functions by one root command
	--@Example
	abc = #("c", "b", "a")
	scm.run "reverseArray" params:#(abc)
	--@Output 	#("a", "b", "c")
*/