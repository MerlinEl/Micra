fn setNodeWorldRotation theNode theRot = 
 (
 in coordsys (transmatrix theNode.transform.pos) 
 theNode.rotation = theRot
 )
 setNodeWorldRotation $ (eulerangles 45 45 0)

$object.transform.controller[axis].value
 e.g $box01.pos.controller[2].value
 
 
-- degrees to radians
a = 90
b = degToRad a
--or
b = a* Pi/180
-- radians to degrees
radToDeg b
--or
b/pi* 180



$.rotation.x_rotation
$.rotation.y_rotation
$.rotation.z_rotation



--
$.rotation.z_rotation = 20

$.rotation = (eulerangles 0 0 0)
--
in coordsys local $.rotation = (eulerangles 0 0 0)
--
in coordsys world rotate selection (EulerAngles 0 0 90)

Node Transform Matrix = Controller Scale * Controller Rotation * Controller Position * Parent Transform Matrix



-------------------------------------------------------------------------------
resetMaxFile #noPrompt --reset the file
theV = normalize [5,0,10] --the vector to rotate, normalized to unit vector
theStep = 10 --the step by which you want to rotate
--rotate from 0 to 360-theStep with step TheStep:
for a = 0 to 360-theStep by theStep do 
	(
	rm = rotateZMatrix a --create a rotation matrix from the value
	theRotV = theV * rm --transform the original vector using the matrix
	format "%: %\n" a theRotV --print the result to Listener 
	c = cylinder() --create a cylinder
	c.dir = theRotV --orient along the vector to see what it looks like
	)
-------------------------------------------------------------------------------
$.rotation as eulerangles
$.Transform
rotate $ (angleaxis 13 [0,1,0])
$.rotation.angle
$.rotation.axis
$.rotation as angleaxis
$.rotation.x
$.rotation.y
$.rotation.z

$.rotation = quat 0.368818 0.495017 0.244115 0.747889
$.rotation
$.rotation.axis[1]
quatToEuler ($.rotation)
$.transform

x= $.transform
x.translation
$.transform.rotationpart
$.transform.translationpart
$.transform.scalepart
$.transform.determinantsign


$Sphere01[2]
$Sphere01[3][1].controller
$Sphere01[3][1][3].controller

r=$.transform.rotationPart
$.rotation = inverse r
---------------------------------------------------------------
-- Setting a node's rotation relative to world space without 
-- messing with its position:
fn setNodeWorldRotation theNode theRot = 
(
in coordsys (transmatrix theNode.transform.pos) 
theNode.rotation = theRot
)
setNodeWorldRotation $ (eulerangles 45 45 0)
---------------------------------------------------------------