--How to convert a Bitmap Image to IntPtr


--------------------------------------------------------------------------

--------------------------------------------------------------------------

local clipboardObj = dotNetClass "System.Windows.Forms.Clipboard"
 -- Get the image from the clipboard into a dotNet image object.
 setClipboardBitmap bm
 local imgObj = clipboardObj.GetImage()
 rect = dotNetObject "System.Drawing.Rectangle" 0 0 10 10
 bmd = imgObj.LockBits rect ((dotnetclass "System.Drawing.Imaging.ImageLockMode").Readonly) ((dotnetclass "System.Drawing.Imaging.Pixelformat").Format24bppRgb) --imgObj.PixelFormat

 stride = bmd.Stride; 
 Scan0 = dotnetclass "System.IntPtr" 
 Scan0 = bmd.Scan0

 --p = dotnetclass "byte"
 p = dotnetclass "system.byte[]"
 p = bmd.Scan0
 nOffset = stride - imgObj.Width*3 
 nWidth = imgObj.Width * 3

 For y = 0 To bmd.Height - 1 do
 (
 For x = 0 To bmd.Width - 1 do
 (
 --p[0] = (255-p[0])
 --p += 1;
 --(dotnetclass "System.Runtime.InteropServices.Marshal").writeByte bmd.Scan0 ((bmd.Stride * y) + (4 * x)) 255
 )
 --p += nOffset
 ) 
 imgObj.UnlockBits bmd
 
 
 
 --------------------------------------------------------------------------
 
 --------------------------------------------------------------------------
 IntPtr pval = IntPtr.Zero;
System.Drawing.Imaging.BitmapData bd = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height), ImageLockMode.ReadWrite, PixelFormat.Format24bppRgb);
pval=bd.Scan0;

z = (dotnetClass "IntPtr").zero
bd = (dotnetObject "Drawing.Imaging.BitmapData")
mcsystem.show bd
bd.scan0
