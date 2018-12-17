
"---------------------------------------------------------------------------"
Info:dotNetClass:System.Windows.Forms.Screen
"---------------------------------------------------------------------------"
ClassOf: dotNetClass
SuperClassOf: Value
No ShowClass for dotNetClass:System.Windows.Forms.Screen
No Show for dotNetClass:System.Windows.Forms.Screen
  .AllScreens : <System.Windows.Forms.Screen[]>, read-only, static
  .PrimaryScreen : <System.Windows.Forms.Screen>, read-only, static
PROPERTIES:
  .[static]<System.Boolean>Equals <System.Object>objA <System.Object>objB
  .[static]<System.Windows.Forms.Screen>FromControl <System.Windows.Forms.Control>control
  .[static]<System.Windows.Forms.Screen>FromHandle <System.IntPtr>hwnd
  .[static]<System.Windows.Forms.Screen>FromPoint <System.Drawing.Point>point
  .[static]<System.Windows.Forms.Screen>FromRectangle <System.Drawing.Rectangle>rect
  .[static]<System.Drawing.Rectangle>GetBounds <System.Drawing.Point>pt
  .[static]<System.Drawing.Rectangle>GetBounds <System.Drawing.Rectangle>rect
  .[static]<System.Drawing.Rectangle>GetBounds <System.Windows.Forms.Control>ctl
  .[static]<System.Drawing.Rectangle>GetWorkingArea <System.Drawing.Point>pt
  .[static]<System.Drawing.Rectangle>GetWorkingArea <System.Drawing.Rectangle>rect
  .[static]<System.Drawing.Rectangle>GetWorkingArea <System.Windows.Forms.Control>ctl
  .[static]<System.Boolean>ReferenceEquals <System.Object>objA <System.Object>objB
METHODS:
EVENTS:
PropNames: #(#AllScreens, #PrimaryScreen)
No Interface for dotNetClass:System.Windows.Forms.Screen
Constructors: false
No GetInterface for dotNetClass:System.Windows.Forms.Screen
	

struct SCREENS_DATA
(
	scr = (dotNetClass "System.Windows.Forms.Screen"),	
	fn count = (scr.AllScreens.count),
	fn name num:1 = (scr.AllScreens[num].DeviceName),
	fn size num:1 = 
	(
		local all_scr = scr.AllScreens
		if all_scr.count < num do return false
		[all_scr[num].Bounds.Width, all_scr[num].Bounds.Height]
	),
	fn fullSize = 
	(
		local size = [0, 0]
		for s in scr.AllScreens do size += [s.Bounds.Width, s.Bounds.Height]
		return size
	),
	fn active =
	(
		local p = dotnetObject "Drawing.Point" mouse.screenpos.x mouse.screenpos.y
		for i=1 to scr.AllScreens.count where scr.AllScreens[i] == (scr.FromPoint p) do return i
	)
 )
 
my_screens = SCREENS_DATA()
 
my_screens.count()
my_screens.name num:2
my_screens.size num:1
my_screens.size num:2
my_screens.fullSize()
my_screens.active()

 
 
 
 
--where is my max?
 
 scr = dotNetClass "System.Windows.Forms.Screen"
h = DotNetObject "IntPtr" ( Windows.GetMAXHWND() )
(scr.FromHandle h).DeviceName
 
 
 
 --------------------------
info = dotnetClass "SystemInformation"
mcsystem.show info
  .MonitorCount : <System.Int32>, read-only, static
  .PrimaryMonitorMaximizedWindowSize : <System.Drawing.Size>, read-only, static
  .PrimaryMonitorSize : <System.Drawing.Size>, read-only, static
  .VirtualScreen : <System.Drawing.Rectangle>, read-only, static
  .WorkingArea : <System.Drawing.Rectangle>, read-only, static
.DragSize : <System.Drawing.Size>, read-only, static
  .VirtualScreen : <System.Drawing.Rectangle>, read-only, static
  .WorkingArea : <System.Drawing.Rectangle>, read-only, static
  .MaxWindowTrackSize : <System.Drawing.Size>, read-only, static
    .RightAlignedMenus : <System.Boolean>, read-only, static
  .ScreenOrientation : <System.Windows.Forms.ScreenOrientation>, read-only, static
    .MonitorsSameDisplayFormat : <System.Boolean>, read-only, static
	
info.MonitorCount
info.PrimaryMonitorMaximizedWindowSize.tostring()
info.PrimaryMonitorSize.tostring()
info.VirtualScreen.tostring()
info.WorkingArea.tostring()
info.DragSize.tostring()
info.MaxWindowTrackSize.tostring()
sysInfo.DesktopSize


 info.RightAlignedMenus ---test it
 mcsystem.show  info.ScreenOrientation
info.MousePresent
info.MonitorsSameDisplayFormat

full_desktop_size = [info.VirtualScreen.width, info.VirtualScreen.height]
prim_monitor_size = [info.PrimaryMonitorSize.width, info.PrimaryMonitorSize.height]
sec_monitor_size = [full_desktop_size.x - prim_monitor_size.x, 



/*HeaderStart**************************************  *****************
:Created By:			Paul Neale
:Company:				PEN Productions Inc.
:Site:					http://paulneale.com
:Email:				info@paulneale.com
:Client:				PEN Productions

:Purpose: Retuns the HWND for the active viewport. 

:History:
	Oct 04 2009
		Created.

:Todo:

:Bugs:
	None Known

:Tests:
for x in windows.getChildrenHWND #max do format "%\n" x

-->Use this to create a dotNet handle for the viewport. 
	p = DotNetObject "System.IntPtr" ( (getViewportHwnd()) [1])
	maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" p
**************************************************  *****HeaderEnd*/


/*FnStart******************************************  *************
:Function: getActiveViewportName
:Usage: getActiveViewportName()
:Todo: 
:Notes: 
	Called by getViewportHwnd
 **************************************************  *****FnEnd*/
fn getActiveViewportName=
(
	local viewName=viewport.getType()
	case of
	(
		(viewName==#view_top): "Top"
		(viewName==#view_bottom): "Bottom"
		(viewName==#view_right): "Right"
		(viewName==#view_left): "Left"
		(viewName==#view_back): "Back"
		(viewName==#view_persp_user): "Perspective"
		(viewName==#view_iso_user): "Orthographic"
		(viewName==#view_camera): (viewport.getCamera index:viewport.activeViewport).name
		(viewName==#view_spot): (viewport.getCamera index:viewport.activeViewport).name
		(viewName==#view_shape): "Shape"
		(viewName==#view_grid): "Grid" --Will need to search for "Grid" in the name here.
	)
)

/*FnStart******************************************  *************
:Function: getViewportHwnd
:Usage: getViewportHwnd()
:Todo: 
:Notes: 
	Calls getActiveViewportName and returns the HWND array for the active viewport. 
 **************************************************  *****FnEnd*/
fn getViewportHwnd=
(
	local viewPortName=getActiveViewportName()
	local returnHwnd=undefined
	if viewPortName!=undefined do
	(
		for wHwnd in windows.getChildrenHWND #max do 
		(
			if wHwnd[4]=="D3DWindow" and findString wHwnd[5] viewPortName!=undefined do 
			(
				returnHwnd=wHwnd
				exit
			)
		)
	)
	returnHwnd
)



----------------

for wHwnd in windows.getChildrenHWND #max while returnHwnd == undefined do 
    (
    	 if wHwnd[4]=="D3DWindow" and findString wHwnd[5] viewPortName!=undefined do 
    	 (
    		  returnHwnd=wHwnd
    	 )
    )
    