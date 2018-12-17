	fn grabImage s =
	(
		local img = gw.getViewportDib() 
		local new_img = bitmap picture_size picture_size
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		copy img new_img
		setclipboardBitmap new_img
		s.image = if clipboardClass.containsimage() then clipboardClass.getImage()
	)

setImage = setclipboardBitmap anim_bmp
returnImage = getclipboardBitmap()
display returnImage 

--pastebitmap is the right way to go. You can program custom functions for pasting. 
--it's really nice. should look like this:

fn pasteblue color1 pixel1 color2 pixel2 = 
   (
   		res = color2 -- the result will contain the Green and Red of color2
   		res.b = color1.b --but the Blue from color1
   		res 
   )
-- paste the blue channel from bmp1 into the blue channel of bmp2
pastebitmap bmp1 bmp2 [0,0] [0,0] type:#function function:pasteblue




freeSceneBitmaps()
--set image to clipboard

img = bitmap 240 240 color:(green)
display img
theFileName = GetDir #image + "ImageClipboard.bmp" --define a temp.file name
img.filename = theFileName
save img
close img

clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass

theImage = dotNetClass "System.Drawing.Image" --create an Image dotNetClass
theBitmap = theImage.FromFile theFileName --get the saved image from file as bitmap
clipboardClass.setImage theBitmap --copy the image to clipboard
theBitmap.Dispose() --release the bitmap 
deleteFile theFileName --delete the temp. file





--get image from clipboard

clipboardClass = dotNetClass "System.Windows.Forms.Clipboard" --create a Clipboard dotNetClass
theFileName = GetDir #image + "ImageClipboard.bmp" --define a temp.file name
theBitmap = clipboardClass.getImage()
clipboardClass.ContainsImage() --return true if the clipboard contains image
w = theBitmap.Width
h = theBitmap.Height
--change bitmap resolution to 71 and bit to 24
theBitmap.SetResolution 71.0 71.0
rect = (dotNetClass "System.Drawing.Rectangle").FromLTRB 0 0 w h --left top right bottom
theBitmap24  = theBitmap.clone rect pixel_format
theBitmap24.Save theFileName
theBitmap.Dispose() --release the bitmap
theBitmap24.Dispose() --release the bitmap
--shows info
s_d_img = dotNetClass "System.Drawing.Image"
s_d_img.GetPixelFormatSize theBitmap24.PixelFormat
theBitmap24.HorizontalResolution 
theBitmap24.VerticalResolution
--.RotateFlip <System.Drawing.RotateFlipType>rotateFlipType
--.MakeTransparent <System.Drawing.Color>transparentColor
--pixels to color

img = bitmap w h color:black
for Y = 0 to (h-1) do
(
	clr_array = #()
	for X = 0 to (w-1) do
	(
		
		pix = (theBitmap.GetPixel x y)
		--format "pixel pos:%\n" [x,y]
		clr_array += #(color pix.r pix.g pix.b)
		
	)
	print y
	setPixels img [ 0, y ] clr_array --fills canvas from left down to left up
)
display img


colorclass = dotnetclass "system.drawing.color"
showmethods colorclass

theBitmap.GetPixelFormatSize theBitmap.PixelFormat

theBitmap.save theFileName

show colorclass
showmethods colorclass
show  theBitmap
showmethods theBitmap
theBitmap.RawFormat.ToString()
codecs = dotNetClass "System.Drawing.Imaging.ImageCodecInfo"
show codecs
showmethods codecs
codecs.GetImageEncoders
codecs.GetImageDecoders
pix =  (theBitmap.GetPixel 25 85)
showmethods pix
pix.a
color pix.r pix.g pix.b

(colorclass.FromArgb(pix.ToArgb())).a
(colorclass.FromArgb(pix.ToArgb())).r
(colorclass.FromArgb(pix.ToArgb())).g
pix.argb

theBitmap.Dispose() --release the bitmap 
doesFileExist theFileName
img = openBitmap theFileName
img = openBitmap "C:\\Documents and Settings\\Merlin\\Dokumenty\\3dsmax\\sceneassets\\imagesImageClipboard.bmp"
close img


--About the capture stuff check Maxscript help for:
getViewportDib() - gw

For bitmap size info check Maxscript help for:
<bitmap>.height
<bitmap>.width


freeSceneBitmaps()
freeSceneBitmaps()

fn getIconFromBitmap thePath number =
(
	tempBmp = openBitmap thePath
	iconBmp = bitmap 16 15
	for v = 0 to 14 do
	setPixels iconBmp [0,v] (getPixels tempBmp [(number-1)*16, v] 16)
	iconBmp.filename = getDir #image +"/_temp.bmp"
	save iconBmp
	close iconBmp 
	close tempBmp
	getDir #image +"/_temp.bmp"
)

fn loadThumbnails =
(
	if catPath == "Undefined" do return false
	local bmpFiles = getFiles (rootPath + catPath + "\\*.jpg")
	if bmpFiles.count == 0 do return false
	
	for i=1 to bmpFiles.count do
	(
		local theName  = getFilenameFile bmpFiles[i]
		local rollTag  = (execute ("roll"+activeCatalog+".tag_"+i as string))
		local rollLbl  = (execute ("roll"+activeCatalog+".lbl_"+i as string))
		rollTag.bitmap = openBitMap bmpFiles[i] 
		rollTag.transparent = color 255 255 0 --avoid transparency on colors
		rollLbl.text   = theName
	)
)

display (gw.getviewportdib())


rollout unnamedRollout "Untitled" width:162 height:300
(
	bitmap BiIm_1 "" pos:[4,4] width:24 height:24 bitmap:(bitmap 50 50 color:blue)
	on BiIm_1 pressed do
	(
	print "do"
	)
)
createDialog unnamedRollout


button btn_1 "" width:190 height:7 pos:[-2,-1] images:#((bitmap 190 7 color:gray),undefined,1,1,1,1,1) tooltip:"Click to"

aboDialog.img1.bitmap =(bitmap 50 50 color:blue)
aboDialog.img1.fileName="E:\Merlin\Micra\About02.bmp"
aboDialog.img1.fileName="About02.bmp"



(
	local b=selectbitmap()
	local bname="bitmap_"+(getfilenamefile b.filename)
	local w=b.width
	local h=b.height
	
	format "----------\nfn load_% = (\n" bname
	format  "local %=bitmap % %\n" bname w h

	format "fn unpack val = for p in val collect (r=p/256^2; g=p/256-r*256; b=mod p 256; color r g b)\n"
	
		for r=0 to h-1 do
		( 
			format "setpixels % [0,%] (unpack #(" bname r
			pixels=getpixels b [0,r] w 
			for c=1 to w do
			( 
				p=pixels[c]
				format "%" (((p.r as integer)*256+(p.g as integer))*256+(p.b as integer))
				if c != w then format ", " else format "))\n"
			)
		)
	format "return %\n" bname
	format ")\n----------\n"
)




global newBitmap
fn mcRescaleBitmapBy bmp x =
(
	local w=bmp.width
	local h=bmp.height
	newBitmap = bitmap (w/x) (h/x)
	
	for r=0 to h-1 by x do
	(
		for c=1 to w by x do
		(
			local pixels=getpixels bmp [c,r] 1
			setpixels newBitmap [c/x,r/x] pixels
		)
	)
	display newBitmap
)
/* 
mcRescaleBitmapBy b1 4 
*/
fn mcRescaleBitmapByXY bmp size =
(
	local w=bmp.width
	local h=bmp.height
	newBitmap = bitmap size.x size.y
	
	local fx = w/size.x
	local fy = h/size.y
	
	for r=0 to h-1 by fx do
	(
		for c=1 to w by fy do
		(
			local pixels=getpixels bmp [c,r] 1
			setpixels newBitmap [c/fx,r/fy] pixels
		)
	)
	display newBitmap
)
/* 
mcRescaleBitmapByXY b1 [100,90] 
*/
fn mcRescaleBitmapByX bmp sizeX =
(
	local w=bmp.width
	local h=bmp.height
	
	local sizeY = h/(w/sizeX)
	
	newBitmap = bitmap sizeX sizeY
	
	local fx = w/sizeX
	local fy = h/sizeY
	
	for r=0 to h-1 by fx do
	(
		for c=1 to w by fy do
		(
			local pixels=getpixels bmp [c,r] 1
			setpixels newBitmap [c/fx,r/fy] pixels
		)
	)
	display newBitmap
)
/*
mcRescaleBitmapByX b1 100
*/
b1 =(gw.getviewportdib()) -- [635,475]
display b1
mcRescaleBitmap b1 [50,30]

img = bitmap 24 24
display img
close img


	fn higlightButton icn col =
	(
		--draw lines
		for i=0 to 24 do
		(
			--top
			setpixels icn [i,1] #(col)
			--bottom
			setpixels icn [i,22] #(col)
			--left
			setpixels icn [1,i] #(col)
			--right
			setpixels icn [22,i] #(col)
		)
		return icn
		--display icn
	)
	
		fn getIconFrom imgFile icnNum =
	(
		if not doesFileExist imgFile do return false
		local pix     = #()
		local icn     = bitmap 24 24 color:green
		local imgLib  = openBitMap imgFile
		local IconPos_X = icnNum*24
		
		--begin at top left hand pixel
		for i=0 to 24 do
		(
			pix = getPixels imgLib [IconPos_X , i] 24 
			setpixels icn [0,i] pix
		)
		--display icn
		return icn
	)
