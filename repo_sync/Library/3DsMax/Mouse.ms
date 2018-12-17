	local viewPoint_ray = mapScreentoWorldRay mouse.pos

mouse.buttonStates[1]
mouse.buttonStates[3]
mouse.buttonStates
system.windows.input.mouse


----------double click
 numTimes=0
 stTime=timeStamp()
 when select $Sphere01 changes id:#selectTest do
 (
 	
 	if (timeStamp())-stTime>3000 then
 	(
 		numTimes=0
 		stTime=timeStamp()
 	)
 	
 	
 	numTimes+=1
 	if stTime==0 then stTime=timeStamp()
 	
 	if numTimes==3 then 
 	(
 		if (timeStamp())-stTime<3000 then
 		(
 			print #yep
 		)
 		numTimes=0
 		stTime=timeStamp()
 	)
 )
 -------------------------------
tol=300		-- time in milliseconds for the doubleclick!
global c1,c2
--print c1
tool doubleclick
(
on start do c1=0
on mousepoint n do
(
print n
if n>1 then	 -- the second click is always the mouse up event from the first press
(
if c1==0 then -- check for first click
(
	c1=timestamp() -- make the first timestamp
) else
(
	c2=timestamp() -- make the second timestamp
	t=c2-c1	-- claculate the difference
	if t<tol then -- check to see if it's below the tolerance
	(	 -- my doubleclick action!
	 format "doubleclick in %\n" t
	 c1=0 -- clear the first click
	) else
	(
	 c1=c2 -- make the second click the first!
	)
)
) 
)
)
starttool doubleclick



/*
tool foo
(
	on mousePoint clickno do (print clickno)
)
startTool foo
*/

--------------
p = pickPoint()
	case of
		(
	(p == undefined): print "escaped" -- user pressed escape
	(p == #rightClick): print "rclick" -- user clicked RMB
	(classOf p == Point3): print "" -- user entered a point
	(classOf p == String): print "" -- user keyed a non-point
	)
--------------
-------------------------------------------
tool create_prim
(
on mousePoint clickno do
	(
	if clickno == 1 then (print "start:")
	else if clickno == 2 then (s = sphere pos:worldPoint)
	else if clickno == 3 then (c = cylinder pos:worldPoint)
	else if clickno == 4 then (p = pyramid pos:worldPoint)
	else if clickno == 5 then (b = box pos:worldPoint)
	else #stop
	)
)
startTool create_prim prompt:"Hello!"
-------------------------------------------
-------------------------------------------
tool create_prim
(
on mousePoint clickno do
	(
	if clickno == 1 then (print "start:")
	else if clickno == 2 then (sphere pos:worldPoint)
	else if clickno == 3 then (cylinder pos:worldPoint)
	else if clickno == 4 then (pyramid pos:worldPoint)
	else if clickno == 5 then (box pos:worldPoint)
	else #stop
	)
)
startTool create_prim prompt:"Hello!"
-------------------------------------------


mouse.pos.x / gw.getWinSizeX()
mouse.pos.y / gw.getWinSizeY()

		
tool dMove
(
on mouseMove clickno do 
(
	setDialogPos movetestDialog (mouse.screenpos - [242,12])
)
)
starttool dMove