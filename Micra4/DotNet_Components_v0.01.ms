--DotNet FN--

Global WindowWrapper
Global mcSCREENS_DATA

if WindowWrapper == undefined do 
(
	fn getWindowWrapper = 
	(
		source = ""
		source += "using System;\n"
		source += "using System.Windows.Forms;\n"
		source += "public class WindowWrapper : IWin32Window\n"
		source += "{\n"
		source += "	public WindowWrapper(IntPtr handle) { _hwnd = handle; }\n"
		source += "	public WindowWrapper(Int32 handle) { _hwnd = (IntPtr)handle; }\n"
		source += "	public IntPtr Handle { get { return _hwnd; } }\n"
		source += "	private IntPtr _hwnd;\n"
		source += "}\n"
		-- Compile on fly
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.ReferencedAssemblies.Add("System.dll");
		compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll");
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)

		compilerResults.CompiledAssembly
	)
	getWindowWrapper()
	WindowWrapper = dotnetobject "WindowWrapper" (windows.getMAXHWND()) 
)

Global netByteClass      = (dotNetClass "System.Byte")
Global netCursors        = (dotNetClass "Cursors")
Global netDragDropEffect = (dotNetClass "DragDropEffects")
Global netPointClass     = (dotnetClass "Drawing.Point")
Global netKeys           = (dotNetClass "Keys")
Global netFile        = (dotnetClass "IO.File")
        
fn netDecimal val       = (dotNetObject "Decimal" val)
/**
* @example:
	netDrColor (color 60 32 104)
	netDrColor #3c2068
*/
fn netDrColor clr       = (
	
	local dotnet_color = case classOf clr of (
		
		Name:(
			local hex_as_color = mcColor.hexToColor clr
			if hex_as_color == undefined do return undefined
			(dotNetClass "Drawing.Color").fromArgb hex_as_color.r hex_as_color.g hex_as_color.b
		)
		Color:(dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b
	)
	return dotnet_color
)
fn netDrBitmap size     = (dotNetObject "Drawing.Bitmap" size.x size.y)
fn netDrPoint pos       = (dotnetObject "Drawing.Point" pos.x pos.y)
fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)
fn netDrSize size       = (dotNetObject "Drawing.Size" size.x size.y)
fn netDrFont font:"Arial" size:12 style:"Regular" =
(
	local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
	dotNetObject "Drawing.Font" font size f_style
) 
fn netString str        = (dotNetObject "System.String" str)

Global mcRect
Global mcFormSnap
Global getIconDotNet
--> Make grid with size 01  to snap dialogs, Rene (2018)
fn mcFormSnap_NEW formA pos =
(
	if classOf formA != dotNetObject or pos == undefined do return false
	
	local formA_newpos = mouse.screenpos - pos
	--round pos to grid size
	formA_newpos.x = mcMath.roundToInt formA_newpos.x 10
	formA_newpos.y = mcMath.roundToInt formA_newpos.y 10

	format "mcFormSnap form:% pos1:%\n" formA.name formA_newpos
	
	--final move action
	formA.location = netDrPoint [formA_newpos.x, formA_newpos.y]
)
fn mcFormSnap formA pos =
(
	if classOf formA != dotNetObject or pos == undefined do return false
	local sd=mcSCREENS_DATA() --dotNetClass:System.Windows.Forms.Screen
	local current_monitor = 1 --sd.active() //causing ** system exception **
	local desktop_size = sd.fullsize()
	desktop_size.y = (sd.size num:current_monitor).y --sysInfo.DesktopSize
	local desktop_pos = sd.pos num:current_monitor --[0, 0]
	local formA_pos = [formA.location.x, formA.location.y] --A form pos
	local formA_size = [formA.width, formA.height] --A form size
	local desktop_rect   = mcRect mi:desktop_pos ma:desktop_size --min/max from windows size
	local formA_rect   = mcRect (p=copy formA_pos) (p+formA_size+[0,4])--min max from picked form
	
	--get bounds rect from picked form
	local x = formA_rect.mi.x
	local y = formA_rect.mi.y
	
	--Zadr
	local formA_newpos = mouse.screenpos - pos
	--round pos to grid size
	--format "form pos A:%\n" formA_newpos
formA_newpos.x = (mcMath.roundToInt formA_newpos.x 10)+2 -- 2(border size)
formA_newpos.y = (mcMath.roundToInt formA_newpos.y 10)+2
	--formA_newpos.x = mcMath.roundToEven formA_newpos.x
	--formA_newpos.y = mcMath.roundToEven formA_newpos.y
	--format "form pos B:%\n" formA_newpos
	--fill rect
	formA_rect.mi.x = formA_newpos.x
	formA_rect.ma.x = x + formA_size.x
	formA_rect.mi.y = formA_newpos.y
	formA_rect.ma.y = y + formA_size.y
	
	local sDist = desktop_rect.ma.x / 200-- set snap distance
	
	--get visible form names
	local all_forms = getINISetting mcTempProfileIni "Properties_1" + getINISetting mcTempProfileIni "Properties_2"
	local visible_forms = for i in all_forms where (execute ("classOf "+ i +"== dotNetObject")) and (execute(i+".Visible")) collect i
	
	for i in visible_forms do
	(
		local formB = (execute i)
		local formB_pos  = [formB.location.x, formB.location.y]
		local formB_size = [formB.width, formB.height]
		--min max from B (visible) forms
		local formB_rect = mcRect formB_pos (formB_pos+formB_size)
		
		--Left
		if formA_rect.mi.x < formB_rect.ma.x+sDist and formA_rect.mi.x > formB_rect.ma.x-sDist and 
		formA_rect.ma.y > formB_rect.mi.y and formA_rect.mi.y < formB_rect.ma.y
		then formA_rect.mi.x = formB_rect.ma.x
		--Zadr???
		formA_rect.ma.x = formA_rect.mi.x + formA_size.x
		--Right
		if formA_rect.ma.x > formB_rect.mi.x-sDist and formA_rect.ma.x < formB_rect.mi.x+sDist and 
		formA_rect.ma.y > formB_rect.mi.y and formA_rect.mi.y < formB_rect.ma.y
		then formA_rect.mi.x = (formB_rect.mi.x-formA_size.x)
		--Top
		if formA_rect.ma.y > formB_rect.mi.y-sDist and formA_rect.ma.y < formB_rect.mi.y+sDist and 
		formA_rect.ma.x > formB_rect.mi.x and formA_rect.mi.x < formB_rect.ma.x 
		then formA_rect.mi.y = (formB_rect.mi.y-formA_size.y)
		--Zadr
		formA_rect.ma.y = formA_rect.mi.y + formA_size.y
		--Bottom
		if formA_rect.mi.y < formB_rect.ma.y+sDist and formA_rect.mi.y > formB_rect.ma.y-sDist and 
		formA_rect.ma.x > formB_rect.mi.x and formA_rect.mi.x < formB_rect.ma.x 
		then formA_rect.mi.y = formB_rect.ma.y
	)

	--if is in Left bound
	if formA_rect.mi.x < desktop_rect.mi.x+sDist 
	then x = 0 
	else 
	--if is in Right bound
	if formA_rect.mi.x+formA_size.x > desktop_rect.ma.x-sDist 
	then x = (desktop_rect.ma.x-formA_size.x) 
	else x = formA_rect.mi.x		
	--if is in Top bound
	if formA_rect.mi.y < desktop_rect.mi.y+sDist 
	then y = 0 
	else 
	--if is in Bottom bound
	if formA_rect.mi.y+formA_size.y > desktop_rect.ma.y-sDist 
	then y = (desktop_rect.ma.y-formA_size.y)
	else y = formA_rect.mi.y
	
	--final move action
	if (formA_pos.x != x or formA_pos.y != y) do formA.location = netDrPoint [x, y]
)
	
fn getIconDotNet icnNum icnSize:24 =
(
	if icnNum == 0 do return undefined
	local img_lib = (dotNetClass "Drawing.Image").FromFile mcIconI --get the saved image from file as bitmap
	local w = h = icnSize
	local img_lib_size = [img_lib.width, img_lib.height]
	local icnCount  = (img_lib_size/icnSize)
	icnNum -= 1
if debug == 5 do format "lib size:% icn count:%\n"	img_lib_size icnCount	
	local X = (mod icnNum icnCount.x)
	local Y = (icnNum / icnCount.y) as integer
if debug == 5 do format "x:% y:%\n" x y		
	local pix_x = X * icnSize
	local pix_y = Y * icnSize
	
	local pos = [pix_x, pix_y]
	
if debug == 5 do format "ic_num:%\ticon pos in img_lib:%\n" icnNum pos

	local icon = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
	--icon.ColorDepth = icon.ColorDepth.Depth24Bit
	local gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
	local newRect = netDrRect [ -1, -1 ] [icnSize, icnSize]  --adjust icon offset X in button 
	gra.DrawImage img_lib newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
	img_lib.dispose()
	icon.MakeTransparent (netDrColor black)--(color 75 75 75)) --gray
	icon
)

fn dotNetArray mxsArray byte:false = 
(
	if classOf mxsArray != Array or mxsArray.count == 0 do return undefined
	local netArray
	case classOf mxsArray[1] of 
	(
		dotNetObject:
		(
			netArray = dotNetObject "System.Object[]" mxsArray.count
			for i=1 to mxsArray.count do 
			(
				local obj = mxsArray[i]
				local indx = if byte then dotNetObject "System.Byte" (i-1) else dotNetObject "System.Int32" (i-1)
				netArray.SetValue obj indx
			)
		)
		String:
		(
			netArray = dotNetObject "System.String[]" mxsArray.count
			for i=1 to mxsArray.count do 
			(
				local str = dotNetObject "System.String" mxsArray[i]
				local indx = if byte then dotNetObject "System.Byte" (i-1) else dotNetObject "System.Int32" (i-1)
				netArray.SetValue str indx
			)
		)
	)
	netArray
)

fn netColorToRGB clr =
(
	local str = clr.ToString()
	local argb = execute (substring str 7 -1)
	color argb[2] argb[3] argb[4]
)