img_list = dotnetObject "ImageList"
mcsystem.show img_list



	
	fn createImage w:24 h:24 clr:white transparent:false =
	(
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
		g.FillRectangle brush 0 0 w h
		g.dispose()
		if transparent do img.makeTransparent()
		img
	)
	fn getImageList w:24 h:24 =
	(
		local img_list = dotNetObject "ImageList"
		img_list.ColorDepth = img_list.ColorDepth.Depth24Bit
		img_list.ImageSize = netDrSize [w, h]
		
		for d in user_data do
		(
			 img_list.images.add (createImage w:w h:h clr:d.clr)
		)
		 img_list
	)


--drawing in imagelist item
dia= mcMaxScriptColorEditorDialog
il=dia.lv.SmallImageList
mcsystem.show il

new_img = createImage w:32 h:20 clr:yellow	
dia.lv.SmallImageList.images.set_item 0 new_img

dia.lv.update()
dia.lv.refresh()	
	
dia.lv.SmallImageList.images.count
dia.lv.items.count
	



il.images.count
il.images.add new_img  
dia.lv.items.item[0].ImageIndex = 0--(il.images.count-1)
il.images.RemoveAt (il.images.count-1)



fn netDrColor clr       = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)


--create new image list
img_list = dotNetObject "ImageList"
--add  image
new_img = createImage w:32 h:20 clr:yellow
img_list.Images.add new_img
--check bitmap color
(img_list.Images.item[0].getPixel 1 1).toString() 
--"Color [A=255, R=255, G=255, B=0]"
new_img = createImage w:32 h:20 clr:red
img_list.Images.set_item 0  new_img
(img_list.Images.item[0].getPixel 1 1).toString() 

img_list.Images.count -- ==2

--------------------------------------------------------------------------

--------------------------------------------------------------------------

img_list.images.get_item 1
img_list.images.set_item 0 new_img
--------------------------------------------------------------------------

--------------------------------------------------------------------------

--create new image list
img_list = dotNetObject "DevExpress.XtraTreeList.TreeList"







/*
00001 using System;
00002 using System.Collections;
00003 using System.Collections.Generic;
00004 using System.Text;
00005 using System.Windows.Forms;
00006 using System.Drawing;
00007 using System.Drawing.Imaging;
00008 using System.Reflection;
00009 using System.Runtime.InteropServices;
00010 
00011 namespace MySQL.Utilities
00012 {
00013         public class ImageListHelper
00014         {
00015                 [StructLayout(LayoutKind.Sequential)]
00016                 private class BitmapInfo
00017                 {
00018                         public Int32 biSize;
00019                         public Int32 biWidth;
00020                         public Int32 biHeight;
00021                         public Int16 biPlanes;
00022                         public Int16 biBitCount;
00023                         public Int32 biCompression;
00024                         public Int32 biSizeImage;
00025                         public Int32 biXPelsPerMeter;
00026                         public Int32 biYPelsPerMeter;
00027                         public Int32 biClrUsed;
00028                         public Int32 biClrImportant;
00029                         public Int32 bmiColors;
00030                 };
00031 
00032                 [DllImport("comctl32.dll")]
00033                 private static extern bool ImageList_Add(IntPtr hImageList, IntPtr hBitmap, IntPtr hMask);
00034                 [DllImport("kernel32.dll")]
00035                 private static extern bool RtlMoveMemory(IntPtr dest, IntPtr source, int dwcount);
00036                 [DllImport("gdi32.dll")]
00037                 private static extern IntPtr CreateDIBSection(IntPtr hdc, [In, MarshalAs(UnmanagedType.LPStruct)]BitmapInfo pbmi, uint iUsage, out IntPtr ppvBits, IntPtr hSection, uint dwOffset);
00038 
00039                 private static Type imageInfoType;
00040                 private static FieldInfo imageFieldInfo;
00041 
00042                 static ImageListHelper() 
00043                 {
00044                         imageInfoType = typeof(ImageList).Assembly.GetType("System.Windows.Forms.ImageList+ImageCollection+ImageInfo");
00045                         imageFieldInfo = typeof(ImageList.ImageCollection).GetField("imageInfoCollection", BindingFlags.NonPublic | BindingFlags.Instance);
00046                 }
00047 
00048                 public static void Add(string FileName, ImageList Imagelist)
00049                 {
00050                         Bitmap bitmap = new Bitmap(FileName);
00051 
00052                         if (bitmap.RawFormat.Guid == ImageFormat.Icon.Guid)
00053                         {
00054                                 Icon icon = new Icon(FileName);
00055 
00056                                 Imagelist.Images.Add(Icon.FromHandle(icon.Handle));
00057                                 icon.Dispose();
00058                         }
00059                         else
00060                                 Add(bitmap, Imagelist);
00061 
00062                         bitmap.Dispose();
00063                 }
00064 
00065                 public static void RestoreImageInfo(ImageList Imagelist)
00066                 {
00067                         if (Imagelist != null)
00068                         {
00069                                 ArrayList imageInfoCollection = 
00070                                         (ArrayList)imageFieldInfo.GetValue(Imagelist.Images);
00071 
00072                                 imageInfoCollection.Add(Activator.CreateInstance(imageInfoType));
00073                         }
00074                 }
00075 
00076                 public static int Add(Bitmap Bitmap, ImageList ImageList)
00077                 {
00078                         IntPtr hBitmap;
00079                         IntPtr ppvBits;
00080                         BitmapInfo bitmapInfo = new BitmapInfo();
00081 
00082       // Make a copy of the bitmap. We are are going to flip it and don't want the
00083       // original file to be modified. This solves another problem en-passant
00084       // where bitmap and image list size differ.
00085       Bitmap = new Bitmap(Bitmap, ImageList.ImageSize.Width, ImageList.ImageSize.Height);
00086 
00087                         bitmapInfo.biSize = 40;
00088                         bitmapInfo.biBitCount = 32;
00089                         bitmapInfo.biPlanes = 1;
00090                         bitmapInfo.biWidth = Bitmap.Width;
00091                         bitmapInfo.biHeight = Bitmap.Height;
00092 
00093                         Bitmap.RotateFlip(RotateFlipType.RotateNoneFlipY);
00094                         hBitmap = CreateDIBSection(new IntPtr(0), bitmapInfo, 0, 
00095                                 out ppvBits, new IntPtr(0), 0);
00096 
00097                         BitmapData bitmapData = Bitmap.LockBits(
00098                                 new Rectangle(0, 0, Bitmap.Width, Bitmap.Height), 
00099                                 ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
00100                         RtlMoveMemory(ppvBits, bitmapData.Scan0, Bitmap.Height * bitmapData.Stride);
00101 
00102                         Bitmap.UnlockBits(bitmapData);
00103 
00104                         ImageList_Add(ImageList.Handle, hBitmap, new IntPtr(0));
00105 
00106                         return ImageList.Images.Count - 1;
00107                 }
00108         }
00109 
00110 }
*/


/*
--img = dia.lv.SmallImageList.Images.item[3 ]
img = createImage w:32 h:20 clr:blue
g=(DotNetClass "system.drawing.Graphics").fromImage img
newRect = netDrRect [0, 0] [32, 20]
g.DrawImage img newRect 0 0 24 24 (dotNetClass "Drawing.GraphicsUnit").Pixel

il.Draw g 32 20 1

dia.lv.SmallImageList = il

mcsystem.show dia.lv.SmallImageList.images	
dia.lv.SmallImageList.images.item[0] = img
dia.lv.SmallImageList.images.add "1" img
	*/
/*
lock_bits =  img_list.Images.item[0].lockBits img_list.Images.item[0]
img_list.Images.item[0].UnlockBits img_list.Images.item[0]

--repaint
img_list.Images.item[0].SetPixel 1 1 (netDrColor blue)

--check bitmap color
(img_list.Images.item[0].getPixel 1 1).toString() 
--"Color [A=255, R=0, G=0, B=255]"



  .Draw <System.Drawing.Graphics>g <System.Int32>x <System.Int32>y <System.Int32>index



mcsystem.show img_list.Images
*/
