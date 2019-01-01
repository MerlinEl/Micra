
--OLD DotNet FN--
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
			local hex_as_color = mcColor.hexToRGB clr
			if hex_as_color == undefined do return undefined
			(dotNetClass "Drawing.Color").fromArgb hex_as_color.r hex_as_color.g hex_as_color.b
		)
		Color:(dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b
	)
	return dotnet_color
)
fn netDrBitmap size     = (dotNetObject "Drawing.Bitmap" size.x size.y)
fn netDrPoint pos  = (
	
	if pos == undefined do (
		
			format "netDrPoint > Error > undefined pos\n"
			return undefined
	)
	dotnetObject "Drawing.Point" pos.x pos.y
)
fn netDrRect pos size   = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y)
fn netDrSize size       = (dotNetObject "Drawing.Size" size.x size.y)
fn netDrFont font:"Arial" size:12 style:"Regular" =
(
	local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
	dotNetObject "Drawing.Font" font size f_style
) 
fn netString str        = (dotNetObject "System.String" str)

Global mcRect
Global getIconDotNet

fn getIconDotNet icnNum icnSize:24 =
(
	if icnNum == 0 do return undefined
	local img_lib = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
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