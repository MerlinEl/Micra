
(
global MicroPaint_CanvasRollout
try(destroyDialog MicroPaint_CanvasRollout)catch()
local isDrawing = false
local bitmapX = bitmapY = 512
local theCanvasBitmap = bitmap bitmapX bitmapY color:white
local theBackgroundBitmap = bitmap bitmapX bitmapY color:white
local currentPos = lastPos = [0,0]

 

--NEW MENU CODE STARTS HERE
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

subMenu "Edit" ( )
subMenu "Help" 
( 
menuItem about_tool "About MicroPaint..." 
)

on new_menu picked do 
(
theBackgroundBitmap = theCanvasBitmap = bitmap bitmapX bitmapY color:MicroPaint_CanvasRollout.paperColor.color
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
)
)

on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."
on quit_tool picked do destroyDialog MicroPaint_CanvasRollout
)

--NEW MENU CODE END HERE

rollout MicroPaint_CanvasRollout "MicroPaint"
(
bitmap theCanvas pos:[0,0] width:bitmapX height:bitmapY bitmap:theCanvasBitmap
colorpicker inkColor height:16 modal:false color:black across:5
colorpicker paperColor height:16 modal:false color:white
checkbutton airBrush "AirBrush" width:50 
spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30
spinner BrushSize "Size" range:[1,50,10] type:#integer fieldwidth:40
listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90

 
fn paintBrush pos =
(
case BrushShape.selection of
(

1: ( 

if distance pos currentPos <= BrushSize.value/2 do
setPixels theCanvasBitmap pos #(inkColor.color)
)

2: setPixels theCanvasBitmap pos #(inkColor.color)
3: ( 

theFactor = (distance pos currentPos) / (BrushSize.value/2.0)
if theFactor <= 1.0 do

(
theFactor = sin ( 90.0 * theFactor)
thePixels = getPixels theCanvasBitmap pos 1
if thePixels[1] != undefined do
(

thePixels[1] = (thePixels[1] * theFactor) + (inkColor.color * (1.0 - theFactor))
setPixels theCanvasBitmap pos thePixels
)
)
)--end case 3
)--end case
)--end fn
 
fn drawStroke lastPos pos =
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
(
for b = 1 to (BrushSize.value / AirBrushSpeed.value) do
paintBrush (currentPos + (random [-BrushSize.value/2,-BrushSize.value/2] [BrushSize.value/2,BrushSize.value/2] ))
)
else
for b = -BrushSize.value/2 to BrushSize.value/2 do
for c = -BrushSize.value/2 to BrushSize.value/2 do
paintBrush (currentPos + [c,b]) 
currentPos += [deltaStepX, deltaStepY]
)
theCanvas.bitmap = theCanvasBitmap 
)
on MicroPaint_CanvasRollout lbuttondown pos do

(
lastPos = pos
isDrawing = true
drawStroke lastPos pos
)
on MicroPaint_CanvasRollout lbuttonup pos do isDrawing = false
on MicroPaint_CanvasRollout mousemove pos do
(
if isDrawing do drawStroke lastPos pos
lastPos = pos
)
)
createDialog MicroPaint_CanvasRollout (bitmapx+100) (bitmapy+30) menu:CanvasMenu 
MicroPaint_CanvasRollout.theCanvas.bitmap = theBackgroundBitmap 
)
