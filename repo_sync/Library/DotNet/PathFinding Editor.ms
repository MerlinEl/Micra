rollout PathRollout "PathFinding Editor" width:512 height:440
 (
 dotNetControl dnPictureBox "pictureBox" pos:[0,0] width:392 height:392
 dotNetControl dnVScrollBar "VScrollBar" pos:[392,0] width:16 height:392
 dotNetControl dnHScrollBar "HScrollBar" pos:[0,392] width:392 height:16
 fn mesh_filter obj = superclassof obj == GeometryClass
 fn moveImage =
 (
 dnPictureBox.Left = -dnHScrollBar.Value
 dnPictureBox.Top = -dnVScrollBar.Value
 dnPictureBox.Update()
 )
 fn resizeImageDisplayed zf =
 (
 img = TGA[chanel]
 pbWidth = dnPictureBox.Width
 pbHeight = dnPictureBox.Height
 newWidth = img.width * ZoomFactor
 newHeight = img.height * ZoomFactor

 newTGA = bitmap newWidth newHeight
 copy img newTGA
 setclipboardBitmap newTGA 
 dnPictureBox.image = if clipboardClass.containsimage() then clipboardClass.getImage()


 dnVScrollBar.Maximum = newWidth-pbWidth
 dnHScrollBar.Maximum = newHeight-pbHeight

 --format "large:% ; small:% ; max:%\n" dnVScrollBar.LargeChange dnVScrollBar.SmallChange dnVScrollBar.Maximum
 )
 bitmap paintPath "MaxScript Bmp" pos:[424,304] width:80 height:80
 button btnDraw "PaintObj" pos:[416,272] width:48 height:24 enabled:false
 pickbutton btnPick "Add" pos:[464,272] width:40 height:24 --filter:mesh_filter
 --filter:mesh_filter
 dropdownList ChList "Show by channel" pos:[416,8] width:88 height:40 items:#("no-channel")
 button btnCreate "<create>" pos:[416,56] width:64 height:16 enabled:false
 listbox lbxPlaneList "Object Used" pos:[416,88] width:88 height:12
 progressBar ProgBar "ProgressBar" pos:[408,393] width:104 height:15
 button btnZoomUp "Zoom[+]" pos:[280,408] width:56 height:24
 button btnZoomDown "Zoom[-]" pos:[336,408] width:56 height:24

 on dnVScrollBar ValueChanged EventArgs do
 (
 --format "Vscrool.Value=%\n" dnVScrollBar.value
 moveImage()
 )
 on dnHScrollBar ValueChanged EventArgs do
 (
 --format "Hscrool.Value=%\n" dnHScrollBar.value
 moveImage()
 )
 on PathRollout open do
 (
 dnPictureBox.backColor=(dotNetClass "system.drawing.color").gray

 )
 on btnDraw pressed do
 (
 if paintPath.bitmap!= undefined then
 (
 thePlane[chanel].material = Standard diffusemap:(bitmapTexture filename:(getFileName chanel))
 showTextureMap thePlane[chanel].material true
 )
 else messageBox "Invalid : no bitmap image loaded !"
 )
 on btnPick picked obj do
 (
 ListArray = for i=1 to lbxPlaneList.items.count where (getNodeByName lbxPlaneList.items[i])!=undefined collect lbxPlaneList.items[i]
 lbxPlaneList.items = ListArray
 if obj!=undefined then
 (
 thePlane[chanel] = obj
 btnDraw.enabled = true
 )
 append ListArray obj.name
 lbxPlaneList.items = ListArray
 )
 on ChList selected index do
 (
 chanel = index
 if TGA!=undefined then
 (
 isEnabled = true
 btnCreate.caption = "create_ch:" + chanel as string
 setclipboardBitmap TGA[index] 
 dnPictureBox.image = if clipboardClass.containsimage() then clipboardClass.getImage()
 --if isChecked do zooming 10.0
 )
 )
 on btnCreate pressed do
 (
 img = TGA[chanel]
 setTempBmpFile img chanel
 obj =plane realWorldMapSize:false width:( img.width*2) length:( img.height*2) widthsegs:1 lengthsegs:1 transform:(matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0]) name =("channel_" + ch as string) 
 obj.material = Standard diffusemap: (bitmapTexture filename:(getFileName chanel))
 showTextureMap obj.material true
 thePlane[chanel] = obj
 )
 on btnZoomUp pressed do
 (
 ZoomFactor*=2.0
 resizeImageDisplayed ZoomFactor
 )
 on btnZoomDown pressed do
 (
 ZoomFactor/=2.0
 resizeImageDisplayed ZoomFactor
 )
 )
 createDialog PathRollout --menu:theMenu
 