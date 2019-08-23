Global P4V_MANAGER

struct P4V_MANAGER (

	/**
	*@Usage mcPprogbUI.msg display messages in new consloe window
	*@Example
		mcPprogbUI.msg "@" --clear log
		mcPprogbUI.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
		mcPprogbUI.msg "Creating Max File" ti:"3DsMax..." ty:"task_open"
		mcPprogbUI.msg "Paths and Name is OK" ty:"proc"
		mcPprogbUI.msg "Name OK" ty:"proc"
		output_dir = @"E:\Aprog\Orien\Micra\Micra4\_New\AssetBulider"
		mcPprogbUI.msg ("Failed Save Max File. Unable to find Directory.\n\tPath:[ "+output_dir+" ]") ti:"Aborted!" ty:"error" tl:1
		mcPprogbUI.msg "All Done" ty:"task_close"
	*/
	fn init = (
	
		if mcPprogbUI == undefined do filein "Progressbar_With_Log.ms"
	),
	i = init(),
	fn checkout fileList changelist = (
	
		if (p4Ops == undefined) do return false
		p4Ops.EditFiles fileList clNumber:changelist
		return true
	),
	fn getLatest fileList = (
	
		if (p4Ops == undefined) do return false
		p4Ops.GetLatest fileList
	),
	fn createChangelist description = (
	
		if (p4Ops == undefined) do return -1
		p4Ops.CreateChangelist description --return Changelist Number 
	),
	fn addFiles fileList changelist = (
	
		if (p4Ops == undefined) do return false
		p4Ops.AddFiles fileList clNumber:changelist
		return true
	),	
	fn checkFileStatus file = (
	
		if (p4Ops == undefined) do return -1
		local result = p4Ops.CheckFileStatus file
		format "Getting P4 status for: %  result = %\n" file result
		case (result) of (
		
			1: mcPprogbUI.msg "Perforce is missing or down" ty:"error"
			2: mcPprogbUI.msg "File in perforce. File is not checked out." ty:"proc"
			3: mcPprogbUI.msg "File in perforce. File is Read Only. File checked out by someone else." ty:"proc"
			4: mcPprogbUI.msg "File in perforce. File is checked out by you." ty:"proc"
			5: mcPprogbUI.msg "File in perforce. Your version is old so sync up" ty:"warn"
			6: mcPprogbUI.msg "File is not in Perforce. File is writeable" ty:"warn"
			15: mcPprogbUI.msg "File is not in Perforce. File is Read Only." ty:"error"
			default: mcPprogbUI.msg "Unknown status of file in Perforce" ty:"error"	 			
		)
		return result
	),
	fn addFileListToP4 fileList objectName = (
	
		mcPprogbUI.msg "Creating new changelist." ti:"P4V..." ty:"task_open"
		local newChangelist = CreateChangelist ("New asset: " + objectName as string)
		if (newChangelist != -1) then (

			mcPprogbUI.msg ("Adding new files to P4 changelist(" + newChangelist as string + ") fileList: " + fileList as string) ty:"proc"
			if (not (AddFiles fileList newChangelist)) then (

				mcPprogbUI.msg "Something went wrong while adding new files to P4." ty:"warn"
			)
		) else (
		
			mcPprogbUI.msg "Something went wrong while creating new changelist." ty:"warn"
		)	
		mcPprogbUI.msg "Creating new changelist." ti:"P4V..." ty:"task_close"		
	), 
	fn revertFiles fileList = (
	
		local cmd = "p4 revert" 
		for f in fileList do cmd += " " + f
		local exitCode = 0
		HiddenDosCommand (cmd) exitCode:&exitCode donotwait:true startpath:""
		if exitCode != 0 then (
			
			false
			
		) else (
		
			true
		)
		--p4 revert -a
		--Revert all unchanged files. This command is often used before submitting a changelist.
		--p4 revert -c default //...
		--Revert every file open in the default changelist to its pre-opened state.
		
		--for f in fileList where doesFileExist f do p4Ops.Revert f changelist:clString
		--p4 revert fdv.cgi flv.cgi
	),
	fn deleteFiles fileList = (
	
	--p4 delete fdv.cgi fv.cgi flv.cgi
    

	-- CreateChangelist
	-- newChanglelistNumber
	-- p4Exist
	-- DoesChangelistExist
	  -- Unlock:<fn>; Public
	-- Lock:<fn>; Public
	  -- Revert:<fn>; Public
	)
)



/*
p4v_man = P4V_MANAGER()
int_ch = p4v_man.createChangelist ("ADD new Asset:" + asset_name)
fileList = #(
	@"d:\!2k_games\scotch_dev\resources\graphics\city\lost_heaven\districts\lh_08_oakwood\static_objects\lh_08_family_house_a_v1_test.max",
	@"d:\!2k_games\scotch_dev\resources\graphics\city\lost_heaven\districts\lh_08_oakwood\static_objects\lh_08_family_house_a_v1_test.xml"
)
p4v_man.addFiles fileList int_ch
p4v_man.revertFiles fileList int_ch
*/
