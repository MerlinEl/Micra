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
if isStruct gAutosaveFileSoft do gAutosaveFileSoft.enabled false
--Interface	
struct sAutosaveFileSoftUI	(
	--vars1
	form		= dotNetObject "MaxCustomControls.MaxForm",
	lbl_info	= dotNetObject "label",
	btn_cancel	= dotnetobject "Button",
	btn_save	= dotnetobject "Button",	
	font1		= dotnetobject "System.Drawing.Font" "Impact" 20,
	font2		= dotnetobject "System.Drawing.Font" "Impact" 12,
	timer_sec 	= dotnetobject "system.timers.timer",
	timer_min 	= dotnetobject "system.timers.timer",
	--vars2
	backups_count = Autosave.NumberOfFiles, -- 1 to 99
	autosave_fname = Autosave.filename,
	seconds_passed = 0,
	cancel_delay = 6, --6 sec to cancell backup
	canceled = false,
	--functions
	fn closeForm = (form.close()),
	fn hideForm = (form.hide()),
	fn showForm = (form.showmodeless()),
	fn setText str_num = (
	
		lbl_info.text = "Autosave After\n( " + str_num + " )"
	),
	fn stopTimer = (
	
		timer_sec.stop()
		dotnet.removeAllEventHandlers timer_sec
		hideForm()
	),
	fn cancelBackup = (
	
		format "\tBackup was canceled\n"
		stopTimer()
	),
	fn backupMaxFile = (
		
		format "\tBackup Max File:\n\t[ % ]\n\tNow!\n" maxFileName	
	),
	fn onBackColorChanged s a = (

		s.backColor = mcDotnet.dColor red
		s.TransparencyKey = s.BackColor
	),
	fn onCancelPressed s a = (
		
		gAutosaveFileSoftUI.cancelBackup()
		s.parent.hide()
	),
	fn onAcceptPressed s a = (
		
		gAutosaveFileSoftUI.backupMaxFile()
		s.parent.hide()
	),
	fn timerTick s a = ( --get current time ---> (a.SignalTime.toString())
		
		local afsUI = gAutosaveFileSoftUI	
		if (afsUI.canceled) then (
					
			afsUI.cancelBackup()	

		) else (
		
			if afsUI.seconds_passed < afsUI.cancel_delay then (
			
				afsUI.seconds_passed += 1	
				local remain_time = (afsUI.cancel_delay - afsUI.seconds_passed)
				format "\tsutosave after [ % ] sec...\n" remain_time
				afsUI.setText (remain_time as string)
				if afsUI.seconds_passed >= afsUI.cancel_delay do ( --when is ready to Backup
					
					afsUI.stopTimer()
					afsUI.backupMaxFile()
				)
				
			) else (
			
				afsUI.stopTimer()
			)
		)
	),	
	fn startTimer = (
	
		seconds_passed = 0
		setText (cancel_delay as String)
		dotNet.addeventhandler timer_sec "Elapsed" timerTick --register seconds timer
		timer_sec.start()
	),
	fn showFormLimited duration_sec = (
	
		format "Backup Max File. Press ABORT to cancel Backup.\n" 
		cancel_delay = duration_sec
		showForm()
		startTimer()
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

		timer_sec.Interval = 4000 --1000 --1 sec	
		timer_min.Interval = 10000 --(1000 * 60) * Autosave.Interval,  -- ( 1 sec * 60 sec = 1min * Autosave Interval)
		timer_sec.Enabled = false
		timer_min.Enabled = false
		timer_sec.AutoReset = true	-- timer fire repeated events
		timer_min.AutoReset = false	-- timer fire single event

		dotNet.addEventHandler btn_save "MouseUp" onAcceptPressed
		dotNet.addEventHandler btn_cancel "MouseUp" onCancelPressed
		dotnet.AddEventHandler form "BackColorChanged" onBackColorChanged
	),
	on create do (initForm())
)
Global gAutosaveFileSoftUI = sAutosaveFileSoftUI()


--Functions
struct sAutosaveFileSoft	(
	
	--variables

	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isRuning = (gAutosaveFileSoftUI.timer_min.Enabled),
	fn startCounter = ( --only first time
		
		gAutosaveFileSoftUI.timer_min.start()
		format "Autosave Monitor Started at:%\n" (mcDotnet.SysTime.Now.toString())
	),
	fn stopCounter = ( --only first time
		
		gAutosaveFileSoftUI.timer_min.stop()
		gAutosaveFileSoftUI.stopTimer()
		format "Autosave Timer Stoped\n"
	),
	fn timerTick s a = (
		
		format "Backup Max File at {%}\n\tpress ABORT to cancel Backup \n" (a.SignalTime.toString())	
		--test thread free
		callbacks.removeScripts id:#cAutosaveFileSoft
		dotNet.removeAllEventHandlers gAutosaveFileSoftUI.timer_min --disable Micra Autosave
		s.stop()
		gAutosaveFileSoftUI.timer_min.Enabled = false					
		local afsUI = gAutosaveFileSoftUI	
		afsUI.showFormLimited afsUI.cancel_delay			
	),	
	fn unregisterAFS = (

		local afsUI = gAutosaveFileSoftUI
		callbacks.removeScripts id:#cAutosaveFileSoft
-- 		dotNet.removeEventHandler tm "Elapsed" timerTick --disable Micra Autosave
		dotNet.removeAllEventHandlers afsUI.timer_min --disable Micra Autosave
	),
	fn registerAFS = (

		local afsUI = gAutosaveFileSoftUI
		callbacks.removeScripts id:#cAutosaveFileSoft
		callbacks.addScript #filePreOpen "stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostOpenProcess "startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePreSave "stopCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #filePostSave "startCounter()" id:#cAutosaveFileSoft
		callbacks.addScript #systemPreReset "stopCounter()" id:#cAutosaveFileSoft
		dotNet.addeventhandler afsUI.timer_min "Elapsed" timerTick --register minutes timer
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
