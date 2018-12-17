--replacing a bitmap in SmallImageList
list_view = mcMaxScriptColorEditorDialog.lv
old_img= list_view.SmallImageList.images.item[0]
new_img=createImage w:32 h:20 clr:green
handle = bm.GetHbitmap()
new_img = dotnetObject "IntPtr" handle

list_view.BeginUpdate()--prevent see the changes until end progress
list_view.SmallImageList.images.item[0].FromHbitmap new_img
list_view.items.item[0].ImageIndex = 1
list_view.items.item[0].ImageIndex = 0
list_view.EndUpdate ()

mcMaxScriptColorEditorDialog.lv.update()
mcMaxScriptColorEditorDialog.lv.refresh()


list_view.items.count

--------------------------------------------------------------------------
replace image in collection
--------------------------------------------------------------------------
fn replaceColorInSmallImageList list_view num clr =
(
	local front_images = if num > 0
		then for i=0 to num-1 collect  list_view.SmallImageList.Images.item[ i ] 
			else #()
	local back_images = if num < list_view.items.count
		then for i=num+1 to list_view.SmallImageList.Images.count-1 collect  list_view.SmallImageList.Images.item[ i ] 
			else #()
	list_view.SmallImageList.Images.clear()	
		format "front:%\tback:%\n" front_images.count back_images.count
	local new_img=createImage w:32 h:20 clr:clr
	list_view.SmallImageList.Images.addRange  (front_images+#(new_img)+back_images)
	list_view.update()
	list_view.refresh()
)
replaceColorInSmallImageList mcMaxScriptColorEditorDialog.lv 8 red 
--------------------------------------------------------------------------

--------------------------------------------------------------------------


list_view.SmallImageList.Images(0) = New Bitmap("c:\green.bmp")
list_view.SmallImageList.Images.item


list_view.SmallImageList.Images.AddStrip  new_img 0
mcsystem.show list_view.SmallImageList.Images.item[list_view.items.count-1]
mcsystem.show list_view.SmallImageList.Images

list_view.SmallImageList.images.item[0] =  new_img
list_view.SmallImageList.images.item[0].GetHbitmap = netDrColor blue

fn fillImage img clr =
(
	for x=1 to img.width-1 do 
		for y=1 to img.height-1 do img.SetPixel x y (netDrColor clr)
)
fillImage list_view.SmallImageList.images.item[0] red
list_view.SmallImageList.images[0].ImageIndex
list_view.SmallImageList.images.item[0].SetPixel --<System.Int32>x <System.Int32>y <System.Drawing.Color>color
















