--------------------------------------------------------------------------------
/* mcScreen by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
Struct MICRA_SCREEN (

	scr = (dotNetClass "System.Windows.Forms.Screen"),	
	fn getSource = getSourceFileName(), --get path of this script
	fn count = (scr.AllScreens.count),
	fn name num:1 = (scr.AllScreens[num].DeviceName),
	fn size num:1 = 
	(
		if scr.AllScreens.count < num do return false
		[scr.AllScreens[num].Bounds.Width, scr.AllScreens[num].Bounds.Height]
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
		--(scr.FromPoint p).DeviceName
	),
	fn pos num:1 = 
	(
		if scr.AllScreens.count < num do return false
		[scr.AllScreens[num].Bounds.x, scr.AllScreens[num].Bounds.y]
	)
	/*<end>*/
 )
 --create instance
Global mcScreen = mcStructMan.instanceStructure MICRA_SCREEN "mcScreen"