--ProSequencer   Jonathan de Blok - jonathan@jdbgraphics.nl 

global prosequencer
global SMTDFunctions = undefined
global SMTDSettings = undefined
global SMTDPaths = undefined 

try ( seq_destroy() ) catch()

--close any active Prism dialogs
lpm_dialogs=#(LPMPassSelectRoll,  LPM_renderRo ,  LPM_netRenderRo ,  LPM_progressRO ,  wildCardRO ,  atmRollout ,  ModifierOverRollout ,  SelectLayarRoll ,  commonRollout ,  AboutRo ,  savePresetRo ,  pickPasses_RO ,  objectSetProps ,  lightSetProps ,  photoStudio_Ro ,  LPMVrayGI ,  AutoMaskRoll ,  MultiformatRoll ,  LPM_treeview_rollout )
dfound = for d in lpm_dialogs where (d!=undefined) collect d

if (dfound.count>0) do
(
	if (querybox("For correct interaction with ProSequencer Prism needs to be restarted.\nDo you want to close all dialogs now?")) do
	(
		for d in dfound do
		(
			try (cui.unRegisterDialogBar  d ) catch()
			try(destroyDialog d) catch ();
			execute (d.name+"=undefined;")
		)	
	)
)	
	
fn GetDeadlineCommandInfo theArgument = --this function can be called to get info from Deadline based on the argument
( 
		/*credits:
		Snippet taken from a post from Bobo on cgtalk.. altered a bit by me :)
		*/
		local submitOutputFile = sysInfo.tempdir + "submitOutput.txt" --the output of DeadlineCommandBG goes into two files. This one contains the output
		local submitExitCodeFile = sysInfo.tempdir + "submitExitCode.txt" --the other contains the exit code. When the code is 0, everything went ok.
		try --we will run this in an error trap to ensure we catch any crashes, for example if deadlineCommandBG is not accessible due to wrong Environment PATH settings
		( 
			local result = -2 --we initialize the exit code variable to -2 which will mean "general error"
			deleteFile submitOutputFile --we also make sure any existing output files are removed
			deleteFile submitExitCodeFile --before we create new ones
			local commandArguments = "-outputfiles \"" + submitOutputFile + "\" \"" + submitExitCodeFile + "\" -"+theArgument --we build a command line with our files and arguments
			ShellLaunch "deadlinecommandbg.exe" commandArguments --and call deadlinecommandbg using shellLaunch, thus avoiding the black box of the MAXScript DosCommand
			local startTimeStamp = timestamp() --we initialize a timestamp to measure the time out
			local ready = false --and we set a flag to notify the following loop when we are done waiting
			while not ready do --the while loop will continuously check for the existence of the output files
			( 
				sleep 0.15 --we wait 0.15 seconds and try again
				if doesFileExist submitExitCodeFile do --if the exit code file exists, the doscommandbg finished executing
				( 
					local theFile = openFile submitExitCodeFile --so we try to read the exit code file first
					try(result = readValue theFile)catch(result = -2) --we read a single value from it and it we fail, we assume error -2
					try(close theFile)catch() --and we try to close the file if it was actually opened.
					ready = true --now we can raise the flag that we are done waiting
				)	
				if timestamp() - startTimeStamp > 10000 then --if we haven't received an answer within 10 seconds, we time out
				( 
					result = -3 --by setting the error code to -3 (which will mean operation timed out)
					ready = true --and we raise the flag to exit the loop
				)--end if
			)--end while loop
			if( result == 0 ) then --now we check to see if the result read from the file was 0 (no errors)
			( 
				local resultFile = OpenFile submitOutputFile --and if it was 0, we try to read the message from the second file
				local resultMsg = "" --we initialize a variable to hold the message
				if (resultFile != undefined) do --and if the file handle is valid, 
				( 
					resultMsg = readLine resultFile  --we read the line from the file
					close resultFile --and close the file
				)--end if
				return resultMsg  --we can now return the message as the result of the function
			)
			else --otherwise we had an error and have to print what kind of error it was
			( 
				if result == -3 then --if it was a timeout error, we print one message
					format "Timed out calling DeadlineCommandBG.\n"
				else --of it was anything else like -1 or -2, we print a more general error message
					format "Failed to get Info from DeadlineCommandBG.\n"	
			)
		)
		catch 
			format "Error calling DeadlineCommandBG\n" --if there was a real crash, we also print an error message. This usually means Deadline is not correctly installed
		false --we return false in the case of any error
	)--end fn
	
	
function fn_deadlineSubmitPrepare =
(

	theNetworkRoot = GetDeadlineCommandInfo "getrepositoryroot"
 
	if (theNetworkRoot!=false) then
	(
	
	if (SMTDFunctions == undefined) do
	(
		if theNetworkRoot != false do 
		(			
			local remoteScript = theNetworkRoot + @"\submission\3dsmax\main\SubmitMaxToDeadline_Functions.ms" 
			
		  if (doesFileExist remoteScript AND SMTDFunctions == undefined ) then
			(
				fileIn remoteScript 
				SMTDFunctions.loadSettings()
				print "SMTDFunctions loaded"		 
			) else
			(
						messagebox("Failed to reach Deadline's repo location at \"" + theNetworkRoot + "\". Aborting render.");
				return false
			)
		)		
	)
		return true
	) else
	(
		messagebox("Failed to get Deadline's repo location! Aborting render.");
		return false
	)
)

function sanityCheck =
(
	result=true
	msg="";
	if (maxFileName=="") do ( result=false; msg="-Max scene needs to be saved first\n" )
	if (  rendOutputFilename == "" ) do ( result=false; msg += "-No renderoutput filename\n" )
	if ( (getFilenameType rendOutputFilename) == "" ) do ( result=false; msg += "-No file extension\n" )
	
	if (msg != "") do (messagebox msg)
	
	if (result  AND getFilenameType rendOutputFilename==".exr" AND  ProSequencer.cs_settings.use_auto_pass == true )  then
	(
		try(
		macros.run "jdbgraphics" "AutoPass"	
		) catch ( print "Error during autopass")
	)  else
	(
		print "Skipping AutoPass, output not EXR and/or AutoPass has been disabled"
	)
	
	if (viewport.numViews==1) do
	(	 
		max tool maximize
	)

	
	return result
)

function fn_deadlineSubmitExecute cam =
(
	/*credits:
	Snippet taken from Klaas Nienhuis's DL tutorial, who took parts of it from Bobo.. altered a bit by me :)
	*/

	if (sanityCheck()) do ( 
			
		local maxFileToSubmit = SMTDPaths.tempdir + timestamp() as string +"_"+maxFileName
		SMTDFunctions.SaveMaxFileCopy maxFileToSubmit

		local SubmitInfoFile = SMTDPaths.tempdir + "max_submit_info.job"
		local JobInfoFile = SMTDPaths.tempdir  + "max_job_info.job"
		SMTDFunctions.CreateSubmitInfoFile SubmitInfoFile 
		SMTDFunctions.CreateJobInfoFile JobInfoFile  forceCamera:cam.name 
		
		local initialArgs="\""+SubmitInfoFile+"\" \""+JobInfoFile+"\" \""+maxFileToSubmit+"\" "
		
		if ( doesfileExist SMTDSettings.preFrameScriptfile ) then
		(		
			initialArgs += "\"" + SMTDSettings.preFrameScriptfile  + "\" " --add this line to include the maxscriptfile in the scene submission
		) else
		(
			print "No PreFrameScriptfile activated, skipping.";	
		)
		
		
		--submit the file
		SMTDFunctions.waitForCommandToComplete initialArgs SMTDSettings.TimeoutSubmission
		
	)
)

if ((getDirectories   (getdir #userscripts+@"\ProSequencer")).count == 0) do
(
	makeDir  (getdir #userscripts+@"\ProSequencer")
)
 
if (  getIniSetting (getMAXIniFile()) #Performance #AutoPlayPreview   !="0" ) do
(
	messageBox "Please disable 'Autoplay Preview file' in the 'Preferences/General'-tab for proper operation of ProSequencers preview features"
	max file preferences
)	

global seq_cleanup

fn seq_trash =
(
 
	callbacks.removeScripts id:#seq_saveEdit
	callbacks.removeScripts id:#seq_loadEdit
	callbacks.removeScripts id:#seq_preload
	callbacks.removeScripts id:#seq_reset
	callbacks.removeScripts id:#seq_prereset
	callbacks.removeScripts id:#seq_postreset
	callbacks.removeScripts id:#seq_new
	callbacks.removeScripts id:#animrange
	callbacks.removeScripts id:#nodeRename
	callbacks.removeScripts id:#nPreDelete
	unRegisterTimeCallback seq_TrackTime 
) 

fn seq_destroy =
(
 	try(destroydialog ProSequencer.CSSettings) catch()
	try(cui.UnregisterDialogBar ProSequencer) catch()
	try(destroydialog ProSequencer) catch()
	
 
 
	seq_trash()	
)

global seq_TrackTime
global seq_panel
global seq_track=#();
global seq_nav=#();
global seq_action=0;	
global seq_OnTick
global seq_debug
global seq_uiscale

try (seq_uiscale= GetUiScaleFactor()) catch (seq_uiscale=1.0)

fn seq_debug str =
(
 -- print str
)

fn setCam cam =
(
	viewport.setCamera cam
	
	try
	(
		LPM_ProSequencerPlay()
	)
	catch()

)
	
struct seq_tr_tag  -- dummy struct to trick out of scope data loader (keep properties in sync with ProSequencer.seq_tr_tag! )
(
  sData,  r_start, r_end, ss,se, i, cam, label, enabled, stateset, camname, version, meta
)

struct seq_nav_tag
(
  sData, fac, range_length, range_start, range_max_length, time_min, time_max , w_start,w_end , ss, se,i , panel_width, drag_start, showhide
)

struct seq_settings
(
  preview_output, render_output, preview_quality, render_outputfile, use_auto_pass, handles
)

fn seq_OnTick s e =
(  
	hwd=0
	elms=#()
 	flang=0
	for hDlg in UIAccessor.GetPopupDialogs() do
	(
		lang= findItem ProSequencer.MakePreviewTrans ((UIAccessor.GetWindowText hDlg) as string )
		 
		if(lang >0) then
		(
			elms=UIAccessor.GetChildWindows hDlg
			hwd=hDlg
			flang=lang
		)
	)


	if (elms.count>20 and flang>0) do
	(
		
		ProSequencer.ttm.Stop()
		dotnet.removeAllEventHandlers ProSequencer.ttm
		i=ProSequencer.cur_track	

		start=seq_track[i][2].tag.value.r_start
		end=(seq_track[i][2].tag.value.r_end-1)
		
		if (seq_track[i][2].tag.value.r_end - seq_track[i][2].tag.value.r_start > 1) do
		(
			start=seq_track[i][2].tag.value.r_start -    prosequencer.cs_settings.handles
			if (start<0) do (start=0)
			end=(seq_track[i][2].tag.value.r_end-1) + prosequencer.cs_settings.handles
		)
		
		if ((maxVersion())[1] > 14000) then
		(
			ProSequencer.setValue elms[9] end
			ProSequencer.setValue elms[5]  start
		) else
		(
			ProSequencer.setValue elms[17] end
			ProSequencer.setValue elms[9]  start
		)
		
		if (ProSequencer.auto_preview==true) do
		(
			UIAccessor.PressButtonByName hwd (ProSequencer.CreateTrans[flang])
		)
		 
		ProSequencer.ttm.Stop()
	)
)
		
		
fn seq_TrackTime = (
 
	f =currentTime as integer / ticksperframe 
	ProSequencer.seq_playhead.left=(ProSequencer.keyToScreen f) + (35*seq_uiscale) + ProSequencer.padding_left
	
	if ((ProSequencer.seq_playhead.left> seq_nav[5].width + seq_nav[5].location.x + ProSequencer.padding_left) or ( ProSequencer.seq_playhead.left <   seq_nav[5].location.x + ProSequencer.padding_left - (35 * seq_uiscale)   ) ) then
	( 
		ProSequencer.seq_playhead.visible=false
	) else (
		ProSequencer.seq_playhead.visible=true
	)
 
	 ProSequencer.timeChange f
 
	if (isAnimPlaying() == false) do
	(
		ProSequencer.refresh()
	)
)
	
fn nodeRenamed  =
(
 
	n=callbacks.notificationParam()
	c=n[3]
	nid=c.inode.handle
 
	stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin"
	stateSets = stateSetsDotNetObject.Instance
	_masterState = stateSets.EntityManager.RootEntity.MasterStateSet
	
	for i= 1 to  seq_track.count do
	(
		if (seq_track[i][2].tag.value.cam==nid) do
		(
	 
			ProSequencer.setLabel seq_track[i][2] n[2]
			seq_track[i][4].Text=n[2]
			
			if (seq_track[i][2].tag.value.stateset!=undefined) do
			(
				--ProSequencer.renameStateSet _masterstate.children 2 n[2] n[1]
			)
		)
	)
)

fn nodeDeleted  =
(
 
	n=callbacks.notificationParam()
	if (n!=undefined) do
	(
		nid= n.inode.handle
		for i= 1 to  seq_track.count do
		(
			if (seq_track[i][2].tag.value.cam==nid) do
			(
				 seq_track[i][2].tag.value.cam=undefined
				 ProSequencer.setLabel seq_track[i][2] n[2]
			)
		)
	)
)

rollout ProSequencer "ProSequencer" width:1000 height:19
(

 	mapped fn setLifetimeControl control = dotnet.setLifetimeControl control #dotnet
 	 
	dotnetcontrol seq_panel "UserControl" pos:[2,0] width:(1000)  height:20 across:3 	 
	
	struct seq_tr_tag
	(
	  sData,  r_start, r_end, ss,se, i, cam, label, enabled, stateset, camname, version, meta
	)
 	
	struct seq_nav_tag
	(
	  sData, fac, range_length, range_start, range_max_length, time_min, time_max , w_start,w_end , ss, se,i , panel_width, drag_start, showhide
	)
	
	struct seq_settings
	(
	  preview_output, render_output, preview_quality, render_outputfile, use_auto_pass, handles
	)

	struct trackData
	(
	   id, clipStart, clipEnd, clipLength, cam, stateSetId, enabled, selected, version, meta
	)

	local uiscale
	local version=1991   -- dont forget to match versions in the mzp_builder/mzp.ini
	local product="prosequencer"
	local vlab="ProSequencer v"+ ((version)/1000.0) as string   
	local MakePreviewTrans = #("Make Preview", "Vorschau erstellen", "Créer aperçu" )
	local CreateTrans = #("Create","Erstellen",  "Créer" )
	local demomode=false
	local track_width=1000
	local track_height 
	local seq_playhead 
	local maxv=(maxVersion())[1]
	local app_data_id=42   --change if conflicts with other plugins that store data in rootnode under then same ID, id+1 is used as well.
	local	ToolTipObj = dotnetobject "System.Windows.Forms.ToolTip"
 	local dnColor = dotnetclass "System.Drawing.Color"
 	local dock = dotnetclass "DockStyle"
	local con = dotNetClass "system.windows.forms.control"
	local	ttm = dotnetobject "System.Timers.Timer"
 	local slidepanel
	local onNavTransform
	local transformUpdate
	local mouse_action=""
	local click_item=""	
	local keyToScreen
	local screenToKey
	local key_size=1.0;
	local setLabel
	local getActiveCam
	local onPickCam
	local removeCam
	local setValue
	local Toggle
	local seq_reset
	local trackAdd
	local trackRemove
	local onTrackRemove
	local setHeight
	local doCloudRenderThis
	local onCloudRenderThis
	local onCloudRenderAll
	local ui_toggle
	local ui_active
	local ui_sync
	local getColor
	local trackSelect
	local ignoreAnimRangeEvent = true
	local ignoreChangeEvent = false
	local ignoreTimeChangeEvent = false
	local ignoreNavChangeEvent = false
	local busyAnimRangeEvent = false
	local changeMade
	local zoomTime
	local color_highlight = getColor(#(173, 216, 230))
	local onSliderDoubleClick
	local color_camera_default = (color 87 120 204)	
	local color_camera_cur_track = (color 225 198 87)
	local color_camera_active = (color 227 10 10)
	local color_slider =getColor(#(240, 240, 240))
	local color_slider_dis = getColor(#(175, 175, 175))
	local color_zebra_a =  getColor((colorMan.getColor #background)  * 255 + 30) 
	local color_zebra_b = getColor((colorMan.getColor #background)  * 255 + 20) 
	local color_background = getColor((colorMan.getColor #background)  * 255)
	local seq_ruler	
	local auto_preview=false	
	local onKey
	local resetDelay=0
	local handle2cam
	local refresh
	local timeChange
	local onProSequencerResized
	local getViewport
	local setTrackRange
	local loadEditFromScene
	local saveEditToScene
	local updateCamLabels
	local updateTimeRange
	local  padding_left
	local  padding_right
	local onPreviewThis
	local onPreviewAll
	local cur_track
	local active_cam
	local makeSlidePanel
	local resetting=false
	local movePreviewFile
	local getProjectPreviewPath
	local getProjectPreviewFile
	local getTrackOutputName
	local getProjectPath
	local getPreviewPath
	local getProjectRenderFile
	local getProjectRenderFileDeadline
	local getProjectRenderPath
	local onRenameCams
	local onRenameSS
	
	local syncTrackWidth
	local ui_match
	local onLinkStateSet
	local onUnlinkStateSet
	local getActiveState
	local findState
	local setState
	local getState
	local getDup
	local onDisable
	local onEnable
	local onExploreRender
	local onSettings
	local ui_setting
	local saveConfigToScene
	local loadConfigFromScene
	local cs_settings = seq_settings "" "" 0 ""
	local CSSettings
	local isLicenced
	local ui_help
	local trackRemoveInternal
	local settings
	local getSequenceData
	local checkLic
	local onSendToVP
	local onPickVPCam
	local onAutoSetup
	local onRangeFromKeys
	local removeFromScene
	local trackReorder
	local getSetting
	local setSetting
	local getRenderRange
	local onToggleAutoStart
	local onToggleJumpGap
	local onToggleNLP
	local onToggleIgnoreSS
	local onToggleVFB
	local GetMSS
	local onToggleUpdateCheck
	local updateCheck
	local hasStates
	local seq_snaphead
	local stopRedraw
	local resumeRedraw
	local ph_scrub
	local ph_up
	local ph_down
	local scrubbing=false
	local getKeyWidth
	local chekcLic
	local option_jump_gap
	local option_nlp
	local option_ignore_statesets
	local option_filter_vfb
	local dispose
	local bakeMaster
	local multitrack=#()
	local	stateSetsDotNetObject 
	local	stateSets  
	local	masterState  
	local oldPos = 0
	
	local  onSetVersion
	local  onSetMeta
	local  onSetVersionAll
	local  onSetMetaAll
	local onTrackDup
	
	
	fn ph_scrub s e=
	(
		c = dotnetclass "System.Windows.Forms.Cursors"
		s.Cursor.Current =  c.SizeWE  --else c.Default
	
		if (scrubbing == true) do
		(
			q=slidertime +  screenToKey e.x - animationrange.start 
			his=0
			snaps=#()
			
			if ( e.Button == e.Button.Left AND con.modifierKeys==con.modifierKeys.Shift  ) do
			(
				for i= 1 to  seq_track.count do
				(
						appendIfUnique  snaps seq_track[i][2].tag.value.r_start
						appendIfUnique  snaps seq_track[i][2].tag.value.r_end
				)
				appendIfUnique  snaps (animationrange.start as integer/ticksperframe)
				appendIfUnique  snaps ((animationrange.end ) as integer/ticksperframe)
				appendIfUnique  snaps 0
				
				snapto=undefined
				sort snaps
						
				seq_snaphead.height=seq_playhead.height
				his=8/getKeyWidth()
			)
		
			if (his>1) do
			(
				for n in snaps do
				(
					if (abs(q-n)<his) do ( q=n;  )
				)
			)

			slidertime = q
		)
	)
	
	fn ph_up s e=
	(
		 scrubbing=false
	)
	
	
	fn ph_down s e=
	(
		  scrubbing=true
		
		if (e.clicks ==1) do
		(
			 stopanimation()
		)
		
		
		if (e.clicks ==2 and scrubbing == false) do
		(
			if (NOT isanimplaying()) then
			(
				playanimation()	
			)
		)
		
	)
	
	fn stopRedraw=
	(
		WM_SETREDRAW=0xB
		windows.sendmessage seq_panel.Handle WM_SETREDRAW 0 0
	)
	
	fn resumeRedraw=
	(
		WM_SETREDRAW=0xB
		windows.sendmessage seq_panel.Handle WM_SETREDRAW 1 0
		seq_panel.Invalidate()
	)
	
	fn updateCheck =
	(
	 
		frc=false
		
		if (getSetting "options" "auto_update_check" == "1") do
		(
			lastCheckTicks =   (getINISetting  (getdir #userScripts+@"\ProSequencer\ProSequencer.ini") "system" "last_update_check") as Integer64
			if (lastCheckTicks==0L OR lastCheckTicks==undefined) do 
			(
				lastCheckTicks = 0L;
				setINISetting  (getdir #userScripts+@"\ProSequencer\ProSequencer.ini") "system" "last_update_check" (0L as string)
			)
			nowTicks = (dotNetClass "System.DateTime").Now.Ticks;
			lastCheckSpan = dotNetObject "System.TimeSpan" (nowTicks - lastCheckTicks);

			if  ((lastCheckSpan.totalDays as integer) > 6 OR frc==true OR  lastCheckTicks==0L) do
			(
				 
				setINISetting  (getdir #userScripts+@"\ProSequencer\ProSequencer.ini") "system" "last_update_check" (nowTicks as string)

				rollout httpSock "httpSock" width:0 height:0
				(
					activeXControl port "Microsoft.XMLHTTP" setupEvents:false releaseOnClose:false
				);
				createDialog httpSock pos:[-100,-100];
				destroyDialog httpSock;
		 
				httpSock.port.open "GET" ("http://www.jdbgraphics.nl/updates/check.php?product=prosequencer&version=" + version as string) false;
				httpSock.port.setrequestheader "If-Modified-Since" "Sat, 1 Jan 1900 00:00:00 GMT";
				httpSock.port.send();

				res=httpSock.port.responsetext
				
				if (res=="1") then
				(
					v=((version/100)/10.0) as string 
				
					r=querybox ("Update for ProSequencer is available! Go to download page?")
					if (r==true) do
					(
						shellLaunch "	http://www.jdbgraphics.nl/prosequencer-updates" ""
					)
				)
			)
		)
	)
	
	fn trackReorder src t = 
	(
		trg=src+t 

		if (trg>0 AND trg< seq_track.count+2) do
		(
			if (t<0) do
			(						
				for i = 1 to (t * -1   ) do
				(
					swap	seq_track[src-i+1][2].tag   seq_track[src-i][2].tag 
					swap	seq_track[src-i+1][2].tag.value.i  seq_track[src-i][2].tag.value.i 
					swap seq_track[src-i+1][2].Backcolor  seq_track[src-i][2].Backcolor 
				)
			)

			if (t>0) do
			(						
				for i = 1 to (t - 1  ) do
				(
					swap	seq_track[src+i][2].tag   seq_track[src+i-1][2].tag 
					swap	seq_track[src+i][2].tag.value.i  seq_track[src+i-1][2].tag.value.i 
					swap seq_track[src+i][2].Backcolor  seq_track[src+i-1][2].Backcolor 
				)
			)	
			
			transformUpdate 0
		)
	)
		
	
	fn onAutoSetup s e =
	(
		r=querybox ("Are you sure?\nThis will replace all tracks with selected cameras.\nRanges are set to match each camera's first and last keys.") 
		if (r==true) do
		(
			
			toggle 2
			
			for i= 1 to seq_track.count do
			(	
				trackRemoveInternal 1
			)
			
			seq_track=#();
			i=1;
			for obj in selection do
			(
				
				if (superclassof obj == camera ) do
				(
					trackAdd()
					seq_track[i][4].Text=obj.name
					seq_track[i][2].tag.value.cam=obj.inode.handle
					setLabel seq_track[i][2] ""
					onRangeFromKeys i -1
					i = i +1
				)
			)
			
			changeMade "track"
			timeChange currentTime	
			
			toggle 1
		)
	)
	
	fn onSendToVP s e=
	(
		i=s.parent.Tag
		curCam=undefined
		if (seq_track[i][2].tag.value.cam!=undefined) do
		(
			curCam=handle2cam seq_track[i][2].tag.value.cam  
			if (curCam != undefined) do
			(
				setCam curCam
			)
		)
	)
	
	fn getSequenceData =
	(
		out=#()

		for i= 1 to  seq_track.count do
		(	
			tag=seq_track[i][2].tag.value
		 
			curCam=undefined
			if (seq_track[i][2].tag.value.cam!=undefined) do
			(
				curCam=handle2cam tag.cam    
			)
		
			if (tag.enabled!=false) then (en=true) else (en=false)
			if (i==cur_track) then (sel=true) else (sel=false)
			
			td=trackData()
			td.id=i
			td.cam=curCam
			td.stateSetId=tag.stateset 
			td.clipStart=tag.r_start 
			td.clipEnd=tag.r_end
			td.clipLength=(tag.r_end - tag.r_start)
			td.enabled=en
			td.selected=sel
			append out td
		)
		
		out
	)

	
	fn checkSettings msg = 
	(
		out=true
		if (cs_settings.preview_output=="") do
		(
			if  ( (getSetting "options" "jdb") == "2") then
			(
					cs_settings.preview_output= "{jdb}/previews/preview_{camera}_{version}.avi"
			) else
			(
				cs_settings.preview_output= "{project_folder}/previews/preview_{camera}.avi"
				out=false
			)
		)

		if (cs_settings.render_output=="") do
		(
			if  ( (getSetting "options" "jdb") == "2") then
			(
				cs_settings.render_output="{jdb}/CGI/{camera}_{version}/" 
			) else
			(
				cs_settings.render_output="{project_folder}/renderoutput/{camera}/" 
				out=false
			)
		)
		
		if (cs_settings.render_outputfile=="") do
		(
		
			if  ( (getSetting "options" "jdb") == "2") then
			(
					cs_settings.render_outputfile="{camera}_{version}.exr" 
				out=false
			
			) else
			(
				cs_settings.render_outputfile="{camera}.exr" 
				out=false
			
			)
			
		)
		
		
	
		
		if (out==false and msg==true) do
		(
		 
			messageBox("Aborting: Output basepath and filename not configured. \nValues are now set to default, please review.")
			Settings()
		)
		
	  out
	)
	
		
	fn getSetting cat var = (
		data=getINISetting  (getdir #userScripts+@"\ProSequencer\ProSequencer.ini") cat var
		data
	)
	
	fn setSetting cat var val= (
 
		if ( cat!=undefined AND var!=undefined and val!=undefined and cat!="" and var!="" and val!="") do
		(
			
			setINISetting  (getdir #userScripts+@"\ProSequencer\ProSequencer.ini") cat var (val as string)
		)
	)
	
	fn isLicenced = (
		return true
	)
	
	fn checkLic lic= 
	(	 
		return true;
	)
	
	fn chekcLic lic =
	(
		return true;
	)
	
	fn onSettings s e=
	(
		ProSequencer.loadConfigFromScene()
		checkSettings false 
		settings()		
	)
	
	fn settings=
	(
		rollout CSSettings "ProSequencer Settings" width:560 height:608
		(
			button 'btn_cancel' "Cancel" pos:[352,568] width:80 height:24 align:#left
			button 'btn_Save' "Save" pos:[448,568] width:80 height:24 align:#left
			GroupBox 'grp1' "ProSequencer Project Settings" pos:[8,8] width:544 height:544 align:#left
			edittext 'inp_preview' "" pos:[24,72] width:440 height:16 align:#left
			label 'lbl3' "Output path*" pos:[24,56] width:224 height:16 align:#left
			button 'btn_preview' "Browse" pos:[472,72] width:56 height:16 align:#left
			edittext 'inp_render' "" pos:[24,184] width:440 height:16 align:#left
			label 'lbl4' "Render output base path:*" pos:[24,168] width:152 height:16 align:#left
			button 'btn_Render' "Browse" pos:[472,184] width:56 height:16 align:#left
			label 'lbl6' "Available tokens for basepath and filename:" pos:[24,248] width:224 height:16 align:#left
			label 'lbl15' "{camera}{cameraDup}{stateset}{track_id}{project_folder} {scene_name}{version}{meta}" pos:[24,264] width:513 height:16 align:#left
			label 'lbl36' "* Non existing folders will be automatically created when required." pos:[24,288] width:320 height:16 align:#left
			label 'lbl7' "Nitrous preview quality:" pos:[24,96] width:128 height:16 align:#left
			spinner 'spn_preview' "" pos:[144,96] width:88 height:16 range:[1,10000,25] type:#integer align:#left
			label 'lbl8' "Jonathan de Blok - www.jdbgraphics.nl" pos:[8,576] width:192 height:20 align:#left
			label 'lbl9' vlab pos:[8,560] width:136 height:16 align:#left
			
			edittext 'edt8' "" pos:[24,224] width:440 height:16 align:#left
			label 'lbl24' "Render output filename (don't add framenumber placeholder):" pos:[24,208] width:416 height:16 align:#left
			checkbox 'chk_ap' "Use AutoPass setup" pos:[32,376] width:120 height:16 align:#left
			label 'lbl17' "Automatically include render element in EXR output using format/type settings as\ndefined in the autoPass.ini file." pos:[32,400] width:472 height:32 align:#left
			button 'btn13' "Open ini file" pos:[160,376] width:80 height:16 align:#left
			groupBox 'grp2' "Previews" pos:[16,32] width:528 height:88 align:#left
			groupBox 'grp3' "Renders" pos:[16,144] width:528 height:184 align:#left
			groupBox 'grp4' "Render elements to EXR layers" pos:[16,352] width:528 height:96 align:#left
			groupBox 'grp5' "Misc" pos:[16,472] width:528 height:56 align:#left
			spinner 'spn_h' "Handles" pos:[40,496] width:97 height:16 range:[0,100,0] type:#integer align:#left
			label 'lbl11' "Pad tracks with extra frames during render/preview for more editing freedom." pos:[184,496] width:346 height:16 align:#left
			
			on btn_cancel pressed do
			(
					destroydialog ProSequencer.CSSettings
				)
			on btn_Save pressed do
			(
					saveConfigToScene()
					destroydialog ProSequencer.CSSettings
				)
			on inp_preview entered text do
			(
			
			try(		
			if ( substring text (text.count-3) 4) !=@".avi" do
			(
				ProSequencer.CSSettings.inp_preview.text +=@".avi"
			)
			) catch()
			
			)
			on btn_preview pressed do
			(
					pth=getSavePath initialDir:(getdir #preview)
					if (pth!=undefined) do
					(
						if (isDirectoryWriteable pth) do
						(
							pth += @"/preview_{camera}.avi"
						 
							ProSequencer.CSSettings.inp_preview.text = pth
						)
					)
				)
			on inp_render entered text do
			(
				try(
				if ( substring text (text.count) 1) !=@"/" do
				(
					ProSequencer.CSSettings.inp_render.text +=@"/"
				)
				) catch
				()
			)
			on btn_Render pressed do
			(
				pa= ProSequencer.cs_settings.preview_output
				 
				pth=getSavePath initialDir:(getdir #Scene)
				if (pth!=undefined) do
				(
					if (isDirectoryWriteable pth) do
					(
						pth += @"/{camera}/"
					 
						ProSequencer.CSSettings.inp_render.text = pth
					)
				)
				)
			on spn_preview changed val do
				(
			
			)
			on edt8 entered text do
				(
			
			)
			on chk_ap changed state do
			(
			
				)
			on btn13 pressed do
			(
			
					inifile= getdir #userScripts+@"\ProSequencer\autoPass.ini"
					shellLaunch "explorer.exe" inifile
				
				)
			on spn_h changed val do
		(
	
			)
		)
		createDialog CSSettings
	
		ProSequencer.CSSettings.inp_render.text= ProSequencer.cs_settings.render_output
		
		ProSequencer.CSSettings.inp_preview.text= ProSequencer.cs_settings.preview_output
		
		ProSequencer.CSSettings.spn_preview.value=ProSequencer.cs_settings.preview_quality
		
		if (ProSequencer.cs_settings.render_outputfile==undefined) do ( ProSequencer.cs_settings.render_outputfile="")
		ProSequencer.CSSettings.edt8.text=ProSequencer.cs_settings.render_outputfile
		
		if (ProSequencer.cs_settings.use_auto_pass==undefined) do
		(ProSequencer.cs_settings.use_auto_pass = true )
		
		if (ProSequencer.cs_settings.handles==undefined) do
		(ProSequencer.cs_settings.handles = 0 )
		
		
		ProSequencer.CSSettings.chk_ap.state=ProSequencer.cs_settings.use_auto_pass
			ProSequencer.CSSettings.spn_h.value=ProSequencer.cs_settings.handles
		
	)
	
	fn onDisable s e =
	(
		i=s.parent.Tag
		seq_track[i][2].tag.value.enabled=false
		seq_track[i][2].Backcolor=color_slider_dis
		changeMade "track"
		timeChange currentTime	
	)
	
	fn onEnable s e =
	(
		i=s.parent.Tag
		seq_track[i][2].tag.value.enabled=true
		seq_track[i][2].Backcolor=color_slider
		changeMade "track"
		timeChange currentTime	
	)
	
	
	fn renameStateSet items id str ostr   =
	(
		if (maxv<=14000) do ( return undefined )
	
		for i = 1 to items.count do
		(
			s=items.item[i-1]
			if  (s as string == "dotNetObject:Autodesk.Max.StateSets.Entities.StateSets.StateSet") do
			(
				if (s.Id==id  AND  items.item[i-1].name==ostr ) do
				(	
					 items.item[i-1].name=str
				)
				
				if (s.children.count>0) do
				(
					renameStateSet s.children id	str ostr
				)
			)
		)
	)
		
	fn getStateSetName items id =
	(
 
	 if (maxv<=14000) do ( return undefined )
		
		ssn=""
		for i = 1 to items.count do
		(
			s=items.item[i-1]
			if  (s as string == "dotNetObject:Autodesk.Max.StateSets.Entities.StateSets.StateSet") do
			(
			  
				
				if (s.Id==id ) do
				(	
					 ssn=items.item[i-1].name 
				 
					break
				)
				
				if (s.children.count>0) do
				(
					--a= getStateSetName s.children id
					--if (a!=undefined) do (ssn=a)
				)
			)
	 
			if (ssn != "") do ( i = items.count+1 )
			
		)
		
		if (ssn =="") do (ssn="State not found")
		ssn
	)
	
	
	
	
	fn onLinkStateSet s e =
	(
		if (maxv<=14000) do ( return undefined )
		_masterState = 	(GetMSS())
		
		i=s.parent.Tag
		seq_track[i][2].tag.value.stateset=getState()
		
		if (seq_track[i][2].tag.value.cam!=undefined) do
		(
			curCam=handle2cam seq_track[i][2].tag.value.cam    
			if (curCam!=undefined) do
			(
				if (_masterState.CurrentState[_masterState.CurrentState.count].name!=curCam.name) do
				(
					r=queryBox "Do you want StateSet.name = camera.name?"
					if (r==true) do
					(
						_masterState.CurrentState[_masterState.CurrentState.count].name=curCam.name
					)
				)
					
			)
		)
		
		setLabel seq_track[i][2] ""
		changeMade "track"
	)
	
	fn onUnlinkStateSet s e =
	(
		if (maxv<=14000) do ( return undefined )
		
		i=s.parent.Tag
		seq_track[i][2].tag.value.stateset=undefined
		setLabel seq_track[i][2] ""
		changeMade "track"
	)
	
	fn findState items id =
	(
		if (maxv<=14000) do ( return undefined )
		_masterState = 	(GetMSS())
			
		for i = 1 to items.count do
		(  
			s=items.item[i-1]
			if  (s as string == "dotNetObject:Autodesk.Max.StateSets.Entities.StateSets.StateSet") do
			(
				 
				if (s.Id==id) do
				(	
					p=#()
					pt=items.item[i-1] 
					while (pt as string != "dotNetObject:Autodesk.Max.StateSets.Entities.StateSets.Master") do
					(
							insertItem  pt p 1
							pt=pt.Parents[1] 
					)
				 
					_masterstate.CurrentState = p
				)
				
				if (s.children.count>0) do
				(
					findState s.children id	
				)
			)
		)
	)

	fn setState sid =
	(
		 
	 if (maxv<=14000) do ( return undefined )
		
		global _masterstate=(GetMSS()) 
		
		skip=false
		if (_masterstate.CurrentState != undefined) do
		(
			if (_masterstate.CurrentState[_masterstate.CurrentState.count].IsRecording == true ) do
			(
				skip=true
			)
		)
		
		if (skip == false ) do
		(
			renderSceneDialog.close()
			
			if (sid!=undefined) then
			(
		 		
				scr="pt=_masterState.getStateByID "+ sid as string +";"
				scr += "p=undefined; if (pt!=undefined) do ( p=#(); while (pt as string != \"dotNetObject:Autodesk.Max.StateSets.Entities.StateSets.Master\") do ( insertItem  pt p 1; pt=pt.Parents[1] ; ) ) try ( _masterstate.CurrentState=p; ) catch( ) ";
				  
				if ( isanimplaying() == true) then
				(
			 
					stopAnimation() 
					execute scr
				 
					
			 
				) else
				(

					redrawviews()
					execute scr
					redrawviews()
					
				)
				
			
				
			) else
			(
				if ( isanimplaying() == true) then
				(  redrawviews()
					stopAnimation() 
					execute "_masterState.CurrentState = undefined ;"
					redrawviews()
					playAnimation()
				) else
				(

					redrawviews()
						execute "_masterState.CurrentState = undefined ;"
					redrawviews()
					
				)
				
			
				 
			
			 
			)
		) 
 

	)

	
	fn GetMSS =  
	(
		if ((maxVersion())[1]>14000) do
		(
		if (masterState==undefined) do
		(
			stateSetsDotNetObject = dotNetObject "Autodesk.Max.StateSets.Plugin"
			stateSets = stateSetsDotNetObject.Instance
			masterState = stateSets.EntityManager.RootEntity.MasterStateSet
		)

		return 	masterState	
	)
	return undefined
	
	)
	
	
	fn getState  =
	(
		if (maxv<=14000) do ( return undefined )
		
		p=(GetMSS()).CurrentState
 
		if (p!=undefined) do
		(
			p=p[p.count]
			return p.Id
		)
		
		undefined
	)

	
	fn getStateForced  =
	(
		if (maxv<=14000) do ( return undefined )
		
		p=(GetMSS()).CurrentState
		if (p!=undefined) do
		(
			p=p[p.count]
			return p.Id
		)
		
		undefined
	)

 fn bakeMaster e s=
	(
		st=animationRange.start as integer/ticksperframe
		end=animationRange.end as integer/ticksperframe
		curcam=undefined
		campos=[0,0,0]
		camtarget=[0,0,0]
		fov=[0,0,0]

	 
	
		if ($PS_bakedCamera != undefined) do
		(
			q=querybox "This will overwrtie existing bakedCamera"
			if (q==false) do (return false)
			
			--remove old stuff
			killme=undefined
			for i= 1 to seq_track.count do
			(	
				tag=seq_track[i][2].tag.value
			 	
				if ( $PS_bakedCamera.inode.handle ==  tag.cam ) do
				(
					killme = i
				)
			)
			
			if (killme!=undefined) do (	trackRemove  killme )
			delete $PS_bakedCamera
		)
		
	 
		camtype=false
		firstcam=undefined
		for f = st to end do
		(
		 
			c=getActiveCam f
		 
 			if (c!=undefined AND c!=-1 and camtype == false) do
			(
				camtype = classof c
				firstcam = c
 			)
		)
		 
		
		
 
		if (camtype!=false) do
		(
		
		mcam=camtype() 
		
		mcam.name = "PS_bakedCamera"
		
		if (classof mcam == FStormCamera) do
		(
			mcam.targeted = firstcam.targeted
			mcam.dof_override = firstcam.dof_override
			mcam.dof_enabled = firstcam.dof_enabled
			mcam.glare_override = firstcam.glare_override
			mcam.glare_enabled = firstcam.glare_enabled
		)

		allTarget=true;
		for i= 1 to seq_track.count do
		(	
			
			tag=seq_track[i][2].tag.value
			testcam=undefined
			if ( tag.cam!=undefined) do
			(
				testcam =  maxOps.getNodeByHandle tag.cam;
			)
			
			if (testcam!=undefined) do
			(
				if (testcam.name != "PS_bakedCamera") do
				(
					try(if (testcam.target == undefined) do (allTarget = false ;  )) catch ()
				)
			)
			
			if ( $PS_bakedCamera.inode.handle ==  tag.cam ) do
			(
				killme = i
			)
		)
			
	 
			
			
		if (allTarget) then
		(
			try(mcam.type = #target) catch ()
			try(mcam.targeted = true) catch ()
		) else
		(
			try(mcam.type = #free) catch ()
			try(mcam.targeted = false ) catch ()
			
		)		
		
		disableSceneRedraw();		
		for f = st to end do
		(
			c=getActiveCam f
			if (c!=undefined AND c!=-1) do
			(
				with animate on  
				(
					at time  f
					(
						if (c!=undefined) do
						(
							mcam.fov = c.fov
							
							if (allTarget) then
							(
								mcam.position = c.position
								mcam.target.transform=c.target.transform
							) 	else
							(
								mcam.transform=c.transform
							)			

							if (classof mcam == FStormCamera) do
							(
								mcam.dof_radius = c.dof_radius 
								mcam.dof_blades = c.dof_blades
								mcam.dof_rotation = c.dof_rotation 
								mcam.dof_focaldist = c.dof_focaldist
								mcam.glare_power = c.glare_power
								mcam.glare_size = c.glare_size
								mcam.glare_raysnum = c.glare_raysnum
								mcam.glare_rotation = c.glare_rotation 
								mcam.glare_blur = c.glare_blur
								mcam.glare_contrast = c.glare_contrast
							)
						)	
					)
				)
			)
		)
		
		obj=mcam
		trackAdd()
		setHeight 0 0
		i=seq_track.count 
		seq_track[i][4].Text= obj.name
		seq_track[i][2].tag.value.cam= obj.inode.handle
		setLabel seq_track[i][2] ""
		onRangeFromKeys i -1
		trackReorder i  (-1*(i-1))
		)	
		changeMade "track"
		timeChange currentTime
		
		enableSceneRedraw();
			
	)

	fn getColor col =
	(
		if col[1]>255 do col[1]=255
		if col[2]>255 do col[2]=255
		if col[3]>255 do col[3]=255
		c=dnColor.FromArgb   col[1]  col[2] col[3] 
		c
	)
	
	fn updateCamColors =
	(
		
		cameras.wirecolor= color_camera_default

		if (cur_track!=undefined AND seq_track[cur_track]!=undefined) do
		(
			if (seq_track[cur_track][2].tag.value.cam!=undefined) do
			(
				curCam=handle2cam seq_track[cur_track][2].tag.value.cam    
				if (curCam!=undefined) do
				(
						curCam.wirecolor= color_camera_cur_track
				)
			)
		)
		
		if (active_cam!=undefined) do
		(
			curCam=handle2cam active_cam  
			if (curCam!=undefined) do
			(
					curCam.wirecolor= color_camera_active
			)
		)
	)
	
	
	fn onExpCB e s =
	(
		data=getAppData rootNode (app_data_id)
		setclipboardText data
		messagebox "Edit copied to clipboard"
	)
	
	fn onImpCB e s =
	(
		data=getclipboardText()
		setAppData rootNode (app_data_id) data
		loadEditFromScene();
	)
	
	
	fn loadEditFromScene =
	(
		if (true) do
		(
			toggle 2
			
			resetDelay=timeStamp()
			data=getAppData rootNode (app_data_id+1)
			 seq_debug "pre loading nav"

			
			if (data!=undefined) do
			(  seq_debug "loading nav"
				
				data=substituteString data "(NAV_tag" "(seq_nav_tag" 
				
				ss = StringStream (data)
				seek ss 0
				data_values = #()
				while not eof ss do( append data_values (readValue ss) )
				
				close ss
				
				for tag in data_values do
				(
					seq_nav[2].tag= dotNetMxsValue tag	
				)		
			 
				animationRange= interval seq_nav[2].tag.value.time_min seq_nav[2].tag.value.time_max
 
				seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min
				seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
				transformUpdate 0
			)
		 
			for i= 1 to seq_track.count do
			(	
				trackRemoveInternal 1
			)
			
			seq_track=#();
			data=getAppData rootNode app_data_id
		
			 seq_debug "pre loading track"
			if (data!=undefined) then
			(  seq_debug "loading track"
				
				data=substituteString data "(TR_tag" "(seq_tr_tag" 
				ss = StringStream (data)
				seek ss 0
				data_values = #()
				while not eof ss do( append data_values (readValue ss) )
				
				close ss
			 
				for tag in data_values do
				(
			 
				  if (seq_track[tag.i]==undefined) do
					(
						 trackAdd()
					)
					
					
					if (handle2cam tag.cam == undefined AND 	tag.camname!=undefined) do
					(
						tmp=getnodebyname 	tag.camname
						 if (tmp!=undefined) do
						(
							tag.cam=tmp.inode.handle
						)
					)
					
					seq_track[tag.i][2].tag= dotNetMxsValue tag	
					
					if (seq_track[tag.i][2].tag.value.enabled!=false) then
					(
						seq_track[tag.i][2].Backcolor=color_slider
					) else
					(
						seq_track[tag.i][2].Backcolor=color_slider_dis	
					)
				)		
			
				 if (updateCamLabels() == false) do
				(
					 messageBox "Some camera(s) used in the edit where not found in scene, it's track has been created without a camera"	
				)
			 
				transformUpdate 0
				 
			) else
			(
			 	
			)
		
			if (seq_track.count==0) do
			(
				trackAdd()	
				trackAdd()	
				trackAdd()	
				seq_nav[2].tag.value.showhide=1
			)
			
			--setHeight 0 0
			st=2
			if ((seq_nav[2].tag.value.showhide)==0) do
			(
				st=3	
			)
	 
			syncTrackWidth()
			seq_panel.refresh()
			loadConfigFromScene()
			
			if ((getSetting "options" "ignore_statesets") == "1"  AND hasStates() == true) do
			(
			  messageBox("Warning: This edit makes use of StateSet switching which you have set to ignore in the options menu.")	
			)
		)
	)
	
	fn removeFromScene =
	(
	 seq_debug "removing from scene"
		deleteAppData rootNode app_data_id 
		deleteAppData rootNode (app_data_id+1)  
		deleteAppData  rootNode (app_data_id+2)  
	)
	
	
	fn saveEditToScene type =
	( 
		if (type==0) do
		(
			seq_debug "saving track"
			ss = StringStream ""
			
			for i= 1 to  seq_track.count do
			(	
				tag=seq_track[i][2].tag.value
				
				if (tag.cam!=undefined) do
				(
						tmp=handle2cam	tag.cam
						if (tmp!=undefined) do
						(
							tag.camname=tmp.name
						)
					
				)
				
				
				s=with printallelements on (tag as string)
				print tag to:ss
			)
			
			if (demomode!=true) do
			(
			 
				setAppData rootNode app_data_id ss
			)
			close ss
		)
		 
		if (type==1) do
		(
			ss = StringStream ""
		
			seq_debug "saving nav"
			tag=seq_nav[2].tag.value
			s=with printallelements on (tag as string)
			print tag to:ss
	 
			if (demomode!=true) do
			(
				setAppData rootNode (app_data_id+1) ss
			)
			close ss
		)
	)

	fn removeConfigFromScene =
	(
		try(destroydialog ProSequencer.CSSettings) catch()
		cs_settings = seq_settings "" "" 25 "" false
		deleteAppData  rootNode (app_data_id+2) 
	)
	
	fn saveConfigToScene =
	(
		 
		cs_settings.render_output=substituteString ProSequencer.CSSettings.inp_render.text "\\" "/"
		cs_settings.render_outputfile=substituteString ProSequencer.CSSettings.edt8.text "\\" "/"
		cs_settings.preview_output=substituteString ProSequencer.CSSettings.inp_preview.text  "\\" "/"
		cs_settings.preview_quality=ProSequencer.CSSettings.spn_preview.value
		
		cs_settings.use_auto_pass=ProSequencer.CSSettings.chk_ap.state
		
			cs_settings.handles=ProSequencer.CSSettings.spn_h.value

		seq_debug "saving condig"
		ss = StringStream ""
	 
		tag=cs_settings
		s=with printallelements on (substituteString (tag as string) "\\" "/" )

		print tag to:ss
 
		if (demomode!=true) do
		(
			setAppData rootNode (app_data_id+2) ss
		)
		close ss
			 
	)

	fn loadConfigFromScene =
	(
	 
		option_jump_gap = getSetting "options" "jump_gap"
		option_ignore_statesets =  getSetting "options" "ignore_statesets" 
		option_filter_vfb=	getSetting "options" "filter_vfb" 	 
	
		data=getAppData rootNode (app_data_id+2)
		
		if (data!=undefined) then
		(  
			seq_debug "loading config"
			ss = StringStream (data)
			seek ss 0
			data_values = #()
			append data_values (readValue (ss) ignoreStringEscapes:true )  

			close ss
			
			cs_settings = data_values[1]
		 
		) else
		(
			cs_settings.render_output=""
			cs_settings.render_outputfile=""
			cs_settings.preview_output=""
			cs_settings.preview_quality=25
			cs_settings.use_auto_pass=true
			cs_settings.handles=0
			
		)
	)
	
	fn onTrackRemove s e =
	(
		r=queryBox "Are you sure?"
		
		if (r==true) do
		(
			i= s.parent.tag
			trackSelect seq_track[1][5]
			cur_track=1
			
			trackRemove i
			changeMade "track"
		)	
	)
	
	fn trackRemove i =
	(
	 
		if (seq_track.count>1) do
		(
			seq_track[i][1].dispose()
			 
			deleteitem seq_track i
			
			for i= 1 to seq_track.count do
			(	 
				seq_track[i][1].tag=i
				seq_track[i][2].tag.value.i=i
		 
				seq_track[i][4].tag=i
				seq_track[i][5].tag=i
				seq_track[i][1].top=(i-1)*track_height+20*uiscale
				
				if (mod i 2 == 0) then
				(
					seq_track[i][5].backcolor =color_zebra_a
				) else
				(
					seq_track[i][5].backcolor =color_zebra_b
				)
			)
		 
			trackSelect seq_track[1][1]
			setHeight seq_track.count 0
			changeMade "track"
		)
	)
	
		
	fn trackRemoveInternal i =
	(
	 
		seq_track[i][1].dispose()
		deleteitem seq_track i
		
		for i= 1 to seq_track.count do
		(	 
			seq_track[i][1].tag=i
			seq_track[i][2].tag.value.i=i
			seq_track[i][4].tag=i
			seq_track[i][5].tag=i
			seq_track[i][1].top=(i-1)*track_height+20
			
			if (mod i 2 == 0) then
			(
				seq_track[i][5].backcolor =color_zebra_a
			) else
			(
				seq_track[i][5].backcolor =color_zebra_b
			)
		)
	)
	
	fn dump_data =
	(
		for i= 1 to seq_track.count do
		(	 
			seq_track[i][1].dispose()
		)
		seq_track=#()
		removeConfigFromScene()
	)
	
	
	fn seq_reset str=
	(	
		seq_debug ("resetting: "+str)  
		
		if str=="postnew" do
		(
			dump_data()
		)
				
		loadEditFromScene()
		removeConfigFromScene()
		busyAnimRangeEvent=true
	
		seq_nav[2].tag.value.time_min=animationRange.start as integer/ticksperframe
		seq_nav[2].tag.value.time_max=animationRange.end as integer/ticksperframe
 
		seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min 
		seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max

		seq_nav[2].tag.value.range_start=0
		seq_nav[2].tag.value.range_length=seq_nav[2].tag.value.range_max_length

		seq_nav[2].location.x=  seq_nav[2].tag.value.range_start
		seq_nav[2].width=seq_nav[2].tag.value.range_max_length
		
		seq_nav[2].tag.value.ss=0
		seq_nav[2].tag.value.se=(seq_nav[5].width / uiscale ) as integer +0.5
		
		onNavTransform seq_nav[2] 0
		changeMade "time"

		syncTrackWidth()

		toggle 2

		busyAnimRangeEvent=false

	)
	
	fn removeCam i =
	(
		if (seq_track[i][2].tag.value.cam!=undefined OR 	seq_track[i][4].Text!="Pick Cam" )
		do
		(
		seq_track[i][4].Text="Pick Cam"
		seq_track[i][2].tag.value.cam=undefined
		changeMade "track"
		)
	)
	
fn getTrackBarBox =
(
		pq=Box2 0 0 0 0
		mw=Box2 0 0 0 0
		try(
			mw=windows.getWindowPos (windows.getMAXHWND())  removeUIScaling:false
			for obj in (windows.getChildrenHWND #max) where obj[4]=="TrackBar" do ( pq=(windows.getWindowPos obj[1] removeUIScaling:false))
	
		) catch
		(
			mw=windows.getWindowPos (windows.getMAXHWND()) 
			for obj in (windows.getChildrenHWND #max) where obj[4]=="TrackBar" do ( pq=(windows.getWindowPos obj[1]  ))
		)

		return #(pq,mw)
)

	fn syncTrackWidth =
	(
		 
			
		if ( cui.getDockState ProSequencer == #cui_dock_bottom) do
		( 
			pq=getTrackBarBox()
				 
			if (pq[1].w>0) do
			(
				animationRange = interval seq_nav[2].tag.value.time_min seq_nav[2].tag.value.time_max
				
				
				padding_left= pq[1].x - pq[2].x
				if ((maxVersion())[1] >= 20000) do
				(
						padding_left=10 * uiscale  
				)
				
				onProSequencerResized (padding_left + pq[1].w  )
			
			)
		)
		


		busyAnimRangeEvent=true
		
		animationRange = interval seq_nav[2].tag.value.time_min seq_nav[2].tag.value.time_max
		 
		seq_nav[2].tag.value.time_min=animationRange.start as integer/ticksperframe
		seq_nav[2].tag.value.time_max=animationRange.end as integer/ticksperframe
 
		seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min 
		seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
		
		seq_nav[2].tag.value.ss=0
		seq_nav[2].tag.value.se=seq_nav[2].tag.value.range_max_length-1
		
		seq_nav[2].tag.value.range_start=0
		seq_nav[2].tag.value.range_length=seq_nav[2].tag.value.range_max_length
		seq_nav[2].location.x=seq_nav[2].tag.value.range_start 
		seq_nav[2].width=seq_nav[2].tag.value.range_max_length  
		
		changeMade "time"
		onNavTransform seq_nav[2] 0
		ProSequencer.transformUpdate 0
		
		busyAnimRangeEvent=false
	)
	
	on ProSequencer resized size do 
	(
		onProSequencerResized ((size.x) * uiscale)
	
	)
	
	fn onProSequencerResized size =
	(	
		st=#cui_dock_bottom
		try ( st=cui.getDockState ProSequencer) catch (st=#cui_dock_bottom)
		pl=padding_left
		if  (st== #cui_floatable) then
( pl = 10 * uiscale		)		

			
		size = size + (83 * uiscale)
		dx=(seq_nav[2].tag.value.panel_width as float ) / (size as float)

	 	if (dx!=undefined) do
		(		 
				pw=padding_right+ pl
				seq_panel.Width = size  - padding_right
				seq_panel.left=0

				track_width=size - padding_right  -  pl - (34 * uiscale)

				for i= 1 to seq_track.count do
				(	
					seq_track[i][1].width= track_width 

					seq_track[i][1].left=	 pl-(34*uiscale)
					seq_track[i][5].width= (track_width )-(83*uiscale)  -- + getKeywidth() *uiscale
				)

				ui_toggle.left=seq_panel.Width  - padding_right  
				ui_sync.left=seq_panel.Width  -   padding_right 
				ui_active.left=seq_panel.Width - padding_right
				

				ui_match.left= pl-(10*uiscale)
				ui_setting.left= pl-(10*uiscale)
				ui_help.left= pl-(10*uiscale)
				
				slide_width= track_width-(83*uiscale);
				
				seq_nav[1].width=track_width
				seq_nav[1].left= pl - (34*uiscale)
				seq_nav[5].width=slide_width
				seq_nav[2].tag.value.range_max_length=slide_width

				seq_ruler.width =slide_width
				seq_ruler.left= pl + 34 * uiscale 
				seq_nav[2].tag.value.range_start=seq_nav[2].tag.value.range_start*dx
			 
				 dx=(seq_nav[2].tag.value.panel_width - (90*uiscale) - pw ) as float / ((size - (90*uiscale) - pw) as float)
				seq_nav[2].tag.value.ss=seq_nav[2].tag.value.ss / dx as float 
				seq_nav[2].tag.value.se=seq_nav[2].tag.value.se / dx as float 
		 
				seq_nav[2].location.x =  seq_nav[2].tag.value.ss 
				seq_nav[2].width = (seq_nav[2].tag.value.se - seq_nav[2].tag.value.ss)  
				 
				seq_nav[2].tag.value.panel_width=size  
				transformUpdate 0	
			)
	)
	
	fn getActiveState t =
	(
		found=false
		curState=undefined
		
		for i= 1 to seq_track.count do
		(	
			tag=seq_track[i][2].tag.value
			if (tag!=undefined) do
			(
				if ( (t >= tag.r_start and t<tag.r_end) AND found==false AND tag.enabled!=false) do
				(  
					curState=tag.stateset    
					found=true
				)
			)
		)
		
		curState
	)
	
	fn hasStates  =
	(
		found=false
		for i= 1 to seq_track.count do
		(	
			tag=seq_track[i][2].tag.value
			if ( tag.stateset  != undefined ) do (found = true)
		)
		 
		found
	)
	
	fn handle2cam handle=
	(
		c=cameras as array
 
		for item in c do
		(
			if ( item.inode.handle == handle) do (
 
					return item
			)
		)
		return undefined
	)
	
	fn getActiveCam t qs:undefined=
	(
		active_cam=undefined
		curCam=undefined
		ct=false
	 try(
		for i= 1 to seq_track.count do
		(	
			tag=seq_track[i][2].tag.value
			
			if ( (t >= tag.r_start and t<tag.r_end) AND curCam==undefined AND tag.enabled!=false) do
			(
			 
			 	if (tag.cam!=undefined) do
				(
					
					if(qs!=undefined) then
					(
						if (qs.inode.handle == tag.cam AND qs!=undefined ) then
						(
						 
							curCam = qs;
						) else
						( 
							curCam = handle2cam  tag.cam
				 
							
						)
					) else 
					
					(
					 
						curCam = handle2cam  tag.cam
					 
					)
				)
				
				if (curCam==undefined) then
				(
					removeCam i
				) else
				(
					active_cam=tag.cam
				)
			)
		)
	) catch()

		if (curcam==undefined and ct==false) do
		(
			curCam=-1	
		)
		
		curCam
	)
	
	fn updateCamLabels =
	(
		succes=true
		for i= 1 to seq_track.count do
		(	
			if (seq_track[i][2].tag.value.cam!=undefined) do
			(
				a=handle2cam seq_track[i][2].tag.value.cam
				if (a!=undefined) then
				(
					seq_track[i][4].Text=a.name
				) else
				(
					succes=false
					removeCam i
				)
			)	
		)
		succes
	)
	
	fn onPickCam s e =
	(
		bk=false
		try
		(
			if  ( e.Button==e.Button.Right) do
			(
				bk=true
			)
		) 
		catch()
		
		if  (bk==false) do
		(
		
			fn camFilt o = (superClassOf o == Camera)
			i=s.parent.Tag
			t=seq_track[i][2]
			
			oc=seq_track[i][2].BackColor	
			seq_track[i][2].BackColor =color_highlight
		
			a=pickObject  message:"Select a camera" filter:camFilt
			if (a!=undefined AND a!=#escape ) then
			(
				seq_track[i][4].Text=a.name
				seq_track[i][2].tag.value.cam=a.inode.handle
				setLabel seq_track[i][2] ""
				onRangeFromKeys i -1
				timeChange currentTime
			 
			) else
			(
				--s.Text="Pick Cam"
				--s.tag.value.cam=undefined
			)
				seq_track[i][2].BackColor=oc
	  )
	  
	   changeMade "track"
	  
	)
	
	fn onPickSelCam s e =
	(
			i=s.parent.Tag
		
			if (superclassof selection[2]==camera  ) then
			(
				seq_track[i][4].Text= selection[2].name
				seq_track[i][2].tag.value.cam= selection[2].inode.handle
				setLabel seq_track[i][2] ""
				
				if (con.modifierKeys==con.modifierKeys.shift) do
				(
					onRangeFromKeys i -1
				)				
				
				changeMade "track"
				timeChange currentTime
			)  
			
			if (superclassof selection[1]==camera ) then
			(
				seq_track[i][4].Text=selection[1].name
				seq_track[i][2].tag.value.cam=selection[1].inode.handle
				setLabel seq_track[i][2] ""
				if (con.modifierKeys==con.modifierKeys.shift) do
				(
					onRangeFromKeys i -1
				)
				changeMade "track"
				timeChange currentTime
			)  
	  
	)
	
	fn onPickVPCam s e =
	(
		i=s.parent.Tag
	
		if (getActiveCamera() != undefined ) then
		(
			seq_track[i][4].Text=(getActiveCamera()).name
			seq_track[i][2].tag.value.cam=(getActiveCamera()).inode.handle
			setLabel seq_track[i][2] ""
			
			if (con.modifierKeys==con.modifierKeys.shift) do
			(
				onRangeFromKeys i -1
			)	
				
			changeMade "track"
			timeChange currentTime
		)  
	)
	
	
	fn onSync s e =
	(
		if (s.tag==1) then
		(
			s.BackColor= s.BackColor.Transparent
			s.Tag=0	
		) else
		(
			s.Tag=1
			s.BackColor= color_highlight
			onNavTransform seq_nav[2] 0
		)
	)
	
	fn onActive s e =
	(
		if (s.tag==1) then
		(
			s.BackColor= s.BackColor.Transparent
			s.Tag=0	
		) else
		(
			s.Tag=1
			s.BackColor=color_highlight
			timeChange currentTime
		)
	)
	
	fn onUnPickCam s e =
	(
		i=s.parent.Tag
		seq_track[i][4].Text="Pick Cam"
		seq_track[i][2].tag.value.cam=undefined
		setLabel seq_track[i][2] ""
		changeMade "track"
	)
	
	

	
	fn timeChange f =
	(
		if (ui_active.tag==1 AND ignoreTimeChangeEvent==false ) do
		(
				
			ov=viewport.activeViewport 
			stat=isanimplaying()
	
			curCam=(getActiveCam f qs:(viewport.getCamera index:ov)   ) 
	 
			switched=false
			noTrack=false
			
			if (curCam==-1) do ( noTrack=true; curCam=undefined)
			 

				curState=(getActiveState f)
				if (getState()!=curState  and option_ignore_statesets  != "1"     ) do
				(  
					 setState curState
					 switched=true
	
				)

		
			if (curCam!=undefined) then
			(
				vp=getViewport()
				
				if (vp!=false) do
				(
					if (viewport.getCamera index:vp !=curCam) do
					(
						
						if (ov<1) do (ov=1)
					
						if (vp!=false) do
						(
							viewport.activeViewport=vp
							setCam curCam
							switched=true
							updateCamColors()					
						)
					) 
				)	
					
			  if (curCam.wirecolor != color_camera_active) do (  updateCamColors() )
				
			)   
			 
			if (VFBPlus2!=undefined) do
			(
				 
				if (option_filter_vfb == "1" AND stat==false  ) then
				(
						if (notrack==false and curCam!=undefined) then
						(
							
							if (VFBPlus2.FilmStripViewFilter != curCam.name) do
							(
								VFBPlus2.FilmStripViewFilter = curCam.name
							)
							
						)  else
						(
							if (VFBPlus2.FilmStripViewFilter !="") do
							(
								VFBPlus2.FilmStripViewFilter = "";
							)
						)
				)
			)
	
				  
			if (noTrack==true AND stat==true AND option_jump_gap == "1") then
			(
				ct=(slidertime as integer/ticksperframe)	
				t=0
				for i= 1 to seq_track.count do
				(	
					tag=seq_track[i][2].tag.value
					if (  tag.r_start - ct > 0 AND ((tag.r_start  )<t OR t==0)  AND tag.enabled!=false  ) do
					(
					  t= tag.r_start
					)
				)
				
				if (t!=0) do
				(
					--enableSceneRedraw();
					stopAnimation() 
					sliderTime = t
					ignoreTimeChangeEvent = false
					switched=true
					f=t
				) 
			)
		  		 
			if (stat==true and switched==true) then
			(
				curState=(getActiveState f)
				
				if (getState()!=curState  and option_ignore_statesets  != "1"   ) do
				(  
					  setState curState
					 switched=true
			
				)
 
			 --	if (isanimplaying() == false) do
			 --	( 
				 redrawviews()
				 playAnimation()
			--	)
			) else
			(
				if (ov!= viewport.activeViewport) do
				(
					 viewport.activeViewport = ov
				)
			)
		)			
	)
	
	fn refresh  = 
	(
		try(
		 seq_panel.refresh()
		) catch ()
	)

	on seq_panel Paint s e do if s.tag != off do
 	(
 		s.tag = off
 		seq_panel.Refresh()
 		s.tag = on
 	)
	
	fn getDup id =
	(
		dup=0
		cam=seq_track[id][2].tag.value.cam
	
		for i=1 to id do
		(
			if (seq_track[i][2].tag.value.cam ==  cam AND i != id) do
			(
			dup += 1	
			)
		)

		if (dup>0) then
		(
			dup="_["+(dup+1) as string+"]"
		) else 
		(
			dup=""	
		)	
	
		dup
	)
	
	
	fn setLabel s lab =
	(
			tag=s.tag.value
			id=tag.i
		
			c="no camera"
			str = tag.r_start as string + " ("+(tag.r_end- tag.r_start) as string  +") "+ ((tag.r_end-1)) as string
			tt= tag.r_start as string + "\n("+(tag.r_end- tag.r_start) as string  +") "+ ((tag.r_end-1)) as string
		
			ss=""
			if (tag.stateset!=undefined) then 
			(	
				ss="# "
			)
		
			v=""
			if (tag.version!=undefined) then 
			(
				v="v:"+tag.version+" "
			)
			
			m=""
			if (tag.meta!=undefined) then 
			(
				m="m:"+tag.meta+" "
			)
			
			if (tag.cam!=undefined) then 
			(	
				cm= handle2cam  tag.cam
				if (cm!=undefined) do
				(
					dup=""
					if (m=="") do
					(
						dup=getDup id
					)
					
					if (lab=="") then (c=cm.name) else (c=lab)	
					str =ss+  "'"+c+dup+"' "+v+m+tag.r_start as string + " ("+(tag.r_end- tag.r_start) as string  +") "+ ((tag.r_end-1)) as string 
				)
			)
			
			sss="none"
			if (tag.stateset != undefined) do
			(
				sss= tag.stateset as string	
			)
			
			if ((dotnetclass "TextRenderer").MeasureText str s.Font).width > s.Width-12 then ( 
				str = ss+ tag.r_start as string + " ("+(tag.r_end- tag.r_start) as string  +") "+ ((tag.r_end-1)) as string
			)
		
			if ((dotnetclass "TextRenderer").MeasureText str s.Font).width > s.Width-12 then ( 
				 	str =ss + tag.r_start as string + "  "+ ((tag.r_end)) as string 
			) 
			
			if ((dotnetclass "TextRenderer").MeasureText str s.Font).width > s.Width-12 then ( 
				str =(tag.r_end- tag.r_start) as string 
			) 
			
			if ((dotnetclass "TextRenderer").MeasureText str s.Font).width > s.Width-8 then ( 
				str = "-"
			) 
			
			s.Text =  str 		
	)
	
	fn screenToKey x = 
	(
		nav=seq_nav[2].tag.value
 		w_start=nav.w_start
		w_end=nav.w_end
		fac=((nav.time_max) - nav.time_min as float )/(w_end - w_start as float)*nav.range_max_length as float/(nav.time_max-nav.time_min as float )
	 	--fac /= uiscale
		n=(((x/fac)+w_start) )    
		n=(floor ((n) + 0.5))  
		n 
	)

	fn keyToScreen n = 
	(
		try (
		nav=seq_nav[2].tag.value
 		w_start=nav.w_start
		w_end=nav.w_end
		fac=((nav.time_max ) - nav.time_min as float  )/(w_end - w_start as float)*nav.range_max_length as float/(nav.time_max-nav.time_min as float )
	 --  fac /= uiscale
		x=(n - w_start)*fac 
		) catch ( x= 1 )			
		x   
	)

	fn getKeyWidth = 
	(
		nav=seq_nav[2].tag.value
		w_start=nav.w_start
		w_end=nav.w_end
		fac=((nav.time_max ) - nav.time_min as float )/(w_end - w_start as float)*nav.range_max_length as float/(nav.time_max-nav.time_min as float )
	 
		keysize=((nav.range_max_length as float) /(w_end-w_start)) / uiscale   --snap distance in px
		(keysize    ) as float
	)
	
	fn onHelp s e =
	(
		shellLaunch "http://www.jdbgraphics.nl/prosequencer-online-help" ""
	)
	
	fn trackSelect s  trg:false = 
	(
		
		if (s.name=="track_slider" OR s.name=="track_area") do
		(
			for i= 1 to seq_track.count do
			(	
				
				if (mod i 2 == 0) then
				(
					seq_track[i][5].backcolor =color_zebra_a
				) else
				(
					seq_track[i][5].backcolor =color_zebra_b
				)
			)	
			
			s.backcolor =s.backcolor.SlateGray	
			cur_track= s.tag
			updateCamColors() 
			
			if ( isanimplaying() == true) do
			(
				
				stopAnimation() 
				redrawviews()
				print trg
				if (trg==false) do
				(
					slidertime = seq_track[cur_track][2].tag.value.r_start
				)
				if (trg!=false) do
				(
					slidertime = trg
				)
				
				
				redrawviews()
				playAnimation()
			)
		)
	)

	fn transformUpdate i = 
	(
		stopRedraw()
		nav=seq_nav[2].tag.value
 		w_start=nav.w_start
		w_end=nav.w_end
		fac=(nav.time_max - nav.time_min as float )/(w_end - w_start as float)*(nav.range_max_length ) as float/(nav.time_max - nav.time_min as float)
		seq_action=1
		--  fac /= uiscale
		if (i==0) then
		(
			is=1
			ie= seq_track.count
		) else
		(
				is=i
				ie=i
		)
		
		if (seq_track.count>0) do
		(
			for i= is to ie do
			(	
				if (seq_track[i][2].tag.value.r_start!=undefined) do
				(
					sTag=seq_track[i][2].tag.value 
					
					start= floor ( (sTag.r_start - w_start  ) * fac)  
					end= floor ((sTag.r_end - w_start  ) * fac)  
					w=floor (end-start)
					seq_track[i][2].location.x=start					
					seq_track[i][2].width=(w  )+(1*uiscale)
					
					setLabel seq_track[i][2] ""
				)

			)
		)
	
		seq_action=0
		key_size=getKeyWidth()
		resumeRedraw()
	)
	
	fn onTransform s e = 
	(
 
		if seq_action==0  do
		(
			seq_action=1
			
			nav=seq_nav[2].tag.value
			w_start=nav.w_start
			w_end=nav.w_end
			fac=(nav.time_max - nav.time_min as float)/(w_end - w_start as float)*nav.range_max_length as float/(nav.time_max-nav.time_min as float  )
			fac /= uiscale
			x = 	s.tag.value.ss
			en=	s.tag.value.se
			start=(x) as integer   
			end=(en)  as integer
			s.tag.value.r_start=start 
			s.tag.value.r_end=end 
			setLabel s ""
			transformUpdate 	s.tag.value.i
			seq_action=0
		)  
	)
	
	fn onTrackAdd s e =
	(
		trackAdd()
		setHeight 0 0
	)

	fn onTrackDup s e =
	(

		par=s.parent.Tag;
		
		trackAdd()
		
		
		
		i=seq_track.count;
	 
		seq_track[i][2].Tag.value.sData =	seq_track[par][2].Tag.value.sData
		seq_track[i][2].Tag.value.r_start =	seq_track[par][2].Tag.value.r_start
		seq_track[i][2].Tag.value.r_end =	seq_track[par][2].Tag.value.r_end
		seq_track[i][2].Tag.value.ss =	seq_track[par][2].Tag.value.ss
		seq_track[i][2].Tag.value.se =	seq_track[par][2].Tag.value.se
		seq_track[i][2].Tag.value.i =	i
		seq_track[i][2].Tag.value.cam =	seq_track[par][2].Tag.value.cam
		seq_track[i][2].Tag.value.enabled =	seq_track[par][2].Tag.value.enabled
		seq_track[i][2].Tag.value.stateset =	seq_track[par][2].Tag.value.stateset
		seq_track[i][2].Tag.value.camname =	seq_track[par][2].Tag.value.camname
		seq_track[i][2].Tag.value.version =	seq_track[par][2].Tag.value.version
		seq_track[i][2].Tag.value.meta =	seq_track[par][2].Tag.value.meta
		
		setLabel seq_track[i][2] ""
		setHeight 0 0
		
		changeMade "track"
		
	)

	
	fn updateTimeRange =
	(
	    if  (ignoreAnimRangeEvent==false AND busyAnimRangeEvent==false) do
		(
			busyAnimRangeEvent=true
 
			seq_nav[2].tag.value.time_min=animationRange.start as integer/ticksperframe
			seq_nav[2].tag.value.time_max=(animationRange.end ) as integer/ticksperframe
	 
			seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min 
			seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
			seq_nav[2].tag.value.range_start=0
			seq_nav[2].tag.value.range_length=seq_nav[2].tag.value.range_max_length
			seq_nav[2].location.x= seq_nav[2].tag.value.range_start
			seq_nav[2].width=seq_nav[2].tag.value.range_max_length

			changeMade "time"
			onNavTransform seq_nav[2] 0
			ProSequencer.transformUpdate 0
			seq_TrackTime()
			busyAnimRangeEvent=false
		)
	)
	
	fn onNavTransform s e = 
	(
	 
		if (ignoreNavChangeEvent==false) do
		(
			s.tag.value.range_start=s.location.x 
			s.tag.value.range_length=s.width 
			fac=(s.tag.value.time_max-s.tag.value.time_min as float )/s.tag.value.range_max_length as float
		 --fac /= uiscale
			start=(s.tag.value.time_min+(s.tag.value.range_start)*fac)  
			end=(start+ (s.tag.value.range_length*fac)) as integer  
			start=start as integer
 				
			if (start==end) do (end += 1)	
			if (end>s.tag.value.time_max) do (end=s.tag.value.time_max)	
			if (ui_sync.tag==1) do
			(
				if (busyAnimRangeEvent==false) do
				(
					ignoreAnimRangeEvent=true
					animationRange= interval  start end
					ignoreAnimRangeEvent=false
				)
			)

			s.tag.value.w_start=start
			s.tag.value.w_end=end
	 
			x = s.Location.x
			w = s.Width
 
			seq_nav[3].left=0
			seq_nav[4].left=w-(3*uiscale)
			)
	)

	fn changeMade s =
	(
	
		if (ignoreChangeEvent==false) do
		(
			setSaveRequired true
			
			if (s=="track") do
			(
				saveEditToScene 0
				
				try
				(  
					LPM_ProSequencerSync()
				)
				catch()

			)
			
			if (s=="time") do
			(
				saveEditToScene 1
			)	
			
			if (s=="all") do
			(
				saveEditToScene 0
				saveEditToScene 1
				
				try
				(
					LPM_ProSequencerSync()
				)
				catch()

			)	
		)
	)
		
	fn onMouseUp s e = 
	(
		 
		mouse_action=""
		if s.name=="track_slider" do
		(
			s.TextAlign=s.TextAlign.MiddleCenter	
			s.tag.value.ss=s.tag.value.r_start
			s.tag.value.se=s.tag.value.r_end
			seq_TrackTime()
			
			changeMade "track"
		)
		
		if s.name=="nav_slider" do
		(
		 
			seq_TrackTime()
			
		 
		)
		
		
		seq_ruler.visible = false
		seq_snaphead.visible = false
		
		if s.name=="track_area" do
		( 
			
			seq_ruler.visible = false
			src=s.tag 
			trg=(floor((e.y / uiscale + 10 )/20.0 ))
			if (trg>1 or trg<0) do
			(
				trackReorder s.tag trg
				changeMade "track"
			)
		)
	)

	fn setValue ui val =
	(
		uiaccessor.setwindowtext ui (val as string)
		VM_CHAR=0x0102
		VK_RETURN = 0x000D
		windows.sendMessage ui VM_CHAR VK_RETURN 0
	)
	
	fn onPreviewThis s e =
	(
		
		auto_preview=false
		i=s.parent.Tag
		
		if (checkSettings true == false) then
		(
		) else
		(
			ttm.Interval = 100  
			dotnet.addEventHandler ttm "Elapsed" seq_OnTick
			
			ot=currenttime
			ov=viewport.activeViewport
			vp=getViewport()
			maxed=false
			if (vp==false) do
			(
				max tool maximize	
				maxed=true				
				vp=getViewport()
			)
		 
			if (seq_track[i][2].tag.value.cam != undefined) do
			(
				curCam=handle2cam seq_track[i][2].tag.value.cam 
				if (curCam!=undefined) do
				(
					if (vp!=false) then
					(
						viewport.activeViewport=vp
						setCam curCam
				 
						if (getState()!=seq_track[i][2].tag.value.stateset) do
						(  
							setState seq_track[i][2].tag.value.stateset
						)
						
						max tool maximize	
						max tool maximize	
						if (maxv<=14000) then () else
						(						 
							NitrousGraphicsManager.MakePreviewQuality=cs_settings.preview_quality
						)
						ignoreTimeChangeEvent=true
						ttm.Start()
						actionMan.executeAction 0 "40033"
					 	ttm.Stop()
						
						src=getPreviewPath()
						
						mBitmap = openBitmap src
						
						if (mBitmap!=undefined) then
						(
							chk=mBitmap.numFrames
					 
							close mBitmap
							free mBitmap
							if ((seq_track[i][2].tag.value.r_end-seq_track[i][2].tag.value.r_start)==chk) then
							(
								movePreviewFile i
							) else
							(
								r=queryBox ("Incomplete previewfile! ("+(chk as string)+  " out of "+((seq_track[i][2].tag.value.r_end-seq_track[i][2].tag.value.r_start) as string) +" frames) \n Use anyways?")
								if (r==true) then
								(
									movePreviewFile i	
								) else
								(
									deleteFile  src
								)
							)
						)  
										
						viewport.activeViewport=ov
						sliderTime=ot
						seq_TrackTime()
					
						dotnet.removeAllEventHandlers ttm
						ignoreTimeChangeEvent=false
					) else
					(
						if (maxed==true) do
						(
								maxed= false
								max tool maximize	
						)
						messageBox "Please set one of the viewports to 'camera' to be able to use MakePreview"	
					)
				)
			)
			if (maxed==true) do
			(
					max tool maximize	
			)
		)
	)
	
	fn onCloudRenderThis s e =
	(
		doCloudRenderThis s e #()  
		
	)
	
	fn doCloudRenderThis s e tracks   =
	(
		--This is some inhouse stuff.. not used unless a flag is set in ini file.
		local curCam;
		local origval;
		
	 
		
		qs=false
		if (con.modifierKeys==con.modifierKeys.shift) do (qs=true)
		
		r=true
		
		if (qs==false) do
		(
		--	r=queryBox("Is Deadline repo reachable?")
		)
		r2=checkSettings true  			
 
	 
		if (r==true AND r2==true) do
		(
			
			
			if (tracks.count==0) do ( tracks[1]=s.parent.Tag  )
			
			
			for tloop=1 to tracks.count do
			(
			
				i=tracks[tloop]
				
				ctrack=i
				ov=viewport.activeViewport
				vp=getViewport()
				ss=seq_track[i][2].tag.value.stateset
				
					
				trackSelect seq_track[tloop][5]
					
				maxed=false
				if (vp==false) do
				(
					max tool maximize	
					vp=getViewport()
					maxed=true
				)
				
				if (vp!=false) then
				(
					viewport.activeViewport=vp
					if (seq_track[i][2].tag.value.cam != undefined  ) then
					(
						curCam=handle2cam seq_track[i][2].tag.value.cam 
						if (curCam!=undefined) do
						(
							if (getState()!=ss) do
							(  
								setState ss
							)
							
							setCam curCam
								
							renderSceneDialog.close()
							_masterState = 	(GetMSS())
							
					
							print "Weather report:"
							print ("Camera: " + curCam.name + " (viewport:" + (vp as string)+ ")")
							
							if (seq_track[i][2].tag.value.stateset!=undefined) then
							(
								print (("Stateset: "+(getStateSetName _masterState.children  (ss))) + " (Id: "+ss as string+")");
							) else
							(
								print "Stateset: none"	
							)
							------------------
						
							version=seq_track[i][2].tag.value.version
							if (version==undefined ) then (version="") else (version="_"+version)
						
							debug=false
		
								origval=rendOutputFilename
								
							
							
								renderSceneDialog.close()
								rendOutputFilename=getProjectRenderFileDeadline i silent:true
							
								range=getRenderRange i
							
							
								rendStart=range[1] as time
								rendEnd= range[2] as time
								
								if (rendStart == rendEnd ) then
								(
									rendTimeType = 1
								) else
								(
									rendTimeType = 3
								)
									
								rendSaveFile = true
								
								renderSceneDialog.update()
						

								print ("start: "+range[1] as string)
								print ("end: "+range[2] as string)
								if ( cs_settings.handles>0 and range[1]!=range[2]) do (
									print ("Render range includes "+  cs_settings.handles as string+" handle frames")
								)
								
								val=rendOutputFilename
								pth2=getFilenamePath val
								pth=getFilenamePath val
				 
								renderSceneDialog.update()
								
								out=rendOutputFilename
								
								if (range[1] != range[2]) do
								(
									ext=getFilenameType out;
									p=getFilenamePath  out
									f=getFilenameFile out;
									out=p+f+"####"+ext;
								)
								
								print ("output: "+out)
									
								r=true
								if (qs==false) do
								(
								--	r=querybox("All systems go?")
								)
								
							 
									if (getState()!=ss) do
									(  
										setState ss    -- double check
										print "State sets not correct, fixed now?"
									)
									
									print ("submitting ["+tloop as string +"/"+ tracks.count as string+"]")

									setState ss   
									
									if (fn_deadlineSubmitPrepare()) then
									(
									
										SMTDSettings.jobname= (curCam.name +version+"_track"+(ctrack as string) )+"_"+(timestamp() as string);
										SMTDSettings.comment="ProSequencer submit";
		 
										SMTDSettings.RestartRenderer=false;
										SMTDSettings.RestartMax=false;
										SMTDSettings.ChunkSize = 10;
										
										SMTDSettings.ShowRendererFrameBufferOverride = false
										SMTDSettings.ShowRendererFrameBuffer = true
										SMTDSettings.ShowFrameBuffer	= false

										
										SMTDSettings.SubmitAsSuspended = false;
										SMTDSettings.RunPreFrameScript = true;
										SMTDSettings.PreFrameScriptFile = (getdir #userscripts)+@"\Prosequencer\deadline_preFrame.ms"
										
										SMTDSettings.RemovePadding=false
										if (rendtimetype==1) do
										(
											SMTDSettings.RemovePadding = true
										)
										
										SMTDSettings.Delimiter="";
										
										fn_deadlineSubmitExecute curCam  
											print ("done!")
									) else
									(
											print ("aborted!")
										break;
									)
								
									
								--rendOutputFilename=origval
								renderSceneDialog.update()
								--print ("output restored: "+rendOutputFilename)	
					
					 
						)
					) else
					(
						messageBox  "Please assing a camera to this track to be able to render"	
					)
				)
				else
				(	if (maxed==true) do (max tool maximize	  )
					messageBox "Please set one of the viewports to 'camera' to be able to use \"Render this\""	
				)
			)
		)  
	)
	
	fn onSetVersion s e =
	(
			i=s.parent.parent.Tag
			bn=seq_track[i][2].tag.value.version;
		
			if (bn==undefined) do ( bn="")

			theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" bn
			theobj.text ="Set version identifier to:"
			DialogResult = theObj.Showmodal()

			if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
			(
				basename=theobj.InstanceName
				seq_track[i][2].tag.value.version =  basename
				
				setLabel seq_track[i][2] ""
				
				changeMade "track"
			)
		
	)
	
	fn onSetVersionAll s e =
	(
		theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
		theobj.text ="Set version identifier to:"
		DialogResult = theObj.Showmodal()

		if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
		(
			basename=theobj.InstanceName
			
			for i= 1 to seq_track.count do
			(	
				seq_track[i][2].tag.value.version =  basename
				setLabel seq_track[i][2] ""
			)
		)

		changeMade "track"
	)
	
	fn onSetMeta s e =
	(
		i=s.parent.parent.Tag
	
		bn=seq_track[i][2].tag.value.meta;
	
		if (bn==undefined) do ( bn="")

		theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" bn
		theobj.text ="Set meta data to:"
		DialogResult = theObj.Showmodal()

		if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
		(
			basename=theobj.InstanceName
			seq_track[i][2].tag.value.meta =  basename
			setLabel seq_track[i][2] ""
			changeMade "track"
		)
	)
	
	fn onSetMetaAll s e =
	(
		
		theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" ""
		theobj.text ="Set meta data on all tracks to:"
		DialogResult = theObj.Showmodal()

		if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
		(
			basename=theobj.InstanceName
			for i= 1 to seq_track.count do
			(	
				seq_track[i][2].tag.value.meta =  basename
				setLabel seq_track[i][2] ""
			)
		
		)
	)	
	
	fn onPrintSum s e =
	(
	 
				bDlg = renderSceneDialog.isOpen()
	
		
			renderSceneDialog.close()
		
		result=true
		msg="";
		if (maxFileName=="") do ( result=false; msg="-Max scene needs to be saved first\n" )
		if (  rendOutputFilename == "" ) do ( result=false; msg += "-No renderoutput filename\n" )
		if ( (getFilenameType rendOutputFilename) == "" ) do ( result=false; msg += "-No file extension\n" )
		
		if (msg != "") do (messagebox msg; return false;)

		
			clearlistener();
			print "Output location:"
			for i = 1 to seq_track.count do
			(	

				numframes=(seq_track[i][2].tag.value.r_end-1) as time - seq_track[i][2].tag.value.r_start as time
	 										
				if (seq_track[i][2].tag.value.cam != undefined) then
				(
					if (numframes==0f) then
					(				
						print ("\tTrack "+ i as string+": "+(getProjectRenderFileDeadline i silent:true) +  " (single frame)")
					) else
					(
						out=(getProjectRenderFileDeadline i silent:true);
						ext=getFilenameType out;
						p=getFilenamePath  out
						f=getFilenameFile out;
						out=p+f+"####"+ext;
						print ("\tTrack "+ i as string+": "+ out +" ("+(numframes as integer/ticksperframe + 1) as string+" frames)")
					)
				) else
				(
					print ("\tTrack "+ i as string+": Skipping, no camera assigned")
				)
			)
	
			print "StateSets:"
			_masterState=GetMSS()
			
			for i = 1 to seq_track.count do
			(		
				
				ss=seq_track[i][2].tag.value.stateset
				if (ss !=undefined) then
				(
				print ("\tTrack "+ i as string+": "+ (getStateSetName _masterState.children  (ss)))
				) else
				(
						print ("\tTrack "+ i as string+" - StateSet: none")
				)
			)

if bDlg do ( renderSceneDialog.open() )
			
			
	)
	
	fn onCloudRenderAll s e =
	(
	
		ot=currenttime
		ov=viewport.activeViewport
		maxed=false
	
		oact=ui_active.tag
		ui_active.tag=0
	
	
		abort=false
		
		nav=seq_nav[2].tag.value
		w_start=nav.w_start
		w_end=nav.w_end
		expl=""
		hlc=0
 		
		tracks=#()
			for i = 1 to seq_track.count do
			(					
				if (seq_track[i][2].tag.value.r_start>=w_start AND seq_track[i][2].tag.value.r_end<=(w_end+1) ) do
				(
					if (seq_track[i][2].tag.value.cam!=undefined AND seq_track[i][2].tag.value.enabled != false ) then
					(
						seq_track[i][2].backcolor = color_highlight
						hlc += 1
						
						append tracks i
					)	else 
					(
						expl="\n(Only clips with a camera assigned will render/render)"
					)
				)
			)
			
			if (hlc>0) then
			(
				r=querybox ("Cloudrender highlighted clips?" + expl)
			) else
			(
				messageBox("No renderable clips in working area."+expl)
				r=false	
			)
			
			if (r) do
			(
				doCloudRenderThis s e tracks 
			)
			
			for i = 1 to seq_track.count do
			(					
					seq_track[i][2].backcolor = color_slider
			)
			
			ui_active.tag=oact;
			
	)

	fn getRenderRange i =
	(
		
		start=seq_track[i][2].tag.value.r_start
		end=(seq_track[i][2].tag.value.r_end-1)
		
		if (seq_track[i][2].tag.value.r_end - seq_track[i][2].tag.value.r_start > 1) do
		(
			start=seq_track[i][2].tag.value.r_start -    cs_settings.handles
			if (start<0) do (start=0)
			end=(seq_track[i][2].tag.value.r_end-1) + cs_settings.handles
		)

			return #(start, end)
	)
 
	fn onRenderThis s e=
	(
		
		i=s.parent.Tag
		r=checkSettings true		
		
		if (r==true) do
		(
			renderSceneDialog.close()
			ss=seq_track[i][2].tag.value.stateset
			ov=viewport.activeViewport
			vp=getViewport()
			maxed=false
			if (vp==false) do
			(	maxed=true
				max tool maximize	
				vp=getViewport()
			)
			
			if (vp!=false) then
			(
				viewport.activeViewport=vp
				
				if (seq_track[i][2].tag.value.cam != undefined  ) then
				(
					curCam=handle2cam  seq_track[i][2].tag.value.cam 
					if (curCam!=undefined) then
					(
						
					setCam curCam
					if (getState()!=ss) do
					(  
						setState ss
					)
					setclipboardText curCam.name
					rendOutputFilename=getProjectRenderFile i
		
					range=getRenderRange i
					
					rendStart=range[1] as time
					rendEnd= range[2] as time
					
					if (rendStart == rendEnd ) then
					(
						rendTimeType = 1
					) else
					(
						rendTimeType = 3
					)
					
					rendSaveFile = true
					renderSceneDialog.close()
					
					if (getFilenameType rendOutputFilename==".exr" AND  ProSequencer.cs_settings.use_auto_pass == true )  then
					(
						try(
						macros.run "jdbgraphics" "AutoPass"	
						) catch ( print "Error during autopass")
					)  else
					(
					print "Skipping AutoPass, output not EXR and/or AutoPass has been disabled"
					)
					
		
		
					renderSceneDialog.update()
					renderSceneDialog.open()
					) 
				)	else
				(
					messageBox "Please assing a camera to this track to be able to render"	
				)	
			
			)	else
			(
				if (maxed==true) do (max tool maximize	  )
				messageBox "Please set one of the viewports to 'camera' to be able to render"	
			)
		)
 
	)
	
	fn onExplorePreview s e =
	(
		
		i=s.parent.Tag
 
		file=getProjectPreviewFile i
		
		if (doesFileExist file) then
		(
			op=" /select, \""+(getProjectPreviewFile i)+"\""
		) else
		(
			op=getProjectPreviewPath()
		)
			op=getProjectPreviewPath()
		 
 		shellLaunch "explorer.exe" op
	)
	
		
	fn onExploreRender s e =
	(
		i=s.parent.Tag
		op=getProjectRenderPath i
 		shellLaunch "explorer.exe " op
	)
	
	fn parseToken str i =
	(
		 

		
		cam_name="default_"
		nraw="";
		
		if (i>0) do
		(
			
			n="_default_"+ i as string
		
			
			if (seq_track[i]!=undefined) do
			(
				if (seq_track[i][2].tag.value.cam != undefined) do
				(
					a=handle2cam  seq_track[i][2].tag.value.cam 

						
					if (superclassof a == camera) do
					(
						dup=""
						if (seq_track[i][2].tag.value.meta==undefined or  seq_track[i][2].tag.value.meta=="") do
						(
							dup=getDup i
						)
						nraw=a.name
						n=a.name+dup
					)
				)  
			)
		
			cam_name = n
		)			
		
		sname="no_state"
		try
		(
			sname=(getStateSetName _masterState.children  (seq_track[i][2].tag.value.stateset))
		) catch
		(
			
		)
		
		if (cam_name==undefined or cam_name=="" ) do (cam_name="missing_cam")		
		if (nraw==undefined or nraw=="")  do (nraw="missing_cam")	
		if (sname==undefined or sname=="") do (sname="no_stateset")					
		str=substituteString str "{camera}"  nraw
		str=substituteString str "{cameraDup}"  cam_name
		str=substituteString str "{track_id}"  (i as string)
		str=substituteString str "{project_folder}"  (pathConfig.getCurrentProjectFolder() )
		str=substituteString str "{scene_name}"  (getFilenameFile  maxfilename)
 		str=substituteString str "{jdb}"  (getProjectPath())
		str=substituteString str "{stateset}"  sname
		
		if (i>0) do 
		(
			v = seq_track[i][2].tag.value.version
			if (v==undefined) do (v=""; )		
			str=substituteString str "{version}"  v
				
			m = seq_track[i][2].tag.value.meta
			if (m==undefined) do (m=""; )		
			str=substituteString str "{meta}" m
		)
		str			
	)
	
	fn getPreviewPath =
	(
		p=((getDir #preview)+"\_scene.avi") 
		p
	)
	
	
	fn getProjectPath =
	(
		pa = filterString maxFilePath  @"\" splitEmptyTokens:true		
		
		if (pa[2]=="Projects") then
		(
			pt=pa[1]+@"/"+pa[2]+@"/"+pa[3] 
		) else
		(
			pt=maxFilePath
		)
		
		if (pt=="") do (pt=(getDir #Scene) )
		pt
	)
	
	fn getProjectPreviewPath =
	(
		
		pt=getFilenamePath (parseToken cs_settings.preview_output 0)
		
		if (isDirectoryWriteable (substring pt 1 (pt.count-1)) == false) do
		(
			makeDir pt
		)
		
		if (isDirectoryWriteable (substring pt 1 (pt.count-1)) == false) do
		(
			messageBox ("Can't write to output folder\n"+pt)
		)
		 
		pt
	)
	
	fn getProjectRenderPath i  silent:false=
	(
		checkSettings true
		pt=getFilenamePath (parseToken cs_settings.render_output i)
		
		if (isDirectoryWriteable (substring pt 1 (pt.count-1)) == false) do
		(
			makeDir pt
			if (silent==false) do
			(
				messageBox("An output folder has been created at:\n"+pt+"\nAll renders for this track will be saved there")
			)
		)
		
		if (isDirectoryWriteable (substring pt 1 (pt.count-1)) == false) do
		(
			messageBox ("Can't write to output folder\n"+pt)
		)
		
		pt
	)
	
	
	fn getProjectRenderFile i  silent:false  =
	(
		ext=".exr"
		pt="";
		
		if (rendOutputFilename!=undefined) do
		(
			ext=getFilenameType (rendOutputFilename)
		)
		
		
				rendStart=seq_track[i][2].tag.value.r_start as time
				rendEnd= (seq_track[i][2].tag.value.r_end-1) as time
				
				if (rendStart == rendEnd ) then
				(
				  	pt=(getProjectRenderPath i silent:silent) + (getTrackOutputName i)
				) else
				(
					out=(getTrackOutputName i) 
					ext=getFilenameType out;
					p=getFilenamePath  out
					f=getFilenameFile out;
				 	pt=(getProjectRenderPath i silent:silent) + p+f+"_0000"+ext;
					
				)

		pt
	)
	
	
	fn getProjectRenderFileDeadline i  silent:false  =
	(
		ext=".exr"
		pt="";
		
		if (rendOutputFilename!=undefined) do
		(
			ext=getFilenameType (rendOutputFilename)
		)
		
		
				rendStart=seq_track[i][2].tag.value.r_start as time
				rendEnd= (seq_track[i][2].tag.value.r_end-1) as time
				
				if (rendStart == rendEnd ) then
				(
				  	pt=(getProjectRenderPath i silent:silent) + (getTrackOutputName i)
				) else
				(
					out=(getTrackOutputName i) 
					ext=getFilenameType out;
					p=getFilenamePath  out
					f=getFilenameFile out;
				 	pt=(getProjectRenderPath i silent:silent) + p+f+"_"+ext;
				)

		pt
	)
	
	fn getProjectPreviewFile i =
	(
		
		p = parseToken cs_settings.preview_output i
		p
	)
	
	fn getTrackOutputName i =
	(
	 
		str=ProSequencer.cs_settings.render_outputfile
		out=parseToken str i 
		out
	)
	
	fn movePreviewFile i =
	(
		auto_preview=false
		trg=false
		src=getPreviewPath()
				
		trg=getProjectPreviewFile i

		skip=false
		if (doesFileExist trg) do
		(
			while ((deleteFile  trg)==false AND skip==false) do 
			( 
				r=queryBox("Error overwriting target file:\n"+trg+"\nRetry?"))
				if (r==false) do (
				skip=true	
			)
		)
		
		if (doesFileExist src) do
		(	
			renameFile  src trg
		)

		trg		
	)
	

	
	fn onPreviewAll s e =
	(
		id=s.parent.Tag
	
		r=checkSettings true  			
		
		if (r==true) do
		(
			auto_preview=false
			ot=currenttime
			ov=viewport.activeViewport
			maxed=false
			
			ui_active.tag=0
			abort=false
			
			nav=seq_nav[2].tag.value
			w_start=nav.w_start
			w_end=nav.w_end
			expl=""
			hlc=0
			
			for i = 1 to seq_track.count do
			(					
				if (seq_track[i][2].tag.value.r_start>=w_start AND seq_track[i][2].tag.value.r_end<=(w_end+1) ) do
				(
					if (seq_track[i][2].tag.value.cam!=undefined) then
					(
						seq_track[i][2].backcolor = color_highlight
						hlc += 1
					)	else 
					(
						expl="\n(Only clips with a camera assigned will preview/render)"
					)
				)
			)
			
			if (hlc>0) then
			(
				r=querybox ("Create preview files for highlighted clips?" + expl)
			) else
			(
				messageBox("No previewable clips in working area."+expl)
				r=false	
			)
			for i = 1 to seq_track.count do
			(					
					seq_track[i][2].backcolor = color_slider
			)
			
			if (r==true) do
			(	
				for i = 1 to seq_track.count do
				(
				
					if (con.modifierKeys==con.modifierKeys.Escape) do (abort=true)   -- not working
					
					if (seq_track[i][2].tag.value.r_start>=w_start AND seq_track[i][2].tag.value.r_end<=w_end) do
					(
						if (abort==false) do
						(
							trackSelect seq_track[i][5]
								
							vp=getViewport()
						
							if (vp==false) do
							(
								max tool maximize	
								maxed=true				
								vp=getViewport()
							)
					 
							if (seq_track[i][2].tag.value.cam != undefined  ) do
							(
								curCam=handle2cam  seq_track[i][2].tag.value.cam 
								if (curCam!=undefined) do
								(
									if (vp!=false) then
									(
										if (getState()!=seq_track[i][2].tag.value.stateset) do
										(  
											setState  seq_track[i][2].tag.value.stateset
										)
							
										ttm.Interval = 100 -- every two seconds
										dotnet.addEventHandler ttm "Elapsed" seq_OnTick
										ttm.Start()
										
										viewport.activeViewport=vp
										setCam curCam
										max tool maximize	
										max tool maximize	
											
										src=getPreviewPath()
										
										if (doesFileExist src) do
										(
											if ( (deleteFile  src)==false) do (messageBox ("Error overwriting preview file:\n"+trg))
										)
									 	if (maxv<=14000) then (   ) else
										(
											NitrousGraphicsManager.MakePreviewQuality=cs_settings.preview_quality
										)
										ignoreTimeChangeEvent=true 
										actionMan.executeAction 0 "40033"
										ignoreTimeChangeEvent=false
										
								 
										mBitmap = openBitmap src
										if (mBitmap!=undefined) then
										(
											chk=mBitmap.numFrames
									 
											close mBitmap
											free mBitmap
											if ((seq_track[i][2].tag.value.r_end-seq_track[i][2].tag.value.r_start)!=chk) do
											(
												abort=true
											)
											
										) else
										(
											abort=true
										)
							 			
										if (abort!=true) do
										(
											movePreviewFile i
										)
										
										auto_preview=true
										
										viewport.activeViewport=ov
										sliderTime=ot
										seq_TrackTime()
										ttm.Stop()
										dotnet.removeAllEventHandlers ttm
								 
										
									) else (
										if (maxed==true) do
										(
												maxed= false
												max tool maximize	
										)
							
									 	messageBox "Please set one of the viewports to 'camera' to be able to use MakePreview"	
									)
								)
							)
						)
					)
				)
			)
		)
	
		if (maxed==true) do
		(
				max tool maximize	
		)
			ui_active.tag=1
	)

	
	fn onRangeFromKeys s e=
	(
		if (e == -1 ) then
		(
			i=s
		) else
		(
			i=s.parent.Tag
		)
		
		curCam=handle2cam  seq_track[i][2].tag.value.cam 	
		
		if (curCam!=undefined) do
		(
			os=selection as array
			
			select curCam
			if (curCam.target!=undefined) do
			(
				
			selectMore curCam.target	
			)
			
			pf=-20000
			nf=-19999;

			minf=-10000
			maxf=-10000

			while (pf<nf  ) do 
			(
				pf=nf;  
				at time nf (
					nf=trackbar.getNextKeyTime();
				)

				if (nf!=undefined) then 
				(
				 
					if (minf == -10000) do ( minf=nf)	
					if (  pf<nf) do ( maxf=nf)
					
				) else (
					nf=-1	
				)
			)
 
			select os
			minf = minf as integer/ticksperframe
			maxf = maxf as integer/ticksperframe
			
			if (minf != maxf) then
			(
			setTrackRange i minf maxf
			)	else
			(
				if (e != -1) do
				(				
					messageBox ("\""+curCam.name+"\" needs atleast 2 keys at different times to get a range")	
				)
			)
		)
	)	
	
	fn onTrackUp s e =
	(
			id=s.parent.Tag
			swap seq_track[id] seq_track[id-1]
			transformUpdate 0
	)

	fn onTrackDown s e =
	(
			id=s.parent.Tag
		
			t1= deepCopy  seq_track[id]
			t2= deepCopy  seq_track[id+1]
		
			seq_track[id]=deepcopy t2
			seq_track[id+1] = deepcopy t1
		 
			transformUpdate 0
	)

	
	fn setTrackRange i start end =
	(
			seq_track[i][2].tag.value.r_start=start
			seq_track[i][2].tag.value.r_end=end+1
				
			seq_track[i][2].tag.value.ss=start
			seq_track[i][2].tag.value.se=end+1
			transformUpdate i	
			seq_TrackTime()
	)
		
	
	fn onMouseDown s e = 
	(
		mouse_action=s.name
		oldPos = (s.PointToScreen e.Location).X
		
		if (e.clicks==2 and s.name=="track_area") then
		(
			if (isanimplaying()) then ( stopanimation(); redrawviews()) else
				(
					slidertime = (screenToKey((e.x) )) 
				)
		)

		
			if (con.modifierKeys==con.modifierKeys.Control AND mouse_action=="track_slider") then
			(
				 curCam=s.tag.value.cam
				if (curCam!=undefined) do
				(
					curCam=handle2cam  curCam    
					if (curCam!=undefined) do
					(
						setCam curCam
					)
				) 	 
			)
			
		if ((e.clicks==2  )and s.name=="track_slider") do
		(
			 curCam=s.tag.value.cam
			if (curCam!=undefined) do
			(
				curCam=handle2cam  curCam    
				if (curCam!=undefined) do
				(
					a=curCam
					done=false
					if (a.target!=undefined) then
					(
						if ( (selection[1]==a.target AND  selection[2]!=a.target AND done==false ) OR (  selection[1]!=a AND  selection[1]!=a.target ) ) then 
						(		
							clearSelection() 
							select (a)
							 
								selectMore (a.target)
							 
							done=true
						)  
						
						 
						if ( selection[1]==a AND  selection[2]==a.target AND done==false ) then 
						(		
							clearSelection() 
							select (a)
			 
							done=true
						)  
						
						if ( selection[1]==a   AND done==false ) then 
						(		
							clearSelection() 
							select (a.target)
				 
							done=true
						)  
					) else
					(
						clearSelection() 
						select (a)
					)
	
				)
				
				if (con.modifierKeys==con.modifierKeys.shift AND ui_active.tag==0) then
				(
				
					ui_active.tag=1
					timeChange (screenToKey((e.x)+s.location.x))
					 ui_active.tag=0
				)
			)
		)
		
		if (e.clicks==2 and s.name=="nav_slider") then
		(
			 
			busyAnimRangeEvent=true
			if (con.modifierKeys==con.modifierKeys.shift) then
			(
				st=10000
				end=-10000
				
				for i= 1 to seq_track.count do
				(	
					if (seq_track[i][2].tag.value.r_start < st ) do (st= seq_track[i][2].tag.value.r_start)
					if (seq_track[i][2].tag.value.r_end > end ) do (end= seq_track[i][2].tag.value.r_end)
				)	
				
				hdl=((end-st)/20) as integer
				if (st!=0) then ( st=st-hdl )
				end += hdl
				animationRange = interval st end
			) else
			(
				animationRange = interval seq_nav[2].tag.value.time_min seq_nav[2].tag.value.time_max
			)
		
			seq_nav[2].tag.value.time_min=animationRange.start as integer/ticksperframe
			seq_nav[2].tag.value.time_max=(animationRange.end ) as integer/ticksperframe
	 
			seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min 
			seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
			
			seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min 
			seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
			
			seq_nav[2].tag.value.range_start=0
			seq_nav[2].tag.value.range_length=seq_nav[2].tag.value.range_max_length
			seq_nav[2].location.x=seq_nav[2].tag.value.range_start
			seq_nav[2].width=seq_nav[2].tag.value.range_max_length
			
			changeMade "time"
			onNavTransform seq_nav[2] 0
			ProSequencer.transformUpdate 0
			seq_TrackTime()
			busyAnimRangeEvent=false
		)
		

		
		if (mouse_action=="track_area" and e.Button==e.Button.Left AND con.modifierKeys!=con.modifierKeys.Control ) do
		(
			
		 
			
		)
		
		--move sliders
		if ((mouse_action=="track_slider" OR mouse_action=="nav_slider"  ) and e.Button==e.Button.Left AND con.modifierKeys!=con.modifierKeys.Control) do
		(

			trackSelect s.parent
			x=e.x
		
			c = dotnetclass "System.Windows.Forms.Cursors"
			s.tag.value.sData = case of
			(
				(e.x < 10): 
				(
					s.Cursor.Current = c.SizeWE
					s.TextAlign=s.TextAlign.MiddleLeft	
					#(e.x,0,0)   --length,  0=drag_left|1=draw whole|2=drag rigth
				)
				
				(e.x > s.width - 10): 
				(
					s.Cursor.Current = c.SizeWE
					s.TextAlign=s.TextAlign.MiddleRight	
					#(e.x,2,0,s.width)
				)
				
				default: 
				(
					s.Cursor.Current = c.Default
					s.TextAlign=s.TextAlign.MiddleCenter	
					#(e.x,1,0)
				)
			)
		 			
			mouse_action="slider_drag"
		 
		)
		
		--track select
		if (mouse_action=="track_area" AND e.Button==e.Button.Left AND con.modifierKeys!=con.modifierKeys.Control) do
		( 
			
			if (		cur_track == s.tag ) then
			(
				cont=isanimplaying()
			 
				stopanimation()
				slidertime = (screenToKey((e.x) )) 
				 if (cont) do (playanimation())
				
				
			) else(
				
				if (isanimplaying()) then (
				stopanimation()
				) else
				(
				
				trackSelect s trg:(screenToKey((e.x) )) 
				)
			)
		)
		
		
		fn onRenameSS = 
		(
		
			
			
		)
		
		
		fn onRenameCams =
		(
		
			theObj = dotNetObject "MaxCustomControls.RenameInstanceDialog" "Basename_"
			theobj.text ="Please provide a basename:"
			DialogResult = theObj.Showmodal()

			if (dotnet.compareenums TheObj.DialogResult ((dotnetclass "System.Windows.Forms.DialogResult").OK)) then
			(
				basename=theobj.InstanceName
				
				for i= 1 to  seq_track.count do
				(	
					if (seq_track[i][2].tag.value.cam!=undefined) do
					(
						ccc=handle2cam  seq_track[i][2].tag.value.cam    
						 
						if (ccc!=undefined) do
						(
							uid = i as string

							if uid.count < 3 do
							(
							leadingZero = ""
							for n = 1 to 3 - uid.count do append leadingZero "0"
							uid = leadingZero + uid
							)

								ccc.name=basename+uid
						)
					)
				)
			)
		)

		--context menu
		if ((mouse_action=="track_area" OR mouse_action=="track_slider")  AND e.Button==e.Button.Right ) do
		( 
			
			stopAnimation()
		
			if (mouse_action=="track_area") do
			(
				trackSelect s trg:#area
				x=e.x + s.location.x
				y=e.y + s.parent.location.y
				id=s.tag
			)
			
			if (mouse_action=="track_slider") do
			(
				trackSelect s.parent  trg:#slider
				x=e.x + s.location.x+s.parent.location.x
				y=e.y + s.parent.location.y+s.parent.parent.location.y
				id=s.tag.value.i
			)
		
			contextMenu = dotNetObject "System.Windows.Forms.ContextMenu"
			contextMenu.Tag=id
			cam=seq_track[id][2].tag.value.cam

			gotcam=false		
			if ( selection.count==2 ) do
			(
				if ( (classof selection[1]==Targetobject OR classof selection[2]==Targetobject   ) AND (superclassof selection[1]==camera OR superclassof selection[2]==camera   ) ) do
				(
					gotcam=true
				)
			)
			
			if (superclassof $ == camera AND selection.count==1) then
			(
					gotcam=true
			)
			
			if (	gotcam==true) then
			(
				I_ab=contextMenu.MenuItems.Add("Link Selected Camera")
				dotnet.addEventHandler I_ab "Click" onPickSelCam
			) else 
			(
			
				I_a=contextMenu.MenuItems.Add("Pick Camera")
					dotnet.addEventHandler I_a "Click" onPickCam
			)
			
			if (viewport.getType() == #view_camera) do
			(
					I_pv=contextMenu.MenuItems.Add("Link Active Viewport Camera")
					dotnet.addEventHandler I_pv "Click" onPickVPCam
			)
			
			I_a2=contextMenu.MenuItems.Add("Unlink camera")
			I_r=contextMenu.MenuItems.Add("Range from keys")
			I_sv=contextMenu.MenuItems.Add("Send Camera to active viewport")
			I_as=contextMenu.MenuItems.Add("AutoSetup from cam selection")
			I_ba=contextMenu.MenuItems.Add("Bake range to single cam")
			contextMenu.MenuItems.Add("-")
			
			
			if (maxv<=14000) then (   ) else
			(
				I_lss=contextMenu.MenuItems.Add("Link current StateSet")
				dotnet.addEventHandler I_lss "Click" onLinkStateSet
				if (getStateForced()==undefined) do
				(
						I_lss.Enabled=false
				)
			
				if (seq_track[id][2].tag.value.stateset!=undefined) then
				(
					I_uss=contextMenu.MenuItems.Add("UnLink StateSet")
					dotnet.addEventHandler I_uss "Click" onUnlinkStateSet
					
				)
			)
	
			contextMenu.MenuItems.Add("-")
			I_ddr=contextMenu.MenuItems.Add("Print summary")
			contextMenu.MenuItems.Add("-")
			I_pt=contextMenu.MenuItems.Add("Preview this")
			I_pa=contextMenu.MenuItems.Add("Preview all in workarea")
			I_op=contextMenu.MenuItems.Add("Explore Preview location")
			
			
			contextMenu.MenuItems.Add("-")
			I_rt=contextMenu.MenuItems.Add("Render this")
			I_rc="";
			
			I_rca="";
 
			 
				I_rc=contextMenu.MenuItems.Add("Submit this to Deadline")
				I_rca=contextMenu.MenuItems.Add("Submit all tracks in workarea to Deadline")
				dotnet.addEventHandler I_rc "Click" onCloudRenderThis
				dotnet.addEventHandler I_rca "Click" onCloudRenderAll
			 
				dotnet.addEventHandler I_ddr"Click" onPrintSum
			
			
			I_opr=contextMenu.MenuItems.Add("Explore Render location")
			contextMenu.MenuItems.Add("-")
			I_cr= contextMenu.MenuItems.Add("Auto rename all cameras")
			I_crss= contextMenu.MenuItems.Add("Auto rename StateSets to linked cameras")
			
			sub_version=contextMenu.MenuItems.Add("Shot version")
				
			a_ver = sub_version.MenuItems.add "Set Shot version"
			a_met = sub_version.MenuItems.add "Set Shot metadata"
			a_vera = sub_version.MenuItems.add "Set Shot version (all tracks)"
			a_meta = sub_version.MenuItems.add "Set Shot metadata (all tracks)"


			dotnet.addEventHandler a_ver "Click" onSetVersion
			dotnet.addEventHandler a_met "Click" onSetMeta
			
			dotnet.addEventHandler a_vera "Click" onSetVersionAll
			dotnet.addEventHandler a_meta "Click" onSetMetaAll
			
				
			contextMenu.MenuItems.Add("-")
			
			if (seq_track[id][2].tag.value.enabled!=false) then
			(
				I_tdis= contextMenu.MenuItems.Add("Disable Track")	
				dotnet.addEventHandler I_tdis "Click" onDisable
			) else
			(	
				I_ten= contextMenu.MenuItems.Add("Enable Track")
				dotnet.addEventHandler I_ten "Click" onEnable
			)
						
			contextMenu.MenuItems.Add("-")
			
			I_at= contextMenu.MenuItems.Add("Add Track")
			I_atd= contextMenu.MenuItems.Add("Duplicate Track")
			I_d=contextMenu.MenuItems.Add("Delete Track")
			contextMenu.MenuItems.Add("-")
			
			if (seq_track.count>1) then
			(
					I_d.Enabled=true
			) else
			(
					I_d.Enabled=false
			)
			
			if (cam == undefined) do
			(
				I_a2.Enabled=false
				I_r.Enabled=false
				
				I_a2.Enabled=false
				I_r.Enabled=false
				
				I_sv.enabled=false
			)
			
			dotnet.addEventHandler I_r "Click" onRangeFromKeys
			dotnet.addEventHandler I_d "Click" onTrackRemove
			dotnet.addEventHandler I_as "Click" onAutoSetup
			dotnet.addEventHandler I_op "Click" onExplorePreview
			dotnet.addEventHandler I_opr "Click" onExploreRender
			dotnet.addEventHandler I_a2 "Click" onUnPickCam
			dotnet.addEventHandler I_at "Click" onTrackAdd	
			dotnet.addEventHandler I_atd "Click" onTrackDup	
			
			dotnet.addEventHandler I_pt "Click" onPreviewThis
			dotnet.addEventHandler I_pa "Click" onPreviewAll
			dotnet.addEventHandler I_rt "Click" onRenderThis

			
			
			
			dotnet.addEventHandler I_cr "Click" onRenameCams
			dotnet.addEventHandler I_crss "Click" onRenameSS
			
			
			dotnet.addEventHandler I_sv "Click" onSendToVP
			dotnet.addEventHandler I_ba "Click" bakeMaster
			sub_options=contextMenu.MenuItems.Add("Options")
			adv_options=contextMenu.MenuItems.Add("Advanced/Beta")

	
			if ( seq_track[id][2].tag.value.cam==undefined  ) then
			(
				I_pt.Enabled=false
				I_rt.Enabled=false
		 
				I_rc.Enabled=false
			 
			)
			
			a_exp = adv_options.MenuItems.add "Copy edit to clipboard"
			a_imp = adv_options.MenuItems.add "Paste edit from clipboard"
			a_vfb = sub_options.MenuItems.add "Filter VFB+ filmstrip for current camera"

			
			dotnet.addEventHandler a_exp "Click" onExpCB
			dotnet.addEventHandler a_imp  "Click" onImpCB
	 
			I_ojg  =sub_options.MenuItems.add "Jump Gaps"
			
			I_nlp  =sub_options.MenuItems.add "Non Linear Playback"
			I_iss =sub_options.MenuItems.add "Ignore StateSet Switching"
			I_cfu= item =sub_options.MenuItems.add "Check for updated weekly"
			
			if ( (getSetting "options" "jump_gap") == "1" ) do
			(
				I_ojg.checked=true
			)
			
					if ( (getSetting "options" "nlp") == "1" ) do
			(
				I_nlp.checked=true
			)
			
			
			if ( (getSetting "options" "ignore_statesets") == "1" ) do
			(
				I_iss.checked=true
			)
			
			
			if ( (getSetting "options" "autostart") == "1" ) do
			(
				--I_asm.checked=true
			)
			
			
			if ( (getSetting "options" "auto_update_check") == "1" ) do
			(
				I_cfu.checked=true
			)
			
			if ( (getSetting "options" "filter_vfb") == "1" ) do
			(
				a_vfb.checked=true
			)
				
			dotnet.addEventHandler a_vfb "Click" onToggleVFB
			dotnet.addEventHandler I_ojg "Click" onToggleJumpGap
			dotnet.addEventHandler I_nlp "Click" onToggleNLP
			dotnet.addEventHandler I_iss "Click" onToggleIgnoreSS
			dotnet.addEventHandler I_cfu "Click" onToggleUpdateCheck
			pointTest = (dotNetObject "System.Drawing.Point" x y)
			contextmenu.Show seq_panel pointTest
				
		)
		
		--drag middle mouse
		if (e.Button==e.Button.Middle ) do
		(
			if (mouse_action=="track_area") do
			(
				mouse_action="time_drag"	 
				seq_nav[2].tag.value.drag_start=e.x
			)
			
			if (mouse_action=="track_slider") do
			(
				seq_nav[2].tag.value.drag_start=e.x + s.location.x
				mouse_action="time_drag"		
			)
		)
	)
	
	fn onToggleJumpGap s e =
	(
		if ( (getSetting "options" "jump_gap") == "1" ) then
		(
			setSetting "options" "jump_gap" "0"
			option_jump_gap = "0"
		)
		else
		(
			setSetting "options" "jump_gap" "1"
			option_jump_gap = "1"
		)  
	)
	
		fn onToggleNLP s e =
	(
		if ( (getSetting "options" "nlp") == "1" ) then
		(
			setSetting "options" "nlp" "0"
			option_nlp = "0"
		)
		else
		(
			setSetting "options" "nlp" "1"
			option_nlp = "1"
		)  
	)
	
	fn onToggleVFB e =
	(
		if ( (getSetting "options" "filter_vfb") == "1" ) then
		(
			setSetting "options" "filter_vfb" "0"
			option_jump_vfb = "0"
			
		)  else
		(
			setSetting "options" "filter_vfb" "1"
			option_filter_vfb = "1"
		)  
	)
	
	
	fn onToggleIgnoreSS s e =
	(
		if ( (getSetting "options" "ignore_statesets") == "1" ) then
		(
			setSetting "options" "ignore_statesets" "0"
			option_ignore_statesets =  "0"
			timeChange currentTime
		)  else
		(
			setSetting "options" "ignore_statesets" "1"
			option_ignore_statesets =  "1"
		)  
	)
	
		
	fn onToggleAutoStart s e =
	(
		if ( (getSetting "options" "autostart") == "1" ) then
		(
			setSetting "options" "autostart" "0"
		)  else
		(
			src=(GetDir #publicExchangeStoreInstallPath)+@"JDBgraphics ProSequencer.bundle\Contents\scripts\ProSequencer_autostart.ms"
			dst=getdir #userscripts + @"\startup\ProSequencer_autostart.ms"  

			if ( (getfiles dst).count == 0 AND (getfiles src).count == 1)  do
			(
				copyFile src  dst
			)
			setSetting "options" "autostart" "1"
		)  
	)
		
	fn onToggleUpdateCheck s e =
	(
		if ( (getSetting "options" "auto_update_check") == "1" ) then
		(
			setSetting "options" "auto_update_check" "0"
		)  else
		(
			setSetting "options" "auto_update_check" "1"
			updateCheck()
		)  
	)
	
 
	fn onMouseDownTrack s e = 
	(
			 trackSelect s
	)
	
	fn zoomTime s e  = 
	(
		dx=0
		cx=0
		
		try (
		dx=e.delta
		cx=e.x
		) catch
		(
		
		)
		
		dt=dx /5.0
		t_width=seq_nav[2].tag.value.range_max_length
		
		fac=((cx-70-padding_left)/t_width as float)*1.0
		 
		d=dt *fac
		
		s=seq_nav[2]
		t_width=seq_nav[2].tag.value.range_max_length
		
		if d  >= 0 then
		(
			w = amax 2 ((s.tag.value.se-s.tag.value.ss) - d)
			dx = s.tag.value.ss + ((s.tag.value.se-s.tag.value.ss) - w)
		)
		else
		( 
			dx = amax 0 (s.tag.value.ss + d)
			w = amax 2 ((s.tag.value.se-s.tag.value.ss) + (s.tag.value.ss- dx))
		)
							
		d=dt*(1-fac  )*-1
		
		w = amin (t_width - dx) (amax 2 (w + d))
		s.tag.value.range_start=s.location.x
		s.tag.value.range_length=s.width
		fac=(s.tag.value.time_max-s.tag.value.time_min as float )/s.tag.value.range_max_length as float
		
		start=(s.tag.value.time_min+(dx)*fac) as integer
		end=(start+ (w*fac)) as integer
			
		nav=s.tag.value
		fac=(nav.time_max - nav.time_min as float )/(end - start as float)*nav.range_max_length as float/(nav.time_max-nav.time_min as float)
		ks=nav.range_max_length as float/(end-start)  --snap distance in px
 
		if (ks<140 and w>5) do
		(			
			s.width = w
			s.location.x=dx 
			s.tag.value.ss=dx
			s.tag.value.se=dx+w
			if (d!=0) do
			(
				transformUpdate 	0
				seq_TrackTime()
			)
		)
		
		 changeMade "time"
	)
	
	fn dragTime n = 
	(
		s=seq_nav[2]
		tag = s.tag.value.sData
		fac=seq_nav[2].tag.value.range_max_length/seq_nav[2].tag.value.range_length as float

		d = ((n as float)/key_size)  
		t_width=seq_nav[2].tag.value.range_max_length

		fac=seq_nav[2].tag.value.fac
		x = amin (t_width - s.width) (amax 0 (s.location.x + d))
		s.location.x = x
		 
		s.tag.value.sData = tag
		s.tag.value.ss=x
		s.tag.value.se=x +s.width
			
		if (d!=0) do
		(
			transformUpdate 	0
			seq_TrackTime()
			 changeMade "time"
		)
	)
		
		
	fn onMouseMoveReg s e= 
	(

		c = dotnetclass "System.Windows.Forms.Cursors"
		s.Cursor.Current = if ((e.x < 10 or e.x > s.width-10) AND s.name=="nav_slider") then c.SizeWE else c.Default

		if (e.Button==e.Button.Left    ) do
		(
			
			if s.tag.value.sData[3] == 0 then
			(
				
				tag = s.tag.value.sData
				d = e.x - tag[1]
				 
				t_width=s.parent.width
			
				tag[3] = 1

				case tag[2] of
				(
					0:  --length,  0=drag_left|1=drag whole|2=drag right
					(
						if d  >= 0 then
						(
							w = amax 2 (s.width - d)
							dx = s.location.x + (s.width - w)
						)
						else
						(
							dx = amax 0 (s.location.x + d)
							w = amax 2 (s.width + (s.location.x - dx))
						)
						
						s.bounds = dotnetobject "system.drawing.rectangle" dx s.location.y w s.height
					)
					2:
					(
						w = amin (t_width - s.location.x) (amax 2 (s.width + d))
							
						tag[1] += w - s.width
						s.width = w
					)
					default:
					(
						x = amin (t_width - s.width) (amax 0 (s.location.x + d))
						s.location.x = x
					)
				)
			 
				s.tag.value.sData = tag
				s.tag.value.ss=s.location.x 
				s.tag.value.se=s.location.x +s.width
				transformUpdate 	0
			) else 
			(
				tag = s.tag.value.sData
				tag[3] = 0
				s.tag.value.sData = tag
			)
			
			changeMade "time"
		)
	)
	
	fn onMouseMove s e = 
	(
	 
		if ( e.Button == e.Button.None ) do
		(  
			c = dotnetclass "System.Windows.Forms.Cursors"
			s.Cursor.Current = if (((e.x < 10 or e.x > s.width-10) AND s.name!="track_area"  )) then c.SizeWE else c.Default
		)
 
		if (mouse_action=="track_area" AND e.Button == e.Button.Left ) then 
		(
			src=s.tag 
			trg=(floor((e.y / uiscale + 10 )/20.0 ))

			if (trg>1 or trg<0 AND (src+trg)>0) do
			(
				seq_ruler.visible = true			
				seq_ruler.top=(src+trg) * 20 * uiscale
				c = dotnetclass "System.Windows.Forms.Cursors"
				s.Cursor.Current = c.SizeNS
				seq_ruler.BackColor =color_highlight
			)
			
			if ((src+trg)<1) do
			(
				seq_ruler.visible = false	
			)
			
			if (isanimplaying() == false ) do (
			
			  slidertime = (screenToKey((e.x) )) 
			)
			
			
		)
		
		
		if (mouse_action=="time_drag") then 
		(
			if (s.name=="track_area") do
			(
				
				dx=(e.x) - seq_nav[2].tag.value.drag_start 
				if (dx!=0) do
				(
					ro=mod (abs(dx as float)) key_size as float
					dx=dx-  (dx/abs(dx))*ro	
				
					if (dx!=0 ) do
					(
						seq_nav[2].tag.value.drag_start=seq_nav[2].tag.value.drag_start+dx
						dragTime (dx/-1)
					)
					
					changeMade "track"
				)
			)
			
			if (s.name=="track_slider") do
			(
				dx=e.x+ s.location.x-seq_nav[2].tag.value.drag_start

				ox= s.location.x
				if (dx!=0) do
				(
					ro=mod (abs(dx as float)) key_size as float
					dx=dx -  (dx/abs(dx))*ro	
						
					if (dx!=0) do
					(
						dragTime (dx/-1)
						seq_nav[2].tag.value.drag_start  += dx 
					)	
					changeMade "track"
				)
			)
		)
		
		if (mouse_action=="slider_drag") then 
		(
			use_clip=false
			his=0
			
			drg =not (oldpos==(s.PointToScreen e.Location).X )
			if drg == false do  ( return false)
			
			if ( e.Button == e.Button.Left AND con.modifierKeys==con.modifierKeys.Shift  ) do
			(
				snaps=#()
				for i= 1 to  seq_track.count do
				(
					if (s.tag.value.i!=i) do
					(
						appendIfUnique  snaps seq_track[i][2].tag.value.r_start
						appendIfUnique  snaps seq_track[i][2].tag.value.r_end
					)
				)
				
				appendIfUnique  snaps (currenttime as integer/ticksperframe)
				appendIfUnique  snaps (animationrange.start as integer/ticksperframe)
				appendIfUnique  snaps ((animationrange.end) as integer/ticksperframe)
				appendIfUnique  snaps 0
				snapto=undefined
				sort snaps
						
				seq_snaphead.height=seq_playhead.height
				his=8/getKeyWidth()
			)	
				
			if ( e.Button == e.Button.Left   ) do
			(
				if s.tag.value.sData[3] == 0 then
				(
					tag = s.tag.value.sData
					kx=screenToKey ((e.x)+s.location.x)
					kx2=screenToKey ((e.x-tag[1])+s.location.x)  
 				
					d = e.x - tag[1]
					t_width=s.parent.width
					fac=seq_nav[2].tag.value.fac
					tag[3] = 1
					case tag[2] of
					(
						0: --length,  0=drag_left|1=drag whole|2=drag right
						(
							if (his>1) do
							(
								for n in snaps do
								(
									if (abs(kx2-n)<his) do ( kx2=n; snapto=n;  )
									if (abs(kx-n)<his) do ( kx=n; snapto=n;  )
								)
							)
							 
							if (kx2<=seq_nav[2].tag.value.time_min AND use_clip) do
							(
								kx2=seq_nav[2].tag.value.time_min
							)
							
							if (kx2<s.tag.value.se   )  then
							(
								s.tag.value.ss =kx2
							) else
							(
								s.tag.value.ss =s.tag.value.se-1
							)
							
						)
						2:
						(
							kx3=screenToKey ((e.x-tag[1])+s.location.x+tag[4])  

							if  (kx3>=seq_nav[2].tag.value.time_max  AND use_clip) do
							(
							  kx3=	seq_nav[2].tag.value.time_max
							)

							if (his>1) do
							(
								for i = 1 to  snaps.count do
								(
									m=snaps[snaps.count - i + 1]
								 
									if (abs(kx3-m)<his) do (   kx3=m; snapto=m;)
								 
								)
							)
								
								
							if (kx3>s.tag.value.ss+1   )  then
							(
								s.tag.value.se = kx3
							) else
							(
								s.tag.value.se =s.tag.value.ss+1
							)
						)
						default:
						(  
							x = amin (t_width - (s.tag.value.se-s.tag.value.ss)) (amax 0 (s.tag.value.ss + d))
							x2 = amin (t_width - (s.tag.value.se-s.tag.value.ss)) (amax 0 (s.tag.value.se + d))
							w=	s.tag.value.r_end-s.tag.value.r_start
							
							if (his>1) do
							(
								for i = 1 to  snaps.count do
								(
										n=snaps[snaps.count - i+1]
									if (abs((kx2+w)-n)<his) do ( kx2=n-w; snapto=n ;  )
									if (abs(kx2-n)<his) do ( kx2=n; snapto=n;  )
						 
			 					)
							)	
						 
							if ( kx2+w > seq_nav[2].tag.value.time_max AND use_clip) do
							(
									kx2=seq_nav[2].tag.value.time_max-w
							)
							
							if ( kx2 < seq_nav[2].tag.value.time_min AND use_clip) do
							(
									kx2=seq_nav[2].tag.value.time_min
							)
							
							s.tag.value.ss = kx2
							s.tag.value.se =  kx2+w
						)
					)
				 
					if (snapto!=undefined) then
					(

					 

						seq_snaphead.location.x=(keyToScreen snapto)	+ seq_nav[1].left + 69 * uiscale
						seq_snaphead.visible=true
					) else
					(
						seq_snaphead.visible=false
					)
					
					s.tag.value.sData = tag
					
					if s.name != "nav_slider" do
					(
						
						ot=s.tag.value.r_start
						onTransform s e
						
						if (con.modifierKeys==con.modifierKeys.Alt AND tag[2]==1 and s.tag.value.cam!=undefined) do
						(
							curCam=handle2cam  s.tag.value.cam    
							if (curCam!=undefined) do
							(
								insertTime curCam -10000  (s.tag.value.r_start-ot)
								if (curCam.target!=undefined) do
								(
									insertTime curCam.target -10000  (s.tag.value.r_start-ot)
								)
							)
						)
					)
				)
				else 
				(
					tag = s.tag.value.sData
					tag[3] = 0
					s.tag.value.sData = tag
				)
			)
		)
	)
	
	fn navigationAdd = 
	(	
		if (ProSequencer.seq_nav_tag()!=undefined) do
		(
			slide_width= track_width * uiscale - (115 * uiscale)
			nav_height=11* uiscale
			seq_nav[1]=dotnetobject "UserControl"    -- track container
			seq_nav[1].width=track_width * uiscale
			seq_nav[1].height=nav_height
			seq_nav[1].top=4 * uiscale
			seq_nav[2] = dotnetobject "Button"   -- sliding button
			seq_nav[2].backcolor =	dnColor.FromArgb 200 170 30
			seq_nav[2].tag = dotNetMxsValue (ProSequencer.seq_nav_tag())
			seq_nav[2].flatStyle=seq_nav[2].flatStyle.flat
			seq_nav[2].height=nav_height-(2* uiscale)
			seq_nav[2].flatappearance.bordercolor = dnColor.FromArgb 200 170 30
			seq_nav[2].width=slide_width * uiscale
			seq_nav[2].height = track_height * uiscale
			seq_nav[2].left=0
			seq_nav[2].top=0
			seq_nav[2].name="nav_slider"
				
			seq_nav[3]=dotnetobject "UserControl"    -- left indicator
			seq_nav[3].width= 3* uiscale
			seq_nav[3].height=nav_height
			seq_nav[3].left=0
			seq_nav[3].top=0 
			seq_nav[3].backcolor =	dnColor.FromArgb 60 60 60
				
			seq_nav[4]=dotnetobject "UserControl"    --- rigth indicator
			seq_nav[4].width=3* uiscale
			seq_nav[4].height=nav_height
			seq_nav[4].left=slide_width - (10* uiscale)
			seq_nav[4].top=0
			seq_nav[4].backcolor =	dnColor.FromArgb 60 60 60
				
			seq_nav[5]=dotnetobject "UserControl"    -- sliding area
			seq_nav[5].width=slide_width * uiscale
			seq_nav[5].height=nav_height
			seq_nav[5].left=70* uiscale
			seq_nav[5].top=0
			seq_nav[5].name="nav_area"
		 
			seq_nav[5].backcolor =seq_nav[5].backcolor.Silver	
			seq_nav[2].tag.value.i=1
	 
			seq_nav[2].tag.value.time_min=animationRange.start as integer/ticksperframe
			seq_nav[2].tag.value.time_max=(animationRange.end ) as integer/ticksperframe
			seq_nav[2].tag.value.range_max_length=slide_width
			seq_nav[2].tag.value.ss=0
			seq_nav[2].tag.value.se=seq_nav[2].tag.value.range_max_length
			seq_nav[2].tag.value.w_start=seq_nav[2].tag.value.time_min
			seq_nav[2].tag.value.w_end=seq_nav[2].tag.value.time_max
			seq_nav[2].tag.value.range_start=seq_nav[2].location.x
			seq_nav[2].tag.value.range_length=seq_nav[2].tag.value.range_max_length --seq_nav[2].width
			seq_nav[2].tag.value.panel_width=seq_panel.width
			seq_nav[2].tag.value.fac=seq_nav[2].tag.value.range_length/seq_nav[2].tag.value.range_max_length

			dotnet.addeventhandler seq_nav[2] "MouseMove" onMouseMoveReg
			dotnet.addeventhandler seq_nav[2] "MouseDown" onMouseDown
			dotnet.addeventhandler seq_nav[2]  "MouseUp" onMouseUp
			dotnet.addeventhandler seq_nav[2] "Move" onNavTransform
			dotnet.addeventhandler seq_nav[2] "Resize" onNavTransform
		 
			seq_nav[1].controls.addrange #(	seq_nav[5])
			seq_nav[5].controls.addrange #(	seq_nav[2])
			
			seq_nav[2].controls.addrange #(	seq_nav[3])
			seq_nav[2].controls.addrange #(	seq_nav[4])
				
			slidepanel.controls.addrange #(	seq_nav[1])
			setLifetimeControl #(seq_nav[2],  slidepanel)
			setLifetimeControl #(seq_nav[1] , slidepanel)
		
			)
	)

	fn trackAdd = 
	(	
		i=seq_track.count+1
		seq_track[i]=#()
		seq_track[i][1]=dotnetobject "UserControl"    -- track container
		seq_track[i][1].width= track_width 
		seq_track[i][1].height=track_height
		seq_track[i][1].tag = i
		
		seq_track[i][1].top=(i-1)*track_height+(20* uiscale)
		
		seq_track[i][2] = dotnetobject "Button"   -- sliding button
		seq_track[i][2].backcolor =	dnColor.FromArgb 240 240 240
		seq_track[i][2].tag = dotNetMxsValue (ProSequencer.seq_tr_tag())
		seq_track[i][2].flatStyle=	seq_track[i][2].flatStyle.flat
		seq_track[i][2].flatappearance.bordercolor = dnColor.FromArgb 150 150 150
		seq_track[i][2].tag.value.ss=seq_nav[2].tag.value.time_min
		seq_track[i][2].tag.value.se=seq_nav[2].tag.value.time_min + 50
		seq_track[i][2].tag.value.i=i	
		seq_track[i][2].name="track_slider"

		seq_track[i][4] = dotnetobject "Button"  -- pick camera button
		seq_track[i][4].backcolor = 	seq_track[i][4].backcolor.Transparent
		seq_track[i][4].tag = i
		seq_track[i][4].left=0
		seq_track[i][4].top=0
		seq_track[i][4].height=track_height
		seq_track[i][4].width=68* uiscale
		seq_track[i][4].Text="Pick Cam"
		ToolTipObj.SetToolTip seq_track[i][4] "Select a camera to assign to this track"	

		seq_track[i][5]=dotnetobject "UserControl"    -- sliding area
		seq_track[i][5].width= track_width-(90* uiscale)
		seq_track[i][5].height=track_height
		seq_track[i][5].left=70* uiscale
		seq_track[i][5].top=0
		seq_track[i][5].tag=i
		seq_track[i][5].name="track_area"
		
		if (mod i 2 == 0) then
		(
			seq_track[i][5].backcolor =color_zebra_a
		) else
		(
			seq_track[i][5].backcolor =color_zebra_b
		)
			dotnet.addeventhandler seq_track[i][1] "MouseMove" onMouseMove
		dotnet.addeventhandler seq_track[i][2] "MouseMove" onMouseMove
		dotnet.addeventhandler seq_track[i][5] "MouseMove" onMouseMove
		dotnet.addeventhandler seq_track[i][2] "MouseDown" onMouseDown
		dotnet.addeventhandler seq_track[i][2] "MouseUp" onMouseUp
		dotnet.addeventhandler seq_track[i][2] "Move" onTransform
		dotnet.addeventhandler seq_track[i][2] "Resize" onTransform
		dotnet.addeventhandler seq_track[i][5] "MouseDown" onMouseDown
		dotnet.addeventhandler seq_track[i][5] "MouseUp" onMouseUp
		dotnet.addeventhandler seq_track[i][4] "MouseUp" onPickCam
		dotnet.addeventhandler seq_track[i][2] "KeyUp" onKey
		
		
			 
		
		seq_track[i][2].Width = 100 * uiscale
		seq_track[i][2].height = track_height
		seq_track[i][2].top=0

		seq_track[i][1].controls.addrange #(	seq_track[i][5])
		seq_track[i][5].controls.addrange #(	seq_track[i][2])
			
		slidepanel.controls.addrange #(	seq_track[i][1])
		setLifetimeControl #(seq_track[i][2],  slidepanel)
		setLifetimeControl #(seq_track[i][1] , slidepanel)
	)
	
	fn onKey s e =
	(
		if( e.KeyData ==  e.KeyData.Space ) do
		(
		  try ( macros.run "JDBgraphics" "ProPlay_normal"  ) catch ( )
		) 
	)
		
	fn onToggle=
	( 
		Toggle -1
	)
	
	fn Toggle show=
	( 
		--resumeRedraw()
		
		done = false
		if (ui_toggle.Text=="hide" OR show==2  ) then
		(
			ui_toggle.Text="show"
			setHeight 0 (19*uiscale)  
			ui_toggle.TextAlign=ui_toggle.TextAlign.MiddleCenter	
			seq_nav[2].tag.value.showhide=1
			done = true
		)  
		
		if ((ui_toggle.Text=="show" and done==false ) OR show==3 ) then
		(
			if (seq_track.count==0) do
			(
				trackAdd()	
				trackAdd()	
				trackAdd()	
				seq_nav[2].tag.value.showhide=1
			)
			
			
			ui_toggle.Text="hide"
			setHeight 0 0
		
			ui_toggle.TextAlign=ui_toggle.TextAlign.MiddleCenter	
			seq_nav[2].tag.value.showhide=0
			syncTrackWidth()
			slidertime=slidertime
			
		)
		
	)
	
	fn setHeight n p=
	(
		try
		(
			if (n==0) do (n=seq_track.count)
		
			seq_playhead.height=n*track_height
			seq_panel.height=n*track_height+(24*uiscale)
			
			slidepanel.height= 0
			
			if (p==0) then
			(
				total=n*track_height+(24*uiscale)
				if (total<2*track_height+(24*uiscale)) then (total=2*track_height+(24*uiscale))
			) else
			(
				total=p  
			)
	p=0
			if (ProSequencer.dialogBar != false) do
			(
				if (cui.getDockState ProSequencer == #cui_dock_bottom) then
				(		
 					
					cui.UnregisterDialogBar ProSequencer
					ProSequencer.height=(total / uiscale) - 48
					seq_panel.height=(total / uiscale)  
					cui.RegisterDialogBar ProSequencer     maxSize:[-1,1]  style:#(#cui_dock_bottom, #cui_floatable, #cui_max_sized, #cui_handles)
					cui.DockDialogBar ProSequencer #cui_dock_bottom
				) else
				(		
					cui.UnregisterDialogBar ProSequencer
					ProSequencer.height=total / uiscale   - 48
					seq_panel.height=total / uiscale  + 4 * uiscale
					cui.RegisterDialogBar ProSequencer       style:#(#cui_dock_bottom, #cui_floatable, #cui_max_sized, #cui_handles)
				)
			)
		) catch ()
		-- gc()
	)
	
	fn dispose =
	(
		cui.UnregisterDialogBar ProSequencer
		DestroyDialog  ProSequencer
	 
		--gc()
	)
	
	fn getViewport =
	(
	 vp=false
		numvp=viewport.numViews 
		for i = 1 to numvp do
		(	
			if (viewport.getType index:i==#view_camera) do
			(
				vp=i
			)		
		)
		vp
	)
	
	
 	fn makeSlidePanel = 
 	(
		try (uiscale= GetUiScaleFactor()) catch (uiscale=1.0)
			
		track_height = 20* uiscale				
		
		padding_left=5* uiscale
	 	padding_right=75 * uiscale
				
		ui_match = dotnetobject "Button"  -- pick camera button
		ui_match.backcolor = 	ui_match.backcolor.Transparent
		ui_match.tag = 1
		ui_match.left=10*uiscale
		ui_match.top=0
		ui_match.height=19*uiscale
		ui_match.width=42*uiscale
		ui_match.Text="Align"
		ToolTipObj.SetToolTip ui_match "Matched the track's width with Max's native timeline"	
		
		dotnet.addeventhandler ui_match "MouseUp" syncTrackWidth
		seq_panel.controls.addrange #(ui_match)	

		ui_setting = dotnetobject "Button"  -- pick camera button
		ui_setting.backcolor = 	ui_setting.backcolor.Transparent
		ui_setting.tag = 1
		ui_setting.left=10*uiscale
		ui_setting.top=20*uiscale
		ui_setting.height=19*uiscale
		ui_setting.width=42*uiscale
		ui_setting.Text="Setup"
		ToolTipObj.SetToolTip ui_setting "Configure settings and output paths"	
		
		dotnet.addeventhandler ui_setting "MouseUp" onSettings
		seq_panel.controls.addrange #(ui_setting)	
		
		ui_help = dotnetobject "Button"  -- pick camera button
		ui_help.backcolor = 	ui_help.backcolor.Transparent
		ui_help.tag = 1
		ui_help.left=10*uiscale
		ui_help.top=40*uiscale
		ui_help.height=19*uiscale
		ui_help.width=42*uiscale
		ui_help.Text="Help"
		ToolTipObj.SetToolTip ui_help "open online help"	
		
		dotnet.addeventhandler ui_help "MouseUp" onHelp
		seq_panel.controls.addrange #(ui_help)	
		
		ui_toggle = dotnetobject "Button"  -- pick camera button
		ui_toggle.backcolor = 		ui_toggle.backcolor.Transparent
		ui_toggle.left=0
		ui_toggle.top=0
		ui_toggle.height=19*uiscale
		ui_toggle.width=42*uiscale
		ui_toggle.Text="show"
		dotnet.addeventhandler ui_toggle "MouseUp" onToggle
		seq_panel.controls.addrange #(ui_toggle)	
		ToolTipObj.SetToolTip ui_toggle "Expand/collapse the sequencer"
			 
		ui_sync = dotnetobject "Button"  -- pick camera button
		ui_sync.backcolor = color_highlight 
		ui_sync.left=0
		ui_sync.top=20*uiscale
		ui_sync.height=19*uiscale
		ui_sync.width=42*uiscale
		ui_sync.tag=1
		ui_sync.Text="sync"
		ToolTipObj.SetToolTip ui_sync "Keep main-timeline and sequencer-timeline in sync"
		
		dotnet.addeventhandler ui_sync "MouseUp" onSync
		seq_panel.controls.addrange #(ui_sync)	
		
		ui_active = dotnetobject "Button"  -- pick camera button
		ui_active.backcolor = color_highlight
		ui_active.tag=1
		ui_active.left=40*uiscale
		ui_active.top=40*uiscale
		ui_active.height=19*uiscale
		ui_active.width=42*uiscale
		ui_active.Text="active"
		
		ToolTipObj.SetToolTip ui_active "Switch cameras on playback/scrubbing"
		
		dotnet.addeventhandler ui_active "MouseUp" onActive
		seq_panel.controls.addrange #(ui_active)
		seq_panel.backcolor = color_background
  
 		slidepanel = dotnetobject "UserControl"
 		slidepanel.dock = dock.Fill
		 
		seq_snaphead=dotnetobject "UserControl" 
		seq_snaphead.width=2*uiscale
		seq_snaphead.height=seq_track.count*track_height
		seq_snaphead.top=20*uiscale
		seq_snaphead.left=10*uiscale
		seq_snaphead.backcolor = seq_snaphead.backcolor.white	
		seq_panel.controls.addrange #(seq_snaphead)
		seq_playhead=dotnetobject "UserControl" 
		seq_playhead.width=5*uiscale
		seq_playhead.height=seq_track.count*track_height
		seq_playhead.top=20*uiscale
		seq_playhead.left=0*uiscale
 
		seq_playhead.backcolor = dnColor.FromArgb  255 0 0
		seq_panel.controls.addrange #(seq_playhead)

		dotnet.addeventhandler seq_playhead "MouseMove" ph_scrub
		dotnet.addeventhandler seq_playhead "MouseDown" ph_down
		dotnet.addeventhandler seq_playhead "MouseUp" ph_up
		dotnet.addeventhandler seq_playhead "KeyUp" onKey
		
		 
		seq_ruler=dotnetobject "UserControl" 
		seq_ruler.height=2*uiscale
		seq_ruler.width =1000*uiscale
		seq_ruler.top=20*uiscale
		seq_ruler.left=10*uiscale
		seq_ruler.backcolor = seq_ruler.backcolor.Black
		seq_panel.controls.addrange #(seq_ruler)
		seq_ruler.visible = false

		navigationAdd();
		--
		seq_panel.controls.addrange #(slidepanel)
		
		dotnet.addeventhandler slidepanel "MouseWheel" zoomTime
		unRegisterTimeCallback seq_TrackTime 
		registerTimeCallback seq_TrackTime 


		slidepanel
 	)
 	
 
 	on ProSequencer open do slidepanel = makeSlidePanel()
 	on ProSequencer close do seq_trash()

)


createdialog ProSequencer style:#(#style_titlebar, #style_sysmenu, #style_resizing, #cui_floatable)  height:19  
cui.RegisterDialogBar ProSequencer maxSize:[-1,19]   minSize:[1400,19]  style:#(#cui_dock_bottom, #cui_floatable, #cui_max_sized, #cui_handles)
cui.DockDialogBar ProSequencer #cui_dock_bottom
 	
--filePreSave
callbacks.removeScripts id:#seq_saveEdit
callbacks.addScript #filePreSave "ProSequencer.saveEditToScene 0;  ProSequencer.saveEditToScene 1; " id:#seq_saveEdit

--filePostOpen
callbacks.removeScripts id:#seq_loadEdit
--callbacks.addScript #filePostOpen "ProSequencer.loadEditFromScene()" id:#seq_loadEdit
--callbacks.addScript #filePostOpen "seq_destroy()" id:#seq_loadEdit

--filePreOpen
callbacks.removeScripts id:#seq_preload
callbacks.addScript #filePreOpenProcess "ProSequencer.dump_data(); seq_destroy();"   id:#seq_preload
 
--systemPreReset
callbacks.removeScripts id:#seq_prereset
callbacks.addScript #systemPreReset "ProSequencer.dump_data(); seq_destroy();"  id:#seq_prereset

callbacks.removeScripts id:#seq_postreset
callbacks.addScript #systemPostReset "ProSequencer.seq_reset \"prereset\"; seq_destroy();" id:#seq_postreset

--systemPostNew
callbacks.removeScripts id:#seq_new
callbacks.addScript #systemPostNew "ProSequencer.seq_reset \"postnew\"; seq_destroy();" id:#seq_new
	
--animationRangeChange
callbacks.removeScripts id:#animrange
callbacks.addScript #animationRangeChange "ProSequencer.updateTimeRange()" id:#animrange

--rename
callbacks.removeScripts id:#nodeRename
callbacks.addScript #nodeNameSet "nodeRenamed()" id:#nodeRename

--delete
callbacks.removeScripts id:#nPreDelete
callbacks.addScript #nodePreDelete "nodeDeleted()" id:#nPreDelete

ProSequencer.loadEditFromScene()
ProSequencer.transformUpdate 0

ProSequencer.saveEditToScene 0
ProSequencer.saveEditToScene 1

seq_TrackTime()
 
busyAnimRangeEvent=false
ProSequencer.changeMade "time"
ProSequencer.onNavTransform seq_nav[2] 0
ProSequencer.transformUpdate 0
ProSequencer.updateTimeRange()
ProSequencer.syncTrackWidth()


ProSequencer.updateCheck()
ProSequencer.setSetting "options" "autostart" "0"
 
seq_TrackTime() 
ProSequencer.demomode=false
 
 

macroScript AutoPass category:"JDBgraphics"
(
	 
	/*
	g-buffers:
	0. #zDepth
	1. #matID
	2. #objectID
	3. #UVCoords
	4. #normal
	5. #unClamped
	6. #coverage
	7. #node
	8. #mask
	9. #shaderColor
	10. #shaderTransparency
	11. #velocity
	12. #weight

	data formats:
	0 - RGBA 
	1 - RGB 
	2 - Mono 
	3 - XYZ (G-Buffer Channels only) 
	4 - XY (G-Buffer Channels only) 
	5 - UV (G-Buffer Channels only) 

	data types:
	0 - FLOAT32 
	1 - FLOAT16 
	2 - INT32 

	*/
	fname=#()	
	fname[1]= "RGBA"
	fname[2]= "RGB"
	fname[3]= "Mono"
	fname[4]= "XYZ (G-Buffer Channels only)"
	fname[5]= "XY (G-Buffer Channels only)" 
	fname[6]=" UV (G-Buffer Channels only)" 
		 
	dname=#()	 
	dname[1]="FLOAT32"
	dname[2]="FLOAT16"
	dname[3]="INT32"

	 
	 
	bDlg = renderSceneDialog.isOpen()
	renderSceneDialog.close()

	fopenexr.delAllGBufferLayers()
	fopenexr.delAllRenderElementLayers()

	fopenexr.addRenderElementLayer 

	re = maxOps.GetCurRenderElementMgr() -- get the current render element manager
		
	inifile= getdir #userScripts+@"\ProSequencer\autoPass.ini"
	
	l="-----\nStarting AutoPass\n";
	
	if (not (doesfileexist inifile)) do ( l+="nof found: "+inifile)
	
	if (re.getElementsActive() AND (doesfileexist inifile) ) then
	(
		for n =0 to re.NumRenderElements()-1 do
		(
			el=re.GetRenderElement n
			l +=(classof) el as string +"\t"
		
			
			if ( el.enabled ) then
			(
				pclass= classof el  as string
				frm = getINISetting inifile "autoPass" (pclass+"_format")
	 
				if (frm==undefined OR frm=="") do
				(
						frm = getINISetting inifile "autoPass" ("default_format")
				)
		 
				dtype = getINISetting inifile "autoPass" (pclass+"_type")
				if (dtype==undefined OR dtype=="") do
				(
						dtype = getINISetting inifile "autoPass" ("default_type")
				)
		 
				aa = getINISetting inifile "autoPass" (pclass+"_filter")
				if (aa==undefined OR aa=="") do
				(
						aa = getINISetting inifile "autoPass" ("default_filter")
				)
				
				frm=frm as integer
				dtype=dtype as integer
				aa=aa as integer

				fopenexr.addRenderElementLayer el.elementName el.elementName frm dtype    -- mono    float16
	 
				l+="\t"+fname[frm+1];
				l+="\t"+dname[dtype+1];
				
				
				if ( aa == 0  ) then
				(
					try(
					l+="\tfilter: off"
					el.filter=false
					) catch ()
				) else
				(
					try(
					l+="\tfilter: on"
					el.filter=true
					) catch ()
				)
			
			) else
			(
					l += "Disabled"
			)
			l+="\n"
			
		)
	) else
	(
				l += "skipping, Render alements are globally disabled \n"
	)
	l += "Done\n-----";
	print l
	rendOutputFilename = rendOutputFilename 
	if bDlg do ( renderSceneDialog.open() )

)
 
-- AE style macros below kindly provided by Sergey Nezhentsev ------------------------------------------------------------------------------------------------

fn GoToTrackStart =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				sliderTime = tmptrack.clipStart
			)
			
		)
	)
)

fn GoToTrackEnd =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				sliderTime = tmptrack.clipEnd - (1 as time)
			)
			
		)
	)
)

fn CutTrackStart =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				ProSequencer.setTrackRange tmptrack.id (sliderTime as integer/ticksperframe) (seq_track[tmptrack.id][2].tag.value.r_end)
				ProSequencer.changeMade "Track"
				
				ProSequencer.transformUpdate 0
				
			)
			
		)
	)
)

fn CutTrackEnd =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				ProSequencer.setTrackRange tmptrack.id (seq_track[tmptrack.id][2].tag.value.r_start) (sliderTime as integer/ticksperframe)
				ProSequencer.changeMade "Track"
				
				ProSequencer.transformUpdate 0
			)
			
		)
	)
)


fn MoveTrackStart =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				tmpLength = seq_track[tmptrack.id][2].tag.value.r_end - seq_track[tmptrack.id][2].tag.value.r_start
				
				seq_track[tmptrack.id][2].tag.value.r_start = sliderTime as integer/ticksperframe
				seq_track[tmptrack.id][2].tag.value.r_end = seq_track[tmptrack.id][2].tag.value.r_start + tmpLength
				
				seq_track[tmptrack.id][2].tag.value.ss = sliderTime as integer/ticksperframe
				seq_track[tmptrack.id][2].tag.value.se = seq_track[tmptrack.id][2].tag.value.r_start + tmpLength
				
				ProSequencer.transformUpdate 0
				ProSequencer.seq_TrackTime()
			)
			
		)
	)
)

fn MoveTrackEnd =
(
	ProSequencerData=0
	try
	(
		ProSequencerData=ProSequencer.getSequenceData()
	)
	catch()
	
	if ProSequencerData != 0 then
	(
		for tmptrack in ProSequencerData do
		(
			if tmptrack.selected then
			(
				tmpLength = seq_track[tmptrack.id][2].tag.value.r_end - seq_track[tmptrack.id][2].tag.value.r_start
				
				seq_track[tmptrack.id][2].tag.value.r_end = (sliderTime as integer/ticksperframe) + 1
				seq_track[tmptrack.id][2].tag.value.r_start = seq_track[tmptrack.id][2].tag.value.r_end - tmpLength --amax #(0, seq_track[tmptrack.id][2].tag.value.r_end - tmpLength)
				
				
				seq_track[tmptrack.id][2].tag.value.se = (sliderTime as integer/ticksperframe) + 1 
				seq_track[tmptrack.id][2].tag.value.ss = seq_track[tmptrack.id][2].tag.value.r_end - tmpLength
				
				ProSequencer.transformUpdate 0
				ProSequencer.seq_TrackTime()
			)
			
		)
	)
)




macroScript PS_GoToTrackStart
category:"JDBgraphics"
tooltip:"PS_GoToTrackStart"
buttontext:"PS_GoToTrackStart"
(
	try
	(
		GoToTrackStart()
	)
	catch
	(
	)
)


macroScript PS_GoToTrackEnd
category:"JDBgraphics"
tooltip:"PS_GoToTrackEnd"
buttontext:"PS_GoToTrackEnd"

(
	try
	(
		GoToTrackEnd()
	)
	catch
	(
	)
)


macroScript PS_CutTrackStart
category:"JDBgraphics"
tooltip:"PS_CutTrackStart"
buttontext:"PS_CutTrackStart"

(
	try
	(
		CutTrackStart()
	)
	catch
	(
	)
)


macroScript PS_CutTrackEnd
category:"JDBgraphics"
tooltip:"PS_CutTrackEnd"
buttontext:"PS_CutTrackEnd"

(
	try
	(
		CutTrackEnd()
	)
	catch
	(
	)
)

macroScript PS_MoveTrackStart
category:"JDBgraphics"
tooltip:"PS_MoveTrackStart"
buttontext:"PS_MoveTrackStart"

(
	try
	(
		MoveTrackStart()
	)
	catch
	(
	)
)

macroScript PS_MoveTrackEnd
category:"JDBgraphics"
tooltip:"PS_MoveTrackEnd"
buttontext:"PS_MoveTrackEnd"

(
	try
	(
		MoveTrackEnd()
	)
	catch
	(
	)
)

-----

macroScript ProPlay_normal
category: "JDBgraphics"
(
 
	global  pp_sel
	global pp_cathide
	if (pp_sel == undefined) do (pp_sel = #())
	if (pp_cathide == undefined) do (pp_cathide = #(hideByCategory.helpers,hideByCategory.lights,hideByCategory.cameras ))
		
	if (isAnimPlaying()!=false) then 
	( 
		--hideByCategory.helpers = pp_cathide[1]
		--hideByCategory.lights = pp_cathide[2]
		--hideByCategory.cameras = pp_cathide[3]
		redrawviews()
	
		stopAnimation()
		redrawviews()
		--select pp_sel
	) else
	(
		pp_sel=selection as array
		if (superclassof $ != camera) do
		(
			--clearselection();
		)
		pp_cathide = #(hideByCategory.helpers,hideByCategory.lights,hideByCategory.cameras )
		--hideByCategory.helpers =true
		--hideByCategory.lights = true
		--hideByCategory.cameras = true
		redrawviews()
		playAnimation()
	)
 
)

--prosequencer.setSetting "options" "jdb" 2 