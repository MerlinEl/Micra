----------------------------
----------------------------

(
	fn mouseTracking msg ir obj faceNum shift ctrl alt =
	(
		format "%\n" msg

		case msg of
		(
			#mouseAbort: (print "user pressed escape")
			#freeMove: ()
			#mousePoint: ()
			#mouseMove: ()
		)
		if msg == #mouseAbort then #abort else #continue 
	)
	act = mouseTrack trackCallback:mouseTracking
	format "act: %\n" act
)




fn Find3DPoint msg ir obj faceNum shift ctrl alt =
(	
	case msg of
	(
		#freeMove: (print ir)
		#mouseMove: ()
		#mousePoint:(point pos:ir.pos)
		#mouseAbort:(return #stop)	
	)
	#continue
)
mouseTrack on:$ snap:#3D trackCallback:Find3DPoint

----------------------------
----------------------------

fn DrawCross pos dir =
(
	
	--gw.resetUpdateRect()
	completeredraw()
	--gw.clearScreen (Box2 800 600 20 30 ) useBkg:false
	local GridTm = matrixFromNormal dir
	GridTm.row4 = pos
	gw.setTransform GridTm
	gw.setColor #line blue
	
	--Line X
	gw.Polyline #([-10,0,0],[10,0,0]) false
	--Line Y
	gw.Polyline #([0,-10,0],[0,10,0]) false
	
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)
fn Find3DPoint msg ir obj faceNum shift ctrl alt =
(	
	case msg of
	(
		#mouseMove:()
		--tracking mesh surface and drawing cross
		#freeMove: 
		(
			if ir != undefined do 
			(
				DrawCross ir.pos ir.dir
				--format "ir pos:%\tir dir:%\n" ir.pos ir.dir
			)
		)
		--geting pick point and most closest vertex around
		#mousePoint:
		(
			if ir != undefined do
			(
				format "picked face:%\n" faceNum
				format "intersect ray:%\n" ir
				format "position::%\n" ir.pos
				format "direction::%\n" ir.dir
			)
		)
		#mouseAbort:		
		(
			return #stop
		)
	)
	#continue
)

--Run Script A--
(
	local obj = (selection as array)[1]
	if superClassOf obj != GeometryClass do return false
	local IntersectOjb = snapshot obj
	hide IntersectOjb
	mouseTrack on:IntersectOjb snap:#3D trackCallback:Find3DPoint
	if isValidNode IntersectOjb  do delete IntersectOjb
	
	--mouseTrack on:$ prompt:"Chose 3 points to create new grid... " snap:#3D trackCallback:Find3DPoint
)

--Run Script B--
fn alignObjToface =  --select two geometry objects
(
	local sel = selection as array
	if sel.count < 2 do return false
	local obj = sel[1]
	if superClassOf obj != GeometryClass do return false
	local IntersectOjb = snapshot obj
	hide IntersectOjb
	mouseTrack on:IntersectOjb snap:#3D trackCallback:Find3DPoint
	if isValidNode IntersectOjb  do delete IntersectOjb
)
alignObjToface()
 
----------------------------
----------------------------







/*
tv = tv1*arr[3].x + tv2*arr[3].y + tv3*arr[3].z
--InicializePhase
#freeMove -- means the mouse is moved without a button being pressed
#mousePoint -- means the left mouse button has just been pressed
#mouseMove -- means the mouse is being dragged with the left button down
#mouseAbout -- means the right mouse button was clicked, normally meaning cancel
'ir' 

The grid or surface intersection normal Ray at the current mouse position. The ray has a .pos property giving the point in space of the normal and a .dir property giving the normal's direction vector.
'obj' 
The object being dragged over or undefined if no on:<node> was supplied.
'faceNum' 
The number of the face the mouse is over if the object being tracked is an editable mesh, undefined otherwise.
'shift', 'ctrl' and 'alt' 
True or false depending on the down or up state of the <shift>, <ctrl> and <alt> keys on the keyboard.
The function should return the special value #continue to continue tracking or any other value to halt tracking. That value then becomes the result of the original mouseTrack() call.

mouseTrack [on:<node>] [prompt:"msg"] [snap:#2D|#3D] [trackCallback:fn|#(fn,arg)]

on:<node> 
Optionally specifies a scene object to track on. If you don't supply an object, the mouse tracks on the current active grid. Note that the object surface tracker uses the SDK function IntersectRay() which is not reliably implemented on all object types. Editable meshes always work OK, so you can convertToMesh() if needed.
prompt:"msg" 
Displays the prompt message in the MAX status line 
snap:#2D|#3D 
Relevant when not tracking on an object surface (no on:<node> specified). If snap mode is on and #2D is supplied, snaps to snap points on grid, if #3D is specified snaps to any near snap point in space.
trackCallback:fn|#(fn,arg) 
Is where you specify the function to be called as the mouse is dragged over the active grid or object surface. You can specify it is a single function or a function and an argument value in a two element array. The latter form is useful if you have a common callback function for many tasks and want to send in a parameter to control its operation for a particular use. The function you give must be of the following form:

*/