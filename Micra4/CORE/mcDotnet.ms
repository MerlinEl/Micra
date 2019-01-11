--------------------------------------------------------------------------------
/* mcDotnet by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
	mcUIColors
	mcFile
*
*@Used Objects

*
*/
Struct MICRA_DOTNET (
	
	ByteClass   = (dotNetClass "System.Byte"),
	Cursors     = (dotNetClass "Cursors"),
	DragDropEffect = (dotNetClass "DragDropEffects"),
	PointClass  = (dotnetClass "Drawing.Point"),
	Keys        = (dotNetClass "Keys"),
	File       = (dotnetClass "IO.File"),
	fn getSource = getSourceFileName(), --get path of this script
	/*
	*@Usage		convert max color to dotnet
	*@Example 	btn.BackColor = mcDotnet.dColor red
	*/
	fn dColor clr = (
	
		local dotnet_color = case classOf clr of (
			
			Name:(
				local hex_as_color = mcColor.hexToRGB clr
				if hex_as_color == undefined do return undefined
				(dotNetClass "Drawing.Color").fromArgb hex_as_color.r hex_as_color.g hex_as_color.b
			)
			Color:(dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b
		)
		return dotnet_color
	),
	/*
	*@Usage	convert dotnet color to max color <r> <g> <b> [ <a> ]
	*@Example 	clr = mcDotnet.mColor net_color
	*/
	fn mColor dclr = (color dclr.r dclr.g dclr.b dclr.a),
	fn dBitmap size     = (dotNetObject "Drawing.Bitmap" size.x size.y),
	fn dPoint pos       = (
		
		if classOf pos != Point2 do (format "mcDotnet > dPoint > Error at: pos:%\n" pos; return undefined)
		dotnetObject "Drawing.Point" pos.x pos.y
	),
	fn dRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn dSize size       = (dotNetObject "Drawing.Size" size.x size.y),
	fn dFont font:"Arial" size:12 style:"Regular" =
	(
		local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
		dotNetObject "Drawing.Font" font size f_style
	),
	fn dString str  = (dotNetObject "System.String" str),
	fn dDecimal val       = (dotNetObject "Decimal" val),
	/*
	*@Usage get interface color by name
	*@Example btn.BackColor = mcDotnet.uiColor #back
	*/
	fn uiColor color_name = (
		
		local ui_color = mcUIColors.get color_name
		dColor ui_color
	),
	fn dGetIcon icnNum icnSize:24 = (
		if icnNum == 0 do return undefined
		local img_lib = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
		local w = h = icnSize
		local img_lib_size = [img_lib.width, img_lib.height]
		local icnCount  = (img_lib_size/icnSize)
		icnNum -= 1
	if debug == 5 do format "mcDotnet > lib size:% icn count:%\n"	img_lib_size icnCount	
		local X = (mod icnNum icnCount.x)
		local Y = (icnNum / icnCount.y) as integer
	if debug == 5 do format "mcDotnet > x:% y:%\n" x y		
		local pix_x = X * icnSize
		local pix_y = Y * icnSize
		
		local pos = [pix_x, pix_y]
		
	if debug == 5 do format "mcDotnet > ic_num:%\ticon pos in img_lib:%\n" icnNum pos

		local icon = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		--icon.ColorDepth = icon.ColorDepth.Depth24Bit
		local gra  = (dotNetClass "Drawing.Graphics").fromImage icon --Create new Graphics object
		local newRect = netDrRect [ -1, -1 ] [icnSize, icnSize]  --adjust icon offset X in button 
		gra.DrawImage img_lib newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img_lib.dispose()
		icon.MakeTransparent (netDrColor black)--(color 75 75 75)) --gray
		icon
	),
	fn dArray mxsArray byte:false = (
		if classOf mxsArray != Array or mxsArray.count == 0 do return undefined
		local net_array
		case classOf mxsArray[1] of 
		(
			dotNetObject:
			(
				net_array = dotNetObject "System.Object[]" mxsArray.count
				for i=1 to mxsArray.count do 
				(
					local obj = mxsArray[i]
					local indx = if byte then dotNetObject "System.Byte" (i-1) else dotNetObject "System.Int32" (i-1)
					net_array.SetValue obj indx
				)
			)
			String:
			(
				net_array = dotNetObject "System.String[]" mxsArray.count
				for i=1 to mxsArray.count do 
				(
					local str = dotNetObject "System.String" mxsArray[i]
					local indx = if byte then dotNetObject "System.Byte" (i-1) else dotNetObject "System.Int32" (i-1)
					net_array.SetValue str indx
				)
			)
		)
		net_array
	),
	fn maxHW = (
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return hv
	),
	/*
		@Usage	open dotnet form with max handle implementation
		@Example	mcDotnet.dShow form saved_pos:false
	*/
	fn dShow form saved_pos:true = (
		
		if form == undefined or form.IsDisposed or form.visible do return false
		--get last position from Properties_2
		if saved_pos do (
			
			local dpos   = (mcFile.getIniDataFromArray Micra.TempProfileIni "Properties_2" form.name 2) --return Point2 or undefined
			if classOf dpos != Point2 then ( --first entry
				
				format "mcDotnet > dShow > Form [  % ] is not saved, pos:%\n" form.text pos
				dpos = [0,0] --set default pos
			)
			form.Location = dPoint dpos
		)
		if Micra.debug == 8 do ( --unbind form from 3DsMax (test mode for Notepad++)
		
			form.topMost = true
			form.show()
			format ("mcDotnet > form [ % ] start bounded in to windows.\n") form.name
			return OK
		)
		local hv = maxHW ()
		form.show(hv) -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
		hv.ReleaseHandle()
		--form.show(WindowWrapper) --good one try it later
		--form.showModeless()
		--dotNet.setLifeTimeControl form #dotNet --it’s generally a good idea to let the .NET garbage collector take care of the .NET objects, instead of the Max’s one.
	),
	fn dClose form saved_pos:true = ( --not used yet
	
		if form == undefined or form.IsDisposed or not form.visible do return false
		form.close()
	)
)	
 --create instance
Global mcDotnet = Micra.instanceStructure MICRA_DOTNET "mcDotnet"


/* -- old wrapper > mcColorPaleteDialog.show(WindowWrapper)
Global WindowWrapper

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
*/
