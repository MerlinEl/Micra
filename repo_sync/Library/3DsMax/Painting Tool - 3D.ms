(

global MicroPaint_CanvasRollout

try(destroyDialog MicroPaint_CanvasRollout)catch()

local isErasing = isDrawing = false

local bitmapX = bitmapY = 512

local bitmapx_1 = bitmapx-1

local bitmapy_1 = bitmapy-1

 

local temp_bitmap_filename = (getDir #preview +"/microPaint_temp.tga")

local theCanvasBitmap = bitmap bitmapX bitmapY color:white filename:temp_bitmap_filename

local theBackgroundBitmap = bitmap bitmapX bitmapY color:white

local currentPos = lastPos = [0,0]

local theChannel = 1

local theObj = undefined

 

local bary = [0,0,0]

local faceIndex = 1

 

rcMenu CanvasMenu 

(

subMenu "File"

(

menuItem new_menu "New"

menuItem open_menu "Open..."

menuItem save_as "Save As..."

separator file_menu_1

menuItem quit_tool "Quit"  

)

subMenu "Edit" 

( 

menuItem commit_menu "Commit Changes"

separator edit_menu_1

menuItem uv_menu "Get UV Coordinates..."

menuItem paint3d_menu "Toggle 3D Painting..."

)

on commit_menu picked do copy theCanvasBitmap theBackgroundBitmap

 

on uv_menu picked do MicroPaint_CanvasRollout.unwrapTexture()

on paint3d_menu picked do MicroPaint_CanvasRollout.startPainting3D()

 

 

subMenu "Help" 

( 

menuItem about_tool "About MicroPaint..." 

)

 

on new_menu picked do 

(

theBackgroundBitmap = theCanvasBitmap = bitmap bitmapX bitmapY color:MicroPaint_CanvasRollout.paperColor.color filename:temp_bitmap_filename

MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 

)

 

on open_menu picked do 

(

theOpenBitmap= selectBitmap()

if theOpenBitmap != undefined do

(

copy theOpenBitmap theCanvasBitmap

copy theOpenBitmap theBackgroundBitmap 

close theOpenBitmap

MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 

)

)

 

on save_as picked do

(

theSaveName = getSaveFileName types:"BMP (*.bmp)|*.bmp|Targa (*.tga)|*.tga|JPEG (*.jpg)|*.jpg"

if theSaveName != undefined do

(

theCanvasBitmap.filename = theSaveName

save theCanvasBitmap

theCanvasBitmap.filename = temp_bitmap_filename

)

)

on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."

on quit_tool picked do destroyDialog MicroPaint_CanvasRollout

)

 

 

fn mesh_filter obj = superclassof obj == GeometryClass and classof obj != TargetObject

 

rollout MicroPaint_CanvasRollout "MicroPaint"

(

bitmap theCanvas pos:[0,0] width:bitmapX height:bitmapY bitmap:theCanvasBitmap

colorpicker inkColor height:16 modal:false color:black across:6

colorpicker paperColor height:16 modal:false color:white

checkbutton autoSave "AutoSave" width:70 offset:[0,-3] highlightcolor:(color 255 200 200)

checkbutton airBrush "AirBrush" width:70 offset:[0,-3] highlightcolor:(color 200 255 200)

spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30

spinner BrushSize "Size" range:[1,50,1] type:#integer fieldwidth:40

listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90

 

pickbutton pickMesh "Pick Mesh" width:90 height:30 highlightcolor:(color 200 200 255) pos:[bitmapX+5,140] filter:mesh_filter autodisplay:true

 

on pickMesh picked obj do 

(

if obj != undefined do 

  (

   theObj = Obj

   try

   (

    copy theObj.material.diffusemap.bitmap theCanvasBitmap

    copy theObj.material.diffusemap.bitmap theBackgroundBitmap 

    theCanvas.bitmap = theCanvasBitmap 

   )catch() 

  ) 

) 

 

 

checkbutton paint3D "3D PAINT" width:90 height:50 highlightcolor:(color 200 200 255) pos:[bitmapX+5,180]

 

fn paintBrush pos =

(

if isErasing then 

thePaintColor = (getPixels theBackgroundBitmap pos 1)[1]

else

thePaintColor = inkColor.color

if thePaintColor == undefined then thePaintColor = white

 

case BrushShape.selection of

(

1: ( 

if distance pos currentPos <= BrushSize.value/2 do

setPixels theCanvasBitmap pos #(thePaintColor)

)

2: setPixels theCanvasBitmap pos #(thePaintColor)

3: ( 

theFactor = (distance pos currentPos) / (BrushSize.value/2.0)

if theFactor <= 1.0 do

(

theFactor = sin ( 90.0 * theFactor)

thePixels = getPixels theCanvasBitmap pos 1

if thePixels[1] != undefined do

(

thePixels[1] = (thePixels[1] * theFactor) + (thePaintColor * (1.0 - theFactor))

setPixels theCanvasBitmap pos thePixels

)

)

)--end case 3

)--end case

)--end fn

 

fn drawStroke lastPos pos drawIt: =

(

currentPos = lastPos

deltaX = pos.x - lastPos.x

deltaY = pos.y - lastPos.y

maxSteps = amax #(abs(deltaX),abs(deltaY))

deltaStepX = deltaX / maxSteps 

deltaStepY = deltaY / maxSteps 

for i = 0 to maxSteps do

(

if airBrush.checked then

for b = 1 to (BrushSize.value / AirBrushSpeed.value) do

paintBrush (currentPos + (random [-BrushSize.value/2,-BrushSize.value/2] [BrushSize.value/2,BrushSize.value/2] ))

else

for b = -BrushSize.value/2 to BrushSize.value/2 do

for c = -BrushSize.value/2 to BrushSize.value/2 do

paintBrush (currentPos + [c,b]) 

currentPos += [deltaStepX, deltaStepY]

)

if drawIt== true or drawIt == unsupplied do theCanvas.bitmap = theCanvasBitmap 

)

 

fn unwrapTexture =

(

if theObj != undefined then

(

theMesh = snapshotAsMesh theObj

if meshop.getMapSupport theMesh theChannel do

(

faceCount = meshop.getNumMapFaces theMesh theChannel 

for f = 1 to faceCount do

(

theFace = meshop.getMapFace theMesh theChannel f

vert1= meshop.getMapVert theMesh theChannel theFace.x

vert2= meshop.getMapVert theMesh theChannel theFace.y

vert3= meshop.getMapVert theMesh theChannel theFace.z

 

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] drawIt:false

drawStroke [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

)

) 

theCanvas.bitmap = theCanvasBitmap 

save theCanvasBitmap 

if theObj.material == undefined do theObj.material = Standard()

if theObj.material.diffusemap == undefined do

theObj.material.diffusemap = bitmapTexture filename:temp_bitmap_filename 

showTextureMap theObj.material true

autoSave.checked = true

)

)

 

 

fn StartStroke = ( thePainterInterface.undoStart() )

fn PaintStroke = 

(

theMesh = theObj.mesh

thePainterInterface.getHitFaceData &bary &faceIndex theObj 0

theFace = meshop.getMapFace theMesh theChannel faceIndex

vert1= meshop.getMapVert theMesh theChannel theFace.x

vert2= meshop.getMapVert theMesh theChannel theFace.y

vert3= meshop.getMapVert theMesh theChannel theFace.z

thePoint = bary.x*vert1 + bary.y*vert2 + bary.z*vert3

drawStroke [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] 

thePainterInterface.clearStroke()

)

fn EndStroke = 

(

thePainterInterface.undoAccept()

if autoSave.checked do 

(

save theCanvasBitmap 

try(theObj.material.diffsemap.bitmap = theCanvasBitmap)catch()

) 

)

 

fn CancelStroke = (thePainterInterface.undoCancel())

 

fn SystemEndPaintSession = ( paint3D.checked = false ) 

 

fn startPainting3D =

(

if thePainterInterface.InPaintMode() or theObj == undefined then 

(

thePainterInterface.EndPaintSession()

paint3D.checked = false

)

else

(

paint3D.checked = true

thePainterInterface.pointGatherEnable = TRUE

thePainterInterface.initializeNodes 0 #(theObj)

thePainterInterface.offMeshHitType = 2

thePainterInterface.ScriptFunctions startStroke paintStroke endStroke cancelStroke SystemEndPaintSession 

thePainterInterface.startPaintSession()

)

)

 

on paint3D changed state do startPainting3D() 

 

on MicroPaint_CanvasRollout lbuttondown pos do

(

lastPos = pos

isDrawing = true

isErasing = false

drawStroke lastPos pos

)

on MicroPaint_CanvasRollout rbuttondown pos do

(

lastPos = pos

isErasing = isDrawing = true

drawStroke lastPos pos

)

on MicroPaint_CanvasRollout lbuttonup pos do 

(

isErasing = isDrawing = false

if autoSave.checked do save theCanvasBitmap 

) 

on MicroPaint_CanvasRollout rbuttonup pos do 

(

isErasing = isDrawing = false

if autoSave.checked do save theCanvasBitmap 

) 

on autoSave changed state do if state do save theCanvasBitmap 

 

on MicroPaint_CanvasRollout mousemove pos do

(

if isDrawing do drawStroke lastPos pos

lastPos = pos

)

)

createDialog MicroPaint_CanvasRollout (bitmapx+100) (bitmapy+30) menu:CanvasMenu 

MicroPaint_CanvasRollout.theCanvas.bitmap = theBackgroundBitmap 

)

 

 

Step-By-Step
--Code in green has not changes since the previous version!

macroScript MicroPaint category:"HowTo"

(

global MicroPaint_CanvasRollout

try(destroyDialog MicroPaint_CanvasRollout)catch()

local isErasing = isDrawing = false

local bitmapX = bitmapY = 512

local bitmapx_1 = bitmapx-1

local bitmapy_1 = bitmapy-1

 

local temp_bitmap_filename = (getDir #preview +"/microPaint_temp.tga")

local theCanvasBitmap = bitmap bitmapX bitmapY color:white filename:temp_bitmap_filename

local theBackgroundBitmap = bitmap bitmapX bitmapY color:white

local currentPos = lastPos = [0,0]

local theChannel = 1

local theObj = undefined

local bary = [0,0,0]

This variable will be used by the PainterInterface to return the Barycentric Coordinates of the hit point inside the face.

local faceIndex = 1

This variable will be used by the PainterInterface to return the index of the face that has been hit.

 

rcMenu CanvasMenu 

(

subMenu "File"

(

menuItem new_menu "New"

menuItem open_menu "Open..."

menuItem save_as "Save As..."

separator file_menu_1

menuItem quit_tool "Quit"  

)

subMenu "Edit" 

( 

menuItem commit_menu "Commit Changes"

separator edit_menu_1

menuItem uv_menu "Get UV Coordinates..."

menuItem paint3d_menu "Toggle 3D Painting..."

This is the new "Toggle 3D Painting" menu item. We will also add a very prominent button to the main User Interface...

)

on commit_menu picked do copy theCanvasBitmap theBackgroundBitmap

on uv_menu picked do MicroPaint_CanvasRollout.unwrapTexture()

 

on paint3d_menu picked do MicroPaint_CanvasRollout.startPainting3D()

This is the handler of the new "Toggle 3D Painting" menu item. It calls a function that will toggle the PainterInterface on and off.

 

subMenu "Help" 

( 

menuItem about_tool "About MicroPaint..." 

)

 

on new_menu picked do 

(

theBackgroundBitmap = theCanvasBitmap = bitmap bitmapX bitmapY color:MicroPaint_CanvasRollout.paperColor.color filename:temp_bitmap_filename

MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 

)

 

on open_menu picked do 

(

theOpenBitmap= selectBitmap()

if theOpenBitmap != undefined do

(

copy theOpenBitmap theCanvasBitmap

copy theOpenBitmap theBackgroundBitmap 

close theOpenBitmap

MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 

)

)

 

on save_as picked do

(

theSaveName = getSaveFileName types:"BMP (*.bmp)|*.bmp|Targa (*.tga)|*.tga|JPEG (*.jpg)|*.jpg"

if theSaveName != undefined do

(

theCanvasBitmap.filename = theSaveName

save theCanvasBitmap

theCanvasBitmap.filename = temp_bitmap_filename

)

)

on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."

on quit_tool picked do destroyDialog MicroPaint_CanvasRollout

)

 

 

fn mesh_filter obj = superclassof obj == GeometryClass and classof obj != TargetObject

 

rollout MicroPaint_CanvasRollout "MicroPaint"

(

bitmap theCanvas pos:[0,0] width:bitmapX height:bitmapY bitmap:theCanvasBitmap

colorpicker inkColor height:16 modal:false color:black across:6

colorpicker paperColor height:16 modal:false color:white

checkbutton autoSave "AutoSave" width:70 offset:[0,-3] highlightcolor:(color 255 200 200)

checkbutton airBrush "AirBrush" width:70 offset:[0,-3] highlightcolor:(color 200 255 200)

spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30

spinner BrushSize "Size" range:[1,50,1] type:#integer fieldwidth:40

listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90

 

pickbutton pickMesh "Pick Mesh" width:90 height:30 highlightcolor:(color 200 200 255) pos:[bitmapX+5,140] filter:mesh_filter autodisplay:true

 

on pickMesh picked obj do 

(

if obj != undefined do 

(

theObj = Obj

try

(

copy theObj.material.diffusemap.bitmap theCanvasBitmap

copy theObj.material.diffusemap.bitmap theBackgroundBitmap 

theCanvas.bitmap = theCanvasBitmap 

)catch()

)

)

 

 

checkbutton paint3D "3D PAINT" width:90 height:50 highlightcolor:(color 200 200 255) pos:[bitmapX+5,180]

This is the new checkbutton controlling the painting in 3D space. It will turn blue when enabled.

 

fn paintBrush pos =

(

if isErasing then 

thePaintColor = (getPixels theBackgroundBitmap pos 1)[1]

else

thePaintColor = inkColor.color

if thePaintColor == undefined then thePaintColor = white

 

case BrushShape.selection of

(

1: ( 

if distance pos currentPos <= BrushSize.value/2 do

setPixels theCanvasBitmap pos #(thePaintColor)

)

2: setPixels theCanvasBitmap pos #(thePaintColor)

3: ( 

theFactor = (distance pos currentPos) / (BrushSize.value/2.0)

if theFactor <= 1.0 do

(

theFactor = sin ( 90.0 * theFactor)

thePixels = getPixels theCanvasBitmap pos 1

if thePixels[1] != undefined do

(

thePixels[1] = (thePixels[1] * theFactor) + (thePaintColor * (1.0 - theFactor))

setPixels theCanvasBitmap pos thePixels

)

)

)--end case 3

)--end case

)--end fn

 

fn drawStroke lastPos pos drawIt: =

(

currentPos = lastPos

deltaX = pos.x - lastPos.x

deltaY = pos.y - lastPos.y

maxSteps = amax #(abs(deltaX),abs(deltaY))

deltaStepX = deltaX / maxSteps 

deltaStepY = deltaY / maxSteps 

for i = 0 to maxSteps do

(

if airBrush.checked then

for b = 1 to (BrushSize.value / AirBrushSpeed.value) do

paintBrush (currentPos + (random [-BrushSize.value/2,-BrushSize.value/2] [BrushSize.value/2,BrushSize.value/2] ))

else

for b = -BrushSize.value/2 to BrushSize.value/2 do

for c = -BrushSize.value/2 to BrushSize.value/2 do

paintBrush (currentPos + [c,b]) 

currentPos += [deltaStepX, deltaStepY]

)

if drawIt== true or drawIt == unsupplied do theCanvas.bitmap = theCanvasBitmap 

)

 

on pickMesh picked obj do if obj != undefined do theObj = Obj

 

fn unwrapTexture =

(

if theObj != undefined then

(

theMesh = snapshotAsMesh theObj

if meshop.getMapSupport theMesh theChannel do

(

faceCount = meshop.getNumMapFaces theMesh theChannel 

for f = 1 to faceCount do

(

theFace = meshop.getMapFace theMesh theChannel f

vert1= meshop.getMapVert theMesh theChannel theFace.x

vert2= meshop.getMapVert theMesh theChannel theFace.y

vert3= meshop.getMapVert theMesh theChannel theFace.z

 

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] drawIt:false

drawStroke [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

)

) 

theCanvas.bitmap = theCanvasBitmap 

save theCanvasBitmap 

if theObj.material == undefined do theObj.material = Standard()

if theObj.material.diffusemap == undefined do

theObj.material.diffusemap = bitmapTexture filename:temp_bitmap_filename 

showTextureMap theObj.material true

autoSave.checked = true

)

)

 

fn StartStroke = ( thePainterInterface.undoStart() )

This function is executed in the beginning of a stroke. See the PainterInterface documentation and the examples for details.

 

fn PaintStroke = 

(

This function performs the painting of a stroke in 3D.

theMesh = theObj.mesh

We take a copy of the TriMesh of the object to paint on.

thePainterInterface.getHitFaceData &bary &faceIndex theObj 0

Then we call this function to get the last face that was hit by the brush (last argument is face index 0 which means "get the last hit"). The variables bary and faceIndex we defined in the beginning of the script are passed "by reference" - the function will write the results into them. After the call, bary will contain the Barycentric coordinates of the hit point inside the face, and faceIndex will contain the index of the face that was last hit. theObj is the variable containing the object we selected in the scene to paint on.

theFace = meshop.getMapFace theMesh theChannel faceIndex

Using this data we get the map face in channel 1 with the same index as the mesh face that was hit.

vert1= meshop.getMapVert theMesh theChannel theFace.x

vert2= meshop.getMapVert theMesh theChannel theFace.y

vert3= meshop.getMapVert theMesh theChannel theFace.z

Next, we read the texture vertices referenced by the map face. 

thePoint = bary.x*vert1 + bary.y*vert2 + bary.z*vert3

 drawStroke [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] 

Now we can calculate the UV coordinates of the hit point using its barycentric coordinates inside the face and the texture vertex coordinates corresponding to that face. 

thePainterInterface.clearStroke()

Finally, we clear the stroke. 

)

 

fn EndStroke = 

(

This function is called at the end of a stroke.

thePainterInterface.undoAccept()

Accept the changes in the undo system...

if autoSave.checked do 

(

If autosaving is enabled, 

save theCanvasBitmap 

save the painting to disk

try(theObj.material.diffsemap.bitmap = theCanvasBitmap)catch()

and try to force the bitmap of the diffuse map channel in the object's material to the painting bitmap value.

) 

)

 

fn CancelStroke = (thePainterInterface.undoCancel())

This function is called when the stroke is canceled.

fn SystemEndPaintSession = ( paint3D.checked = false ) 

This function is called when the painting session is ended. It will make sure the UI button is unchecked if the painting is stopped for some other reason.

 

fn startPainting3D =

(

This function toggles the 3D Painting.

if thePainterInterface.InPaintMode() or theObj == undefined then 

(

If we are already painting or the object is not selected yet,

  thePainterInterface.EndPaintSession()

  paint3D.checked = false

we end the 3D painting session and uncheck the button in the UI.

) 

else

(

If the 3D paining is not active and the mesh scene object has been selected already,

paint3D.checked = true

we make sure that the checkbutton is pressed (as we can start this from the Main menu, too!)

thePainterInterface.pointGatherEnable = TRUE

Enable point gathering.

thePainterInterface.initializeNodes 0 #(theObj)

Initialize the PainterInterface with just the single object that was selected

thePainterInterface.offMeshHitType = 2

Set the behavior for the cases the mesh was not hit to 2 which does not require a mesh. Obviously, there will be no face hit and no painting in this case.

thePainterInterface.ScriptFunctions startStroke paintStroke endStroke cancelStroke SystemEndPaintSession 

Register all previously defined scripted functions with the PainterInterface and

thePainterInterface.startPaintSession()

start the painting!

) 

)

 

on paint3D changed state do startPainting3D() 

If the checkbutton was pressed by the user, call the above function.

 

on MicroPaint_CanvasRollout lbuttondown pos do

(

lastPos = pos

isDrawing = true

isErasing = false

drawStroke lastPos pos

)

on MicroPaint_CanvasRollout rbuttondown pos do

(

lastPos = pos

isErasing = isDrawing = true

drawStroke lastPos pos

)

on MicroPaint_CanvasRollout lbuttonup pos do 

(

isErasing = isDrawing = false

if autoSave.checked do save theCanvasBitmap 

) 

on MicroPaint_CanvasRollout rbuttonup pos do 

(

isErasing = isDrawing = false

if autoSave.checked do save theCanvasBitmap 

) 

on autoSave changed state do if state do save theCanvasBitmap 

 

on MicroPaint_CanvasRollout mousemove pos do

(

if isDrawing do drawStroke lastPos pos

lastPos = pos

)

)

createDialog MicroPaint_CanvasRollout (bitmapx+100) (bitmapy+30) menu:CanvasMenu 

MicroPaint_CanvasRollout.theCanvas.bitmap = theBackgroundBitmap 

)

