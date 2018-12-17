Global newBitmapScript = stringStream ""
Global mcStreamBitmap

fn mcConvertBitmapStream bmp name =
(
		local w=bmp.width
		local h=bmp.height
		format "\n%=bitmap % %\n" name w h to:newBitmapScript
		
		for r=0 to h-1 do
		(
			--format "setpixels % [0,%] (unpack #(" name r to:newBitmapScript
			format "setpixels % [0,%] #(" name r to:newBitmapScript
			local pixels=getpixels bmp [0,r] w 
			for c=1 to w do
			( 
				local p=pixels[c]
				--format "%" (((p.r as integer)*256+(p.g as integer))*256+(p.b as integer)) to:newBitmapScript
				format "%" p to:newBitmapScript
				if c != w then format ", " to:newBitmapScript
				--else format "))\n" to:newBitmapScript
				else format ")\n" to:newBitmapScript
			)
		)
		format "mcStreamBitmap = % " name to:newBitmapScript
		return newBitmapScript
)

fn mcExecuteStream stream =
(
	local s = stream
	seek s 0
	while not eof s do
	(
		local line=readline s
		execute line
	)
	close a
)
/*
mypic =(gw.getviewportdib())
mypic2 = mcRescaleBitmapByX mypic 120
mcConvertBitmapStream mypic2 "btmp1"
mcExecuteStream newBitmapScript
display mcStreamBitmap
persistents.removeAll()
persistents.show()
*/