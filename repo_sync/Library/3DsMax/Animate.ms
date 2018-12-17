
--delete all keys only in groups
(
	local sel = selection as array
	if sel.count > 0 do
	(
		for i in sel where isGroupMember i do deletekeys i
	)

	
--create dummy for each selected mesh and copy animation
for o in selection do
(
	local d=dummy pos:o.pos name:("bone_"+o.name)
	o.parent = d
	d.controller = copy o.controller --get all animation controls
	d.pos = o.pos --reset pos after controller assinged
	deletekeys o
)
--relink by name
for o in selection where (d = getNodeByName ("bone_"+o.name)) != undefined do (o.parent = d; print d)


ra = animationRange
ra.end
ra.start
for i=ra.start to ra.end do print i
for i=ra.start to ra.end do print $.position.controller

animationRange.start.frame
animationRange.end.frame
animationRange.end.ticks

set animate on
set time 30f
move $ [80,0,0]
scale $ [1,1,3]
$.bend.angle += 23
set animate off
set time off


oldAnimRange = animationRange
animationRange = interval -1 100
animationRange = oldAnimRange


for i in theBoneArray do in coordsys parent 
i.rotation.x_rotation
i.rotation.y_rotation
i.rotation.z_rotation


fn clearAllKeys =
(
	undo label:"Clear Keys" on
	(
		for o in objects do
		(
			setwaitcursor()
			try (deletekeys o.position.controller #allkeys) catch()
			try (deletekeys o.rotation.controller #allkeys) catch()
			try (deletekeys o.scale.controller #allkeys) catch()
			setArrowCursor()
		)
	)
)
/*
clearAllKeys()
max undo
*/


b = box()
convertToMesh b
animateVertex b #all
with animate on 
(
	at time 10 b[4][1][2].value = (random [-50,-50,-50] [0,0,0])
	at time 20 b[4][1][3].value = (random [-50,-50,-50] [0,0,0])
)

[4] is the base object
[4][1] is the Master Point Controller
[4][1][2] is the second vertex' animation track


for i = 1 to 8 do 
(
	$[4][1][i].controller = point3_script()
	$[4][1][i].controller.script="random [0,0,0] [1,1,1]"
)

theMod = $Cylinder02.modifiers[1]
theMpc = theMod[#Master_Point_Controller].controller
theVertexC = theMpc[13].controller

theMpc = $Plane01[4][#Master_Point_Controller].controller
theVertex = theMpc[13].controller
animate on
(
	for i = 1 to theVertex.keys.count do
	(
		local theKey = theVertexC.keys[i]
		at time theKey.time $Dummy04.pos = theKey.value
	)
)

for i=1 to 50 do
(
	print theMod[i]
)


local lstNodes = (selection as array)
loadAnimation f &lstNodes relative:true insert:true insertTime:maxTime

nodeTab is In and Out parameter

relative default value: true

insert default value: false

insertTime default value: 0f

useMapFile default value: false

mapFileName default value: undefined


  first = $.pos.controller.keys[1].time
       last = $.pos.controller.keys[$.pos.keys.count].time
      animationRange = interval first last
	  
	  
Global mcTempPositionControllerData
Global mcTempRotationControllerData
Global mcTempScaleControllerData

fn copyAnimation obj =
(
	mcTempPositionControllerData = obj.position.controller 
	mcTempRotationControllerData = obj.rotation.controller
	mcTempScaleControllerData    = obj.scale.controller
)
fn pasteAnimation obj =
(
	if mcTempRotationControllerData != undefined and  
	mcTempPositionControllerData != undefined and
	mcTempScaleControllerData != undefined do
	(
		obj.position.controller = mcTempPositionControllerData
		obj.rotation.controller = mcTempRotationControllerData
		obj.scale.controller    = mcTempScaleControllerData
	)
)

fn copyAnimation obj =
(
	Global mcTempPositionControllerData = #()
	Global mcTempRotationControllerData = #()
	Global mcTempScaleControllerData    = #()
	struct ANIMATION_DATA (time, val)
	mcTempPositionControllerData = for i in $.pos.controller.keys      collect (ANIMATION_DATA i.time (at time i.time obj.position))
	mcTempRotationControllerData = for i in $.rotation.controller.keys collect (ANIMATION_DATA i.time (at time i.time obj.rotation))
	mcTempScaleControllerData    = for i in $.scale.controller.keys    collect (ANIMATION_DATA i.time (at time i.time obj.scale   ))
)
copyAnimation $

fn pasteAnimation obj =
(
	if mcTempPositionControllerData != undefined and mcTempPositionControllerData.count != 0 do 
	(
		with animate on 
		for i in mcTempPositionControllerData do at time i.time obj.position = i.val
	)
	if mcTempRotationControllerData != undefined and mcTempRotationControllerData.count != 0 do
	(
		with animate on 
		for i in mcTempRotationControllerData do at time i.time obj.rotation = i.val
	)
	if mcTempScaleControllerData    != undefined and mcTempScaleControllerData.count    != 0  do  
	(
		with animate on 
		for i in mcTempScaleControllerData do at time i.time obj.scale = i.val
	)
)
pasteAnimation $




posTime = 10 --your time variable
rotTime = 15 --your rotation time variable
at time posTime pos1 = $.position --copy the key value at the time you want
at time rotTime rot1 = $.rotation --copy the key value at the time you want
with animate on
(
at time 5 $.position = pos1 --assign the value of time 10 to time 5
at time 5 $.rotation = rot1 --assign the value of time 15 to time 5
) 



/*
	p=$.pos
	$.pos = p
	co = $.controller 
	$.controller=co
	
	copyAnimation $
	pasteAnimation $
*/


fn copyAnimation = 
(
	Global mcTempControllerData
	local obj = selection[1]
	if obj == undefined do return false
	mcTempControllerData = #(copy obj.position.controller, copy obj.rotation.controller, copy obj.scale.controller)
)
copyAnimation()
fn pasteAnimation = 
(
	local obj = selection[1]
	if obj == undefined do return false
	local old_obj_pos = obj.pos
	if mcTempControllerData != undefined and mcTempControllerData.count == 3 do undo "Paste Animation" on
	(
		obj.position.controller = mcTempControllerData[1]
		obj.rotation.controller = mcTempControllerData[2]
		obj.scale.controller    = mcTempControllerData[3]
		obj.pos = old_obj_pos
	)
)
pasteAnimation()