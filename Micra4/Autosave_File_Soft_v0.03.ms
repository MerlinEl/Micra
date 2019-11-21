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
--Interface	
struct fAutosaveFileSoft	(
	
	form =  dotNetObject "MaxCustomControls.MaxForm",
	lbl_info=dotNetObject "label",
	btn_cancel = dotnetobject "Button",
	btn_save = dotnetobject "Button",
	tm = dotnetobject "system.timers.timer",	
	font1 = dotnetobject "System.Drawing.Font" "Impact" 20,
	font2 = dotnetobject "System.Drawing.Font" "Impact" 12,
	--form functions
	fn showForm = (form.showmodeless()),
	fn hideForm = (form.hide()),
	fn closeForm = (form.close()),	
	fn onBackColorChanged s a = (

		s.backColor = mcDotnet.dColor red
		s.TransparencyKey = s.BackColor
	),
	--process functions
	fn onCancelPressed s a = (
		
		::gAutosaveFileSoft.cancelBackup()
		s.parent.hide()
	),
	fn onAcceptPressed s a = (
		
		::gAutosaveFileSoft.backupMaxFile()
		s.parent.hide()
	),
	fn initForm = (

		btn_save.text = "BACKUP NOW"
		btn_save.font = font2
		btn_save.foreColor = mcDotnet.dColor (color 9 102 51)
		btn_save.backColor = mcDotnet.dColor green
		btn_save.Dock = btn_save.Dock.Top
	
		btn_cancel.text = "ABORT"
		btn_cancel.font = font2
		btn_cancel.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_cancel.backColor = mcDotnet.dColor green
		btn_cancel.Dock = btn_cancel.Dock.Bottom
		
		lbl_info.text = "Autosave After\n( 5 )"
		lbl_info.font = font1
		lbl_info.TextAlign = lbl_info.TextAlign.MiddleCenter
		lbl_info.width = 200
		lbl_info.height = 200
		lbl_info.foreColor=mcDotnet.dColor yellow
		lbl_info.backColor=mcDotnet.dColor red
		lbl_info.Location = mcDotnet.dPoint [form.Width / 2 - lbl_info.Width / 2, form.Height / 2 - lbl_info.Height / 2]
		
		form.StartPosition = form.StartPosition.Manual
		form.ShowInTaskBar = false
		form.FormBorderStyle = form.FormBorderStyle.None
		form.Controls.addrange #(btn_save, btn_cancel, lbl_info)
		form.StartPosition = form.StartPosition.Manual
		form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)

		dotNet.addEventHandler btn_save "MouseUp" onAcceptPressed
		dotNet.addEventHandler btn_cancel "MouseUp" onCancelPressed
		dotnet.AddEventHandler form "BackColorChanged" onBackColorChanged
	),
	on create do (initForm())
)

--Functions
struct sAutosaveFileSoft	(
	
	--dotnet form
	form,	
	--process variables
	autosave_interval_minutes = 10000, --(1000 * 60) * Autosave.Interval,  -- ( 1 sec * 60 sec = 1min * Autosave Interval)
	backups_count = Autosave.NumberOfFiles, -- 1 to 99
	autosave_fname = Autosave.filename,
	is_enabled = false,
	counter_mode = "autosave_sequence", --switch timer between minutes and seconds
	seconds_passed = 0,
	cancel_delay = 6, --6 sec to cancell backup
	canceled = false,
	--general functions
	fn getSource = getSourceFileName(), --get path of this script
	fn resetTimer = (
		
		counter_mode = "autosave_sequence"
		tm.Interval = afs.autosave_interval_minutes
		canceled = false
	),
	fn cancelBackup = (
	
		format "\tBackup was canceled\n"
		resetTimer()
	),
	fn backupMaxFile = (
		
		format "\tBackup Max File:\n\t[ % ]\n\tNow!\n" maxFileName	
	),

	fn timerTick s a = (
		
		local afs = gAutosaveFileSoft
		if afs.canceled do retun false --prevent multiple abort
		case afs.counter_mode of (
			
			"autosave_sequence":( --minutes
			
				format "Backup Max File at {%}\n\tpress ABORT to cancel Backup \n" (a.SignalTime.toString())
				--flick viewport frame
				afs.seconds_passed = 0	
				afs.counter_mode = "escape_sequence"	
				s.Interval = 10000 --1 sec	
				afs.showForm()				
			)	
			"escape_sequence":( --seconds
			
				if (afs.canceled) then (
					
					afs.cancelBackup()	

				) else (
					
					afs.seconds_passed += 1	
					local remain_time = (afs.cancel_delay - afs.seconds_passed)
					format "\tsutosave after [ % ] sec...\n" remain_time
					afs.lbl_info.text = "Autosave After\n( " + (remain_time as string) + " )"
					if afs.seconds_passed >= afs.cancel_delay do (
						
						afs.closeForm()
						afs.resetTimer()
						afs.backupMaxFile()
					)
				)
			)
		)
	),	
	fn resetTimer = (),
    fn isRuning = (is_enabled),
    fn autoBackupNow = (),
	fn startCounter = ( --only first time
		
		tm.start()
		format "Autosave Timer Started\n"
		format "The application started at:%\n" (mcDotnet.SysTime.Now.toString())
	),
	fn stopCounter = ( --only first time
		
		tm.stop()
		form.hideForm()
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
	
		form = fAutosaveFileSoft()
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
