fn resizeDDSBitmap fpath size clr = (
	
	if not doesFileExist fpath do return false
	local bmp_rect = dotNetObject "System.Drawing.Rectangle" 0 0 size.x size.y
	
	local bm = openBitmap fpath
	local the_mIage= dotnetObject "System.Drawing.Bitmap" size.x size.y
	for i=0 to size.x-1 do (
		for j=0 to size.y-1 do (
			
			local net_clr = (dotnetClass "System.Drawing.Color").FromARGB clr.r  clr.g clr.b
			theImage.SetPixel i j net_clr		
		)
	)	
	close theBitmap
)
resizeDDSBitmap @"C:\temp\temp---d.dds" [256,256] gray


--https://forums.cgsociety.org/t/how-to-support-dds-with-dotnet-drawing-bitmap/1311092/22
assembly = dotNetClass "System.Reflection.Assembly"
assembly.loadfrom @"d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImage32.dll"
assembly.loadfrom @"d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImage64.dll"
FreeImageNetAPI = assembly.loadfrom @"d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImageNET.dll"

fi = micra.AppsDir + "FreeImage"
doesDirectoryExist fi
dotnet.loadassembly (micra.AppsDir + "FreeImage")
dotnet.loadassembly "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImage32.dll"
dotnet.loadassembly "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImage64.dll"
FreeImageNetAPI = dotnet.loadassembly "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImageNET.dll"
dotnet.loadassembly "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\x64"
dotnet.loadAssembly "C:\\WINDOWS\\Microsoft.NET\\Framework\\v2.0.50727\\system.xml.dll"

assembly = dotNetClass "System.Reflection.Assembly"
r = assembly.loadfrom "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage32\FreeImage.dll"
r = assembly.loadfrom "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage64\FreeImage.dll"
r = assembly.loadfrom "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeimageNet.dll"


dotnet.loadassembly "d:\ReneBaca\3DsMax\Micra\Micra4\App\FreeImage\FreeImageNET.dll"
Freeimage = Dotnetclass “FreeImageAPI.Freeimage”


/*
dotnet.loadassembly “C:\FreeImageNet”

Freeimage = Dotnetclass “FreeImageAPI.Freeimage”
LoadFlags = Dotnetclass “FreeImageAPI.FREE_IMAGE_LOAD_FLAGS”
ImageFormat = Dotnetclass “FreeImageAPI.FREE_IMAGE_FORMAT”

– load a DDS as a .Net bitmap
DDSfile = Freeimage.LoadBitmap “C:\	est.dds” LoadFlags.default ImageFormat.FIF_DDS

– also, you could load a TGA as a .Net bitmap if you liked.
– DDSfile = Freeimage.LoadBitmap ((getdir#scripts)+@"	esttga.tga") LoadFlags.default ImageFormat.FIF_TARGA

bmpDisplayed = dotNetObject “System.Drawing.Bitmap” DDSfile
bmpRectangle = dotNetObject “System.Drawing.Rectangle” 0 0 512 512

rollout uiDotNetPictureBox “.NET PictureBox” width:512 height:512
(
dotNetControl uiPictureBox “System.Windows.Forms.PictureBox” pos:[0,0] width:512 height:512

on uiPictureBox Paint senderArg paintEventArgs do
(
Graphics = paintEventArgs.Graphics
Graphics.DrawImage bmpDisplayed bmpRectangle
)
)
createdialog uiDotNetPictureBox style:#(#style_titlebar, #style_border, #style_sysmenu)
*/




b = bitmap 320 240 filename:"c:\\temp\\test.dds" color:gray
save b


b = bitmap 320 240 color:gray
b.fileName = toLower  "c:\\temp\\test.dds"
save b


render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[size,size]

b = bitmap 320 240 filename:"c:\\temp\\test2.bmp" color:gray
save b
close b
tc = micra.AppsDir + "texconv.exe"
cmd = tc + " " + b.fileName
cmd = tc + " " + b.fileName + " -ft dds"

cmd = tc + " -w 128 -h 128 -ft bmp -o c:\temp\ -name test3.dds" 
HiddenDOSCommand cmd donotwait:true startpath:"c:\\" exitCode:&exitcode --true = 0 false 1-~

HiddenDOSCommand "notepad %temp%\\cmdout.tmp" prompt:"Waiting..." startpath:"C:\\"
true

https://developer.nvidia.com/legacy-texture-tools

For us it was the DDS save options - no DDS format was defined. 
I did a render on the PC, saved as .DDS and choose ARGB/8888. 
The image saved and after that the script worked.

You can use the donotwait:false option in hiddenDosCommand to convert a texture to DDS, then move it with the standard max external file operations.

fn createDDSImage dir file_name size bg_color = (

	local newBM = bitmap size.x size.y color:bg_color
	newBM.fileName = dir + file_name + ".dds"
	local success = save newBM
	format "fpath:% saved:%\n" newBM.fileName success
	close newBM
)
createDDSImage "c:\\temp\\" "test.dds" [320, 240] gray
var data = Marshal.UnsafeAddrOfPinnedArrayElement(image.Data, 0);
bmp = 256 256, image.Stride, format, data);
     bitmap.Save(Path.ChangeExtension(path, ".png"), System.Drawing.Imaging.ImageFormat.Png);

pf = dotnetClass "System.Drawing.Imaging.PixelFormat"
fo = dotnetClass "System.Drawing.Imaging.ImageFormat"
bm = dotnetObject "System.Drawing.Bitmap" 256 256 pf.Format32bppArgb
bd = bm.LockBits(dotnetObject "System.Drawing.Rectangle" 0 0 256 256)
bm.save "c:\\temp\\test.png" fo.png

bm = dotnetObject "System.Drawing.Bitmap" 256 256 pf.DXT1
bm.save "c:\\temp\\test.dds" fo.DXT1
ICPCL.exe -convertto dds format:X1R5G5B5 mipmap:yes -source "C:\Original files" -dest "C:\Converted files"

tc + " -w 128 -h 128 -f dds -ft bmp -o c:\temp\ -name test3.dds" 


c:\dxsdk\bin\texconv -w 128 -h 128 -f BMP -ft bmp -c FFFE02A5 -o "C:\Users\onverted to\" -name SHP

FreeImageNetAPI
MSVCP110D.dll
VCOMP110D.DLL
MSVCP110D.dll
(getdir#scripts)+"\LoneRobot\ClassLib\FreeImageNet"
Freeimage
