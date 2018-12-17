gw.setTransform(Matrix3 1)
gw.text [1,0,0] "test" color:green
gw.enlargeUpdateRect #whole
gw.updateScreen()


old_lim = gw.getRndLimits()
lim = gw.getRndLimits()
lim += #(#texture,#illum)
gw.setRndLimits lim
gw.getRndLimits()
gw.getRndMode()


wbit = gw.getViewportDib()
display wbit
wbit.width
wbit.height
get_viewport_name = viewport.GetType()
get_viewport_name == #view_persp_user
view_rect = viewport.getRegionRect viewport.activeViewport
view_rect.h = 180 
view_rect.w = 280
viewport.setRegionRect viewport.activeViewport view_rect
viewport.setBlowupRect viewport.activeViewport view_rect
viewport.getBlowupRect <viewport index>

getViewSize()

tm=viewport.getTM()
viewport.setTM tm


--resets to Max Standard	
viewport.ResetAllViews()
--frames all viewports
actionMan.executeAction 0 "311"
--zoom extens selected
Viewport.ZoomToBounds
--Redraw windows
completeRedraw()
sysInfo.DesktopSize SystemGlobal:DesktopSize [1280,1024]
getMAXWindowPos()--Returns the 3ds max window position in pixels relative to the upper left corner of the desktop. Returns [-4,-4] when the application is maximized.
getMAXWindowSize()--Returns the 3ds max window size in pixels.
gw.getWinSizeX()
gw.getWinSizeY()
getViewSize()
gw.getWinDepth()
viewport.GetType()
getCPTM()
getScreenScaleFactor $.pos
getScreenScaleFactor [0,0,0] --from zero (center scene)
mouse.screenpos
gw.getTextExtent "abc"  --length width | [18,13]

-- Compute the percentage of of the mouse point in screen space
mouse.pos.x / gw.getWinSizeX()
mouse.pos.y / gw.getWinSizeY()
mouse.pos
-- Compute the origin of the slider in screen space
mouse.Pos.x * gw.getWinSizeX()
mouse.Pos.y * gw.getWinSizeY()

focdistance = gw.GetFocalDist()
tm = inverse (viewport.getTM())
---------------------------------------------
--ViewportFrontZoom
(max vpt front ; max zoomext sel)
--ViewportBackZoom
(max vpt back ; max zoomext sel)
--ViewportTopZoom
(max vpt top ; max zoomext sel)
--ViewportBottomZoom
(max vpt bottom ; max zoomext sel)
--ViewportLeftZoom
(max vpt left ; max zoomext sel)
--ViewportRightZoom
(max vpt right ; max zoomext sel)
--=---------------------------------------------
gw.setTransform <matrix3>

max rotateview
max view redo --Performs viewport redo operation
max views undo --Performs viewport undo operation
------------------------------------------------

$.alignToGrid #Vertex               -- align vertices to Grid


-- set active viewport to Top view
viewport.setType #view_top
-- should return what you expect...
viewport.getType()


#view_top -- Top

#view_bottom -- Bottom

#view_right -- Right

#view_left -- Left

#view_front -- Front

#view_back -- Back

#view_persp_user -- Perspective

#view_iso_user -- User

#view_camera -- Camera

#view_spot -- Light

#view_shape -- Shape

#view_grid -- Grid


---------------------------------------------------------
--viewwport matrix
viewport.setTM (matrix3 [0.688355,-0.340543,0.640468] [0.725375,0.323163,-0.607781] [0,0.882948,0.469472] [-3.65436,-9.55707,-119.343])

-------------------------------------------------------------
global Original_Layout = viewport.getLayout ()

viewport.activeViewport = 1
max vpt persp user
viewport.activeViewport = 2
max vpt persp user
viewport.setLayout SmoothRef_Layout --only 2 viewports


viewport.setLayout Original_Layout
-----------------------------------------------------------------------------------------------
--The following is an example that creates an instance of all types of markers, spaced equally:
arr = #("point","hollowBox","plusSign","asterisk","xMarker",
"bigBox","circle","triangle","diamond","smallHollowBox",
"smallCircle","smallTriangle","smallDiamond" )
for i=1 to arr.count do
gw.hMarker [100, (50 + i*10), 50](arr[i] as name)
gw.enlargeUpdateRect #whole
gw.updateScreen() 
-----------------------------------------------------------------------------------------------
local lastViewport

if viewport.activeViewport != lastViewport do
	(
	completeredraw()
	lastViewport = viewport.activeViewport 
	)



		if (viewport.getType() != #view_front and viewport.getLayout() == #layout_4) then 
			(viewport.activeViewport = 2 ; max tool maximize)
		else (viewport.setType #view_front)
		if (viewport.isWire()) do (max wire smooth)
		select P_1 ; max tool zoomextents
	
		
-----------------------------------		
		--Viewport size x y
vs = getviewsize() --[542,392]
--center of viewport x y
c = getviewsize() /2 --[271,196]
--mouse pos in center of viewport
m = mouse.pos --[271,196]

sysInfo.DesktopSize --desktop size in pixels as a <point2> value

x =(getviewsize()).x --542.0
y =(getviewsize()).y --393.0

mouse.pos
mouse.pos - getviewsize() /2


a=mouse.pos.x
b=(getviewsize()).x/2
if a > b then c = a-b
-----------------------------------

with redraw off 
for t=0 to 10 do
(
sliderTime=t
exportFile ("outfile_"+(t as string)+".dxf") #noPrompt selectedOnly:true
)
------------------------------------------------------------------------
updateRect = box2 1278 940 0 0
------------------------------------------------------------------------
textPos=[5,5,1000]
viewText="Text"
updateRect = box2 (textPos.x) (textPos.y-(gw.getTextExtent viewText).y) 0 0
rect = gw.getTextExtent viewText
updateRect.w = rect.x+1
updateRect.h = rect.y+1
gw.clearscreen updateRect useBkg:true
gw.enlargeUpdateRect updateRect 
gw.updateScreen() 
gw.resetUpdateRect()
------------------------------------------------------------------------
--gw.getUpdateRect()
--lastText=(getINISetting (mPath() + "Micra.ini") "MemoryCache" "viewText")
--setINISetting (mPath() + "Micra.ini") "MemoryCache" "viewText" viewText

--DRAW
-- Draw some primitives 
gw.hPolyline #([300,50,16], [300,200,8], [450,250,4]) true --rgb:#(red, blue, green)
gw.setColor #fill (color 255 0 0) --#line
--gw.hPolygon #([200,100,16], [280,100,8], [250,200,4]) #(red, blue, green) #([1.0,.5,0], [0.5,0.5,0], [0,0,0.5])

-- Update the viewports 
gw.enlargeUpdateRect #whole 
gw.updateScreen()


--create a rectangle in center of active viewport
fn displayRect rsize col= --rect_size rect_color =
(
	rect_center = rsize / 2
	vpt_center  = getViewSize() / 2
	rect_pos = vpt_center - rect_center
	p1 =[0           , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
	p2 =[0           , rsize.y, 0] + [rect_pos.x, rect_pos.y, 0]
	p3 =[rsize.x , rsize.y, 0] + [rect_pos.x, rect_pos.y, 0]
	p4 =[rsize.x , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
	updateRect = box2 p2 p4 --<upperleft_point2> <lowerRight_point2>
	updateRect.w +=2
	updateRect.h +=2
	--gw.clearscreen updateRect useBkg:true
	gw.hPolyline #(p1, p2, p3, p4) true rgb:#(col, col, col, col) 
	gw.enlargeUpdateRect updateRect
	gw.updateScreen()
)
displayRect [280,180] red


fn displayRect = --rect_size rect_color =
(
	
	rsize = [280,180]
	col =red
	rect_center = rsize / 2
	vpt_center  = getViewSize() / 2
	rect_pos = vpt_center - rect_center
	p1 =[0           , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
	p2 =[0           , rsize.y, 0] + [rect_pos.x, rect_pos.y, 0]
	p3 =[rsize.x , rsize.y, 0] + [rect_pos.x, rect_pos.y, 0]
	p4 =[rsize.x , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
	updateRect = box2 p2 p4 --<upperleft_point2> <lowerRight_point2>
	updateRect.w +=2
	updateRect.h +=2
	--gw.clearscreen updateRect useBkg:true
	gw.hPolyline #(p1, p2, p3, p4) true rgb:#(col, col, col, col) 
	gw.enlargeUpdateRect #whole 
	gw.updateScreen()
)

unregisterRedrawViewsCallback displayRect 
registerRedrawViewsCallback displayRect
completeRedraw()



fn displayRectIn3D = --rect_size rect_color =
(
	
	local rsize = [280,180]
	local col =red
	gw.setTransform (Matrix3 1)
	gw.setColor #line red
	
	local p1=[0,0,0]
	local p2=[100,0,0]
	local p3=[100,100,0]
	local p4=[0,100,0]
	
	--<upperleft_point2> <lowerRight_point2>
	local updateRect = box2 p2 p4 
	
	gw.Polyline #(p1, p2, p3, p4) true rgb:#(col, col, col, col) 
	gw.enlargeUpdateRect updateRect
	gw.updateScreen()
)

unregisterRedrawViewsCallback displayRectIn3D
registerRedrawViewsCallback displayRectIn3D
completeRedraw()



fn drawBoundingBox theMin theMax =
(
	gw.setTransform(Matrix3 1)
	local lineArrays = #
	(
		#(theMin ,[theMin.x, theMin.y, theMax.z], [theMin.x, theMax.y, theMax.z],[theMin.x, theMax.y, theMin .z]),
		#(theMax ,[theMax.x, theMin.y, theMax.z], [theMax.x, theMin.y, theMin.z],[theMax.x, theMax.y, theMin .z]),
		#(theMin ,[theMax.x, theMin.y, theMin.z]),
		#([theMin.x,theMax.y,theMin.z] ,[theMax.x, theMax.y, theMin.z]),
		#([theMin.x,theMax.y,theMax.z] ,[theMax.x, theMax.y, theMax.z]),
		#([theMin.x,theMin.y,theMax.z] ,[theMax.x, theMin.y, theMax.z])
	)

	gw.setColor #line yellow
	for lines in lineArrays do gw.polyline lines true
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

fn drawBBoxesForSelection =
(
	for o in selection do drawBoundingBox o.min o.max
)

unregisterRedrawViewsCallback drawBBoxesForSelection
registerRedrawViewsCallback drawBBoxesForSelection 
completeRedraw()


/*
$.dir
$.min
$.max
$.rotation
$.rotation.x
$.transform

obj = $
obj.objectoffsetscale
tm = obj.transform
tm_word = tm
tm_word.rotation = quat 0 0 0 0 

tm.min
in coordsys local getvert obj 1
in coordsys local $.min





--expert mode

(
--Variables
UserInt = cui.getConfigFile()

--Toggle structure
if (cui.getExpertMode()) then 
	(
cui.expertModeOff()
trackbar.visible = true
timeslider.setvisible true

	)
else
	(
cui.expertModeOn()
trackbar.visible = false
timeslider.setvisible false
maxops.loadCUIFile "JHN.cui"
	)
)
*/




/*
if CamRoll != undefined do DestroyDialog CamRoll
rollout CamRoll "camera match"
(
	Checkbutton chkPoint "pick point"
	
	fn TheMousePos v = [v.x,v.y,0]
	
	fn CheckView v =
	(
	AVNum = viewport.activeViewport
	if v.x < 0 then AVNum -=1 else if v.x > gw.getWinSizeX() do AVNum +=1
	if v.y < 0 then AVNum -=2 else if v.y > gw.getWinSizeY() do AVNum +=2
	AVNum
	)
	
	fn drawFn=
	(
	viewport.setLayout #layout_4
	gw.setTransform (viewport.getTM())
	
	tool screenDraw
	(
	On MousePoint arg do
	(
	viewport.activeViewport = CheckView viewPoint
	gw.setTransform (viewport.getTM())
	curPoint = TheMousePos viewPoint
	gw.wMarker curPoint #xMarker
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
	)
	On MouseAbort arg do
	(
	#stop
	)
	)
	startTool screenDraw
	print "test"
	enableSceneRedraw()
	)
	
	on ChkPoint changed arg do
	(
	if arg then
	(
	enableSceneRedraw()
	disableSceneRedraw()
	drawFn()
	)else
	(
	enableSceneRedraw()
	)
	)
)
createdialog CamRoll
*/


fn getViewDirectionRay =
(
	-- The affine TM transforms from world coords to view coords
	-- so we need the inverse of this matrix
	local coordSysTM = Inverse(getViewTM())
	-- The Z axis of this matrix is the view direction.
	local viewDir = -coordSysTM.row3
	-- get the view position from this matrix
	local viewPt = coordSysTM.row4
	return ray viewPt viewDir
)
getViewSize()
viewport.GetFOV()
viewport.GetScreenScaleFactor [0,0,0]
getCPTM()
gw.getFocalDist()
viewport.ZoomToBounds  false [0,0,0] [0,0,50]



fn getActiveViewportCenter =
(
	max_size = getMAXWindowSize()
	max_pos = getMAXWindowPos()
	view_size = getViewSize()
	view_count = viewport.numViews
	view_which = viewport.activeViewport
	
	view_type =  case viewport.GetLayout() of --wip
	(
		#layout_1  :()
		#layout_2v :()
		#layout_2h :()
		#layout_2ht :()
		#layout_2hb :()
		#layout_3vl :()
		#layout_3vr :()
		#layout_3ht :()
		#layout_3hb :()
		#layout_4vl :()
		#layout_4vr :()
		#layout_4ht :()
		#layout_4hb :()
		#layout_4   :()
	)
	if viewport.GetLayout() != #layout_4 do return false --wip
	
	view_pos = case view_which of
	(
		1:([0,0,0])
		2:()
		3:()
		4:()
	)
)

getViewportCenter()

dnControl=dotNetClass "system.windows.forms.control"
maxHwnds=(windows.getChildrenHWND #max)
for i = 1 to maxHwnds.count do
(
	hWnd=dnControl.FromChildHandle (dotNetObject "System.IntPtr" maxHwnds[i][1])
	if hWnd!=undefined do print hWnd
)


  fn mapWorldToScreen pos =
   (
       width=gw.getWinSizeX()
       height=gw.getWinSizeY()
   
       thePos = pos * viewport.getTM()
       screenOrigin = mapScreenToView [0,0] (thePos.z) [width,height]
   
       worldSize = screenOrigin*2
       xAspect = width/(abs worldSize.x)
       yAspect = height/(abs worldSize.y)
   
       screenPos=point2 (xAspect *(thePos.x-screenOrigin.x)) (-(yAspect*(thePos.y-screenOrigin.y)))
       if (screenPos.x) < 0 then (screenPos.x=0)
       if (screenPos.y) < 0 then (screenPos.y=0)
       
       screenPos.x = screenPos.x as integer
       screenPos.y = screenPos.y as integer
       
       screenPos
   )
   mapWorldToScreen [0,0,0]
   
   
   
    -- Position a rollout on the objects pivot.
global myrollout

rollout myrollout "myRollOut"
(
	fn mapWorldToScreen pos =
	(
		width=gw.getWinSizeX()
		height=gw.getWinSizeY()
		
		thePos = pos * viewport.getTM()
		screenOrigin = mapScreenToView [0,0] (thePos.z) [width,height]
		
		worldSize = screenOrigin*2
		xAspect = width/(abs worldSize.x)
		yAspect = height/(abs worldSize.y)
		
		screenPos=point2 (xAspect *(thePos.x-screenOrigin.x)) (-(yAspect*(thePos.y-screenOrigin.y)))
		if (screenPos.x) < 0 then (screenPos.x=0)
		if (screenPos.y) < 0 then (screenPos.y=0)
		
		screenPos.x = screenPos.x as integer
		screenPos.y = screenPos.y as integer
		
		screenPos
	)

	fn setpos =
		if selection[1] != undefined then
			setDialogPos myrollout (mouse.screenpos - mouse.pos + (mapWorldToScreen selection[1].pos))

	fn createCallback =
		registerRedrawViewsCallback myrollout.setpos

	fn killCallback =
		unRegisterRedrawViewsCallback myrollout.setpos
	
	button mybutton0 "Reposition"
	button mybutton1 "Create Callback"
	button mybutton2 "Kill Callback"
	
	on mybutton0 pressed do setpos()
	on mybutton1 pressed do createCallback()
	on mybutton2 pressed do killCallback()
	on myrollout open do setpos()
	
)
createDialog myrollout
   
   ---OR
   
  
  -- Position a rollout on the objects pivot.
  global myrollout
  try(destroyDialog myRollout)catch()
  rollout myrollout "myRollOut"
  (
  	fn setpos =
  		if selection[1] != undefined then
  		(
  			gw.setTransform (matrix3 1)
  			setDialogPos myrollout (mouse.screenpos - mouse.pos + (gw.wTranspoint selection[1].pos))
  		)
  
  	fn createCallback =
  		registerRedrawViewsCallback myrollout.setpos
  
  	fn killCallback =
  		unRegisterRedrawViewsCallback myrollout.setpos
  	
  	button mybutton0 "Reposition"
  	button mybutton1 "Create Callback"
  	button mybutton2 "Kill Callback"
  	
  	on mybutton0 pressed do setpos()
  	on mybutton1 pressed do createCallback()
  	on mybutton2 pressed do killCallback()
  	on myrollout open do setpos()
  	on myrollout close do killCallback()
  )
  createDialog myrollout