Global sP4vManager = undefined

struct sP4vManager (

	pLog = mcProgLog,
	fn initLog = ( --validate output log window
	
		if SuperClassOf pLog != StructDef do (
		
			struct pLog (fn msg str = (format "%\n" str))
		)
	),
	l = initLog(),
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
		
			1: pLog.msg "Perforce is missing or down" ty:"error"
			2: pLog.msg "File in perforce. File is not checked out." ty:"proc"
			3: pLog.msg "File in perforce. File is Read Only. File checked out by someone else." ty:"proc"
			4: pLog.msg "File in perforce. File is checked out by you." ty:"proc"
			5: pLog.msg "File in perforce. Your version is old so sync up" ty:"warn"
			6: pLog.msg "File is not in Perforce. File is writeable" ty:"warn"
			15: pLog.msg "File is not in Perforce. File is Read Only." ty:"error"
			default: pLog.msg "Unknown status of file in Perforce" ty:"error"	 			
		)
		return result
	),
	fn addFileListToP4 fileList objectName = (
	
		pLog.msg "Creating new changelist." ti:"P4V..." ty:"task_open"
		local newChangelist = CreateChangelist ("New asset: " + objectName as string)
		if (newChangelist != -1) then (

			pLog.msg ("Adding new files to P4 changelist(" + newChangelist as string + ") fileList: " + fileList as string) ty:"proc"
			if (not (AddFiles fileList newChangelist)) then (

				pLog.msg "Something went wrong while adding new files to P4." ty:"warn"
			)
		) else (
		
			pLog.msg "Something went wrong while creating new changelist." ty:"warn"
		)	
		pLog.msg "Creating new changelist." ti:"P4V..." ty:"task_close"		
	)
	/*fn revertFiles fileList = (
	
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
	)*/
)



/*
p4v_man = sP4vManager()
int_ch = p4v_man.createChangelist ("ADD new Asset:" + asset_name)
fileList = #(
	@"d:\!2k_games\scotch_dev\resources\graphics\city\lost_heaven\districts\lh_08_oakwood\static_objects\lh_08_family_house_a_v1_test.max",
	@"d:\!2k_games\scotch_dev\resources\graphics\city\lost_heaven\districts\lh_08_oakwood\static_objects\lh_08_family_house_a_v1_test.xml"
)
p4v_man.addFiles fileList int_ch
p4v_man.revertFiles fileList int_ch
*/
