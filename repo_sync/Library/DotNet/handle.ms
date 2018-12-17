fn getAllMaxHWND =
(
	local all_max_hwnd = windows.getchildrenhwnd #max
	for a in all_max_hwnd do
	(
		if classOf a == Array then
		(
			format "Item:%\n"  a
			for b in a do 
				if classOf b != IntegerPtr 
					then format "Name:%\n"  b
					else 
					(
						format "Child:%\n" (windows.getchildrenhwnd b)
					)
		)
	)	
)
getAllMaxHWND()


--get all max elements 
all_max_hwnd = windows.getchildrenhwnd #max
classOf all_max_hwnd[1]
for i in all_max_hwnd do format "item:%\n" i

fn getAllChilderns hndw=
(
	for a in hndw do 
		if classOf a != IntegerPtr 
			then (format "Name1:%\n"  a)
			else 
			(
				format "Child1:%\n" (windows.getchildrenhwnd a)
			)
)


all_hwnd = windows.getChildHWND #max "All"
roll_window = #(658238P, 1903008P, 1903008P, "RollupWindow", "", 0P, 2432120P, 2432120P)
roll_window = #(2166150P, 1903008P, 1903008P, "#32770", "", 0P, 2432120P, 2432120P)
roll_window = #(657658P, 2166150P, 2166150P, "CustButton", "Sets", 0P, 2432120P, 2432120P)

getAllChilderns roll_window
getAllChilderns lbx_hwnd
getAllChilderns all_hwnd


--etc:
/*
item:#(1186500P, 990186P, 990186P, "MXS_Scintilla", "MAXScript Mini Listener", 0P, 2432120P, 2432120P)
item:#(920716P, 990186P, 990186P, "MXS_Scintilla", "for i in (windows.getchildrenhwnd #max) do print i", 0P, 2432120P, 2432120P)
item:#(1313332P, 2166150P, 2166150P, "ComboBox", "Modifier List", 0P, 2432120P, 2432120P)
item:#(1903008P, 592690P, 592690P, "ModifyTask", "", 0P, 2432120P, 2432120P)
item:#(658238P, 1903008P, 1903008P, "RollupWindow", "", 0P, 2432120P, 2432120P)
*/

--get names of all popup dialogs
all_hndw = UIAccessor.GetPopupDialogs()
for d in all_hndw do print (UIAccessor.GetWindowText d)



hwnd = DotNetObject "IntPtr" ( Windows.GetMAXHWND() )
mcsystem.show hwnd
hwnd.ToString()


hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
hwnd = (windows.getChildrenHWND hwnd)[1][1]
mcsystem.show hwnd


win32gui.SetFocus(hwnd)---???

ctrl = dotNetclass "Control"
mcsystem.show ctrl 

p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
p = DotNetObject "System.IntPtr" hwnd
c = ctrl.FromHandle p

mcsystem.show p


commandHWND= windows.getChildHWND #max "Command Panel"

 if commandHWND !=undefined do windows.sendmessage commandHWND MN_GETHMENU 0 0


--we can find the first child of "Command Panel" by class name: "SysTabControl32"
first_child_hwnd = for i in (windows.getchildrenhwnd #max) where i[4] == "SysTabControl32" do exit with i[1]
--after that get its parent (that means "Command Panel"):
command_panel_hwnd = uiaccessor.getparentwindow first_child_hwnd
 
UIAccessor.getWindowResourceID command_panel_hwnd
 
windows.sendmessage command_panel_hwnd LVM_GETITEMCOUNT 0 0


fn stopRedraw=
 (
 WM_SETREDRAW=0xB
 commandHWND = (windows.getChildHWND #max "Command Panel")
 if commandHWND != undefined and classOf commandHWND==Array then commandHWND=commandHWND[1]
 else commandHWND = windows.getmaxhwnd()
 if commandHWND !=undefined do windows.sendmessage commandHWND WM_SETREDRAW 0 0
 )
 fn resumeRedraw=
 (
 WM_SETREDRAW=0xB
 commandHWND = (windows.getChildHWND #max "Command Panel")
 if commandHWND != undefined and classOf commandHWND==Array then commandHWND=commandHWND[1]
 else commandHWND = windows.getmaxhwnd()
 if commandHWND !=undefined do windows.sendmessage commandHWND WM_SETREDRAW 1 0
 )