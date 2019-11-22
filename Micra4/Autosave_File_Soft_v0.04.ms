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
if isStruct gAutosaveFileSoft do gAutosaveFileSoft.enabled false
--Interface	
Global gAutosaveFileSoftUI
struct sAutosaveFileSoftUI	(
	--vars1
	form		= dotNetObject "MaxCustomControls.MaxForm",
	lbl_info	= dotNetObject "label",
	btn_cancel	= dotnetobject "Button",
	btn_save	= dotnetobject "Button",	
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	d_timer = dotnetobject "system.timers.timer",
	--vars2
	autosave_interval_minutes = 10000, --(1000 * 60) * Autosave.Interval,  -- ( 1 sec * 60 sec = 1min * Autosave Interval)
	backups_count = Autosave.NumberOfFiles, -- 1 to 99
	autosave_fname = Autosave.filename,
	counter_mode = "autosave_sequence", --switch timer between minutes and seconds
	seconds_passed = 0,
	cancel_delay = 6, --6 sec to cancell backup
	canceled = false,
	--functions
	fn setText str_num = (
	
		lbl_info.text = "Autosave After\n( " + str_num + " )"
	),
	fn startTimer = (d_timer.start()),
	fn stopTimer = (d_timer.stop()),
	fn resetTimer = (
		
		stopTimer()
		counter_mode = "autosave_sequence"
		d_timer.Interval = autosave_interval_minutes
		canceled = false
		startTimer()
	),
	fn isReadyToBackup = (
	
		seconds_passed >= cancel_delay
	),
	fn cancelBackup = (
	
		format "\tBackup was canceled\n"
		resetTimer()
	),
	fn backupMaxFile = (
		
		format "\tBackup Max File:\n\t[ % ]\n\tNow!\n" maxFileName	
	),
	fn showForm = (form.showmodeless()),
	fn hideForm = (form.hide()),
	fn closeForm = (form.close()),
	fn onBackColorChanged s a = (

		s.backColor = mcDotnet.dColor red
		s.TransparencyKey = s.BackColor
	),
	fn onCancelPressed s a = (
		
		cancelBackup()
		s.parent.hide()
	),
	fn onAcceptPressed s a = (
		
		backupMaxFile()
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

		d_timer.Interval = autosave_interval_minutes
		-- d_timer.AutoReset = true -- Have the timer fire repeated events (true is the default)
		d_timer.Enabled = false

		dotNet.addEventHandler btn_save "MouseUp" onAcceptPressed
		dotNet.addEventHandler btn_cancel "MouseUp" onCancelPressed
		dotnet.AddEventHandler form "BackColorChanged" onBackColorChanged
	),
	on create do (initForm())
)


--Functions
struct sAutosaveFileSoft	(
	
	--variables
	is_enabled = false,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn timerTick s a = (
		
		local afsUI = gAutosaveFileSoftUI
		if afsUI.canceled do retun false --prevent multiple abort
		case afsUI.counter_mode of (
			
			"autosave_sequence":( --minutes
			
				format "Backup Max File at {%}\n\tpress ABORT to cancel Backup \n" (a.SignalTime.toString())
				--flick viewport frame
				afsUI.seconds_passed = 0	
				afsUI.counter_mode = "escape_sequence"	
				s.Interval = 10000 --1 sec	
				afsUI.showForm()				
			)	
			"escape_sequence":( --seconds
			
				if (afsUI.canceled) then (
					
					afsUI.cancelBackup()	

				) else (
					
					afsUI.seconds_passed += 1	
					local remain_time = (afsUI.cancel_delay - afsUI.seconds_passed)
					format "\tsutosave after [ % ] sec...\n" remain_time
					afsUI.setText (remain_time as string)
					if afsUI.isReadyToBackup() do (
						
						afsUI.hideForm()
						afsUI.resetTimer()
						afsUI.backupMaxFile()
					)
				)
			)
		)
	),	
	fn isRuning = (is_enabled),
	fn startCounter = ( --only first time
		
		local afsUI = gAutosaveFileSoftUI
		afsUI.startTimer()
		format "Autosave Timer Started\n"
		format "The application started at:%\n" (mcDotnet.SysTime.Now.toString())
	),
	fn stopCounter = ( --only first time
		
		local afsUI = gAutosaveFileSoftUI
		afsUI.stopTimer()
		afsUI.hideForm()
		format "Autosave Timer Stoped\n"
	),
	fn unregisterAFS = (

		local afsUI = gAutosaveFileSoftUI
		callbacks.removeScripts id:#cAutosaveFileSoft
-- 		dotnet.removeEventHandler tm "Elapsed" timerTick --disable Micra Autosave
		dotnet.removeAllEventHandlers afsUI.d_timer --disable Micra Autosave
	),
	fn registerAFS = (

		local afsUI = gAutosaveFileSoftUI
		callbacks.removeScripts id:#cAutosaveFileSoft
		callbacks.addScript #filePreOpen "stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostOpenProcess "startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePreSave "stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostSave "startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #systemPreReset "stopCounter()" id:#cAutosaveFileSoft
		dotnet.addeventhandler afsUI.d_timer "Elapsed" timerTick --enable Micra Autosave
	),
	fn enabled state = (
	
		local afsUI = gAutosaveFileSoftUI
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
	
		gAutosaveFileSoftUI = sAutosaveFileSoftUI()
		format "Autosave struct was created\n"
	)
	/*<end>*/
)	
 --create instance
Global gAutosaveFileSoft = mcStructMan.instanceStructure sAutosaveFileSoft "gAutosaveFileSoft"

/*
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled  true
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled  false
gAutosaveFileSoftUI.showForm()
*/

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

*/
