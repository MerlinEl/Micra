		--flp_cat.controls.RemoveAt 1 -- first item is 0
		--print (flp_cat.controls.Item(11)).text
		--print (flp_cat.controls.Item(11)).name
		--flp_cat.controls.RemoveByKey "vidle"
		--print flp_cat.controls.count
		--mc2system.show flp_cat






rollout roll_imatges "Image List" (
button btn_scan "Scan Dir" pos:[10,10]
label lbl_path pos:[100,16]
dotNetControl lv_imatges "System.Windows.Forms.ListView" pos:[10,40] width:360 height:650
fn myCallback = ( return false )
fn carrega_imatges paths_imatges = (
fn callback_abort = ( dotnetObject "System.Drawing.Image+GetThumbnailImageAbort" myCallback())
local ptr_callback_abort = dotNetClass "System.IntPtr"
Llista_Imatges = dotNetObject "System.Windows.Forms.ImageList"
Llista_Imatges.ColorDepth = Llista_Imatges.ColorDepth.Depth24Bit
Llista_Imatges.ImageSize = dotNetObject "System.Drawing.Size" 160 120
for path_imatge in paths_imatges do (
thumb = dotNetObject "System.Drawing.Bitmap" path_imatge
-- Calling GetThumbnailImage this way doesn't work :(
-- thumb = thumb.GetThumbnailImage 160 120 (callback_abort()) (ptr_callback_abort.Zero)
Llista_Imatges.images.add thumb
)
return Llista_Imatges
)
fn inicialitzaListView lv = (
lv.View = (dotNetClass "System.Windows.Forms.View").Details
lv.borderstyle = (dotnetclass "System.Windows.Forms.BorderStyle").fixedsingle
lv.showitemtooltips = true
lv.gridlines = true
lv.checkboxes = false
lv.labeledit = false
lv.Columns.add "Image" 164
lv.Columns.add "Name" 196
)
fn ompleListView lv llista_imatges = (
lv.Clear()
lv.Columns.add "Image" 164
lv.Columns.add "Name" 178
lv.SmallImageList = carrega_imatges llista_imatges
for i = 1 to llista_imatges.count do (
imatge = llista_imatges[i]
ListViewOps.AddLvItem lv pTextItems:#("",(getFilenameFile imatge)) pImgIndex:(i-1)
)
)
on btn_scan pressed do (
dir_imatges = getSavePath caption:"Choose image dir:"
if dir_imatges != undefined do (
lbl_path.text = dir_imatges
fitxers_jpg = getFiles (dir_imatges + "\\*.jpg")
ompleListView lv_imatges fitxers_jpg
)
)
on roll_imatges open do (
inicialitzaListView lv_imatges
)
)
createDialog roll_imatges 380 700