/* ========================================================================
-- Title: fn_rigUpdateOps.ms
-- Date: 8/24/2010
-- Author: Erik Koehlert

--Description: Perforce functions
fn_p4Ops: MODIFIED VERSIONS FROM THOSE FOUND AT: www.tech-artists.org

-- Revision History:

--8/20/2010
	--Added fixDepotPathing
--7/18/2010 EK
	--addFiles uses perforce -x option to send it a txt file list of files instead of doing individual file adds
	--Added checkFilesStatus uses -x option of perforce to send a txt file list of files to process with fstat and uses -s option to report/handle errors 
--6/30/2010 EK
	--Changed dos command so that if the version is Max 2010 or greater it will return an dosOps.exitCode based on the success of the dos command and accept optional args
	--Added struct struc_File_Info for interacting with Perforce.
	--Convert all filename entries in dos commands to be enclosed by quotes in case filenames have spaces
	--Added getHistory
	--Added testConnected
	--Added checkFileStatus
	--Added prepForWriting
	--Added getDepotPath
	
===========================================================*/

global dosOps = undefined
global p4Ops = undefined
global gP4 = undefined

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct dosOpsDef
(
	exitCode = 0,
	--HELPERS
 	fn Command args Vdonotwait:false Vstartpath:"" =
	(
	/*******************************************************************************
		<DOC> Sets up the DOSCommand function for the struct.  If Max2008 or higher,
		use HiddenDOSCommand, if lower, use DosCommand.
		Arguments:
		Return:
			<int> 0 if using DOSCommand, 1 if using HiddenDOSCommand
	*******************************************************************************/
		if ((maxVersion())[1]) >= 10000 then
		(	
			print ("executing: " + args as string)
			HiddenDosCommand (args) exitCode:&exitCode donotwait:Vdonotwait startpath:Vstartpath
			if exitCode != 0 then (
				--print ("Error while executing: " + args as string)
			)
			return exitCode
		)
		else
		(
			DosCommand (args)
		)
	),
	
	fn Makedir fnew =
	(
		fnewpath=getFilenamePath fnew
		dosOps.command ("mkdir \"" + (fnewpath) + "\"")
		return (doesfileexist (fnew))
	)	
)--end struct	
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct LS3Dp4Lib_struc_File_Info (readOnly,depotFile,clientFile,headAction,headTime,headRev,haveRev,actionOwner,otherOpen)
struct LS3Dp4Lib_ConnectionStatus (userName, workspace, clientHost, clientRoot)
	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct p4OpsDef
(
	--Variables
	myLog  = undefined,
	p4_64_path="C:\\Program Files\\Perforce\\p4.exe",
	p4_32_path="C:\\Program Files (x86)\\Perforce\\p4.exe",
	ek_filetocheckinfo = LS3Dp4Lib_struc_File_Info readOnly:"" depotFile:"" clientFile:"" headAction:"" headTime:"" headRev:"" haveRev:"" actionOwner:"" otherOpen:"",
	newChangelistDesc = "<enter description here>",
	newChanglelistNumber = #("Change ", " created."),
	sourceControlLog = @"d:\p4_Source_Control_LogFile.txt",	
	sourceControlLog2 = @"d:\p4_Source_Control_LogFile2.txt",	
	p4batchscript = @"d:\p4_Source_Control_Batch.bat",
	p4_addBatch = @"d:\p4_addBatchList.txt",
	depotDirectory = undefined,
	p4Exist = false ,
	headRevAry = #(),
	haveRevAry = #(),
	connectionStatus = LS3Dp4Lib_ConnectionStatus userName:"" workspace:"" clientHost:"" clientRoot:"",
	fn GetConnectionStatus = ( return connectionStatus ),
	--FUNCTIONS
	fn LogM message level:1 maxListener:false =
	(
		myLog.LogMessage message level:level maxListener:maxListener
	),	
	
	fn FixDepotPathing fileNameToCheck =
	(
		--print "Checking String"
		localString=@"D:\Perforce"
		depotString=@"d:\perforce"
		if (matchPattern fileNameToCheck pattern:(localString+"*") ignoreCase:true) then
		(
			--print "changing it!"
			blah=substituteString fileNameToCheck localString depotString
			return blah
		)
		else
		(
			return fileNameToCheck
		) 
		--return fileNameToCheck
	),
	
	
	fn UpdateP4Status logFile =
	(
		if ((getFileSize logFile) > 0) then
		(
			f = openFile logFile
--			if (skipToString f "..." )!=undefined then
			(
				stringy = readLine f
				stringy = substituteString stringy "User name: " ""
				connectionStatus.userName = stringy
		
				stringy = readLine f
				stringy = substituteString stringy "Client name: " ""
				connectionStatus.workspace = stringy

				stringy = readLine f
				stringy = substituteString stringy "Client host: " ""
				connectionStatus.clientHost = stringy

				stringy = readLine f
				stringy = substituteString stringy "Client root: " ""
				connectionStatus.clientRoot = stringy
			)
			close f
			return true
		) else return false
	),
	
	fn TestConnected =
	(
		/*******************************************************************************
			<DOC> Checks perforce connection 
			Arguments:
				<filename>
			Return:
				<boolean> true if perforce is installed, server is up, and user is logged in   
		*******************************************************************************/
		--paths to check for perforce executable

		--check for perforce executable
		local result = false

		if (doesFileExist p4_64_path) or (doesFileExist p4_32_path)then
		(
			LogM "Perforce p4.exe found."
			--check if logged in to perforce and p4 is communicating
			dosOps.command ("p4 info> "+ p4Ops.sourceControlLog)
			--format "getFileSize p4Ops.sourceControlLog = %\n" (getFileSize p4Ops.sourceControlLog)
			if ((getFileSize p4Ops.sourceControlLog)>0) then
			(
				UpdateP4Status p4Ops.sourceControlLog
				--check if logged in to perforce and p4 is communicating
				dosOps.command ("p4 login -s")
				if dosOps.exitCode==0 then	--An exit code of 0 means the command was executed without errors, non-zero code usually means an error. 
				(	p4Ops.p4Exist=true
					result = true
				)
			) else ( LogM "Perforce server down!!!!" level:3 )
			deleteFile p4Ops.sourceControlLog
		) else ( LogM "Perforce p4.exe missing?" level:3 )
		return result
	),
	
	fn GetDepotPath =
	(
		/*******************************************************************************
			<DOC> Checks perforce depot path mapping for the client root
			Arguments:
				<None>
			Return:
				 <String> filepath to the perforce depot root on the local machine
		*******************************************************************************/
		if (p4Ops.p4Exist) then
		(
			dosOps.command ("p4 info> "+ p4Ops.sourceControlLog)
			if dosOps.exitCode==0 then
			(
				f = openFile p4Ops.sourceControlLog
				if (not eof f) then (
					seek f 0
					if (skipToString f "Client root:" )!=undefined then
					(
						stringy=readLine f
						filteredResult=filterString stringy " "
						close f
						--Check if case differences exist between local depot path and that described in client info
						localDirsFound=getDirectories (filteredResult[1])
						p4Ops.depotDirectory=localDirsFound[1]
						LogM ("GetDepotPath = " + (localDirsFound[1] as string))
						return (localDirsFound[1] as string)
					)
				)
				close f
			)
			else
			(
				LogM "Perforce is down!" level:3
				return ""
				
			)
		)
		else
		(
			LogM "Perforce is down!" level:3
			return ""
		)
	),
	
	fn CheckFileStatus fileToCheck =
	(
		/*******************************************************************************
			<DOC> This function checks a file for its perforce status and its read/write properties  
			Arguments:
				<filename>
			Return:
				 <int>
				1 Perforce is missing or down
				2 File in perforce. File is not checked out.
				3 File in perforce. File is Read Only. File checked out by someone else.
				4 File in perforce. File is checked out by you.
				5 File in perforce. Your version is old so sync up
				6 File is not in Perforce. File is writeable
				7 File is not in Perforce. File is writeable.
				15 File is not in Perforce. File is Read Only.
		*******************************************************************************/		
		--Check does file exist
		local result = -1
		if (doesFileExist fileToCheck) then
		(
			p4Ops.ek_filetocheckinfo = LS3Dp4Lib_struc_File_Info readOnly:"" depotFile:"" clientFile:"" headAction:"" headTime:"" headRev:"" haveRev:"" actionOwner:"" otherOpen:""
			--LogM ("File exists = " + fileToCheck as string)
			--Check does perforce exist
			if ((p4Ops.p4Exist)) then
			(
				--fileToCheck=fixDepotPathing fileToCheck
				local commandline = "p4 fstat \"" + fileToCheck + "\" > "+ p4Ops.sourceControlLog
				LogM ("Command: " + commandline as string)				
				dosOps.command (commandline)
				--sleep(1)
				f = openFile p4Ops.sourceControlLog
				if (not eof f) then (
					if (skipToString f "... depotFile" )==undefined then
					(
						--File not in Perforce so do the following
						if (getFileAttribute fileToCheck #readOnly)==true then
						( 
						   p4Ops.ek_filetocheckinfo.readOnly=true
						   --format "File not in Perforce. Read only\n"
						   result = 15
						)
						else
						(
						   p4Ops.ek_filetocheckinfo.readOnly=false
						   --format "File not in Perforce.Writeable\n"
						   result = 6
						)
					)
					else --File is in Perforce so do the following
					(
					   p4Ops.ek_filetocheckinfo.depotFile = readLine f
					   seek f 0
					   --format "p4Ops.ek_filetocheckinfo.depotFile=%\n" p4Ops.ek_filetocheckinfo.depotFile
					   if (skipToString f "... clientFile" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.clientFile=readLine f
							--format "p4Ops.ek_filetocheckinfo.clientFile=%\n" p4Ops.ek_filetocheckinfo.clientFile
						   
					   )
					   seek f 0
					   if (skipToString f "... headAction" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.headAction=readLine f
							--format "p4Ops.ek_filetocheckinfo.headAction=%\n" p4Ops.ek_filetocheckinfo.headAction
					   )
					   seek f 0
					   if (skipToString f "... ... otherOpen" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.otherOpen=readLine f
							--format "p4Ops.ek_filetocheckinfo.otherOpen=%\n" p4Ops.ek_filetocheckinfo.otherOpen
					   )
					   seek f 0
					   if (skipToString f "... headTime" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.headTime=(readLine f) as integer
							--format "p4Ops.ek_filetocheckinfo.headTime=%\n" p4Ops.ek_filetocheckinfo.headTime
					   )
					   seek f 0
					   if (skipToString f "... headRev" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.headRev=(readLine f) as integer
							--format "p4Ops.ek_filetocheckinfo.headRev=%\n" p4Ops.ek_filetocheckinfo.headRev
					   )
					   seek f 0
					   if (skipToString f "... haveRev" )!=undefined then
					   (
							p4Ops.ek_filetocheckinfo.haveRev=(readLine f) as integer
							--format "p4Ops.ek_filetocheckinfo.haveRev=%\n" p4Ops.ek_filetocheckinfo.haveRev
					   )
					   seek f 0
					   if (skipToString f "... actionOwner" )!=undefined then
					   (					   
							p4Ops.ek_filetocheckinfo.actionOwner=readLine f
							--format "p4Ops.ek_filetocheckinfo.actionOwner=%\n" p4Ops.ek_filetocheckinfo.actionOwner
					   )
					   
					   if p4Ops.ek_filetocheckinfo.haveRev != p4Ops.ek_filetocheckinfo.headRev then (
							--format "File in perforce. Your version is old so sync up.\n"
							result = 5
					   ) else (
						   if (p4Ops.ek_filetocheckinfo.actionOwner != undefined) and (p4Ops.ek_filetocheckinfo.actionOwner != "") then (
								--format "File in perforce. File checked out by you.\n"
								result = 4
						   ) else (
							   if (p4Ops.ek_filetocheckinfo.otherOpen != "") and (p4Ops.ek_filetocheckinfo.otherOpen != undefined) then (
									--format "File is Read Only. File in perforce. File checked out by someone else.\n"
									result = 3
							   ) else  (
								   --format "File in perforce. File not checked out.\n"
									result = 2
								)
							)
						)
					)
				) else (
					--File not in Perforce so do the following
					if (getFileAttribute fileToCheck #readOnly)==true then
					( 
					   p4Ops.ek_filetocheckinfo.readOnly=true
					   --format "File not in Perforce. Read only\n"
					   result = 15
					)
					else
					(
					   p4Ops.ek_filetocheckinfo.readOnly=false
					   --format "File not in Perforce.Writeable\n"
					   result = 6
					)
				)
				close f
				--deletefile p4Ops.sourceControlLog
			)
			else
			(
				--p4 does not exist or server down
				LogM "p4 does not exist or server down" level:3
				--str_messageText="Perforce does not exist or innacessible command line functionality on this machine!"
				--messagebox (str_messageText)
				--is file Read only
				if (getFileAttribute fileToCheck #readOnly) == true then
				( 
					--"Read Only!!!"
					LogM "File is read only.\n"  level:2
				)
				else --File is writeable
				(
					--"File is readable and writeable."
					LogM "File is writeable.\n"
				)
			)
		)
		else --File does not exist
		(
			str_messageText="File "+fileToCheck+" does not exist!\t"
			LogM str_messageText level:2
		)
		return result
	),	
	
	fn AddFiles fileList clNumber:-1 =
	(		
		if (classof fileList != Array) then return false
		--Output filelist to text file
		listy=createfile p4Ops.p4_addBatch
		for i in fileList do
		(
			format ("%\n") i to:listy
		)
		close listy
		local changeList = ""
		if (clNumber != -1) then changeList = (" -c " + (clNumber as string))
		dosOps.command ("p4 -s -x " + p4Ops.p4_addBatch + " add" + changelist)
		deletefile p4Ops.p4_addBatch
	),
	
	fn EditFiles fileList clNumber:-1 =
	(
		if (classof fileList != Array) then return false
		listy = createfile p4Ops.p4_addBatch
		for i in fileList do
		(
			format ("%\n") i to:listy
		)
		close listy
		local changeList = ""
		if (clNumber != -1) then changeList = (" -c " + (clNumber as string))
--		LogM ("clNumber = " + (clNumber as string) + "           changeList = " + changeList)
		dosOps.command ("p4 -s -x " + p4Ops.p4_addBatch + " edit" + changeList)
		deletefile p4Ops.p4_addBatch
	),
	
	fn CheckFilesStatus fileList =
	(
		fn existFile fname = (getfiles fname).count != 0

		/*******************************************************************************
			<DOC> This function checks a list of files for their perforce status and its read/write properties  
			Arguments:
				<filename>
			Return:
				 <int>
				1 Perforce is missing or down
				2 File in perforce. File is not checked out.
				3 File in perforce. File is Read Only. File checked out by someone else.
				4 File in perforce. File is checked out by you.
				5 File in perforce. Your version is old so sync up
				6 File is not in Perforce. File is writeable.
				15 File is not in Perforce. File is Read Only.
		*******************************************************************************/		
		
		--CULL FILES NOT UNDER DEPOT DIRECTORY FIRST!!!!!!
		
		if (classof fileList != Array) then return false
		--Check does folder exist
		statusAry=#()
		headRevsArray=#()
		haveRevsArray=#()
		if (p4Ops.p4Exist==false)then
		(
				for fileToCheck in fileList do --FINISH ROUTINE
				(
					if (doesFileExist fileToCheck) then
					(
						LogM ("File Exists! " + (fileToCheck as string))
						--File not in Perforce so do the following
						if (getFileAttribute fileToCheck #readOnly)==true then
						( 
							--lbl_filestatus.text="Read Only!!!"
							LogM "File not in Perforce"
						   --return 15
							append statusAry 0
							append headRevsArray 0
							append haveRevsArray 0
						)
						else
						(
						   --lbl_filestatus.text="File is readable and writeable."
						   --lbl_fileinfo.text="File not in Perforce!!!"
						   LogM "File not in Perforce"
						   --close f
						   --return 6
							append statusAry 0
							append headRevsArray 0
							append haveRevsArray 0
						)
					)
					else
					(
						LogM "File not in Perforce"
						   --close f
						   --return 6
							append statusAry 0
							append headRevsArray 0
							append haveRevsArray 0
						
						
					)
				)
		)
		else
		(
			--start = timeStamp()
			--Output filelist to text file
			local tempPath = p4_addBatch
			listy=createfile tempPath
			for i in fileList do
			(
				--print i
				--m=p4Ops.fixDepotPathing i
				--print m
				--test for depot directory difference
				format ("%\n") i to:listy
			)
			close listy
			--Close p4Ops.p4batchscript
			--end = timeStamp()
			--format "Creating Batchscript took % seconds\n" ((end - start) / 1000.0)
			--start = timeS()
			dosOps.command ("p4 -s -x " + tempPath + " fstat> "+p4Ops.sourceControlLog)
			--end = timeStamp()
			--format "Creating Log file took % seconds\n" ((end - start) / 1000.0)
			--start = timeStamp()
			--read log file into stringstream
			ms=memStreamMgr.openFile p4Ops.sourceControlLog
			ms.eos()
			sstream=stringstream ""
			fAry=#()
			dlmtr="{"
			tstream=stringstream ""
			while (not(ms.eos())) do
			(
				local sstream=stringstream "",fmt="%"
				fmt2="%\n"
				--ms.skipSpace()
				--format (ms.readLine()) to:sstream
				format fmt (ms.readline()) to:sstream
				stringy=(sstream as string)+" "
				--if (sstream as string)=="error:" then
				jumpout=false
				if ( matchPattern stringy pattern:"*error:*") then
				(
					format fmt dlmtr to:tstream
					format fmt stringy to:tstream
					--format fmt dlmtr to:tstream
					--append statusAry 0
					jumpOut=true
					--print "p4 patternMatch=*error:*"
				)
				if ( matchPattern stringy pattern:"*depotFile*") and (not jumpout) then
				(
					format fmt dlmtr to:tstream
					format fmt stringy to:tstream
					jumpOut=true
					--print "p4 patternMatch=*depot:*"
				)
				if ( matchPattern stringy pattern:"*exit:*") and (not jumpout) then
				(
					format fmt dlmtr to:tstream
					format fmt stringy to:tstream
					jumpOut=true
					--print "p4 patternMatch=*exit:*"
				)
				if (not jumpout) then
				(
					format fmt stringy to:tstream
				)
			)
			--print (tstream as string)
			format "{\n" to:tstream
			close tstream
			--format "eof tstream=%\n" ((eof tstream) as string)
			seek tstream 0
			readDelimitedString tstream "{"
			while (not(eof tstream)) do
			(
				--print "IN WHILE"
				local sstream=stringstream ""
				breakOut=false
				exitLoop=false
				p4Ops.ek_filetocheckinfo = struc_File_Info readOnly:"" depotFile:"" clientFile:"" headAction:"" headTime:"" headRev:"" haveRev:"" actionOwner:"" otherOpen:""
				sstream=stringstream (readDelimitedString tstream "{")
				--stringy=readDelimitedString tstream "{"
				--print (ms.readblock "{" "}") to:sstream
				--print (sstream as string)
				seek sstream 0
				
				if (((skipToString sstream "exit" )!=undefined)or((sstream as string)=="\n"))and(breakOut!=true) then
				(
					exitLoop=true
					breakOut=true
				)
				seek sstream 0
				if ((skipToString sstream "error" )!=undefined)and(breakOut!=true) then
				(
					append statusAry 0
					append headRevsArray 0
					append haveRevsArray 0
					breakOut=true
				)
				seek sstream 0
				if ((skipToString sstream "depotFile " )!=undefined)and(breakOut!=true) then
				(
					p4Ops.ek_filetocheckinfo.depotFile=readDelimitedString sstream " "
					--format "p4Ops.ek_filetocheckinfo.depotFile=%\n" p4Ops.ek_filetocheckinfo.depotFile
					--print p4Ops.ek_filetocheckinfo.depotFile
				)
				if ((skipToString sstream "action " )!=undefined)and(breakOut!=true) then
				(
					p4Ops.ek_filetocheckinfo.headAction=readDelimitedString sstream " "
					--print p4Ops.ek_filetocheckinfo.headAction
					--format "p4Ops.ek_filetocheckinfo.headAction=%\n" p4Ops.ek_filetocheckinfo.headAction
					if (p4Ops.ek_filetocheckinfo.headAction=="add")then
					(
						--print p4Ops.ek_filetocheckinfo.otherOpen
						breakOut=true
						--format "File is Read Only. File in perforce. File checked out by someone else.\n"
						append statusAry 8
						append headRevsArray 1
						append haveRevsArray 1
						--format "p4Ops.ek_filetocheckinfo.headAction=%\n" p4Ops.ek_filetocheckinfo.headAction
					)
					else()
				)
				if ((skipToString sstream "otherOpen" )!=undefined) and(breakOut!=true)then
				(
					p4Ops.ek_filetocheckinfo.otherOpen=readDelimitedString sstream " "
					--print p4Ops.ek_filetocheckinfo.otherOpen
					breakOut=true
					--format "File is Read Only. File in perforce. File checked out by someone else.\n"
					append statusAry 3
					--format "p4Ops.ek_filetocheckinfo.otherOpen=%\n" p4Ops.ek_filetocheckinfo.otherOpen
				)
				seek sstream 0
				if ((skipToString sstream"actionOwner " )!=undefined)and(breakOut!=true) then
				(
					p4Ops.ek_filetocheckinfo.actionOwner=readDelimitedString sstream " "
					--print p4Ops.ek_filetocheckinfo.actionOwner
					breakOut=true
					--format "File in perforce. File checked out by you.\n"
					append statusAry 4
					--format "p4Ops.ek_filetocheckinfo.otherOpen=%\n" p4Ops.ek_filetocheckinfo.otherOpen
					--format "statusAry.count=%\n" statusAry.count as string
				)
				seek sstream 0
				if ((skipToString sstream"headRev " )!=undefined)and(breakOut!=true)  then
				(
					intVal=(readDelimitedString sstream " ") as integer
					p4Ops.ek_filetocheckinfo.headRev=intVal
					append headRevsArray intVal
					
					--format "p4Ops.ek_filetocheckinfo.headRev=%\n" p4Ops.ek_filetocheckinfo.headRev
					
				)
				seek sstream 0
				if ((skipToString sstream"haveRev " )!=undefined)and(breakOut!=true)  then
				(
					intVal=(readDelimitedString sstream " ") as integer
					p4Ops.ek_filetocheckinfo.haveRev=intVal
					append haveRevsArray intVal
					--format "p4Ops.ek_filetocheckinfo.haveRev=%\n" p4Ops.ek_filetocheckinfo.haveRev
				)
				/* else
				(
					if (breakOut!=true) then
					(
					breakOut=true
					--format "File is Local Only. File not in perforce.\n"
					append statusAry 6
					)
				) */
				if (p4Ops.ek_filetocheckinfo.haveRev!=p4Ops.ek_filetocheckinfo.headRev) and(breakOut!=true)then
				(
					--format "File in perforce. Your version is old so sync up.\n"
					breakOut=true
					append statusAry 5
				)
				if (breakOut!=true) then
				(
					append statusAry 2
					--Print "Added Uncaught value"
				)
			)
			--format  "fAry=%\n" (fAry as string)
			memStreamMgr.close ms
			close sstream
			close tstream
			--format "headRevsArray=%\n" (headRevsArray as string)
			--format "headRevsArray=%\n" (haveRevsArray as string)
			p4Ops.headRevAry=headRevsArray
			p4Ops.haveRevAry=haveRevsArray
			--end = timeStamp()
			--format "Parsing Log file and testing cases took % seconds\n" ((end - start) / 1000.0)
		)
		--format "fileList.count=%\n" (fileList.count) as string
		--format "statusAry.count=%\n" (statusAry.count) as string
		--format "statusAry last-1=%\n" (statusAry[((statusAry.count)-1)]) as string
		--format "statusAry last=%\n" (statusAry[(statusAry.count)]) as string
		--format "statusAry 31=%\n" (statusAry[31]) as string
		return statusAry
	),
	
	fn PrepFileForWriting theFile useSourceControl:true useP4Batch:false =
	(
		 --check path recursively and create necessary missing directory folders
		 --format "theFile1=%\n" theFile
		 local tempString = filterString theFile "\\/" -- break up string 
		 --format "tempString=%\n" tempString
		 --format "In fun_newprepfileforwriting\n"
		 thePathString ="" -- clear the old string
		 if tempString.count>1 then
		 (
			  local thePathString=""
			  for t = 1 to ((tempString.count)-1) do	-- rebuild string 
			  (
				   thePathString=thePathString + (tempString[t] + "/")
				   --format "thePathString=%\n" thePathString
				   if doesFileExist thePathString==False then
				   (
					 --format "Creating directory %\n" thePathString
					 makedir thePathString all:false
				   )
			  ) 
		 )
		 --if the file exists prep for overwrite 
		 if doesFileExist theFile == true then
		 (
		   if (getFileAttribute theFile #readOnly) != undefined then
		   (
				if useSourceControl == true then
				(
				  local e_status = checkFileStatus theFile
				  if (e_status)==6 then
				  (
					if useP4Batch==false then
					(
						try(dosOps.command ("p4 add \"" + theFile + "\""))catch(messagebox "Adding file")
					)
					else
					(
						format "%\n" ("p4 add \"" + theFile + "\"") to:p4Ops.p4batchscript
					)
				  )
				  if (e_status)==5 then
				  (
					if useP4Batch==false then
					(
						try(dosOps.command ("p4 sync -f \"" + theFile + "\""))catch(messagebox "Syncing file")
					)
					else
					(
						format "%\n" ("p4 sync -f \"" + theFile + "\"") to:p4Ops.p4batchscript
					)
				  )
				  if useP4Batch==false then
				  (
					try(dosOps.command ("p4 edit \"" + theFile + "\""))catch(messagebox "Problem with source control access")
				  )
				  else
				  (
					format "%\n" ("p4 edit \"" + theFile + "\"") to:p4Ops.p4batchscript
				  )
				)
				else
				(
					val=(getFileAttribute theFile #readOnly) level:2
					LogM ("getFileAttribute " + (theFile as string) + " #readOnly")
					if (val)!=false then 
					(
						if (queryBox ("Make "+theFile as string+" writeable, currently Read Only? Be careful, this may be dangerous.") title:"File is Read Only?") then
						(
							try
							(
								setFileAttribute (theFile) #readonly False
							)
							catch
							(
								stringy="Could not make "+theFile as string+" writeable!"
								messagebox stringy
							)
						)
					)
				)--end of else
			 )
			 else
			 (
			   LogM ("File not readonly " + (theFile as string))
			 )--end of else
		 )
		 else
		 (
		   LogM ((theFile as string) + " does not exist")
		   local FileOut = createFile theFile
			 
			if useSourceControl==true then
			(
			   if useP4Batch==false then
			   (
					--sleep(0.1)
					dosOps.command ("p4 add \"" + theFile+"\"")
			   )
			   else
			   (
					--format "theFile=%\n" theFile AS STRING
					--format "p4Ops.p4batchscript=%\n" p4Ops.p4batchscript AS STRING
				   format "%\n" ("Type NUL > \"" + theFile+"\"") to:p4Ops.p4batchscript
				   format "%\n" ("p4 add -t binary \"" + theFile+"\"") to:p4Ops.p4batchscript
				   --sleep(0.1)

				)
			)
			close FileOut
			FileOut=undefined
		 ) --end of else
	),
	
	fn GetRevisionUserName filename revision:#head =
	(
		if (p4Ops.p4Exist) then
		(			
			if revision == #head then (				
				local userName = ""
				local commandline = "p4 filelog -m 1 \"" + filename as string + "\" > "+ p4Ops.sourceControlLog as string
				LogM ("Command: " + commandline as string)				
				dosOps.command (commandline)
				--sleep(1)
				local f = undefined
				f = openFile p4Ops.sourceControlLog
				try (
					if (not eof f) then (
						
						if (skipToString f "..." )!=undefined then
						(
							stringy = readLine f
							--print ("stringy = " + stringy as string)
							filtered = filterString stringy " "
							--filtered=#("#34", "change", "738050", "edit", "on", "2010/05/26", "by", "alec.fredericks@alec.fredericks_default", "(binary+l)")
							userName = filtered[8]
						)
					) else (
						LogM ("Error while getting last submit user name. Perforce problem. Probably wrong workspace.") level:3
					)
				) catch ()
				if f != undefined then close f
				return userName
			)
		)		
	),
	
	fn GetHistory filename =
	(
		/*******************************************************************************
			<DOC> Checks perforce for a files history  
			Arguments:
				<filename>
			Return:
				<struct> 
		*******************************************************************************/
		if (p4Ops.p4Exist) then
		(
			--p4 filelog -l -m 1 "D:\\Perforce\\dev\\xcom\\ArtSource\\Character\\Rigs\\Male_MasterRig.max"
			--fileToCheck="D:\\Perforce\\dev\\xcom\\ArtSource\\Character\\Rigs\\Male_MasterRig.max"
			dosOps.command ("p4 filelog -l -m 1 \"" + filename + "\" > "+ p4Ops.sourceControlLog)
			--sleep(1)
			f=openFile p4Ops.sourceControlLog
			if (not eof f) then (
				if (skipToString f "..." )!=undefined then
				(
					stringy=readLine f
					filtered=filterString stringy " "
					--format "filtered=%\n" (filtered as string)
					--filtered=#("#34", "change", "738050", "edit", "on", "2010/05/26", "by", "alec.fredericks@alec.fredericks_default", "(binary+l)")
					--format "Version=%\n" filtered[1]
					--format "ChangeListNumber=%\n" filtered[3]
					--format "Date=%\n" filtered[6]
					--format "User=%\n" filtered[8]
					stringy=""
					while not (eof f) do
					(
						stringy+=readLine f
					)
					--format "Comments=%\n" stringy
				)
			)
			close f
		)
	),

	fn GetLatest fileList =
	(
		if (classof fileList != Array) then return false
		listy=createfile p4Ops.p4_addBatch
		try (
			for i in fileList do
			(
				format ("%\n") i to:listy
			)
		) catch ()
		close listy
		--Close p4Ops.p4batchscript
		dosOps.command ("p4 -s -x " + p4Ops.p4_addBatch + " sync")
		deletefile p4Ops.p4_addBatch		
	),
	
	fn Add filename filetype:"" changelist:"" =
	(
	/*******************************************************************************
		<DOC> Add a file to Perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/add.html#1040670
		Arguments:
			<string> filename:				Name of the file.
			<string> filetype:				Type of file (usually "text" or "binary")
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		/* filetype = getFiletype filetype
		changelist = getChangelist changelist
		
		dos ("p4 add " + filetype + changelist + " " +"\"" + filename + "\"") */
		dosOps.command ("p4 add " +"\"" + filename + "\"")
		
	),
	
	fn Lock filename =
	(
		dosOps.command ("p4 lock " +"\"" + filename + "\"")
	),
	
	fn Unlock filename =
	(
		dosOps.command ("p4 unlock " +"\"" + filename + "\"")
	),	
	
	-- Check if cangelist with description already exist. If yes, it returns it's CL number. If not it returns -1
	fn DoesChangelistExist description =
	(
		dosOps.command ("p4 changes -l -s pending -u "+ connectionStatus.username + " -c " + connectionStatus.workspace + " > " + p4Ops.sourceControlLog)
		local f = openFile p4Ops.sourceControlLog
		try (
			while (not(eof f)) do
			(
				local stringy = readline f
				if (matchpattern stringy pattern:("Change *")) then (
					local desc = readline f	-- skipping one empty line
					desc = readline f
					if (matchpattern desc pattern:("\t" + description)) then (	-- found description. Let's get changelist number
						local filtered = filterstring stringy " "
						close f
						deletefile p4Ops.sourceControlLog
						return filtered[2]
					)
				)
			)
		) catch ()
		close f
		deletefile p4Ops.sourceControlLog
		return -1
	),
	
	fn CreateChangelist description =
	(
		local existingCL = DoesChangelistExist description
		if (existingCL != -1) then ( return existingCL as number )
		-- create new changelist with description and return its number. Return -1 in case of error
		-- creating new changelist and getting description
		dosOps.command ("p4 change -o >" + p4Ops.sourceControlLog)
		
		local f = openFile p4Ops.sourceControlLog
		local s = ""
		-- searching for description and replacing it
		while (not(eof f)) do
		(
			local stringy = readline f
			if (matchpattern stringy pattern:("*" + newChangelistDesc)) then stringy = substituteString stringy newChangelistDesc (description as string)
			s += (stringy + "\n")
		)
		close f
		-- creating file with changed description
		f = createfile p4Ops.sourceControlLog2
		format "%" s to:f
		close f
		dosOps.command ("p4 change -i < " + p4Ops.sourceControlLog2 + " > " + p4Ops.sourceControlLog)
		-- reading P4 change result - to get changelist number
		f = openFile p4Ops.sourceControlLog
		local stringy = ""
		if (not eof f) then (
			stringy = readline f
		)
		close f
		deletefile p4Ops.sourceControlLog
		deletefile p4Ops.sourceControlLog2
		if (matchpattern stringy pattern:(newChanglelistNumber[1] + "*" + newChanglelistNumber[2])) then (
			stringy = substituteString stringy newChanglelistNumber[1] ""
			stringy = substituteString stringy newChanglelistNumber[2] ""
		) else return -1
		return stringy as number		
	),
	
	fn Change descr:"" = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Create a new changelist.  Uses DOSCommand only, since if it is hidden and the
		user does not create a new list, will freeze up max.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/change.html#1040665
		Arguments:
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		if descr == "" then
			dosOps.command "p4 change"
		else
		(
			createSpec descr
		)
	),
	
	fn Delete filename changelist:"" = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Delete a file from Perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/delete.html#1040665
		Arguments:
			<string> filename:				Name of the file.
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		changelist = getChangelist changelist
		
		dosOps.command ("p4 delete " + changelist + " " +"\"" + filename + "\"")
	),
	
	fn Edit filename filetype:"" changelist:"" = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Check out a file from perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/edit.html#1040665
		Arguments:
			<string> filename:				Name of the file.
			<string> filetype:				Type of file (usually "text" or "binary")
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		filetype = getFiletype filetype
		changelist = getChangelist changelist
		
		dosOps.command ("p4 edit " + filetype + changelist + " " +"\"" + filename + "\"")
	),
	
	fn Lock filename changelist:"" = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Locks a file in Perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/lock.html#1040665
		Arguments:
			<string> filename:				Name of the file.
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		changelist = getChangelist changelist
		
		dosOps.command ("p4 lock " + changelist + " " +"\"" + filename + "\"")
	),
	
	fn Obliterate filename = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Removes a file and all history from Perforce.  USE WITH CAUTION.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/obliterate.html#1040665
		Arguments:
			<string> filename:				Name of the file.
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		dosOps.command ("p4 obliterate " +"\"" + filename + "\"")
	),
	
	fn Reopen filename filetype:"" changelist:"" lock:false = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Reopen a file in Perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/reopen.html#1040665
		Arguments:
			<string> filename:				Name of the file.
			<string> filetype:				Type of file (usually "text" or "binary")
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		filetype = getFiletype filetype
		changelist = getChangelist changelist
		
		dosOps.command ("p4 reopen " + changelist + filetype + " " +"\"" + filename + "\"")
	),
	
	fn Revert filename changelist:"" unchanged:false keep:false = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Reverts a file from perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/revert.html#1040665
		Arguments:
			<string> filename:				Name of the file.  Useful with wildcards.
			<string> changelist:			Add to specified changelist
			<bool> unchanged:				If true, revert unchanged files only.
			<bool> keep:					If true, keep workspace files (remove from changelists/server records,
												but keep unchanged in client workspace)
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		if unchanged then
			unchanged = " -a"
		else
			unchanged = ""
		
		if keep then
			keep = " -k"
		else
			keep = ""
		changelist = getChangelist changelist
		
		dosOps.command ("p4 revert " + unchanged + keep + changelist +"\"" + filename + "\"")
	),
	
	fn Unlock filename changelist:"" = --UNTESTED
	(
	/*******************************************************************************
		<DOC> Unlocks a file in Perforce.
		http://www.perforce.com/perforce/doc.081/manuals/cmdref/unlock.html#1040665
		Arguments:
			<string> filename:				Name of the file.
			<string> changelist:			Add to specified changelist
		Return:
			<bool> True on success, false on failure.
	*******************************************************************************/
		changelist = getChangelist changelist
		
		dosOps.command ("p4 unlock " + changelist + " " +"\"" + filename + "\"")
	),
	
	fn Init =
	(
		myLog = sLS3DLog()
		myLog.Init()		
		LogM "P4 Library - Init"
	)
)--end struct


struct sP4Connect
(
	myLog = undefined,

	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn LogM message level:1 maxListener:false =
	(
		myLog.LogMessage message level:level maxListener:maxListener
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_GetUserName =
	(
		if (p4Ops != undefined) then
		(
			local userName = (p4Ops.GetConnectionStatus()).userName
			return userName
		) else (
			return ""
		)
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_Checkout fileList changelist =
	(
		if (p4Ops != undefined) then
		(
			p4Ops.EditFiles fileList clNumber:changelist
			return true
		) else (
			return false
		)
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_GetLatest fileList =
	(
		if (p4Ops != undefined) then
		(
			p4Ops.GetLatest fileList
		) else (
			return false
		)
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_CreateChangelist description =
	(
		if (p4Ops != undefined) then
		(
			return (p4Ops.CreateChangelist description)
		) else (
			return -1
		)		
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_AddFiles fileList changelist =
	(
		if (p4Ops != undefined) then
		(
			p4Ops.AddFiles fileList clNumber:changelist
			return true
		) else	 (
			return false
		)
	),
	
	fn P4_GetRevisionUserName file revision:#head =
	(
		if (p4Ops != undefined) then
		(
			return p4Ops.GetRevisionUserName file revision:revision
		) else	 (
			return undefined
		)		
	),
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4_CheckFileStatus file = 
	(
		local result = -1
		if (p4Ops != undefined) then
		(
			result = p4Ops.CheckFileStatus file
			LogM("Getting P4 status for: " + file + "   result = " + (result as string))
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
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	fn P4Init = 
	(
		if p4Ops != undefined then (
			if (p4Ops.TestConnected() == false) then (
				LogM ("P4 script support is not active. Perforce connection was not established. Check your P4 login and environment variables settings.") level:3 maxListener:true
			) else (
				connectionStatus = p4Ops.GetConnectionStatus()
				LogM "----------------------------------------------------------------------------------"
				LogM ("P4 script support is active.") maxListener:true
				LogM ("User name: " + connectionstatus.userName)
				LogM ("Client host: " + connectionstatus.clientHost)
				LogM ("Active workspace: " + connectionstatus.workspace) maxListener:true
				LogM ("Workspace root: " + connectionstatus.clientRoot)
				LogM "----------------------------------------------------------------------------------"
			)			
		) else (
			LogM ("P4 script support is not active. p4Ops not found. Get latest exporter and if it does not help TTP this.") level:3 maxListener:true
		)
	),
	fn init =
	(
		myLog = sLS3DLog()
		myLog.Init()		
		LogM "P4 support library - Init"
		P4Init()
	)
)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (dosOps == undefined) then ( dosOps = dosOpsDef() )
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if (p4Ops == undefined) then (	
	p4Ops = p4OpsDef() 
	p4Ops.Init()
--	p4Ops.testConnected()
--	p4Ops.CheckFileStatus (@"d:\!2k_games\whiskey_dev_main\resources\city\bourbon_city\districts\03_downtown\bc_city03_downtown_north_block_a.max")
--	a = p4Ops.CreateChangelist "teeeeest"
--	p4Ops.AddFiles #(@"d:\!2k_games\whiskey_dev_main\resources\city\bourbon_city\districts\03_downtown\bc_city03_teeeeeeest.max") clNumber:a
--	p4Ops.EditFiles #(@"d:\!2k_games\whiskey_dev_main\resources\city\bourbon_city\ground_material\bc_terrain.mat") clNumber:313795
--	p4Ops.getDepotPath()
--	p4Ops.GetLatest #(@"d:\!2k_games\whiskey_dev_main\resources\city\bourbon_city\ground_material\bc_terrain.mat")
)

if (gP4 == undefined) then (
	gP4 = sP4Connect()
	gP4.Init()
)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



