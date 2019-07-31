Global P4V_MANAGER

struct P4V_MANAGER (

	fn init = (
	
		if gLS3DDXSupport == undefined do gLS3DDXSupport.ShaderUpdateScriptInit()
		local console = sLS3DLog(); console.Init(); console
	),
	myLog = init(),
	/**
	*@Example
		LogM "Zpráva se zobrazí v Max Listeneru" maxListener:true
		LogM ("Incorrect path.") maxListener:true level:3 -- tabs level > 1-3
	*/
	fn LogM message level:1 maxListener:true = ( --default false --debug true
	
		myLog.LogMessage message level:level maxListener:maxListener
	),
	fn Checkout fileList changelist = (
	
		if (p4Ops != undefined) then
		(
			p4Ops.EditFiles fileList clNumber:changelist
			return true
		) else (
			return false
		)
	),
	fn GetLatest fileList = (
	
		if (p4Ops != undefined) then
		(
			p4Ops.GetLatest fileList
		) else (
			return false
		)
	),
	fn CreateChangelist description = (
	
		if (p4Ops != undefined) then
		(
			return (p4Ops.CreateChangelist description)
		) else (
			return -1
		)		
	),
	fn AddFiles fileList changelist = (
	
		if (p4Ops != undefined) then
		(
			p4Ops.AddFiles fileList clNumber:changelist
			return true
		) else	 (
			return false
		)
	),	
	fn CheckFileStatus file = (
	
		local result = -1
		if (p4Ops != undefined) then
		(
			result = p4Ops.CheckFileStatus file
			LogM("Getting P4 status for: " + file as string + "   result = " + (result as string))
			case (result) of
			(
				1: LogM("Perforce is missing or down.") level:3
				2: LogM("File in perforce. File is not checked out.")
				3: LogM("File in perforce. File is Read Only. File checked out by someone else.")
				4: LogM("File in perforce. File is checked out by you.")
				5: LogM("File in perforce. Your version is old so sync up") level:2
				6: LogM("File is not in Perforce. File is writeable") level:2
				15: LogM("File is not in Perforce. File is Read Only.") level:3
				default: LogM("Unknown status of file in Perforce") level:3				
			)
		)	
		return result
	),
	fn AddFileListToP4 p4FileList objectName = (
	
		LogM ("Creating new changelist.")
		local newChangelist = CreateChangelist ("New asset: " + objectName as string)
		if (newChangelist != -1) then (
			LogM ("Adding new files to P4 changelist(" + newChangelist as string + ") fileList: " + p4FileList as string)
			if (not (AddFiles p4FileList newChangelist)) then (
				LogM ("Something went wrong while adding new files to P4.") level:2
			)
		) else (
			LogM ("Something went wrong while creating new changelist.") level:2
		)		
	)
)



/*
p4 = P4V_MANAGER()
local p4FileList = #()
p4.AddFileListToP4 p4FileList asset_name
*/
