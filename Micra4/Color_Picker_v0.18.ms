
--------------------
--------------------
-- 	              --
-- 	Color Picker  --
-- 	              --
--------------------
--------------------
Global mcColorPickerDialog
Global mcColorPaleteDialog
Global mcColorPaleteActiveSlot
--Dialog:--------------------------------------------------------------------
try ( destroyDialog mcColorPickerDialog ) catch()
-----------------------------------------------------------------------------
if doesFileExist (Micra.RootDir+"Img\\ColorBySat.png") and doesFileExist (Micra.RootDir+"Img\\ColorByVal.png") and mcColorPaleteActiveSlot != undefined do
(
	rollout mcColorPickerDialog "" width:328 height:276
	(
		--Locals:--------------------------------------------------------------------
		local oldColor, dMove = false, DmPos
		-----------------------------------------------------------------------------
		
		dotNetControl HueBitmap "picturebox" pos:[2,16] width:256 height:256
		dotNetControl oldColorBt "label" pos:[262,178] width:62 height:20
		dotNetControl newColorBt "label" pos:[262,156] width:62 height:20
		
		label lbl1 "R:" pos:[262,16] width:12 height:16
		label lbl2 "G:" pos:[262,36] width:12 height:16
		label lbl3 "B:" pos:[262,56] width:12 height:16
		label lbl4 "H:" pos:[262,88] width:12 height:16
		label lbl5 "S:" pos:[262,108] width:12 height:16
		label lbl6 "V:" pos:[262,128] width:12 height:16
		
		spinner spnR "" pos:[278,16] width:46 height:16 range:[0,255,0] type:#integer scale:1
		spinner spnG "" pos:[278,35] width:46 height:16 range:[0,255,0] type:#integer scale:1
		spinner spnB "" pos:[278,55] width:46 height:16 range:[0,255,0] type:#integer scale:1
		spinner spnH "" pos:[278,88] width:46 height:16 range:[0,255,0] type:#integer scale:1
		spinner spnS "" pos:[278,107] width:46 height:16 range:[0,255,0] type:#integer scale:1
		spinner spnV "" pos:[278,127] width:46 height:16 range:[0,255,0] type:#integer scale:1

		button btnAdd "Add" pos:[262,230] width:62 height:20
		button btnReset "Reset" pos:[262,202] width:62 height:20
		button btnClose "Close" pos:[262,252] width:62 height:20

		radiobuttons btswitch "" pos:[148,0] width:110 height:16 labels:#("sat:", "value:") columns:2
		label lbl7 "Color Picker:" pos:[4,2] width:138 height:14

		-----------------------------------------------------------------------------
		--Struct Definitions
		-----------------------------------------------------------------------------
		struct pick
		(		
			fn changeObjectsWire color = (if selection.count != 0 do selection.wirecolor = color ),
			fn add =
			(
				local clr = newColorBt.backColor
				mcColorPaleteActiveSlot.backColor = clr
				setIniSetting Micra.UserSettings "ColorPalete" mcColorPaleteActiveSlot.tag ((netColorToRGB clr) as string)
			),
			fn updateRGBHSVSpinners col = 
			(
				spnR.value = col.r
				spnG.value = col.g
				spnB.value = col.b
				spnH.value = col.h
				spnS.value = col.s
				spnV.value = col.v 
			),
			fn change val rgbhsv = 
			(
				newColor = netColorToRGB newColorBt.backColor
				case rgbhsv of
				(
					"r":newColor.r = val
					"g":newColor.g = val
					"b":newColor.b = val
					"h":newColor.h = val
					"s":newColor.s = val
					"v":newColor.v = val
				)
				newColorBt.backColor = netDrColor newColor
				pick.changeObjectsWire newColor
				pick.updateRGBHSVSpinners newColor
			),
			fn reset =
			(
				OldColor = oldColorBt.backColor
				newColorBt.backColor = oldColor
				pick.changeObjectsWire (netColorToRGB OldColor)
				pick.updateRGBHSVSpinners (netColorToRGB OldColor)
			),
			fn isPosInRect pos rect = 
			(					
				return (pos.x>=rect.LT.x and pos.y>=rect.LT.y and pos.x<=rect.RD.x and pos.y<=rect.RD.x)
			),
			fn loadImage = 
			(
				if btswitch.state == 1 
				then openBitmap (Micra.RootDir+"Img\\ColorBySat.png") 
				else openBitmap (Micra.RootDir+"Img\\ColorByVal.png")
			)
		)
		-----------------------------------------------------------------------------
		--Functions
		-----------------------------------------------------------------------------
		fn getPixelsFromImage s a =
		(
			--format "x:%\ty:%\n" a.x a.y
			if a.x > s.width-1 or a.x < 0 or a.y > s.height-1 or a.y < 0  --if is out of bounds
			then 
			(
				s.cursor.current = netCursors.Arrow
			)
			else
			(
				s.cursor.current = netCursors.Cross
				local clr =  s.Image.GetPixel a.x a.y
				if clr != undefined do
				(
					newColorBt.backColor = clr
					pick.updateRGBHSVSpinners (netColorToRGB clr)
					pick.changeObjectsWire (netColorToRGB clr)
				)
			)
		)
		fn onMouseMove s a =
		(
			case a.button of
			(
				(a.button.left) : (getPixelsFromImage s a)
			)
		)
		fn onMouseDown s a =
		(
			case a.button of
			(
				(a.button.left) : (getPixelsFromImage s a)
			)
		)
		fn onMouseUp s a =
		(

		)
		fn loadCPImage type =
		(
			local fpath = Micra.RootDir + "Img\\" + 
			(
				case type of
				(
					1:"ColorBySat.png"
					2:"ColorByVal.png"
				)
			)
			if not doesFileExist fpath do return undefined
			local img_file = (dotNetClass "Drawing.Image").FromFile fpath --get the saved image from file as bitmap
			local w=img_file.width
			local h=img_file.height
			local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
			local gra  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
			local newRect = netDrRect [ 0, 0 ] [ w, h ]  --adjust icon offset X in button 
			gra.DrawImage img_file newRect 0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
			img_file.dispose()
			return img
		)
		-----------------------------------------------------------------------------
		 --ON OPEN 
		 on mcColorPickerDialog open do 
		 ( 
			HueBitmap.Image = loadCPImage 1
			oldColor = newColorBt.backColor = oldColorBt.backColor = mcColorPaleteActiveSlot.backColor
			pick.changeObjectsWire (netColorToRGB oldColor)
			pick.updateRGBHSVSpinners (netColorToRGB oldColor)
		 )
		 --ON Close 
		 on mcColorPickerDialog close do ( mcCall.saveIniDialog "mcColorPickerDialog" "Properties_2" )
		 --ON Move Dialog 
		on mcColorPickerDialog rbuttonup   pos do ( DestroyDialog mcColorPickerDialog  )
		on mcColorPickerDialog lbuttonup   pos do (dMove = false)
		on mcColorPickerDialog lbuttondown pos do (dMove = true; DmPos = pos)
		on mcColorPickerDialog mousemove pos do (if dMove do setDialogPos mcColorPickerDialog (mouse.screenpos - DmPos) )
		--Actions -----------------------------------------------------------------------
		on spnR changed val do pick.change val "r"
		on spnG changed val do pick.change val "g"
		on spnB changed val do pick.change val "b"
		on spnH changed val do pick.change val "h"
		on spnS changed val do pick.change val "s"
		on spnV changed val do pick.change val "v"
		on btnAdd   pressed do pick.add()
		on btnReset pressed do pick.reset()
		on btnClose pressed do DestroyDialog mcColorPickerDialog
		on btswitch changed stat do (HueBitmap.Image = loadCPImage btswitch.state)
		on HueBitmap MouseMove s a do onMouseMove s a
		on HueBitmap MouseDown s a do onMouseDown s a 
		on HueBitmap MouseUp  s a do onMouseUp s a
	)

	mcCall.createIniDialog "mcColorPickerDialog" "Properties_2"
)
