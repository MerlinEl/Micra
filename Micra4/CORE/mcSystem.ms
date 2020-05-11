--------------------------------------------------------------------------------
/* mcSystem by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcUser32
*
*@Used Objects

*
*/
struct MICRA_SYSTEM (

	maxHandle =  Windows.GetMAXHWND(),
	fn getSource = getSourceFileName(), --get path of this script
	fn getMaxWindow = (
	
		local nw = DotNetObject "NativeWindow"
		nw.AssignHandle (DotNetObject "System.IntPtr" maxHandle) 
		nw
	),
	fn getMicraWindow = (mcMicraDialog),
	--local uType = mcSystem.unitsType()
	fn unitsType = (
	
		case units.SystemType of
		(
			#Inches:"inc"
			#Feet:"ft"
			#Miles:"mi"
			#Millimeters:"mm"
			#Centimeters:"cm"
			#Meters:"m"
			#Kilometers:"km"
		)
	),
	fn time = 
	(
		Local arr, mTime
		arr = filterString LocalTime "./ :"
		if arr.count < 5 do return "invalid time"
		mTime = arr[4] + ":" + arr[5] + "   " + arr[1] + "." + arr[2] + "." + arr[3]
		return mTime
	),
	fn autosaveSwitch = (
	
		local current_state = autosave.enable
		autosave.enable = not current_state
		messageBox ("Autosave is turned to:" + autosave.enable as string) title:" Micra:"
	),
	fn keyboardSwitch = (
	
		local settings_dir = mcFile.readSettings Micra.UserSettings "USER/Settings/MaxSavedSettings" --read default type "val"
		if not (mcFile.isPath settings_dir) do (
			settings_dir = mcPopUp.show "" title:"Settings:" type:#Input
			if not (mcFile.isPath settings_dir) do return false
			mcFile.saveSettings Micra.UserSettings "USER/Settings/MaxSavedSettings" settings_dir --add-replace type "val"
		)

		local current_shortcuts = actionMan.getKeyboardFile() 
		local user_shortcuts = settings_dir + @"\Merlin_UI_2018.kbdx"
		local default_shortcuts = settings_dir + @"\DefaultUI.kbdx"
		
-- 		format "shortcuts:\n\tcurrent:%\n\tnuser  :%\n\tdefault:%\n" current_shortcuts user_shortcuts default_shortcuts
-- 		format "user:%\n" (current_shortcuts == user_shortcuts)
-- 		format "default:%\n" (current_shortcuts == default_shortcuts)
		
		local sortcuts_file = if current_shortcuts == user_shortcuts then default_shortcuts else user_shortcuts
		actionMan.loadKeyboardFile sortcuts_file
		local state = if sortcuts_file == user_shortcuts then "User" else "Default"
		messageBox ("Shortcuts was set to:" + state) title:" Micra:"
	),
	fn editTexturesInPhotoshop = 
	(		
		if not QueryBox "Edit Textures in Photosop?" title:" Micra:" do return false
		fn getDirectXBitmaps mat = 
		(
			local bCount = mat.numberofbitmaps()
			newimages= for i=1 to bCount where ((local b = mat.geteffectbitmap i) != undefined) collect b
		)
		
		local images=#()
		if mateditor.isopen() 
		then
		(
			local mat=medit.getcurmtl()
			if classOf mat == DirectX_9_Shader
			then images= getDirectXBitmaps mat
			else images= getClassInstances Bitmaptexture target:mat -- get all textures from material or multimaterial
		) 
		else
		(
			local sel=selection as array
			if sel.count == 0 do return false
			for o in sel do
			(
				if o.material!=undefined then
				(
					local newimages

					if classOf o.material == DirectX_9_Shader 
					then newimages= getDirectXBitmaps o.material
					else newimages= getclassinstances Bitmaptexture target:o.material

					--collecting unique images to array
					for i in newimages do mcArray.appendIfUnique images i
				)
			)
		)
		local ps=CreateOLEObject"Photoshop.Application"
		ps.Visible=true
		for i in images do
		( 
			if doesFileExist i.filename 
			then ps.open i.filename
			else messageBox ("The file: ["+i.filename+"] is not Exist.") title:"Micra..."
		)
	), 
	--creating instance caused endless loop
	fn getObjectInfo arg  =
	(
		print "---------------------------------------------------------------------------" 
		format "Info:%\n" arg 
		print "---------------------------------------------------------------------------"
		try (format "ClassOf: %\n"      (classOf        arg)) catch (format "No ClassOf for %\n" arg)
		try (format "SuperClassOf: %\n" (superClassOf   arg)) catch (format "No SuperClassOf for %\n" arg)
		try (format "ShowClass: %\n"   (showClass      arg)) catch (format "No ShowClass for %\n" arg)
		try (format "show:%\n"       (show           arg)) catch (format "No Show for %\n" arg)
 		try (format "PROPERTIES:\n"   (showProperties arg)) catch (format "No Properties for %\n" arg)
 		try (format "METHODS:\n"    (showMethods    arg)) catch (format "No Methods for %\n" arg)
 		try (format "EVENTS:\n"      (showEvents     arg)) catch (format "No Events for %\n" arg)
		try (format "PropNames: %\n" (getPropNames   arg)) catch (format "No PropNames for %\n" arg)
		try (format "Interface: %\n"   (showInterface  arg)) catch (format "No Interface for %\n" arg)
		try (format "Constructors: %\n" (dotNet.showConstructors arg)) catch (format "No Constructors for %\n" arg)
		try (format "GetInterface: %\n" (getInterface arg)) catch (format "No GetInterface for %\n" arg)
		/*try ( --crash
			local interfaces = getInterfaces arg
			if classOf interfaces == Array do (
				
				for i in interfaces do (
					
					format "GetInterface: %\n" i
					showinterface i
				)
			)
		) catch (format "No GetInterfaces for %\n" arg)
		try (
			local currentClass = arg
			local parentClass = undefined
			while parentClass != currentClass do
			(
				format "% Properties:\n" currentClass as string 
				for prop in getPropNames currentClass do format "\t%\n" (prop as string) 
				currentClass = classof currentClass 
				parentClass = classof currentClass
			)	
		) catch ()*/
	),
	fn getAllDialogsHWND = ( for i in UIAccessor.GetPopupDialogs() collect (UIAccessor.GetWindowText i) ),
	fn closeDialogByTitle window_text =
	(
		local ace = UIAccessor.GetPopupDialogs()
		for i in ace where findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			UIAccessor.CloseDialog i
			--UIAccessor.PressButtonByName i "Cancel"
			exit
		)
	),	
	fn getDialogHWND window_text =
	(
		for d in UIAccessor.GetPopupDialogs() where
		findString (UIAccessor.GetWindowText d) window_text != undefined do exit with d
	),
	fn getDialogData window_text =
	(
		for i in UIAccessor.GetPopupDialogs() where 
		findString (UIAccessor.GetWindowText i) window_text != undefined do 
		(
			format "WindowText:%\n" (UIAccessor.GetWindowText i)
			format "WindowClassName:%\n" (UIAccessor.GetWindowClassName i)
			format "WindowResourceID:%\n"(UIAccessor.GetWindowResourceID i)
			format "GetChildWindows:%\n"(UIAccessor.GetChildWindows i)
			format "GetParentWindow:%\n"(UIAccessor.GetParentWindow i)
			format "GetFirstChildWindow:%\n"(UIAccessor.GetFirstChildWindow i)
			format "GetPrevWindow:%\n"(UIAccessor.GetPrevWindow i)
			format "GetNextWindow:%\n"(UIAccessor.GetNextWindow i)
			format "IsWindow:%\n"(UIAccessor.IsWindow i)
			format "GetWindowDllFileName:%\n"(UIAccessor.GetWindowDllFileName i)
			format "GetWindowDllDescription:%\n"(UIAccessor.GetWindowDllDescription i)
			exit
		)
	),
	/**
	*Not used anymore --delete or redefine also in Actions.xml
	*/
	fn getSHGameVersion =
	(
		local ifile = "c:/Dev/SilentHill/SHGame/Build-info.txt"
		if not doesFileExist ifile do return false
		local f = openfile ifile
		local first_line = readline f
		local v = (filterString first_line ": ")[2]
		setclipboardText v
		print v
		flush f
		close f
	),
	/**
	*@Usage > manage all windows applications
	*@Example
		mcSystem.minMaxApp "notepad" #min
		mcSystem.minMaxApp "notepad" #max
	*/
	fn getAppHandle app_name = (
	
		local processes = (dotnetclass "System.Diagnostics.Process").GetProcesses()
		--collect all running applications(using app name) handles
		for j in processes where j.ProcessName == app_name collect j.MainWindowHandle
	),
	--set focus to Max Application Window
	fn setFocusToMaxApp = (
	
		windows.SendMessage maxHandle mcWinMsg.WM_SETFOCUS 0 0
	),
	/**
	*@Usage
		set focus to any max window
	*@Example
		setFocusTo mcProgLogDialog.hwnd --set focus to mcProgLogDialog
		setFocusTo hForm.handle --set Focus To TextboxForm
		setFocusTo (Windows.GetMAXHWND()) --set focus to Max App
		mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND
		setFocusTo mxse_hwnd --Set Focus To Max Script Editor
	*/
	fn setFocusTo hwnd = ( --Not used Yet
	
		windows.SendMessage hwnd mcWinMsg.WM_SETFOCUS 0 0
	),
	fn minMaxApp app_name state = (
	
		local app_handle = (mcSystem.getAppHandle app_name)[1]
		if app_handle == undefined do return false
		if state == #max then (
		
			windows.sendmessage app_handle mcWinMsg.WM_SYSCOMMAND mcWinMsg.WM_MINIMIZE  0
			windows.sendmessage app_handle mcWinMsg.WM_SYSCOMMAND mcWinMsg.WM_RESTORE  0
			
		) else (
	
			windows.sendmessage app_handle mcWinMsg.WM_SYSCOMMAND mcWinMsg.WM_MINIMIZE  0
		)
	),
	fn getMaxBounds = (
		
		return windows.getWindowPos maxHandle
	),
	fn getMaxCenter = (
	
		local max_pos = getMaxBounds()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	),
	/**
	*@Author denisT 2011
	*@Usage	
		I simulate middle mouse click in view
		I don’t send activation message because i don’t want accidentally change the active window.
	*/
	fn setFocusToMaxActiveViewport = (

		local hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
		hwnd = (windows.getChildrenHWND hwnd)[1][1]
		mcUser32.postmessage hwnd mcWinMsg.WM_MBUTTONDOWN 0 0
		mcUser32.postmessage hwnd mcWinMsg.WM_MBUTTONUP 0 0
	)
	/*<end>*/
)
Global mcSystem = mcStructMan.instanceStructure MICRA_SYSTEM "mcSystem"



/*
namespace maxCustomControls
{
   public class Win32HandleWrapper : System.Windows.Forms.IWin32Window
   {
       public IntPtr Handle { get; set; }
       public Win32HandleWrapper(IntPtr handle) { this.Handle = handle; }
   }
}
*/
