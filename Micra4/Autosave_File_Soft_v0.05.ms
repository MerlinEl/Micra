--TODO
--1 compare files size before backup or comething do not backup same file again and again or clear undo histrory or memory mouse clicks
--2 after wait seeuence finished leave form opened with mesage SAWING NOW! and close it after is finished
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
	Micra Autosave
*
*@Example	
	undefined
*
*/
--
if isStruct gAutosaveFileSoft do gAutosaveFileSoft.enabled false
--Interface	
struct sAutosaveFileSoftUI	(
	--vars1
	form		= dotNetObject "MaxCustomControls.MaxForm",
	lbl_info	= dotNetObject "label",
	btn_cancel	= dotnetobject "Button",
	btn_save	= dotnetobject "Button",	
	btn_abort	= dotnetobject "Button",	
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	timer_sec 	= dotnetobject "System.Windows.Threading.DispatcherTimer",
	timer_main 	= dotnetobject "System.Windows.Threading.DispatcherTimer",
	--vars2
	backups_count = Autosave.NumberOfFiles, -- 1 to 99
	autosave_dir = (getdir #autoback) + "\\", 
	autosave_fname = Autosave.FileName,
	autosave_interval = 10, --Autosave.Interval*60,
	seconds_passed = 0,
	cancel_delay = 6, --6 sec to cancell backup
	saving = false,
	canceled = false,
	abort_pressed = false, --When Micra Autosave is disabled by user , Max AutoBackup is remains Disabled too
	backup_notifications_params = #(),
	--functions
	fn isReadyToBackup = (
		
		maxFileName.count != 0 and getSaveRequired()
	),
	fn closeForm = (form.close()),
	fn hideForm = (form.hide()),
	fn showForm = (form.showmodeless()),
	fn setText str_num = (
	
		lbl_info.text = "Autosave After\n( " + str_num + " )"
	),
	fn stopTimerMain = (
	
		timer_main.stop()
		timer_main.IsEnabled = false
	),
	fn stopTimerSec = (
	
		timer_sec.stop()
		timer_main.IsEnabled = false
	),
	fn restartMainTimer = (
		
		timer_main.stop()
		timer_main.start()
	),
	fn cancelBackup = (
	
		format "\tBackup was Postponed\n"
		stopTimerSec()
		hideForm()
		gAutosaveFileSoftUI.startMainTimer()
	),
	fn backupMaxFile = (
		
		local afsUI = gAutosaveFileSoftUI	
--autosave.isactive()
		if (afsUI.saving) do return false
		afsUI.stopTimerSec()
		afsUI.hideForm()
		afsUI.saving = true
		backup_notifications_params = #()
		format "\tBackup Max File:\n\t[ % ]\n\tNow!\n" maxFileName
		
		---saveAsVersion:<integer>
		--saveMaxFile (autosave_dir + autosave_fname + next_index) clearNeedSaveFlag:false useNewFile:false quiet:true
		/*Autosave.resetTimer()
		AutoBackup.Time = 0.01 --start Max autosave Now!
		Autosave.Interval = 0.01*/
		
		if (isProperty Autosave "BailoutEnabled")  do Autosave.BailoutEnabled = false --disable slowdown escape backup fn
		Autosave.resetTimer()
		AutoBackup.Enabled = true
		Autosave.Enable = true
		autosave.autoBackupNow()
	),
	fn onBackColorChanged s a = (

		s.backColor = mcDotnet.dColor red
		s.TransparencyKey = s.BackColor
	),
	fn onCancelPressed s a = (
		
		gAutosaveFileSoftUI.cancelBackup()
		s.parent.hide()
	),
	fn onAbortPressed s a = (
		
		gAutosaveFileSoftUI.abort_pressed = true
		gAutosaveFileSoft.enabled false
	),
	fn onBackupNowPressed s a = (
		
		gAutosaveFileSoftUI.backupMaxFile()
	),
	fn timerTickSec s a = (
		
		local afsUI = gAutosaveFileSoftUI	
		if (afsUI.canceled) then (
					
			afsUI.cancelBackup()	

		) else (
		
			if afsUI.seconds_passed < afsUI.cancel_delay then ( --count down seconds
			
				afsUI.seconds_passed += 1	
				local remain_time = (afsUI.cancel_delay - afsUI.seconds_passed)
				afsUI.setText (remain_time as string)
				format "\tsutosave after [ % ] sec...\n" remain_time
				
			) else (  --is ready to Backup
			
					afsUI.stopTimerSec()
					afsUI.hideForm()
					afsUI.backupMaxFile()
			)
		)
	),	
	fn startTimerSec = (
		
		seconds_passed = 0
		setText (cancel_delay as String)
		timer_sec.start()
	),
	fn showFormLimited duration_sec = (
	
		format "Backup Max File.\n\tpress POSTPONE to wait for another Backup.\n\tpress ABORT to disable backup Manager. \n" 
		cancel_delay = duration_sec
		showForm()
		startTimerSec()
	),
	fn timerTickMain s a = (
		
		local afsUI = gAutosaveFileSoftUI	
		if not (afsUI.isReadyToBackup()) do(
			
			format "Is not Ready To Backup. Restarting Main Timer...\n"
			afsUI.restartMainTimer()
			return OK
		)
		afsUI.stopTimerMain()
		afsUI.showFormLimited afsUI.cancel_delay
	),	
	fn startMainTimer = ( --restart Timer Main
		
		timer_main.start()
	),
	fn unregisterTimers = (
		
		dotnet.removeAllEventHandlers timer_sec
		dotnet.removeAllEventHandlers timer_main
	),
	fn initForm = (

		btn_save.text = "BACKUP NOW"
		btn_save.font = font2
		btn_save.foreColor = mcDotnet.dColor (color 9 102 51)
		btn_save.backColor = mcDotnet.dColor green
		btn_save.Dock = btn_save.Dock.Top
	
		btn_cancel.text = "POSTPONE"
		btn_cancel.font = font2
		btn_cancel.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_cancel.backColor = mcDotnet.dColor green
		btn_cancel.Dock = btn_cancel.Dock.Bottom
		
		btn_abort.text = "ABORT"
		btn_abort.font = font2
		btn_abort.foreColor = mcDotnet.dColor  (color 9 102 51)
		btn_abort.backColor = mcDotnet.dColor green
		btn_abort.Dock = btn_abort.Dock.Bottom
		
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
		form.Controls.addrange #(btn_save, btn_cancel, btn_abort, lbl_info)
		form.StartPosition = form.StartPosition.Manual
		form.location = mcDotnet.dPoint (mcSystem.getMaxCenter() - [form.width, form.height] / 2)
		form.opacity = 0.8

		timer_sec.Interval = mcDotnet.secondsToTimeSpan 1	
		timer_sec.IsEnabled = false

		timer_main.Interval = mcDotnet.secondsToTimeSpan autosave_interval
		timer_main.IsEnabled = false

		dotNet.addEventHandler btn_save "MouseUp" onBackupNowPressed
		dotNet.addEventHandler btn_cancel "MouseUp" onCancelPressed
		dotNet.addEventHandler btn_abort "MouseUp" onAbortPressed
		dotnet.addEventHandler form "BackColorChanged" onBackColorChanged
		dotNet.addEventHandler timer_main "Tick" timerTickMain --register minutes timer	
		dotNet.addEventHandler timer_sec "Tick" timerTickSec --register seconds timer
	),
	on create do (initForm())
)
Global gAutosaveFileSoftUI = sAutosaveFileSoftUI()


--Functions
struct sAutosaveFileSoft	(
	
	--variables

	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isRuning = (gAutosaveFileSoftUI.timer_main.IsEnabled),
	fn startCounter = ( --only first time
		
		if gAutosaveFileSoftUI.saving do (
			
			format "saving:%\n" (autosave.isactive())
			gAutosaveFileSoftUI.backup_notifications_params = callbacks.notificationParam()	
			format "Autosave Params:\n\t%\n" gAutosaveFileSoftUI.backup_notifications_params
			AutoBackup.Enabled = false
			Autosave.Enable = false
-- 			Autosave.Interval = gAutosaveFileSoftUI.autosave_interval
-- 			AutoBackup.Time = gAutosaveFileSoftUI.autosave_interval
			if (isProperty Autosave "BailoutEnabled")  do Autosave.BailoutEnabled = true --enable escape backup fn	
			gAutosaveFileSoftUI.saving = false
		)
		gAutosaveFileSoftUI.startMainTimer()
		format "Autosave Monitor Started at:%\n" (mcDotnet.SysTime.Now.toString())
	),
	fn stopCounters = ( --only first time
		
		gAutosaveFileSoftUI.stopTimerSec()
		gAutosaveFileSoftUI.stopTimerMain()
		format "Autosave Monitor Stoped at:%\n" (mcDotnet.SysTime.Now.toString())
	),
	fn unregisterAFS = (
		
		gAutosaveFileSoftUI.unregisterTimers()
		callbacks.removeScripts id:#cAutosaveFileSoft
	),
	fn registerAFS = (

		callbacks.removeScripts id:#cAutosaveFileSoft
		callbacks.addScript #filePreOpen "gAutosaveFileSoft.stopCounters()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostOpenProcess "gAutosaveFileSoft.startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePreSave "gAutosaveFileSoft.stopCounters()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostSave "gAutosaveFileSoft.startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #systemPreReset "gAutosaveFileSoft.stopCounters()" id:#cAutosaveFileSoft
	),
	fn enabled state = ( -- Start / Stop Autosave Monitor App  from Micra Customize. 
	
		local is_running = isRuning()
		case state of (
		
			true:(
				
				if is_running do return false
				AutoBackup.Enabled = false	
				Autosave.Enable = false --disable 3DsMax Autosave
				registerAFS()
				startCounter()
			)
			false: ( 
		
				stopCounters()
				unregisterAFS()
				gAutosaveFileSoftUI.hideForm()
				if not gAutosaveFileSoftUI.abort_pressed do (
					
					AutoBackup.Enabled = true
					Autosave.Enable = true --enable 3DsMax Autosave
				)
			)
		)
		OK
	),
	on create do (
	
		format "Autosave struct was created\n"
	)
	/*<end>*/
)	
 --create instance
Global gAutosaveFileSoft = mcStructMan.instanceStructure sAutosaveFileSoft "gAutosaveFileSoft"

/*
gAutosaveFileSoftUI.showFormLimited 5
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled true
gAutosaveFileSoft.isRuning()
gAutosaveFileSoft.enabled false
gAutosaveFileSoftUI.showForm()
C:\Users\Orien Star\Documents\3dsMax\autoback
*/

/*
public class Class1 {
    static System.Windows.Forms.Timer myTimer = new System.Windows.Forms.Timer();
    static int alarmCounter = 1;
    static bool exitFlag = false;
 
    --This is the method to run when the timer is raised.
    private static void TimerEventProcessor(Object myObject,
                                            EventArgs myEventArgs) {
       myTimer.Stop();
 
       --Displays a message box asking whether to continue running the timer.
       if(MessageBox.Show("Continue running?", "Count is: " + alarmCounter, 
          MessageBoxButtons.YesNo) == DialogResult.Yes) {
          --Restarts the timer and increments the counter.
          alarmCounter +=1;
          myTimer.Enabled = true;
       }
       else {
          --Stops the timer.
          exitFlag = true;
       }
    }
 
    public static int Main() {
       -- Adds the event and the event handler for the method that will 
       -- process the timer event to the timer.
       myTimer.Tick += new EventHandler(TimerEventProcessor);
 
       --Sets the timer interval to 5 seconds.
       myTimer.Interval = 5000;
       myTimer.Start();
 
       --Runs the timer, and raises the event.
       while(exitFlag == false) {
          --Processes all the events in the queue.
          Application.DoEvents();
       }
    return 0;
    }
 }
*/



/*
		--flick viewport frame
case afsUI.counter_mode of (
			
			"autosave_sequence":( --minutes

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
