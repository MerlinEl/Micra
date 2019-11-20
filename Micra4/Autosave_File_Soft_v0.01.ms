--------------------------------------------------------------------------------
/* gAutosaveFileSoft by Orien 2019 */
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
if superClassOf  gAutosaveFileSoft == StructDef do gAutosaveFileSoft.enabled false
struct sAutosaveFileSoft	(
	
	--variables
	tm = dotnetobject "system.timers.timer",
	-- timer interval > ( 1 sec * 60 sec = 1min * Autosave Interval)
	autosave_interval_minutes = 4000, --(1000 * 60) * Autosave.Interval,
	backups_count = Autosave.NumberOfFiles, -- 1 to 99
	autosave_fname = Autosave.filename,
	is_enabled = false,
	counter_mode = "autosave_sequence", --switch timer between minutes and seconds
	seconds_passed = 0,
	cancel_delay = 6, --6 sec to cancell backup
	escape_pressed = false,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn cancelBackup = (
	
		format "\tBackup Max File was canceled\n"
		tm.Interval = autosave_interval_minutes
		counter_mode = "autosave_sequence"
		escape_pressed = false
	),
	fn backupMaxFile = (
		
		format "\tBackup Max File:\n\t[ % ]\n\tNow!\n" maxFileName	
	),
	fn showWarning = (
		
		format "\tpress Escape to cancel Auto Backup \n"
		--flick viewport frame
		--display text with count down before backup
		--keyboard.escPressed
	),
	fn timerTick s a = (
		
		local afs = gAutosaveFileSoft
		if afs.escape_pressed do retun false --prevent multiple abort
		case afs.counter_mode of (
			
			"autosave_sequence":( --minutes
			
				format "Backup Max File at {%}\n" (a.SignalTime.toString())
				afs.seconds_passed = 0	
				afs.counter_mode = "escape_sequence"	
				s.Interval = 1000 --1 sec	
				afs.showWarning()				
			)	
			"escape_sequence":( --seconds
			
				if (keyboard.escPressed) then (
					
					afs.escape_pressed = true
					afs.cancelBackup()	

				) else (
					
					afs.seconds_passed += 1	
					format "\tsutosave after [ % ] sec...\n" (afs.cancel_delay - afs.seconds_passed)
					if afs.seconds_passed >= afs.cancel_delay do (
						
						afs.counter_mode = "autosave_sequence"
						s.Interval = afs.autosave_interval_minutes
						afs.backupMaxFile()
					)
				)
			)
		)
		--warning message for autosave begin after 5 sec
	),	
	fn resetTimer = (),
    fn isRuning = (is_enabled),
    fn autoBackupNow = (),
	fn startCounter = (
		
		tm.start()
		format "Autosave Timer Started\n"
		format "The application started at:%\n" ((dotnetClass "System.DateTime").Now.toString())
	),
	fn stopCounter = (
		
		tm.stop()
		format "Autosave Timer Stoped\n"
	),
	fn unregisterAFS = (

		callbacks.removeScripts id:#cAutosaveFileSoft
-- 		dotnet.removeEventHandler tm "Elapsed" timerTick --disable Micra Autosave
		dotnet.removeAllEventHandlers tm --disable Micra Autosave
	),
	fn registerAFS = (

		callbacks.removeScripts id:#cAutosaveFileSoft
		callbacks.addScript #filePreOpen "gAutosaveFileSoft.stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostOpenProcess "gAutosaveFileSoft.startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePreSave "gAutosaveFileSoft.stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostSave "gAutosaveFileSoft.startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #systemPreReset "gAutosaveFileSoft.stopCounter()" id:#cAutosaveFileSoft
		dotnet.addeventhandler tm "Elapsed" timerTick --enable Micra Autosave
	),
	fn enabled state = (
	
		case state of (
		
			true:(
		
				Autosave.Enable = false --disable 3DsMax Autosave
				registerAFS()
				if maxFileName.count != 0 do startCounter() --start counter if max file is opened
			)
			false: ( 
			
				stopCounter()
				unregisterAFS()
				Autosave.Enable = true --enable 3DsMax Autosave
			)
		)
		is_enabled = state
	),
	on create do (
	
		tm.Interval = autosave_interval_minutes
		tm.Enabled = false
--         tm.AutoReset = true -- Have the timer fire repeated events (true is the default)
		format "Autosave struct was created with interval:% ms\n" autosave_interval_minutes
	)
	/*<end>*/
)	
 --create instance
Global gAutosaveFileSoft = mcStructMan.instanceStructure sAutosaveFileSoft "gAutosaveFileSoft"
/*
vpt_tm = getViewTM() 
vpt_tm.pos
gw.hPolyline #([300,50,16], [300,200,8], [450,250,4]) true
unregisterRedrawViewsCallback GW_DISPLAY_FRAME
fn GW_DISPLAY_FRAME =
(
	local rect = (box2 0 0 96 97)
	gw.wrect rect red
	gw.wmarker [rect.left,rect.top,0] #point color:green
	gw.wmarker [rect.left,rect.bottom,0] #point color:green
	gw.wmarker [rect.right,rect.top,0] #point color:green
	gw.wmarker [rect.right,rect.bottom,0] #point color:green
	local eRect = rect -- enlargeUpdateRect 1 pixel too small in either direction?
	eRect.right += 1
	eRect.bottom += 1
	gw.enlargeUpdateRect eRect
	gw.updateScreen()
)
registerRedrawViewsCallback GW_DISPLAY_FRAME
redrawViews()



Did you set the KeyPreview option of the form to true?
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled  true
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled  false
*/
