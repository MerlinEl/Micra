--Bitmap To FileStream
persistent global mcStreamBitmap
persistent global bmp1 = "C:\\temp\\folder.ms"
persistent global bmp2 = "C:\\temp\\foldea.ms"
bmp1=u
bmp2=u
struct mcFileSTR
(
	fn FindPos path str begin:0 =
	(
		local f = openFile path mode:"r"
		local pos = 0
		
		if  begin != 0 do (seek f begin)
		
		while not eof f do
		(
			local line=readline f
			if line == str do (pos = filePos f; exit)
		)
		close f
		return pos
	),
	
	fn ExecuteAll path =
	(
		f = openFile path  
		
		seek f 0
		
		while not eof f do
		(
			local line=readline f
			execute line
		)
		close f
	),
	
	fn ExecuteHead path head =
	(
		local f = openFile path  
		local start = mcFileSTR.FindPos path ("["+head+"]--Start")
		local end   = (mcFileSTR.FindPos path ("["+head+"]--End"  ) begin:start)-(head.count+10)

		seek f start
		
		while not eof f do
		(
			local line=readline f
			execute line
			if filePos f >= end do exit
		)
		close f
	),
	
	fn ConvertBitmap bmp name begin:0 =
	(
		local w=bmp.width
		local h=bmp.height
		local fPath = maxFilePath
		local fName = mcGetFile maxFileName #name
		if fPath == "" do return false
		local f = createFile (fPath+fName+".mic")
		
		if  begin != 0 do (seek f begin)
		
		format "\n[%]--Start\n" name to:f
		format "%=bitmap % %\n" name w h to:f
		
		for r=0 to h-1 do
		(
			--format "setpixels % [0,%] (unpack #(" name r to:f
			format "setpixels % [0,%] #(" name r to:f
			local pixels=getpixels bmp [0,r] w 
			for c=1 to w do
			( 
				local p=pixels[c]
				--format "%" (((p.r as integer)*256+(p.g as integer))*256+(p.b as integer)) to:f
				format "%" p to:f
				if c != w then format ", " to:f
				--else format "))\n" to:f
				else format ")\n" to:f
			)
		)
		format "mcStreamBitmap = % " name to:f
		format "\n[%]--End\n" name to:f
		close f
	)
)--end


/*
mypic =(gw.getviewportdib())
mypic2 = mcRescaleBitmapByX mypic 120
display mypic2
mcFileSTR.ConvertBitmap mypic2 "btmp2"
mcFileSTR.ConvertToBitmap mypic2 "btmp2"
mcFileSTR.mcExecuteFileStream newBitmapScript
display mcStreamBitmap
persistents.removeAll()
persistents.show()
f = openFile "C:\\Temp\\bmpTest\\Button02.mic" mode:"r"
*/

/*
seek fin #eof

maxlen=filepos fin

seek fin 0

res = readChars fin maxlen errorAtEOF:false

*/