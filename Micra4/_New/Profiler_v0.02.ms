--source (shape) must be created from front
--target (rectangle) must be created from top



Global mc2DialogProfiler
try(mc2DialogProfiler.close())catch()
rollout mc2DialogProfiler "Spline Profiler:" width:332 height:274
(
	--locals
	local button_size = 128, top_offset = 10, diaSize = [324, button_size*4]
	local buttons_count = 0, minmax = [0,200]
	--items
	dotNetControl lp "flowlayoutpanel" pos:[4,24] width:324 height:260
	button btn_add "+" pos:[4,4] width:24 height:24
	button btn_del "-" pos:[32,4] width:24 height:24
	--functions
	fn netDrSize size     = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDrColor clr     = ((dotNetClass "Drawing.color").fromArgb clr.r clr.g clr.b)
	fn OnButtonClick send arg = 
	(
		format "send:%\targ:%\nbtn_name:%\tbtn_tag:%\n" send arg send.text send.tag
	)
	fn manageInterface size =
	(
		lp.width = size.x
		lp.height = size.y - top_offset 
	)
	fn maxImageToDotnet img =
	(
		setclipboardBitmap img
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
		if clipboardClass.containsimage() then clipboardClass.getImage()
	)
	fn renderToLibrary = with redraw off --rendered shape must be created from front view
	(
		
		local sel = selection[1]
		if classOf sel != SplineShape do return false
		local sp = copy sel
		addmodifier sp (extrude())
		sp.material = standardMaterial diffuseColor:gray
		old_view = viewport.getType()
		--old_tm = viewport.getTM()
		if old_view != #view_front do viewport.setType #view_front
		max zoomext sel
		select sp
		max hide inv
		local w = button_size, h = w - w/4
		local pic = render outputwidth:w outputheight:h vfb:off
		max undo
		delete sp 
		viewport.setType old_view
		--gw.setTransform old_tm
		--tg_draw.bitmap = pic
		select sel
		return (maxImageToDotnet pic)
	)
	fn generateButtons buttons_count =
	(
		lp.controls.clear()
		for i = 1 to buttons_count do
		(
			local btn = (dotNetObject "Button")
			btn.size = netDrSize [button_size, button_size]
			btn.flatstyle = (dotNetclass "FlatStyle").flat
			btn.margin =  dotnetobject "padding" 1
			btn.textalign =  (dotnetclass "Drawing.ContentAlignment").BottomCenter
			btn.image = renderToLibrary()
			--btn.Text = (i as integer) as string
			dotNet.addEventHandler btn "Click" OnButtonClick -- Setup an event handler for buttons
			lp.Controls.Add btn
		)
	)
	fn initializeInterface =
	(
		lp.backColor = netDrColor( orange ) --form Back Color
		lp.Padding = dotNetObject "Padding" 2 --panel left up offset
		lp.Top = top_offset
		lp.BorderStyle = (dotNetClass "BorderStyle").None	
		lp.width = diaSize.x
		lp.height = diaSize.y - top_offset 
		lp.AllowDrop = true
		lp.AutoSize = true
		lp.autoscroll = true
		generateButtons buttons_count
	)
	fn splineToScript sp =
	(
		if classOf sp != SplineShape do return false
		local SPLINE_DATA, VERTEX_DATA
		struct SPLINE_DATA (pos, steps, clr, splines, closed = #())
		struct VERTEX_DATA (pos, type, invec, outvec)
		local splines =#() --collect verts for each spline
		for s=1 to (numSplines sp) do --for all splines
		(
			local points_array = #()
			for v=1 to (numKnots sp s) do --for verts in current spline
			(
				points_array += #(VERTEX_DATA (getKnotPoint sp s v) (getKnotType sp s v) (getInVec sp s v) (getOutVec sp s v))
			)
			append splines points_array
		)
		local SD = SPLINE_DATA sp.pos sp.steps sp.wirecolor splines
		for s=1 to (numSplines sp) do SD.closed += #(isClosed sp s) -- collect if spline is closed
		return SD
	)
	fn scriptToSpline str =
	(
		local sps = SplineShape pos:str.pos wirecolor:str.clr --create spline
		for s=1 to str.splines.count do --for all splines
		(	
			addNewSpline sps
			--for verts in current spline
			for v in str.splines[s] do (addKnot sps s v.type #curve v.pos v.inVec v.OutVec)
			if str.closed[s] do close sps s
		)
		updateShape sps
		return sps
	)
	--actions
	on mc2DialogProfiler open do initializeInterface()
	on mc2DialogProfiler resized size do (manageInterface size)
	on btn_add pressed do (if buttons_count < minmax.y then generateButtons (buttons_count+=1))
	on btn_del pressed do (if buttons_count > minmax.x then generateButtons (buttons_count-=1))
)
createDialog mc2DialogProfiler  style:#(#style_titlebar, 
 #style_sysmenu, #style_minimizebox, #style_maximizebox, #style_sunkenedge, #style_resizing)
