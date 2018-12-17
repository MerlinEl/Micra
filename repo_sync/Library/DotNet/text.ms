        
		mcs.lbl_lvl.bounds = netDrRect [form_size.x/2 - btn_size/2, bar_height+form_offset*2] [btn_size, btn_size]
		mcs.lbl_lvl.Text = "0"
		mcs.lbl_lvl.TextAlign = mcs.lbl_lvl.TextAlign.MiddleCenter --(dotnetClass "Drawing.ContentAlignment").MiddleCenter
		mcs.lbl_lvl.BackColor = netDrColor clr_back
		mcs.lbl_lvl.ForeColor = netDrColor clr_text


fn funnyText txt back: font: =
         (
         	fn colorByName name seed:0 val:1 =
         	(
         		local c
         		maxops.colorById (gethashvalue name seed) &c
         		c *= val
         		(dotnetclass "System.Drawing.Color").fromARGB c.r c.g c.b
         	)
         
         	temp = (dotNetClass "System.IO.Path").GetTempFileName()
         	
         	tr = dotnetclass "TextRenderer"	
         	tf = (dotnetclass "TextFormatFlags").NoPadding
         
         	xx = #(0)
         	ch = " "
         	sh = tr.MeasureText ch font
         	for k=1 to txt.count do
         	(
         		ss = tr.MeasureText (txt[k] + ch) font
         		append xx (xx[xx.count] + ss.width - sh.width)
         	)
         	
         	w = xx[xx.count]		-- text width
         	h = font.GetHeight()	-- text height
         	
         	bm = dotnetobject "System.Drawing.Bitmap" w h
         	gr = (dotnetclass "System.Drawing.Graphics").FromImage bm
         
         	clip = dotnetobject "System.Drawing.Rectangle" 0 0 0 bm.height
         
         	gr.Clear back
         	for k=1 to txt.count do
         	(
         		clip.x = xx[k]
         		clip.width = xx[k+1] - xx[k] 
         		fore = colorByName txt[k] seed:0 val:0.4
         		tr.DrawText gr txt[k] font clip fore back tf
         	)
         	gr.DrawImage bm (dotnetobject "System.Drawing.Rectangle" 0 0 bm.width bm.height)
         	
         	bm.Save temp (dotnetclass "System.Drawing.Imaging.ImageFormat").png
         	
         	gr.Dispose()
         	deletefile temp
         	bm
         )
         
         try(form.close()) catch()
         form = dotnetobject "form"--"MaxCustomControls.Maxform"
         form.Text = ".NET FunnyText"
         form.Size = dotnetobject "System.Drawing.Size" 500 100
         form.BackgroundImageLayout = form.BackgroundImageLayout.Center
         
         form.backgroundimage = funnyText "Tris: 8945 | Length: 56,7 cm | Heigth: 192,4 cm | Width: 164,78 cm | UV verts: 6372" \
         	font:(dotnetclass "SystemInformation").MenuFont \
         	back:
         	( 
         		c = 255*(colorman.getcolor #background as color)
         		(dotnetclass "System.Drawing.Color").fromARGB c.r c.g c.b
         	)
         
         form.show()--modeless()	
         