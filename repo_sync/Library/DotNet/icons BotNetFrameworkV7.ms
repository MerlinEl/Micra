-- BotNet Framework v7

-- Feel free to add any methods you like!
-- email suggestions, comments to pete@lonerobot.com

-- at the moment all GDI button are designed for 24x24 square buttons. It wouldnt be too hard to adapt the code to 
-- reflect the client rectangle, this will perhaps be done in the future!

global BotNet, GDIplus

struct BotNetFramework (
--define some base classes to use in the struct
BNFcolor = dotnetclass "System.Drawing.Color",
BNFsize = dotnetclass "System.Drawing.Size",
BNFfont =dotnetclass "System.Drawing.Font",
BNFpoint =dotnetclass	"System.Drawing.Point",
BNFfontStyle = dotNetClass "System.Drawing.FontStyle"	,
	
BNFimageclass = dotNetclass "System.Drawing.image",
BNFimagelist = dotnetclass "System.Windows.Forms.ImageList",
	
BNFButton = dotNetclass "System.Windows.Forms.Button",
BNFLabel = dotNetclass "System.Windows.Forms.Label",
ButtonStyle = dotNetclass "System.Windows.Forms.FlatStyle",	

--BNFMaxIcon = dotnetobject "System.Drawing.Icon" (LRUIdir+"maxicon.ico"),
BNFBorderStyle = dotNetClass "System.Windows.Forms.BorderStyle",
BNFimage = dotNetclass "System.Drawing.image",

--alignment classes	
BNFalign = dotnetclass "System.Drawing.ContentAlignment",
-- #alignment options
--   .BottomCenter 
--   .BottomLeft 
--   .BottomRight 
--   .MiddleCenter 
--   .MiddleLeft 
--   .MiddleRight 
--   .TopCenter 
--   .TopLeft 
--   .TopRight 

BNFHorizalign = dotnetclass "System.Windows.Forms.HorizontalAlignment",
BNFLRalign =dotnetclass "System.Windows.Forms.LeftRightAlignment",

--scope variable for messagebox title and messagestring
msgboxtitle,
msgboxtext,
 	
fn colorpreset arg =
	(
		if classof arg == point3 then	
		(
			return BNFcolor.fromARGB 0 arg.x arg.y arg.z
		)			
		else
			(	
				case arg of
				(
				--	dotnet preset colors
					#AliceBlue : return BNFcolor.AliceBlue		
					#AntiqueWhite : return BNFcolor.AntiqueWhite
					#Aqua : return BNFcolor.Aqua 
					#Aquamarine : return BNFcolor.Aquamarine 
					#Azure : return BNFcolor.Azure
					#Beige : return BNFcolor.Beige
					#Bisque : return BNFcolor.Bisque
					#Black : return BNFcolor.Black 
					#BlanchedAlmond : return BNFcolor.BlanchedAlmond
					#Blue : return BNFcolor.Blue
					#BlueViolet : return BNFcolor.BlueViolet 
					#Brown : return BNFcolor.Brown
					#BurlyWood : return BNFcolor.BurlyWood
					#CadetBlue : return BNFcolor.CadetBlue
					#Chartreuse : return BNFcolor.Chartreuse
					#Chocolate : return BNFcolor.Chocolate
					#Coral : return BNFcolor.Coral
					#CornflowerBlue : return BNFcolor.CornflowerBlue
					#Cornsilk : return BNFcolor.Cornsilk
					#Crimson : return BNFcolor.Crimson
					#Cyan : return BNFcolor.Cyan
					#DarkBlue : return BNFcolor.DarkBlue
					#DarkCyan : return BNFcolor.DarkCyan 
					#DarkGoldenrod : return BNFcolor.DarkGoldenrod
					#DarkGray : return BNFcolor.DarkGray
					#DarkGreen : return BNFcolor.DarkGreen
					#DarkKhaki : return BNFcolor.DarkKhaki
					#DarkMagenta : return BNFcolor.DarkMagenta
					#DarkOliveGreen : return BNFcolor.DarkOliveGreen
					#DarkOrange : return BNFcolor.DarkOrange
					#DarkOrchid : return BNFcolor.DarkOrchid 
					#DarkRed : return BNFcolor.DarkRed
					#DarkSalmon : return BNFcolor.DarkSalmon
					#DarkSeaGreen : return BNFcolor.DarkSeaGreen
					#DarkSlateBlue : return BNFcolor.DarkSlateBlue
					#DarkSlateGray : return BNFcolor.DarkSlateGray
					#DarkTurquoise : return BNFcolor.DarkTurquoise 
					#DarkViolet : return BNFcolor.DarkViolet
					#DeepPink : return BNFcolor.DeepPink
					#DeepSkyBlue : return BNFcolor.DeepSkyBlue
					#DimGray : return BNFcolor.DimGray
					#DodgerBlue : return BNFcolor.DodgerBlue
					#Firebrick : return BNFcolor.Firebrick
					#FloralWhite : return BNFcolor.FloralWhite
					#ForestGreen : return BNFcolor.ForestGreen
					#Fuchsia : return BNFcolor.Fuchsia
					#Gainsboro : return BNFcolor.Gainsboro
					#GhostWhite : return BNFcolor.GhostWhite
					#Gold : return BNFcolor.Gold
					#Goldenrod : return BNFcolor.Goldenrod
					#Gray : return BNFcolor.Gray
					#Green : return BNFcolor.Green
					#GreenYellow : return BNFcolor.GreenYellow 
					#Honeydew : return BNFcolor.Honeydew 
					#HotPink : return BNFcolor.HotPink
					#IndianRed : return BNFcolor.IndianRed
					#Indigo : return BNFcolor.Indigo
					#Ivory : return BNFcolor.Ivory 
					#Khaki : return BNFcolor.Khaki
					#Lavender : return BNFcolor.Lavender
					#LavenderBlush : return BNFcolor.LavenderBlush
					#LawnGreen : return BNFcolor.LawnGreen
					#LemonChiffon : return BNFcolor.LemonChiffon
					#LightBlue : return BNFcolor.LightBlue 
					#LightCoral : return BNFcolor.LightCoral
					#LightCyan : return BNFcolor.LightCyan
					#LightGoldenrodYellow : return BNFcolor.LightGoldenrodYellow
					#LightGray : return BNFcolor.LightGray
					#LightGreen : return BNFcolor.LightGreen
					#LightPink : return BNFcolor.LightPink
					#LightSalmon : return BNFcolor.LightSalmon
					#LightSeaGreen : return BNFcolor.LightSeaGreen
					#LightSkyBlue : return BNFcolor.LightSkyBlue
					#LightSlateGray : return BNFcolor.LightSlateGray 
					#LightSteelBlue : return BNFcolor.LightSteelBlue 
					#LightYellow : return BNFcolor.LightYellow
					#Lime : return BNFcolor.Lime
					#LimeGreen : return BNFcolor.LimeGreen
					#Linen : return BNFcolor.Linen
					#Magenta : return BNFcolor.Magenta
					#Maroon : return BNFcolor.Maroon
					#MediumAquamarine : return BNFcolor.MediumAquamarine 
					#MediumBlue : return BNFcolor.MediumBlue
					#MediumOrchid : return BNFcolor.MediumOrchid
					#MediumPurple : return BNFcolor.MediumPurple
					#MediumSeaGreen : return BNFcolor.MediumSeaGreen
					#MediumSlateBlue : return BNFcolor.MediumSlateBlue
					#MediumSpringGreen : return BNFcolor.MediumSpringGreen
					#MediumTurquoise : return BNFcolor.MediumTurquoise
					#MediumVioletRed : return BNFcolor.MediumVioletRed 
					#MidnightBlue : return BNFcolor.MidnightBlue 
					#MintCream : return BNFcolor.MintCream
					#MistyRose : return BNFcolor.MistyRose
					#Moccasin : return BNFcolor.Moccasin
					#NavajoWhite : return BNFcolor.NavajoWhite
					#Navy : return BNFcolor.Navy
					#OldLace : return BNFcolor.OldLace
					#Olive : return BNFcolor.Olive
					#OliveDrab : return BNFcolor.OliveDrab
					#Orange : return BNFcolor.Orange
					#OrangeRed : return BNFcolor.OrangeRed 
					#Orchid : return BNFcolor.Orchid
					#PaleGoldenrod : return BNFcolor.PaleGoldenrod
					#PaleGreen : return BNFcolor.PaleGreen
					#PaleTurquoise : return BNFcolor.PaleTurquoise
					#PaleVioletRed : return BNFcolor.PaleVioletRed 
					#PapayaWhip : return BNFcolor.PapayaWhip
					#PeachPuff : return BNFcolor.PeachPuff 
					#Peru : return BNFcolor.Peru
					#Pink : return BNFcolor.Pink 
					#Plum : return BNFcolor.Plum
					#PowderBlue : return BNFcolor.PowderBlue
					#Purple : return BNFcolor.Purple 
					#Red : return BNFcolor.Red
					#RosyBrown : return BNFcolor.RosyBrown
					#RoyalBlue : return BNFcolor.RoyalBlue 
					#SaddleBrown : return BNFcolor.SaddleBrown 
					#Salmon : return BNFcolor.Salmon
					#SandyBrown : return BNFcolor.SandyBrown
					#SeaGreen : return BNFcolor.SeaGreen
					#SeaShell : return BNFcolor.SeaShell
					#Sienna : return BNFcolor.Sienna
					#Silver : return BNFcolor.Silver
					#SkyBlue : return BNFcolor.SkyBlue
					#SlateBlue : return BNFcolor.SlateBlue
					#SlateGray : return BNFcolor.SlateGray
					#Snow : return BNFcolor.Snow
					#SpringGreen : return BNFcolor.SpringGreen
					#SteelBlue : return BNFcolor.SteelBlue
					#Tan : return BNFcolor.Tan
					#Teal : return BNFcolor.Teal
					#Thistle : return BNFcolor.Thistle
					#Tomato : return BNFcolor.Tomato
					#Transparent : return BNFcolor.Transparent
					#Turquoise : return BNFcolor.Turquoise
					#Violet : return BNFcolor.Violet
					#Wheat : return BNFcolor.Wheat
					#White : return BNFcolor.White
					#WhiteSmoke : return BNFcolor.WhiteSmoke
					#Yellow : return BNFcolor.Yellow
					#YellowGreen : return BNFcolor.YellowGreen	
					---- max UI colors as dotnet colors					
					#maxactive :(local maxforecolor = colorMan.getColor #activeCommand;return BNFcolor.FromArgb (maxForeColor[1] * 255.0f) (maxForeColor[2] * 255.0f) (maxForeColor[3] * 255.0f))					
					#maxback:(local maxbackcolor = colorMan.getColor #background;return BNFcolor.FromArgb (maxBackColor[1] * 255.0f) (maxBackColor[2] * 255.0f) (maxBackColor[3] * 255.0f))
					#maxfore :(local maxforecolor = colorMan.getColor #text;return BNFcolor.FromArgb (maxForeColor[1] * 255.0f) (maxForeColor[2] * 255.0f) (maxForeColor[3] * 255.0f))					
					#LoneRobot :(return BNFcolor.FromArgb 52 101 51)				
					default:return undefined
				)				
			)			
	),
	
-- font functions	
-- returns a font object in system style. Sometimes on smaller buttons Verdana (my prefered choice) is too small to read or does not fit. 
fn Systemfont size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "System" size BNFfontStyle.regular 	
return dnfont
),

-- returns a font object in Verdana style. I just like this font on UI's!
fn UIfont size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "Verdana" size BNFfontStyle.regular 	
return dnfont
),

-- returns a bold font object in system style. Sometimes on smaller buttons Verdana (my prefered choice) is too small to read or does not fit. 
fn SystemfontBold size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "System" size BNFfontStyle.bold	
return dnfont
),

-- returns a bold font object in Verdana style. I just like this font on UI's!
fn UIfontBold size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "Verdana" size BNFfontStyle.bold
return dnfont
),

-- returns an italic font object in system style. Sometimes on smaller buttons Verdana (my prefered choice) is too small to read or does not fit. 
fn SystemfontItalic size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "System" size BNFfontStyle.italic 	
return dnfont
),


-- returns an italic font object in Verdana style. I just like this font on UI's!
fn UIfontItalic size = 
(
local dnfont = dotNetObject "System.Drawing.Font" "Verdana" size BNFfontStyle.italic	
return dnfont
),

-- returns a border sylte for controls supporting this like labels
fn border arg =
(
	case arg of
	(
		#single:return BNFBorderStyle.fixedsingle		
		#3d:return BNFBorderStyle.fixed3d
		#none: return BNFBorderStyle.none
		default:return BNFBorderStyle.none
	)
	
),

fn label dnobject text fontsize edgestyle bgcolor alignment fontcolor:undefined=
(
		dnobject.text = text	
		dnobject.font = uifont fontsize
		If fontcolor != undefined then dnobject.forecolor = colorpreset fontcolor else dnobject.forecolor = colorpreset #black
		dnobject.borderstyle  = border edgestyle
		dnobject.backcolor = colorpreset bgcolor
		dnobject.textalign = alignment 
),
	
fn FontStyleRegular font size = 
	(
	),

fn FontStyleBold font size =
	(
	),
	
fn imagelist imagefile invisible:undefined =
	-- invisible is a variable holding a botnet color preset that the image list will use as a matte 
	(		 	
	--load the dotnet image
	BNFimage = dotNetclass "System.Drawing.image"
	IListimage = BNFimage.fromfile imagefile
	--construct the imagelist
	BNFimglist = dotnetobject "System.Windows.Forms.ImageList"
	BNFimglist.imagesize =  dotnetobject "System.Drawing.Size" IListimage.width IListimage.height
	BNFimglist.TransparentColor = colorpreset invisible
	BNFimglist.images.add Ilistimage		
	--if invisible != undefined do 

	return BNFimglist
	),
		
fn Button btn btntext fontsize style bgcolor mobg mdbg fontcolor:undefined =
	(
	btn.text = btntext
	btn.font = SystemFont fontsize
	If fontcolor != undefined then btn.forecolor = colorpreset fontcolor else btn.forecolor = colorpreset #maxfore
	btn.backcolor = colorpreset bgcolor
	btn.flatstyle = style
	btn.FlatAppearance.MouseOverBackColor = colorpreset mobg
	btn.FlatAppearance.MouseDownBackColor = colorpreset mdbg	
	),
	
	-- same as image button but with text property and text align.	
fn imagetextbutton btn btntext fontsize image style bgcolor mobg mdbg tcolor:undefined fontcolor:undefined textalignment:undefined imagealignment:undefined=
	(
	btn.text = btntext
	btn.font = SystemFont fontsize
	If fontcolor != undefined then btn.forecolor = colorpreset fontcolor else btn.forecolor = colorpreset #maxfore
	if textalignment !=undefined then btn.textalign = textalignment else btn.textalign = bnfalign.MiddleCenter		
	if imagealignment !=undefined then btn.imagealign = imagealignment else btn.imagealign = bnfalign.MiddleCenter				
	btn.backcolor = colorpreset bgcolor
	btn.flatstyle = style
	btn.FlatAppearance.MouseOverBackColor = colorpreset mobg
	btn.FlatAppearance.MouseDownBackColor = colorpreset mdbg	
	if tcolor != undefined then (btn.imagelist = (imagelist image invisible:tcolor)) else (btn.imagelist =(imagelist image))
	btn.imageindex = 0
	image = nothing		
	),
	
fn imagebutton btn image style bgcolor mobg mdbg tcolor:undefined = 
	-- tcolor is transparent color to be passed to the imagelist
	(
	btn.backcolor = colorpreset bgcolor
	btn.flatstyle = style
	btn.FlatAppearance.MouseOverBackColor = colorpreset mobg
	btn.FlatAppearance.MouseDownBackColor = colorpreset mdbg	
	if tcolor != undefined then (btn.imagelist = (imagelist image invisible:tcolor)) else (btn.imagelist =(imagelist image))
	btn.imageindex = 0	
	image = nothing
	),
	
fn Spinner spn text font edgestyle style fgcolor bgcolor dp:0 =
	(
		spn.borderstyle  = border edgestyle
		spn.ForeColor  = colorpreset fgcolor
		spn.BackColor  = colorpreset bgcolor
		spn.DecimalPlaces = dp		
		spn.textalign = (BNFHorizalign).center
	),
	
fn Messagebox title stringtext =
	(	
	msgboxtitle = title
	msgboxtext	= stringtext		
					
		rollout CustomMessageBox "" width:288 height:186
		(
			dotNetControl msgleg "label" pos:[8,87] width:270 height:63
			dotNetControl msgpanel "label" pos:[3,2] width:221 height:70
			dotNetControl msglrlogo "label" pos:[222,2] width:62 height:70
			dotNetControl msgok "button" pos:[222,155] width:62 height:27		
			dotNetControl labelsep "label" pos:[3,72] width:281 height:13
			
			on CustomMessageBox open do
			(
				BNFimage = dotNetclass "System.Drawing.image"
				Msglrlogo.image =  BNFimage.fromfile ((getdir #scripts) + "\\LRlogo.bmp")
				Botnet.label msglrlogo "" 7 #none #lonerobot botnet.bnfalign.MiddleCenter
				Botnet.label msgleg msgboxtext 8 #none #maxback botnet.bnfalign.Middleleft
				Botnet.label msgpanel msgboxtitle  8 #none #lonerobot  botnet.bnfalign.Middleleft fontcolor:#white
				BotNet.button msgok "OK" 9 flat #maxback #maxactive #crimson
				Botnet.label labelsep "" 7 #single #white botnet.bnfalign.MiddleCenter
			)
			on msgok click do
			(
				msgboxtitle = undefined
				msgboxtext	= undefined		
				destroydialog CustomMessageBox
			)
		)	
	createdialog CustomMessageBox modal:true style:#(#style_toolwindow, #style_sysmenu)
	),
	
GDI = GDIplus()
	
	
	
	
)

Struct GDIplus (
	
--	Path = dotnetclass "System.Drawing.Drawing2D.GraphicsPath",	
	
	--brushes	
--	SolidBrush = dotnetclass "System.Drawing.SolidBrush",
--	HatchBrush = dotnetclass "System.Drawing.Drawing2D.HatchBrush",
--	GradientBrush = dotnetclass "System.Drawing.Drawing2D.LinearGradientBrush",	
	
--	GradientMode = dotnetclass "System.Drawing.Drawing2D.LinearGradientMode",	
	
	-- pens
--	Pen = dotnetclass "System.Drawing.Pen",
	
	--line methods
	
	--LineJoin = dotnetclass "System.Drawing.Drawing2D.LineJoin",
	--  .Bevel
	--  .Round
	--  .Miter 
	--  .MiterClipped 
	
	--TextRender = dotnetclass "System.Drawing.Text.TextRenderingHint",
	-- 	.AntiAlias 
	--   .AntiAliasGridFit 
	--   .ClearTypeGridFit 
	--   .SingleBitPerPixel
	--   .SingleBitPerPixelGridFit 
	--   .SystemDefault 
	
--	smoothingmode = dotnetclass "System.Drawing.Drawing2D.SmoothingMode",
	--   .AntiAlias 
	--   .Default 
	--   .HighQuality 
	--   .HighSpeed 
	--   .Invalid 
	--   .None 

mapped fn dispose gdiobjs =
		(
			gdiobjs.Dispose
			--print (gdiobjs as string + " Disposed")
		),
		
fn Rectangle p1 p2 p3 p4 = 
(
local rectobj = dotnetobject "System.Drawing.Rectangle" p1 p2 p3 p4
return rectobj
),
		
fn minus paintargs outline fill =
	(	
	
	RectBrush =  dotnetobject "System.Drawing.SolidBrush"  (botnet.colorpreset fill)
    RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
	RectObj = dotnetobject "System.Drawing.Rectangle" 2 8 20 8
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
	RectPen.LineJoin = (dotnetclass "System.Drawing.Drawing2D.LineJoin").MiterClipped	
	GdiIcon = paintargs.graphics		
	GdiIcon.FillRectangle RectBrush RectObj
	GdiIcon.DrawRectangle RectPen RectObj
	gdiplus.dispose #(Rectbrush,rectpen)
	),
	
	
	fn squares paintargs outline fill = 
	(
	RectBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)
    RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 1	
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
	RectObj1 = botnet.GDI.rectangle 13 13 8 8 ;RectObj2 = botnet.GDI.rectangle 3 13 8 8   ;RectObj3 = botnet.GDI.rectangle 3 3 8 8  ;RectObj4 = botnet.GDI.rectangle 13 3 8 8
	GdiIcon = paintargs.graphics		
	GdiIcon.FillRectangle RectBrush RectObj1	;	GdiIcon.FillRectangle RectBrush RectObj2	;	GdiIcon.FillRectangle RectBrush RectObj3	;	GdiIcon.FillRectangle RectBrush RectObj4;	GdiIcon.DrawRectangle RectPen RectObj2
	GdiIcon.DrawRectangle RectPen RectObj1;	GdiIcon.DrawRectangle RectPen RectObj3;	GdiIcon.DrawRectangle RectPen RectObj4
	gdiplus.dispose #(Rectbrush,rectpen)
		
	),
	
fn square paintargs outline fill diamond:undefined= 
	(
	RectBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)
    RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
	GdiIcon = paintargs.graphics		
		
		if diamond == undefined then
		(	
		RectObj1 = botnet.GDI.rectangle 3 3 19 19		
		GdiIcon.FillRectangle RectBrush RectObj1	
		GdiIcon.DrawRectangle RectPen RectObj1
		)
			else
			(
				RectObj1 = botnet.GDI.rectangle 3 3 17 17
				aa = dotnetclass "System.Drawing.Drawing2D.SmoothingMode"
				GdiIcon.SmoothingMode = aa.Antialias
				GDiIcon.RotateTransform 45
				GDiIcon.TranslateTransform 5 -12
				GdiIcon.FillRectangle RectBrush RectObj1	
				GdiIcon.DrawRectangle RectPen RectObj1
			)
	gdiplus.dispose #(rectbrush,rectpen)		
	),
	
fn AxisX paintargs outline = 
	(
	RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 3
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset	
	RectPen.StartCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	RectPen.EndCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	GdiIcon = paintargs.graphics	
	GdiIcon.SmoothingMode = (dotnetclass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
--	GdiIcon.TextRenderingHint = (dotnetclass "System.Drawing.Text.TextRenderingHint").AntiAlias			
	GDiIcon.drawline rectpen 12 1 12 23	
	gdiplus.dispose #(rectpen)		
	),
	
fn AxisY paintargs outline = 
	(
	RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 3
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset	
	RectPen.StartCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	RectPen.EndCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	GdiIcon = paintargs.graphics	
	GdiIcon.SmoothingMode = (dotnetclass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
--	GdiIcon.TextRenderingHint = (dotnetclass "System.Drawing.Text.TextRenderingHint").AntiAlias			
	GDiIcon.drawline rectpen 1 12 23 12
	gdiplus.dispose #(rectpen)		
	),
	
fn AxisXY paintargs outline = 
	(
	RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 3
	RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset	
	RectPen.StartCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	RectPen.EndCap = (dotnetclass "System.Drawing.Drawing2D.LineCap").ArrowAnchor
	GdiIcon = paintargs.graphics	
	GdiIcon.SmoothingMode = (dotnetclass "System.Drawing.Drawing2D.SmoothingMode").AntiAlias
--	GdiIcon.TextRenderingHint = (dotnetclass "System.Drawing.Text.TextRenderingHint").AntiAlias			
	GDiIcon.drawline rectpen 12 1 12 23	
	GDiIcon.drawline rectpen 1 12 23 12
	gdiplus.dispose #(rectpen)		
	),
	
fn script paintargs outline fill innerlinecolor =
	(
		PointClass = dotnetclass "System.drawing.point"
		ByteClass = dotNetclass "System.byte" 
		PaintBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)		
		PaintPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2		
		LinePen1 = dotnetobject "System.Drawing.Pen" (botnet.colorpreset innerlinecolor) 1
		LinePen2 = dotnetobject "System.Drawing.Pen" (botnet.colorpreset innerlinecolor) 1
		LinePen3 = dotnetobject "System.Drawing.Pen" (botnet.colorpreset innerlinecolor) 1
		LinePen4 = dotnetobject "System.Drawing.Pen" (botnet.colorpreset innerlinecolor) 1	
		DStyle = dotnetclass "System.Drawing.Drawing2D.DashStyle"		
 		LinePen1.DashStyle = DStyle.DashDot
        LinePen2.DashStyle = DStyle.Dot
        LinePen3.DashStyle = DStyle.Dash
		LinePen4.dashstyle = Dstyle.solid
		
		PaintPen.LineJoin = (dotnetclass "System.Drawing.Drawing2D.LineJoin").miterclipped
		PaintPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
		
		PlusGDIArray = dotNetObject "System.drawing.point[]" 5
		ByteArray = dotNetObject "System.byte[]" 5
		local pointloop = #((pt1 = dotNetObject PointClass  5 3),(pt2= dotNetObject PointClass  18 3),(pt3= dotNetObject PointClass  21 7),(pt4 = dotNetObject PointClass  21 22),(pt5 = dotNetObject PointClass  5 22))
		
		--for i = 1 to pointloop.count do PlusGDIArray.setvalue pointloop[i] (dotNetObject "System.Int32"(i-1))	
		PlusGDIArray = dotNetArray pointloop byte:true
		
		local byteloop = #((Byte1 = dotNetObject ByteClass 0),(Byte2= dotNetObject ByteClass 1),(Byte3= dotNetObject ByteClass 1),(Byte4 = dotNetObject ByteClass 1),(Byte5 = dotNetObject ByteClass 129))
		
		--for i = 1 to byteloop.count do ByteArray.setvalue Byteloop[i] (dotNetObject "System.Int32"(i-1))
		ByteArray =  dotNetArray Byteloop byte:true
		
		ClosedPath = dotnetobject "System.Drawing.Drawing2D.GraphicsPath" PlusGDIArray ByteArray
		GdiIcon = paintargs.graphics	

		GdiIcon.FillPath PaintBrush ClosedPath
		GdiIcon.DrawPath PaintPen ClosedPath		  
		GdiIcon.DrawLine LinePen1 (dotNetObject PointClass  8 10) (dotNetObject PointClass  18 10) 
        GdiIcon.DrawLine LinePen2 (dotNetObject PointClass  8 14) (dotNetObject PointClass  18 14) 
        GdiIcon.DrawLine LinePen3 (dotNetObject PointClass  8 18) (dotNetObject PointClass  18 18) 
		
		GdiIcon.DrawLine LinePen4 (dotNetObject PointClass  8 16) (dotNetObject PointClass  17 16) 
		GdiIcon.DrawLine LinePen4 (dotNetObject PointClass  8 12) (dotNetObject PointClass  17 12) 
		GdiIcon.DrawLine LinePen4 (dotNetObject PointClass  8 16) (dotNetObject PointClass  17 16) 
		GdiIcon.DrawLine LinePen4 (dotNetObject PointClass  8 16) (dotNetObject PointClass  17 16) 

		gdiplus.dispose #(paintbrush,paintpen,linepen1,linepen2,linepen3,linepen4)

),
	
fn marquee paintargs outline fill = 
	(
		RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
		Rectpen.dashstyle = (dotnetclass "System.Drawing.Drawing2D.DashStyle").Dash
		RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
		RectObj1 = botnet.GDI.rectangle 3 3 19 19
		GdiIcon = paintargs.graphics		
		GdiIcon.DrawRectangle RectPen RectObj1
		gdiplus.dispose #(rectpen)		
	),
	
fn DrawString paintargs outline fill stringvalue = 
	(
		local x
		local y		
		
		if stringvalue < 10 then
		(		
		StringFont = dotnetobject "System.Drawing.Font" "Verdana" 12 ((dotnetclass "System.Drawing.FontStyle").bold) ((dotnetclass "System.Drawing.GraphicsUnit").Point) 0
		x = 4
		y = 2
	)
	else
	(
			
		StringFont = dotnetobject "System.Drawing.Font" "Verdana" 7. ((dotnetclass "System.Drawing.FontStyle").bold) ((dotnetclass "System.Drawing.GraphicsUnit").Point) 0
		
		x = 4
		y = 7
	)
	
		RectBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)
		TextBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset outline)
		RectPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
		RectPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
		RectObj1 = botnet.GDI.rectangle 3 3 19 19
		
		GdiIcon = paintargs.graphics	
		GdiIcon.TextRenderingHint = (dotnetclass "System.Drawing.Text.TextRenderingHint").AntiAlias			

		GdiIcon.FillRectangle RectBrush RectObj1	
		GdiIcon.DrawRectangle RectPen RectObj1
		Gdiicon.DrawString (dotnetobject "System.String" (stringvalue as string)) StringFont TextBrush x y	
		
		gdiplus.dispose #(rectpen,rectbrush)		
	),
	
	
fn plus paintargs outline fill cross:undefined=
	(
		PointClass = dotnetclass "System.drawing.point"
		ByteClass = dotNetclass "System.byte" 
		PaintBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)
		PaintPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
		PaintPen.LineJoin = (dotnetclass "System.Drawing.Drawing2D.LineJoin").miterclipped
		PaintPen.alignment = (dotnetclass"System.Drawing.Drawing2D.PenAlignment").inset
		PlusGDIArray = dotNetObject "System.drawing.point[]" 12
		ByteArray = dotNetObject "System.byte[]" 12
		local pointloop = #((pt1 = dotNetObject PointClass  8 2),(pt2= dotNetObject PointClass  8 8),(pt3= dotNetObject PointClass  2 8),(pt4 = dotNetObject PointClass  2 16),(pt5 = dotNetObject PointClass  8 16),(pt6 = dotNetObject PointClass  8 22),(pt7= dotNetObject PointClass  16 22),(pt8 = dotNetObject PointClass  16 16),(pt9 = dotNetObject PointClass  22 16),(pt10 = dotNetObject PointClass  22 8),(pt11 = dotNetObject PointClass  16 8),(pt12 = dotNetObject PointClass  16 2))
		
		--for i = 1 to pointloop.count do PlusGDIArray.setvalue pointloop[i] (dotNetObject "System.Int32"(i-1))	
		PlusGDIArray = dotNetArray pointloop byte:true
		
		local byteloop = #((Byte1 = dotNetObject ByteClass 0),(Byte2= dotNetObject ByteClass 1),(Byte3= dotNetObject ByteClass 1),(Byte4 = dotNetObject ByteClass 1),(Byte5 = dotNetObject ByteClass 1),(
		Byte6 = dotNetObject ByteClass 1),(Byte7= dotNetObject ByteClass 1),(Byte8 = dotNetObject ByteClass 1),(Byte9 = dotNetObject ByteClass 1),(Byte10 = dotNetObject ByteClass 1),(Byte11 = dotNetObject ByteClass 1),(Byte12 = dotNetObject ByteClass 129))
		
		--for i = 1 to byteloop.count do ByteArray.setvalue Byteloop[i] (dotNetObject "System.Int32"(i-1))
		ByteArray =  dotNetArray Byteloop byte:true
		
		ClosedPath = dotnetobject "System.Drawing.Drawing2D.GraphicsPath" PlusGDIArray ByteArray
		GdiIcon = paintargs.graphics	

		if cross == true do ((GDiIcon.RotateTransform 45);(GDiIcon.TranslateTransform 5 -12))
					
		GdiIcon.FillPath PaintBrush ClosedPath
		GdiIcon.DrawPath PaintPen ClosedPath
		gdiplus.dispose #(paintbrush,paintpen)

),

fn arrow paintargs outline fill angle:undefined = 
	(
		Pointclass = dotnetclass "System.drawing.point"
		ByteClass = dotNetclass "System.Byte"
		PaintBrush = dotnetobject "System.Drawing.SolidBrush" (botnet.colorpreset fill)
		PaintPen = dotnetobject "System.Drawing.Pen" (botnet.colorpreset outline) 2
		PaintPen.LineJoin = (dotnetclass "System.Drawing.Drawing2D.LineJoin").miter
		PlusGDIArray = dotNetObject "System.drawing.point[]" 7
		ByteArray = dotNetObject "System.byte[]" 7
		local pointloop = #((pt1 = dotNetObject pointclass 12 2),(pt2= dotNetObject PointClass  3 13),(pt3= dotNetObject PointClass  7 13),(pt4 = dotNetObject PointClass  7 22),(pt5 = dotNetObject PointClass  17 22),(pt6 = dotNetObject PointClass  17 13),(pt7= dotNetObject PointClass  21 13))	
		
		--for i = 1 to pointloop.count do PlusGDIArray.setvalue pointloop[i] (dotNetObject "System.Int32"(i-1))
		PlusGDIArray = dotNetArray pointloop byte:true
		
		local byteloop = #((Byte1 = dotNetObject ByteClass  0),(Byte2= dotNetObject ByteClass  1),(Byte3= dotNetObject ByteClass  1),(Byte4 = dotNetObject ByteClass  1),(Byte5 = dotNetObject ByteClass  1),(
		Byte6 = dotNetObject ByteClass  1),(Byte7= dotNetObject ByteClass  129))
		
		--for i = 1 to byteloop.count do ByteArray.setvalue Byteloop[i] (dotNetObject "System.Int32"(i-1))
		ByteArray =  dotNetArray Byteloop byte:true
		
		ClosedPath = dotnetobject "System.Drawing.Drawing2D.GraphicsPath" PlusGDIArray ByteArray
		GdiIcon = paintargs.graphics	
		aa = dotnetclass "System.Drawing.Drawing2D.SmoothingMode"
		
		if angle != undefined do
			(
				case angle of
				(
				45:((GDiIcon.RotateTransform 45);(GDiIcon.TranslateTransform 5 -14))
				90:((GDiIcon.RotateTransform 90);(GDiIcon.TranslateTransform 0 -24))
				135:((GDiIcon.RotateTransform 135);(GDiIcon.TranslateTransform -12 -30))
				180:((GDiIcon.RotateTransform 180);(GDiIcon.TranslateTransform -24 -24))
				215:((GDiIcon.RotateTransform 215);(GDiIcon.TranslateTransform -28 -16))
				270:((GDiIcon.RotateTransform 270);(GDiIcon.TranslateTransform -24 0 ))
				315:((GDiIcon.RotateTransform 315);(GDiIcon.TranslateTransform -12 5))		
				default:undefined			
				)
			)
					
			GdiIcon.SmoothingMode = aa.Antialias
			GdiIcon.FillPath PaintBrush ClosedPath
			GdiIcon.DrawPath PaintPen ClosedPath
			gdiplus.dispose #(paintbrush,paintpen)
	),
	
fn UItest = 
(
		rollout DNimagebuttons "BotNet.Framework.Icons()" width:302 height:201
	(
		dotNetControl cust22 "button" pos:[5,18] width:24 height:24
		dotNetControl cust23 "button" pos:[33,18] width:25 height:25
		dotNetControl cust24 "button" pos:[62,18] width:25 height:25
		dotNetControl custTM "button" pos:[137,22] width:25 height:25
		dotNetControl custBL "button" pos:[109,76] width:25 height:25
		dotNetControl custTR "button" pos:[164,22] width:25 height:25
		dotNetControl custML "button" pos:[109,48] width:25 height:25
		dotNetControl custC "button" pos:[137,48] width:25 height:25
		dotNetControl custMR "button" pos:[164,48] width:25 height:25
		dotNetControl custMarqSq "button" pos:[62,111] width:25 height:25
		dotNetControl custBM "button" pos:[137,76] width:25 height:25
		dotNetControl cust43 "button" pos:[5,111] width:25 height:25
		dotNetControl custTL "button" pos:[109,22] width:25 height:25
		dotNetControl custBR "button" pos:[164,76] width:25 height:25
		dotNetControl cust124 "button" pos:[138,113] width:25 height:25
		dotNetControl cust125 "button" pos:[110,167] width:25 height:25
		dotNetControl cust126 "button" pos:[165,113] width:25 height:25
		dotNetControl cust127 "button" pos:[110,139] width:25 height:25
		dotNetControl custD "button" pos:[138,139] width:25 height:25
		dotNetControl cust129 "button" pos:[165,139] width:25 height:25
		dotNetControl cust130 "button" pos:[138,167] width:25 height:25
		dotNetControl cust131 "button" pos:[110,113] width:25 height:25
		dotNetControl cust132 "button" pos:[165,167] width:25 height:25
		dotNetControl cust166 "button" pos:[5,48] width:25 height:25
		dotNetControl cust167 "button" pos:[33,48] width:25 height:25
		dotNetControl cust168 "button" pos:[62,48] width:25 height:25
		dotNetControl cust169 "button" pos:[5,78] width:25 height:25
		dotNetControl cust170 "button" pos:[33,78] width:25 height:25
		dotNetControl cust171 "button" pos:[62,78] width:25 height:25
		dotNetControl cust323 "button" pos:[5,168] width:25 height:25
		dotNetControl cust364 "button" pos:[33,168] width:25 height:25
		dotNetControl cust365 "button" pos:[62,168] width:25 height:25
		dotNetControl cust440 "button" pos:[5,139] width:25 height:25
		dotNetControl cust72 "button" pos:[33,139] width:25 height:25
		dotNetControl cust73 "button" pos:[62,139] width:25 height:25
		dotNetControl cust109 "button" pos:[33,111] width:24 height:24
		dotNetControl custno2 "button" pos:[237,22] width:25 height:25
		dotNetControl cust111 "button" pos:[209,76] width:25 height:25
		dotNetControl cust112 "button" pos:[264,22] width:25 height:25
		dotNetControl cust113 "button" pos:[209,48] width:25 height:25
		dotNetControl cust114 "button" pos:[237,48] width:25 height:25
		dotNetControl cust115 "button" pos:[264,48] width:25 height:25
		dotNetControl cust116 "button" pos:[237,76] width:25 height:25
		dotNetControl custno1 "button" pos:[209,22] width:25 height:25
		dotNetControl cust118 "button" pos:[264,76] width:25 height:25
		dotNetControl cust119 "button" pos:[238,113] width:25 height:25
		dotNetControl cust120 "button" pos:[210,167] width:25 height:25
		dotNetControl cust121 "button" pos:[265,113] width:25 height:25
		dotNetControl cust122 "button" pos:[210,139] width:25 height:25
		dotNetControl cust123 "button" pos:[238,139] width:25 height:25
		dotNetControl cust1245 "button" pos:[265,139] width:25 height:25
		dotNetControl cust1255 "button" pos:[238,167] width:25 height:25
		dotNetControl cust1265 "button" pos:[210,113] width:25 height:25
		dotNetControl cust1275 "button" pos:[265,167] width:25 height:25
		GroupBox grp7 "Numbers/Letters" pos:[202,3] width:97 height:191
		GroupBox grp1 "Arrow Icons" pos:[102,3] width:94 height:191
		GroupBox grp4 "Misc Icons" pos:[2,3] width:94 height:192
		
		on DNimagebuttons open do
		(
		for i in DNimagebuttons.controls do 
		(	
			if classof i == dotnetcontrol do
			(
			BotNet.button i "" 7 flat #maxback #maxactive #crimson
			)
		)
		-- 		
		)
		on cust22 Paint args do botnet.gdi.plus args #maxfore #white
	
		on cust23 Paint args do botnet.gdi.minus args #maxfore #green
		on cust24 Paint args do
			botnet.gdi.squares args #maxfore #red
		on custTM Paint args do
			botnet.gdi.arrow args #maxfore #MediumSeaGreen
		on custTM backgroundPaint args do ()
		on custBL Paint args do
			botnet.gdi.arrow args #maxfore #LightSteelBlue angle:215
		on custTR Paint args do
			botnet.gdi.arrow args #maxfore #LightSteelBlue angle:45
		on custML Paint args do
			botnet.gdi.arrow args #maxfore #MediumSeaGreen  angle:270
		on custC Paint args do
			botnet.gdi.square args #maxfore #coral
		on custMR Paint args do
			botnet.gdi.arrow args #maxfore #MediumSeaGreen  angle:90
		on custMarqSq Paint args do
			botnet.gdi.marquee args #maxfore #white
		on custBM Paint args do
			botnet.gdi.arrow args #maxfore #MediumSeaGreen   angle:180
		on cust43 Paint args do
			botnet.gdi.plus args #yellow #MediumPurple cross:true
		on custTL Paint args do
			botnet.gdi.arrow args #maxfore #LightSteelBlue angle:315
		on custBR Paint args do
			botnet.gdi.arrow args #maxfore #LightSteelBlue angle:135
		on cust124 Paint args do
			botnet.gdi.arrow args #maxfore #maxback
		on cust125 Paint args do
			botnet.gdi.arrow args #maxfore #maxback angle:215
		on cust126 Paint args do
			botnet.gdi.arrow args #maxfore #maxback angle:45
		on cust127 Paint args do
			botnet.gdi.arrow args #maxfore #maxback  angle:270
		on custD Paint args do
			botnet.gdi.square args #maxfore #coral diamond:true
		on cust129 Paint args do
			botnet.gdi.arrow args #maxfore #maxback  angle:90
		on cust130 Paint args do
			botnet.gdi.arrow args #maxfore #maxback angle:180
		on cust131 Paint args do
			botnet.gdi.arrow args #maxfore #maxback angle:315
		on cust132 Paint args do
			botnet.gdi.arrow args #maxfore #maxback angle:135
		on cust166 Paint args do
			botnet.gdi.plus args #yellow #limegreen
		on cust167 Paint args do
			botnet.gdi.minus args #maxfore #orangered
		on cust168 Paint args do
			botnet.gdi.squares args #yellow #MediumPurple
		on cust169 Paint args do
			botnet.gdi.plus args #orchid #yellow
		on cust170 Paint args do
			botnet.gdi.minus args #maxfore #orchid
		on cust171 Paint args do
			botnet.gdi.squares args #limegreen #slategray
		on cust323 Paint args do
			botnet.gdi.AxisX args #red
		on cust364 Paint args do
			botnet.gdi.AxisY args #limegreen
		on cust365 Paint args do
			botnet.gdi.AxisXY args #blue
		on cust440 Paint args do
			botnet.gdi.script args #maxfore #white #green
		on cust72 Paint args do
			botnet.gdi.script args #yellow #mediumpurple #yellow
		on cust73 Paint args do
			botnet.gdi.script args #limegreen #slategray #white
		on cust109 Paint args do
			botnet.gdi.plus args #white #red cross:true
		on custno2 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 2
		on cust111 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 7
		on cust112 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 3
		on cust113 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 4
		on cust114 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 5
		on cust115 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 6
		on cust116 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 8
		on custno1 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 1
		on cust118 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 9
		on cust119 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 12
		on cust120 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 97
		on cust121 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 13
		on cust122 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 33
		on cust123 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 35
		on cust1245 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 37
		on cust1255 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 98
		on cust1265 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 11
		on cust1275 Paint args do
			botnet.gdi.drawstring args #maxfore #maxback 99
		
	
			
		
	)
	createdialog DNimagebuttons style:#(#style_toolwindow, #style_sysmenu)
)
		
)

BotNet = BotNetframework()
clearlistener()
BotNet.GDI.UItest()

