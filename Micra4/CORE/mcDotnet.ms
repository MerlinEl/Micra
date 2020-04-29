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
	
	ByteClass   	= dotNetClass "System.Byte",
	Cursor			= dotNetClass "System.Windows.Forms.Cursor",
	Cursors     	= dotNetClass "Cursors",
	Brushes 		= dotNetClass "System.Drawing.Brushes", --many colors (Aqua, Violet, Turquoise, Transparent...)
	Graphics 		= dotNetClass "System.Drawing.Graphics",
	Drawing2D		= dotNetClass "System.Drawing.Drawing2D", --InterpolationMode, CompositingQuality, PixelOffsetMode, SmoothingMode
	PenAlignment 	= dotnetClass "System.Drawing.Drawing2D.PenAlignment",
	ControlPaint 	= dotnetClass "System.Windows.Forms.ControlPaint",
	ButtonBorderStyle= dotnetClass "System.Windows.Forms.ButtonBorderStyle",
	FrameStyle		= dotnetClass "System.Windows.Forms.FrameStyle",
	LineCap			= dotnetClass "System.Drawing.Drawing2D.LineCap", --Round, Flat
	DragDropEffect 	= dotNetClass "DragDropEffects",
	PointClass		= dotnetClass "Drawing.Point",
	Keys			= dotNetClass "Keys",
	File			= dotnetClass "IO.File",
	Screen			= dotnetClass "System.Windows.Forms.Screen",
	SysTime			= dotnetClass "System.DateTime",
	AnchorStyles	= dotnetClass "System.Windows.Forms.AnchorStyles",
	--@Example > text_size = mcDotnet.TextRenderer.MeasureText "abc" (mcDotnet.dFont())
	TextRenderer	= dotnetClass "System.Windows.Forms.TextRenderer",
	DockStyle		= dotnetClass "System.Windows.Forms.DockStyle",
	MouseButton	= dotnetClass "System.Windows.Input.MouseButton",
	/**
	*@Example
		ns = "http://test"
		ns_foo = "http://www.example.com"
		mcDotnet.format "ww_1:{0} www_2:{1}"  ns ns_foo
		> "<data xmlns=http://test xmlns:foo=http://www.example.com></data>"
	*/
	Format = (dotnetClass "System.String").format,
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Replaced By mcCsharp.getClassInstance
	*@Usage
		Load Dll libraries from C#
	*@Example
		--------
		MATH
		--------
		Global _mcMath = loadAssembly "Orien.Tools" "Orien.Tools.mcMath"
		_mcMath.minMax 100	1	50	--> 50
		_mcMath.minMax -1	1	50	--> 1
		_mcMath.minMax 100	1	200	--> 100
		--------
		XML
		--------
		Global _mcXml = loadAssembly "Orien.Tools" "Orien.Tools.mcXml" params:#(micra.RootDir + "Actions_test.xml")
		net_xml_node = _mcXml.GetNode "/ACTIONS/Object/Clone_2"
		net_xml_node.GetAttribute "icon"
		net_xml_node.SetAttribute "icon" "89"
		_mcXml.Save()
	
	fn loadAssembly dll_name class_name params:#() forceLoad:false = (
		
		local cls = dotNet.getType class_name  --pickup class from memory
		if cls == undefined or forceLoad do (  --if dll is not loaded 
			
			dotNet.loadAssembly (micra.AssemblyDir + dll_name + ".dll") --load dll in to memory (but lock the dll file)
		)
		cls = dotNet.getType class_name  --pickup class from memory
		if cls == undefined do return undefined
		local activator = (dotNetClass "System.Activator")
		try (
			if params.count == 0 then (
				
				activator.CreateInstance cls --create class instance
			) else (
				
				local args = dotNet.ValueToDotNetObject params (dotNetObject "System.Object")
				activator.CreateInstance cls args
			)
		) catch (format "Unable to init Class:%\n\t%\n" class_name (getCurrentException()))
	),*/
	/*
	*@Usage		convert max color to dotnet
	*@Example 	
		btn.BackColor = mcDotnet.dColor (color 15 254 251)
		btn.BackColor = mcDotnet.dColor #ffefbf
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
	fn dBrush clr = (dotnetobject "System.Drawing.SolidBrush" (dColor clr)),
	fn dPen clr size = (dotnetobject "System.Drawing.Pen" (dColor clr) size),
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
	fn dPadding left top right bottom = (dotnetObject "System.Windows.Forms.Padding" left top right bottom),
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
	/**
	*@Usage > create rounded rectangle graphic path
	*@Example
		fn OnLabelPaint s a = (
			local gpath = mcDotnet.createRoundRectanglePath s.ClientRectangle radius:22
			local gra = a.graphics
			gra.SmoothingMode = gra.SmoothingMode.AntiAlias
			local fillBrush = dotNetObject "System.Drawing.SolidBrush" s.BackColor
			local outLinePen = dotNetObject "system.drawing.pen" s.ForeColor 2	--color and thickness
			gra.FillPath fillBrush gpath
			gra.DrawPath outLinePen gpath
			mcDotnet.TextRenderer.DrawText gra s.text s.Font s.ClientRectangle s.ForeColor
		)
	*/
	fn createRoundRectanglePath rect radius:15 = (

		local diminisher = 1
		local gpath = dotNetobject "System.Drawing.Drawing2D.GraphicsPath"
		gpath.AddArc rect.X rect.Y radius  radius  180  90 
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) rect.Y  radius radius 270 90
		gpath.AddArc (rect.X + rect.Width - radius - diminisher) (rect.Y + rect.Height - radius - diminisher) radius radius 0 90
		gpath.AddArc rect.X (rect.Y + rect.Height - radius - diminisher) radius radius 90 90
		gpath.CloseAllFigures()
		return gpath
	),
	fn getBitmapFromFile fpath = (
	
		local img = (dotNetClass "Drawing.Image").FromFile fpath
		local size = [img.width, img.height]
		local bm = (dotNetObject "Drawing.Bitmap" size.x size.y) --Create new bitmap object
		local rect = dotNetObject "System.Drawing.Rectangle" 0 0 size.x size.y
		local gra  = (dotNetClass "Drawing.Graphics").fromImage bm --Create new Graphics object
	    gra.DrawImage bm rect
		img.dispose()
		bm
	),
	/**
	*@Example
		mcDotnet.getIcon 308
	*/
	fn getIcon icn_num icn_size:24 = (
		
		if icn_num == 0 do return undefined
		local img_lib = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
		local w = h = icn_size
		local img_lib_size = [img_lib.width, img_lib.height]
		local icnCount  = (img_lib_size/icn_size)
		icn_num -= 1
		local X = (mod icn_num icnCount.x)
		local Y = (icn_num / icnCount.y) as integer	
		local pix_x = X * icn_size
		local pix_y = Y * icn_size
		local pos = [pix_x, pix_y]
		local bmp_dn = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		--bmp_dn.ColorDepth = bmp_dn.ColorDepth.Depth24Bit
		local gra  = (dotNetClass "Drawing.Graphics").fromImage bmp_dn --Create new Graphics object
		local newRect = dRect [ -1, -1 ] [icn_size, icn_size]  --adjust icon offset X in button 
		gra.DrawImage img_lib newRect pos.x pos.y w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img_lib.dispose()
		bmp_dn.MakeTransparent (dColor (color 0 0 0)) -- 75 75 75  --gray
		bmp_dn
	),
	fn addButtonToolTip dbtn show_text img_name = (
	
		if not mcCsharp.isLoaded() do return false
		try (
			local tltp = mcCsharp.getClassInstance "Orien.NetUi.McImageTooltip" 
			if tltp == undefined do return false
			tltp.AutoSize = false
			--Set up the delays for the ToolTip.
		   /*tltp.AutoPopDelay = 5000;
		   tltp.InitialDelay = 1000;
		   tltp.ReshowDelay = 500;*/
			--#002040
			tltp.SetFont "Verdana" 14 (::mcGetCs.FontStyles()).Regular (::mcGetCs.NewColor 0 32 64)
			tltp.BorderColor = (::mcGetCs.NewColor 1 247 46)
			--tltp.Size 200 64
			tltp.SetToolTip dbtn show_text
			dbtn.Tag = (dotNetClass "Drawing.Image").FromFile  (micra.ImagesPath + "TooltipIcons\\" + img_name + ".png")
		) catch ()
	),
	/**
	TODO > check this method instead
		--Max array to dotnet array
		arr = #("http://test", "http://www.example.com")
		dotNetArg=dotNet.ValueToDotNetObject arr (dotNetObject "System.Object")
		dotNetArg.Length
		dotNetArg[1]
		(dotnetClass "System.String").format "ww_1:{0} www_2:{1}"  dotNetArg
	*/
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
	/**
	*@Usage	> convert sconds in to TimeSpan
	*@Example
		(mcDotnet.secondsToTimeSpan 61).toString()
	*/
	fn secondsToTimeSpan sec_val = (
	
		local ts = dotnetObject "System.TimeSpan" 0
		ts.FromSeconds sec_val
	),
	fn maxHW = (
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			return hv
	),
	fn focusViewport = ( 

		local WM_MBUTTONDOWN = 0x0207
		local WM_MBUTTONUP 	= 0x0208
		local hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
		hwnd = (windows.getChildrenHWND hwnd)[1][1]
		mcUser32.postmessage hwnd WM_MBUTTONDOWN 0 0
		mcUser32.postmessage hwnd WM_MBUTTONUP 0 0
	),
	fn getFormItemByName form item_name = (
		
		if classOf form != dotNetObject do return undefined
		local controls = form.controls
		for i=0 to controls.count - 1  do (
			
			local itm = controls.item[i]
			if not (isProperty itm "name") do continue
			if itm.name == item_name do return itm
		)
		undefined
	),
	/*
		@Usage	open dotnet form with max handle implementation
		@Example	mcDotnet.dShow form saved_pos:false
	*/
	fn dShow form saved_pos:true modal:false = (
		
		if form == undefined or form.IsDisposed or form.visible do return false
		--get last position from Properties_2
		if saved_pos do (
			
			local dpos = execute (mcFile.readSettings Micra.UserProfile ("Properties_2/" + form.name) type:"pos")
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
		 -- Shows the form with the specified owner (MAX) to the user (creatd by lo)
		if modal then form.ShowModal() else form.Show(hv)
		
		hv.ReleaseHandle()
		--form.show(WindowWrapper) --good one try it later
		--form.showModeless()
		--dotNet.setLifeTimeControl form #dotNet --it’s generally a good idea to let the .NET garbage collector take care of the .NET objects, instead of the Max’s one.
	),
	fn dClose form saved_pos:true = ( --not used yet
	
		if form == undefined or form.IsDisposed or not form.visible do return false
		form.close()
	)
	/**
	*@Replaced By mcCsharp.getClassInstance
	*@Usage Load Assemblies
	fn init = (
		return OK --break for now (tsting another method)
		if not doesFileExist micra.AssemblyDir do return ok
		
		try (
			dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
			dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")
			
		) catch (format "Unable to load Orien Assemblies > %\n" (getCurrentException()))
		Global mcGetCs = loadAssembly "Orien.Tools.dll" "Orien.Tools.McGetCs" 
	),
	_init = init()*/
	/*<end>*/
)	
 --create instance
Global mcDotnet = mcStructMan.instanceStructure MICRA_DOTNET "mcDotnet"




/*
mystring = DotNetObject "System.String" "my_string_literate"
mystring.split "_"





-- old wrapper > mcColorPaleteDialog.show(WindowWrapper)
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
