-- LoneRobot DotNetClass Color Chart

-- version:		0.2
-- max version:	2009
-- date 25th Nov 2008
-- author: Pete Addington
-- website: www.lonerobot.com

-- history:		24th Nov 2008 - created

	--		25th Nov - 
	--		Added copying to clipboard of dotnet string
	--		Added DotNet color dialog to pick color
	-- 		Added RGB swatches
	
-- email suggestions, comments to pete@lonerobot.com

global LR_DotNetColorPresetArray 

rollout ColorChart "LoneRobot DotNet Preset Color Chart" width:556 height:597
(
	local colorclass = dotnetclass "system.drawing.color"
	local ClipboardCache = dotnetclass "system.windows.forms.clipboard"
	local SystemColorPicker = dotnetobject "System.windows.forms.ColorDialog"
	
	dotNetControl flp "flowlayoutpanel" pos:[5,52] width:543 height:531	
	dotNetControl legend "textbox" pos:[5,4] width:543 height:20
	dotNetControl colorbutton "button" pos:[265,28] width:283 height:20
	dotNetControl Rlabel "label" pos:[6,28] width:84 height:20
	dotNetControl Glabel "label" pos:[92,28] width:84 height:20
	dotNetControl Blabel "label" pos:[178,28] width:84 height:20
		
	fn FnLabelPressed sender eventargs =
	(
		ClipboardCache.Clear()
		local stringdata
		legend.forecolor = sender.forecolor		
		legend.backcolor = if sender.text == "Transparent" then colorclass.white else sender.backcolor		
		if sender.backcolor.issystemcolor then stringdata = ("(DotNetClass \"System.Drawing.SystemColors\")." + sender.text)else stringdata = ("(DotNetClass \"System.Drawing.Color\")." + sender.text)			
		legend.text = stringdata
		SystemColorPicker.color = legend.backcolor
		
		Rlabel.text = "R :" +	(sender.backcolor.R as string)
		Glabel.text = "G :"+	(sender.backcolor.G as string)
		Blabel.text = "B :" + (sender.backcolor.B as string)
		
		Rlabel.backcolor = colorclass.fromargb sender.backcolor.R 0 0
		Glabel.backcolor = colorclass.fromargb 0  sender.backcolor.G 0
		Blabel.backcolor = colorclass.fromargb 0 0 sender.backcolor.B
		
		if (Rlabel.backcolor.GetBrightness()) < 0.3 do Rlabel.forecolor = colorclass.ivory	
		if (Glabel.backcolor.GetBrightness()) < 0.3 do Glabel.forecolor = colorclass.ivory	
		if (Blabel.backcolor.GetBrightness()) < 0.3 do Blabel.forecolor = colorclass.ivory	
				
		ClipboardCache.SetText stringdata
	)	
	
	on colorchart open do
	(	
	local singleborder = (dotNetClass "System.Windows.Forms.BorderStyle").fixedsingle	
	local dnfont = dotNetObject "System.Drawing.Font" "Verdana" 6.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnfontlarge = dotNetObject "System.Drawing.Font" "Verdana" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	local dnMXSlarge = dotNetObject "System.Drawing.Font" "System" 8.5 ((dotNetClass "System.Drawing.FontStyle").bold)
	
	systemcolorpicker.solidcoloronly = false
	systemcolorpicker.anycolor = true
	systemcolorpicker.allowfullopen = true
	systemcolorpicker.fullopen = true

	Rlabel.borderstyle= Glabel.borderstyle = Blabel.borderstyle = singleborder	
	Rlabel.font = Glabel.font = Blabel.font =  dnfontlarge
	Rlabel.text = "R :"		
	Glabel.text = "G :"		
	Blabel.text = "B :"		
	Rlabel.textalign = Glabel.textalign = Blabel.textalign =  (dotnetclass "System.Drawing.ContentAlignment").MiddleLeft	
	
	flp.autoscroll = true	
	flp.padding = dotnetobject "system.windows.forms.padding" 2	
	legend.borderstyle = flp.borderstyle = singleborder
	legend.text = "Pick a color - MaxScript code is automatically copied to the clipboard"
	legend.font = dnMXSlarge 
	legend.textalign =  (dotnetclass "System.Windows.Forms.HorizontalAlignment").center
	dnobjarray = #()		
	dnsyscolarray = #()		
	
	colorbutton.text = "Pick Color"
	colorbutton.flatstyle = (dotNetclass "System.Windows.Forms.FlatStyle").flat
		
	
	if LR_DotNetColorPresetArray == undefined do 
		(
			enumclass = dotnetclass "enum"
			LR_DotNetColorPresetArray = enumclass.GetNames (dotNet.getType "System.drawing.KnownColor")
		)
	
	for i in LR_DotNetColorPresetArray do
		(
		clabel = dotnetobject "button"
		clabel.flatstyle = (dotNetclass "System.Windows.Forms.FlatStyle").flat
		clabel.font= dnfont
		clabel.size = dotnetobject "system.drawing.size" 100 24
		labelbackcolor = colorclass.fromname i		
		clabel.backcolor = labelbackcolor
		clabel.margin =  dotnetobject "system.windows.forms.padding" 2
		clabel.text = i		
			
		dotNet.addEventHandler clabel "click" FnLabelPressed 
					
		if (labelbackcolor.GetBrightness()) < 0.3 do clabel.forecolor = colorclass.ivory			
		clabel.textalign =  (dotnetclass "System.Drawing.ContentAlignment").MiddleCenter				
			
		if labelbackcolor.issystemcolor then append dnsyscolarray clabel else append dnobjarray clabel
		clabel = nothing
		)	
	
	colorlabel = dotnetobject "label"
	Syslabel = dotnetobject "label"
		
	Syslabel.borderstyle = colorlabel.borderstyle = singleborder
	Syslabel.margin = colorlabel.margin =  dotnetobject "system.windows.forms.padding" 2
	Syslabel.backcolor =colorlabel.backcolor = colorclass.cadetblue
	Syslabel.font = colorlabel.font= dnfontlarge
	colorlabel.text = "Named Colors"			
	Syslabel.size = colorlabel.size = dotnetobject "system.drawing.size" 516 24	
	Syslabel.textalign = colorlabel.textalign =  (dotnetclass "System.Drawing.ContentAlignment").MiddleCenter		

	Syslabel.text = "System Colors"			
	
	flp.controls.add colorlabel		
	flp.controls.addrange dnobjarray			
	flp.controls.add syslabel		
	flp.controls.addrange dnsyscolarray	
		
	) -- end open

	on colorbutton click do
	(		
		 If SystemColorPicker.ShowDialog() == (dotnetclass "system.windows.forms.DialogResult").OK do
			(
			ClipboardCache.Clear()
			local stringdata
			local scol = SystemColorPicker.Color
			stringdata = ("(DotNetClass \"System.Drawing.Color\").fromARGB " + (scol.r as string) + " " + (scol.g as string)+ " " + (scol.b as string))	
			
			legend.backcolor = scol
				
			if (legend.backcolor.GetBrightness()) < 0.3 then legend.forecolor = colorclass.ivory else legend.forecolor = colorclass.black
			
			legend.text = stringdata
			ClipboardCache.SetText stringdata
				
			Rlabel.text = "R :" +	(scol .R as string)
			Glabel.text = "G :"+	(scol .G as string)
			Blabel.text = "B :" + (scol .B as string)
			
			Rlabel.backcolor = colorclass.fromargb scol.R 0 0
			Glabel.backcolor = colorclass.fromargb 0  scol.G 0
			Blabel.backcolor = colorclass.fromargb 0 0 scol.B
			
			if (Rlabel.backcolor.GetBrightness()) < 0.3 do Rlabel.forecolor = colorclass.ivory	
			if (Glabel.backcolor.GetBrightness()) < 0.3 do Glabel.forecolor = colorclass.ivory	
			if (Blabel.backcolor.GetBrightness()) < 0.3 do Blabel.forecolor = colorclass.ivory						
			)

	)
	
	
)-- end rollout
createdialog ColorChart style:#(#style_toolwindow, #style_sysmenu)

