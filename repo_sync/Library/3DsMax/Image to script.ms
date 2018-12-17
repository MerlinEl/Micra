-- image to string

fn imageToScript =
(
	local b=selectbitmap()
	local bname= getfilenamefile b.filename
	local w=b.width
	local h=b.height
	format "----------\nfn getIcon_% = \n(\n" bname
	format "\tlocal %=bitmap % %\n" bname w h
	format "\tfn unpack val = for p in val collect (r=p/255^2; g=p/255-r*255; b=mod p 255; color r g b)\n"
	format "\tlocal icon_data = \n"
	format "\t#(\n"
	for r=0 to h-1 do
	(
		local pixels = getpixels b [0,r] w
		format "\t\t#("
		for c=0 to w-1 do
		(
			local p = pixels[c+1]
			format "%" (((p.r as integer)*255+(p.g as integer))*255+(p.b as integer))
			if c != w-1 then format ", " else ""
		)
		if r != h-1 then format "),\n" else format ")\n"
	)
	format "\t)\n"
	format ("\tfor i=0 to icon_data.count-1 do setpixels " +bname+ "[0,i] (unpack icon_data[i+1])\n")
	format "\treturn %\n" bname
	format ")\n"
)

imageToScript()


--OUTPUT
fn getIcon_DirRoot = 
(
	local DirRoot=bitmap 14 14
	fn unpack val = for p in val collect (r=p/255^2; g=p/255-r*255; b=mod p 255; color r g b)
	local icon_data = 
	#(
		#(13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572),
		#(13839572, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 11998546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 16635546, 16635546, 0, 16635546, 16635546, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 0, 16635546, 16635546, 0, 16635546, 16635546, 0, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 0, 0, 0, 0, 0, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 0, 11998546, 16635546, 11998546, 0, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 0, 0, 0, 16635546, 16635546, 16635546, 0, 0, 0, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 0, 11998546, 16635546, 11998546, 0, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 0, 0, 0, 0, 0, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 0, 16635546, 16635546, 0, 16635546, 16635546, 0, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 16635546, 16635546, 0, 16635546, 16635546, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 11998546, 16635546, 16635546, 16635546, 16635546, 16635546, 16635546, 16635546, 16635546, 16635546, 16635546, 0, 13839572),
		#(13839572, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13839572),
		#(13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572, 13839572)
	)
	for i=0 to icon_data.count-1 do setpixels DirRoot[0,i] (unpack icon_data[i+1])
	return DirRoot
)

display (getIcon_DirOpen())
display (getIcon_DirRoot())

/*
fn imageToScript =
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
imageToScript()



fn load_bitmap_DirOpen = (
local bitmap_DirOpen=bitmap 14 14
fn unpack val = for p in val collect (r=p/256^2; g=p/256-r*256; b=mod p 256; color r g b)
setpixels bitmap_DirOpen [0,0] (unpack #(13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116))
setpixels bitmap_DirOpen [0,1] (unpack #(13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116))
setpixels bitmap_DirOpen [0,2] (unpack #(13948116, 13948116, 13948116, 13948116, 0, 0, 0, 0, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116))
setpixels bitmap_DirOpen [0,3] (unpack #(13948116, 13948116, 13948116, 0, 16766063, 16766063, 16766063, 16766063, 0, 13948116, 13948116, 13948116, 13948116, 13948116))
setpixels bitmap_DirOpen [0,4] (unpack #(13948116, 13948116, 0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 0, 0, 13948116, 13948116))
setpixels bitmap_DirOpen [0,5] (unpack #(13948116, 13948116, 0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 13948116))
setpixels bitmap_DirOpen [0,6] (unpack #(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16766063, 16766063, 0, 13948116))
setpixels bitmap_DirOpen [0,7] (unpack #(0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 16766063, 0, 13948116))
setpixels bitmap_DirOpen [0,8] (unpack #(0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 16766063, 0, 13948116))
setpixels bitmap_DirOpen [0,9] (unpack #(13948116, 0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 0, 13948116))
setpixels bitmap_DirOpen [0,10] (unpack #(13948116, 0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 0, 13948116))
setpixels bitmap_DirOpen [0,11] (unpack #(13948116, 13948116, 0, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 16766063, 0, 13948116))
setpixels bitmap_DirOpen [0,12] (unpack #(13948116, 13948116, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 13948116))
setpixels bitmap_DirOpen [0,13] (unpack #(13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116, 13948116))
return bitmap_DirOpen
)

*/