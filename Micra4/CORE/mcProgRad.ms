--------------------------------------------------------------------------------
/* mcProgRad by Orien 2020 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcDotnet
	mcSystem
*
*@Used Objects

*
*@Example
	------------------------------------
	Close when finished >
	------------------------------------
	max_count = 500
	for i = 1 to max_count do (

		local percent = (100.*i/max_count) --or (100.0/max_count*i)
		mcProgRad.progressTo percent msg:"Processing..."
	)
	------------------------------------
	Stay visible when finished witn OK Button >
	------------------------------------
	max_count = 500
	for i = 1 to max_count do (

		local percent = (100.*i/max_count)
		mcProgRad.progressTo percent msg:"Processing..." confirm:true
	)
	------------------------------------
	Stay visible when finished without OK Button (last line will allow acces to OK button) >
	------------------------------------
	max_count = 500
	for i = 1 to max_count do (

		local percent = (100.*i/max_count)
		mcProgRad.progressTo percent msg:"Processing...please wait..." confirm:true showButton:false clr:green
	)
	--allow acces OK button after process is done
	mcProgRad.progressTo 100 msg:"Collapse Objects Is Finished!" confirm:true showButton:true clr:green
	------------------------------------
	Debug >
	------------------------------------
	mcProgRad.progressTo 0 msg:"..."
	mcProgRad.progressTo 45 msg:"Processing..."
	mcProgRad.progressTo 100 msg:"Processing Finished:"
	mcProgRad.progressTo 100 msg:"Processing...please wait..." confirm:true showButton:false clr:green
	mcProgRad.progressTo 100 msg:"Collapse Objects Is Finished!" confirm:true showButton:true clr:green
*/
Global mcProgRad
if isStruct mcProgRad do mcProgRad.closeForm()
struct MICRA_PROGRESSBAR_STRUCT (	
	
	form = dotNetObject "MaxCustomControls.MaxForm",
	canvas = dotNetObject  "System.Windows.Forms.PictureBox",
	lbl_title = dotnetObject "Label",
	lbl_info = dotnetObject "Label",
	btn_close= dotnetobject "Button",	
	font_button	= mcDotnet.dFont font:"Impact" size:20 style:"Regular",
	font_title	= mcDotnet.dFont font:"Arial" size:12 style:"Regular",
	font_percent= mcDotnet.dFont font:"Impact" size:30 style:"Regular",
	circ_bar	= undefined,
	bar_radius= 124,
	bar_thickness = 20,
	border_thickness = 4,
	transparent_color = mcDotnet.dColor (color 0 50 50),
	border_color = color 50 50 50,
	form_center = [0, 0],
	fn showForm modal:true = (

		local form = mcProgRad.form
		form.show(mcMicraDialog)
	),
	fn hideForm = (mcProgRad.form.hide()),
	fn closeForm = (mcProgRad.form.close()),
	fn onHideFormPressed s a = (
		
		mcProgRad.hideForm()
	),
	fn onFormPaint s a = (

		s.backColor = mcDotnet.dColor (color 0 50 50) --set form transparent
		--draw border
		local thickness = mcProgRad.border_thickness
		local clr = (dotNetClass "Drawing.Color").fromArgb 255 81 68
		local rect =  s.ClientRectangle --copy
		rect.Inflate -thickness -thickness --crop rect by line thickness
		local pen = dotnetobject  "Drawing.Pen" clr thickness
		a.Graphics.DrawRectangle pen rect
	),
	fn onTitlePaint s a = (
		
		local g = a.Graphics
		g.TextRenderingHint = g.TextRenderingHint.AntiAlias
		g.SmoothingMode = g.SmoothingMode.AntiAlias	
		local rect = s.ClientRectangle
		rect.X = rect.X + 1
        rect.Y = rect.Y + 1
        rect.Width -= 2
        rect.Height -= 2
		format "onTitlePaint > rect:%\n" rect
		/*
		local fillBrush = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor blue)
		local outLinePen =dotNetObject "system.drawing.pen" (mcDotnet.dColor black) 3	
		format "onTitlePaint > brush:%\n" fillBrush
		local graphic2D = dotNetobject "System.Drawing.Drawing2D.GraphicsPath"
-- 		graphic2D.AddRectangle rect
		------------------------------------------------
		string_text = "test"
		font_family =  dotNetObject "System.Drawing.FontFamily" "Arial Black"
		font_style = 1		
		font_size = 50
		startPoint = dotNetObject "system.drawing.point" 2 2		
		font_format = (dotNetclass "System.Drawing.StringFormat").GenericTypographic
		graphic2D.AddString string_text font_family font_style font_size startPoint font_format
		------------------------------------------------
		g.FillPath fillBrush graphic2D
		g.DrawPath outLinePen graphic2D		
		*/
-- 		local clr = (dotNetClass "Drawing.Color").fromArgb 255 81 68
-- 		local pen = dotnetobject  "Drawing.Pen" clr
-- 		g.DrawEllipse (mcDotnet.uiColor #back) rect
	),
	-- fn onFormShown s a = (
		
	-- ),
	fn drawProgressBar radius start_angle end_angle thickness:10 fill_clr:blue border_clr:black= (
	
		local brush_1 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor gray) --background
		local brush_2 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor fill_clr) --fill arc
		local brush_3 = dotNetObject "System.Drawing.SolidBrush" (mcDotnet.dColor border_clr) --border
		local pen_1 = dotNetObject "system.drawing.pen" brush_1 thickness  
		local pen_2 = dotNetObject "system.drawing.pen" brush_2 thickness  
		local pen_3 = dotNetObject "system.drawing.pen" brush_3 2  
		local bm = dotNetObject "System.Drawing.Bitmap" (radius*2) (radius*2)
		local g = mcDotnet.Graphics.FromImage bm 
		g.Clear(mcDotnet.dColor (color 0 50 50))
		-- g.Clear(mcDotnet.dColor blue)
		--set best quality
		g.InterpolationMode = g.InterpolationMode.HighQualityBilinear
		g.CompositingQuality = g.CompositingQuality.HighQuality
		g.PixelOffsetMode = g.PixelOffsetMode.HighQuality
		g.SmoothingMode = g.SmoothingMode.AntiAlias
		--Create rectangle to bound ellipse. (in ,out, center)
		local pos_1 = [thickness, thickness]/2 + 1
		local pos_2 = [1, 1]
		local pos_3 = [1, 1] + thickness
		local rect = mcDotnet.dRect pos_1 ([radius*2, radius*2] - thickness-2)
		local rect_out = mcDotnet.dRect pos_2 ([radius*2, radius*2]-2)
		local rect_in = mcDotnet.dRect pos_3 ([radius*2, radius*2]-2 - thickness*2)
	   --Draw arc to screen.
		g.DrawEllipse pen_1 rect --draw circle background
		pen_2.StartCap = mcDotnet.LineCap.Round
        pen_2.EndCap = mcDotnet.LineCap.Round
		g.DrawArc pen_2 rect start_angle end_angle --draw arc fill
		g.DrawEllipse pen_3 rect_out --draw outer border
		g.DrawEllipse pen_3 rect_in	--draw inner border
		bm
	),
	/**
	*@Usage
		percent		: number in range 1 - 100
		msg			: title message
		confirm		: will not close at end and display OK button
		showButton	: manage whwen is button ok accesible (if need delay before process finished use false)
		clr			: progressbar color
	*/
	fn progressTo percent msg:"Processing..." confirm:false showButton:true clr:green = (
	
		-- format "progressTo > percent:%\n" percent
		percent = mcMath.minMax percent 1 100 --min max value correction
		local start_angle = -90
		local end_angle = (360 / 100.0) * percent
		lbl_title.text = msg
		lbl_title.location = mcDotnet.dPoint (form_center - ([lbl_title.width, lbl_title.height] /2) - [0, bar_radius + 20] )
		lbl_info.text = int(percent) as string + "%"
		canvas.Image = drawProgressBar bar_radius  start_angle end_angle thickness:bar_thickness fill_clr:clr border_clr:border_color
		canvas.update()
		lbl_info.update()
		if not form.visible do (
			
			btn_close.visible = false
			showForm()
			form.backColor = transparent_color --remove form untransparent artefact
			form.update()
		)
		if percent == 100 do (

			if confirm then btn_close.visible = showButton else (sleep 0.3; hideForm())
		)
	),
	fn initForm = (
		
		local margins = 2
		local percent = 90
		local max_bounds = mcSystem.getMaxBounds()
		max_bounds.x += border_thickness + 1
		max_bounds.y += border_thickness + 1
		max_bounds.w -= border_thickness*2 - 2
		max_bounds.h -= border_thickness*2 - 2
		form_center = [max_bounds.x + max_bounds.w/2, max_bounds.y + max_bounds.h/2]
		form.ShowInTaskBar = false
		form.FormBorderStyle = form.FormBorderStyle.None
		form.StartPosition = form.StartPosition.Manual
		form.Location = mcDotnet.dPoint [max_bounds.x, max_bounds.y]
		form.Size = mcDotnet.dSize [max_bounds.w, max_bounds.h]
		form.AllowTransparency = true
		form.TransparencyKey = transparent_color
		form.opacity = 0.8
		
		lbl_title.text = "Loading..."
		lbl_title.name = "lbl_title"
		lbl_title.BorderStyle = lbl_title.BorderStyle.None
		lbl_title.textAlign = lbl_title.textAlign.MiddleCenter
		lbl_title.AutoSize = true
		lbl_title.font = font_title
		lbl_title.BackColor = mcDotnet.uiColor #back
		lbl_title.ForeColor = mcDotnet.uiColor #text
		lbl_title.location = mcDotnet.dPoint (form_center - ([lbl_title.width, lbl_title.height] /2) - [0, bar_radius + 20] )
-- 		lbl_title.backColor = transparent_color
		
		local canvas_size = bar_radius*2
		local canvas_center = form_center - canvas_size /2 
		canvas.BorderStyle = canvas.BorderStyle.None
		canvas.bounds = mcDotnet.dRect canvas_center [canvas_size, canvas_size]
		canvas.backColor = transparent_color
		canvas.Dock = canvas.Dock.None

		lbl_info.text = "100%"
		lbl_info.name = "lbl_title"
		lbl_info.AutoSize = false
		lbl_info.BorderStyle = lbl_info.BorderStyle.None
		lbl_info.textAlign = lbl_info.textAlign.MiddleCenter
		lbl_info.font = font_percent
		lbl_info.foreColor = mcDotnet.dColor (color 215 247 122)
		lbl_info.backColor = mcDotnet.dColor green
		lbl_info.backColor = transparent_color
		lbl_info.Size = mcDotnet.dSize [164, 58]
		lbl_info.location = mcDotnet.dPoint (form_center - [lbl_info.width, lbl_info.height] / 2)
		
		btn_close.text = "OK"
		btn_close.name = "btn_close"
		btn_close.font = font_button
		btn_close.foreColor = mcDotnet.dColor border_color
		btn_close.backColor = mcDotnet.dColor green
		btn_close.Bounds = mcDotnet.dRect [form_center.x-30, form_center.y+50] [60, 32]
		-- btn_close.backColor = transparent_color
		btn_close.visible = false
		btn_close.visible = true

		form.Controls.addrange #(lbl_info, lbl_title, btn_close, canvas)

		dotNet.addEventHandler form "Paint" onFormPaint
		dotNet.addEventHandler lbl_title "Paint" onTitlePaint
		-- dotNet.addEventHandler form "Shown" onFormShown
		dotNet.addEventHandler btn_close "MouseUp" onHideFormPressed
	),
	on create do (initForm())
)
mcProgRad = MICRA_PROGRESSBAR_STRUCT()
-- mcProgRad.progressTo 45 msg:"Processing..."


/*
        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            using (GraphicsPath graphicsPath = _getRoundRectangle(this.ClientRectangle))
            {
                e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                using (SolidBrush solidBrush = new SolidBrush(_BackColor))
                    e.Graphics.FillPath(solidBrush, graphicsPath);
                using (Pen pen = new Pen(_BackColor, 1.0f))
                    e.Graphics.DrawPath(pen, graphicsPath);
                TextRenderer.DrawText(e.Graphics, Text, this.Font, this.ClientRectangle, this.ForeColor);
            }
        }

        private GraphicsPath _getRoundRectangle(Rectangle rectangle)
        {
            int cornerRadius = 15;
            int diminisher = 1;
            GraphicsPath path = new GraphicsPath();
            path.AddArc(rectangle.X, rectangle.Y, cornerRadius, cornerRadius, 180, 90);
            path.AddArc(rectangle.X + rectangle.Width - cornerRadius - diminisher, rectangle.Y, cornerRadius, cornerRadius, 270, 90);
            path.AddArc(rectangle.X + rectangle.Width - cornerRadius - diminisher, rectangle.Y + rectangle.Height - cornerRadius - diminisher, cornerRadius, cornerRadius, 0, 90);
            path.AddArc(rectangle.X, rectangle.Y + rectangle.Height - cornerRadius - diminisher, cornerRadius, cornerRadius, 90, 90);
            path.CloseAllFigures();
            return path;
        }
*/


/*

protected override void OnPaint(PaintEventArgs e)
        {
            e.Graphics.InterpolationMode = InterpolationMode.HighQualityBilinear;
            e.Graphics.CompositingQuality = CompositingQuality.HighQuality;
            e.Graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
            e.Graphics.SmoothingMode = SmoothingMode.AntiAlias;

            LinearGradientBrush brush = new LinearGradientBrush(this.ClientRectangle, Color.Aqua, Color.Blue, 90);

            using (GraphicsPath gp = new GraphicsPath())
            {
                gp.AddArc(new Rectangle(new Point(0, 0), new Size(this.Height, this.Height)), 90, 180);
                gp.AddLine(new Point(this.Height / 2, 0), new Point(this.Width - (this.Height / 2), 0));
                gp.AddArc(new Rectangle(new Point(this.Width - this.Height, 0), new Size(this.Height, this.Height)), -90, 180);
                gp.CloseFigure();

                e.Graphics.FillPath(brush, gp);
            }

            base.OnPaint(e);
        }
*/