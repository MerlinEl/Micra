(

global MicroPaint_CanvasRollout

try(destroyDialog MicroPaint_CanvasRollout)catch()

local isErasing = isDrawing = false

local bitmapX = bitmapY = 512

local bitmapx_1 = bitmapx-1

local bitmapy_1 = bitmapy-1

local temp_bitmap_filename = (getDir #preview +"/microPaint_temp.bmp")

local theCanvasBitmap = bitmap bitmapX bitmapY color:white filename:temp_bitmap_filename

local theBackgroundBitmap = bitmap bitmapX bitmapY color:white

local currentPos = lastPos = [0,0]

 

local theChannel = 1

local theObj = undefined

 

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

)

on commit_menu picked do copy theCanvasBitmap theBackgroundBitmap

on uv_menu picked do MicroPaint_CanvasRollout.unwrapTexture()

 

 

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

checkbutton autoSave "AutoSave" width:70 

checkbutton airBrush "AirBrush" width:70 

spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30

spinner BrushSize "Size" range:[1,50,1] type:#integer fieldwidth:40

listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90

 

 

--NEW PICK BUTTON AND HANDLER:

pickbutton pickMesh "Pick Mesh" width:90 height:30 pos:[bitmapX+5,140] filter:mesh_filter autodisplay:true

 

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

--END NEW PICK BUTTON AND HANDLER

 

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

 

 

--NEW UNWRAP TEXTURE FUNCTION STARTS HERE

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

drawStroke [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] [vert2.x * bitmapx, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

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

--NEW UNWRAP TEXTURE FUNCTION END HERE

 

on autoSave changed state do if state do save theCanvasBitmap 

 

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

In order to calculate the position of the UV coordinates inside the bitmap, we have to count the pixels as the size of the bitmap minus one (for example, 0 to 511 and not 1 to 512). To make out life easier, we define two variables to store these corrected values.

 

local temp_bitmap_filename = (getDir #preview +"/microPaint_temp.tga")

local theCanvasBitmap = bitmap bitmapX bitmapY color:white filename:temp_bitmap_filename

In order to be able to save the current painting to a temporary file on disk, we have to define a file name and assign it to the bitmap. The file name is stored in a local variable which will be used in other parts of the script to access it. TGA appears to be faster to save than BMP for example, but you can save to any format you want.

 

local theBackgroundBitmap = bitmap bitmapX bitmapY color:white

local currentPos = lastPos = [0,0]

 

local theChannel = 1

This is the map channel to read from. You could add a User Interface spinner to control its value... For now, we will work with channel 1 only.

local theObj = undefined

This variable will store the mesh object to access the UV coordinates from.

 

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

)

We add a new menu item which will be used to acquire texture coordinates from a scene object.

on commit_menu picked do copy theCanvasBitmap theBackgroundBitmap

 

on uv_menu picked do MicroPaint_CanvasRollout.unwrapTexture()

If the user picked the menu item, we call a new function which will be defined inside the rollout. (see below)

 

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

After saving to a new file name, set back the filename to the temporary location, otherwise autosaving would start writing into the new file and we don't want this to happen!

 

)

)

on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."

on quit_tool picked do destroyDialog MicroPaint_CanvasRollout

)

 

fn mesh_filter obj = superclassof obj == GeometryClass and classof obj != TargetObject

This function allows us to pick only geometry objects except target objects. It will be used as a filter function by a new pickbutton User Interface control.

 

rollout MicroPaint_CanvasRollout "MicroPaint"

(

bitmap theCanvas pos:[0,0] width:bitmapX height:bitmapY bitmap:theCanvasBitmap

 

colorpicker inkColor height:16 modal:false color:black across:6

To accommodate the new autoSave option, we increase the across parameter to 6.

 

colorpicker paperColor height:16 modal:false color:white

 

checkbutton autoSave "AutoSave" width:70 

This new checkbutton will control whether the paiting is constantly saved to disk after each stroke.

 

checkbutton airBrush "AirBrush" width:70 

spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30

 

spinner BrushSize "Size" range:[1,50,1] type:#integer fieldwidth:40

The default brush size is now 1. This is to avoid drawing a texture unwrapping with a thickness of 10 which can be very slow...

 

listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90

 

pickbutton pickMesh "Pick Mesh" width:90 height:30 pos:[bitmapX+5,140] filter:mesh_filter autodisplay:true

This pickbutton will be used to select the scene object to unwrap the texture coordinates. It uses the new optional keyword autoDisplay added to 3ds Max 7. When set to true, it will display the name of the picked object on the button automatically. In 3ds Max 6 and earlier, the option will be ignored, but the script will still function correctly!

Pickbutton 

 

on pickMesh picked obj do 

(

This is the event handler of the pickbutton. If the user picked an object, it will be passed to the handler in the obj variable.

 

if obj != undefined do 

(

If the obj variable contains a valid object (in other words, the user did not cancel the picking), then

 

theObj = Obj

we first assign the picked object to our new variable which will store the pick during the painting session.

try

(

copy theObj.material.diffusemap.bitmap theCanvasBitmap

copy theObj.material.diffusemap.bitmap theBackgroundBitmap 

theCanvas.bitmap = theCanvasBitmap 

Then we try to read the diffusemap bitmap of the object and copy it into the canvas and background bitmaps of the painting tool, then assign it to the UI. 

If there is no bitmap there, the error will be trapped and nothing will happen.

)catch() 

)

)

 

 

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

We add a new optional keyword to the drawStroke function. If it is set to false, the stroke will be drawn but the bitmap will not be updated in the rollout. If it is true or not supplied, the bitmap will be updated after the stroke. This is to allow for faster drawing of the unwrapped texture without updating the view after each texture face!

 

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

If the new switch is set to true or not set at all, we update the display as before, otherwise the update is skipped!

)

 

fn unwrapTexture =

(

This is the new function which performs the selection of an object, the unwrapping of the texture coordinates and the material/texture assignment.

if theObj != undefined then

(

If the user clicked a valid object...

theMesh = snapshotAsMesh theObj

...we extract the mesh from the top of its stack.

if meshop.getMapSupport theMesh theChannel do

(

If the selected object supports the specified channel, 

faceCount = meshop.getNumMapFaces theMesh theChannel 

we read the number of texture faces in that channel...

for f = 1 to faceCount do

(

...and repeat the following code for every face found in the mesh:

theFace = meshop.getMapFace theMesh theChannel f

This is the map face definition. It returns a Point3 value where .x .y and .z are indices pointing at the texture vertices the face is using.

vert1= meshop.getMapVert theMesh theChannel theFace.x

vert2= meshop.getMapVert theMesh theChannel theFace.y

vert3= meshop.getMapVert theMesh theChannel theFace.z

Using this data, we read the 3 vertices of the face. Each one is a Point3 value containing the actual U, V and W values. We will draw only the UV and discard the W though.

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

We call the drawStroke function using the first and second texture vertex coordinates multiplied by the size of the bitmap. The flag drawIt is set to false to speed up the generation of the image. If you would change it to true, you could watch the function drawing interactively in the image, but this could take a very long time.

The calculation of the coordinates is based on the fact that the lower left corner of the UV space has coordinates 0,0 and the upper right has coordinates 1,1. 

The bitmap on the other hand has its UPPER left corner as 0,0 and its lower right corner as bitmapx-1,bitmapy-1 (511,511 in our example). 

So in order to convert the UV coordinates in pixel coordinates, we multiply the width resp. height of the bitmap by the U resp. V value, and turn the vertical result upside-down by subtracting from the height.

drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] drawIt:false

drawStroke [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false

We call the drawStroke function for the other two pairs of vertices, thus drawing all edges of the face.

)

) 

theCanvas.bitmap = theCanvasBitmap 

Now we can update the rollout bitmap to show the result.

save theCanvasBitmap 

We can also save the bitmap to its temporary location.

if theObj.material == undefined do theObj.material = Standard()

If the selected object has no material, we assign a new material.

try

(if theObj.material.diffusemap == undefined do

theObj.material.diffusemap = bitmapTexture filename:temp_bitmap_filename 

If the selected object's diffusemap is not defined yet, we try to assign a new texure map pointing at the temporary copy of our painting. If the object does not have a standard material assigned, trying to access the diffusemap channel will cause an error which will be prevented by the try()catch() context.

showTextureMap theObj.material true

We press the Show Map In Viewport of the material at object level. If the texture assignment was successful, the bitmap should be shown in the viewport.

autoSave.checked = true

If everything went ok, we can also turn the new autosave option on to force the bitmap to update on the selected object as you paint...


)catch()

)

)

 

on autoSave changed state do if state do save theCanvasBitmap 

If the user checked the new checkbutton, the bitmap will be saved to its temporary location immediately.

 

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

If the new checkbutton is pressed, the bitmap will be saved to its temporary location after each stroke.

 

) 

on MicroPaint_CanvasRollout rbuttonup pos do 

(

isErasing = isDrawing = false

 

if autoSave.checked do save theCanvasBitmap 

If the new checkbutton is pressed, the bitmap will be saved to its temporary location after each erase stroke.

 

) 

 

on MicroPaint_CanvasRollout mousemove pos do

(

if isDrawing do drawStroke lastPos pos

lastPos = pos

)

)

createDialog MicroPaint_CanvasRollout (bitmapx+100) (bitmapy+30) menu:CanvasMenu 

MicroPaint_CanvasRollout.theCanvas.bitmap = theBackgroundBitmap 

)
