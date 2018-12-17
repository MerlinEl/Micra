sliderTime = 0

pc = $.pos.controller
show pc
getPropNames $  


 fn getSubKeyInfo sub spaces:"" = (
   	for i = 1 to sub.numsubs do (
   		subSub = sub[i]
   		format "%%\n" spaces subSub
   		if ((subSub.keys != undefined) AND (subSub.keys.count > 0)) then (
   			for k in subSub.keys do (
   				local kVal
   				try ( kVal = k.value )
   				catch ( kVal = "-- inaccessible - master controller? --" )
   				format "%% -> %\n" spaces k kVal
   			)
   		)
   		getSubKeyInfo subSub spaces:(spaces + "  ")
   	)
   )
getSubKeyInfo $
   
  /*getKeyTime obj.pos.controller 1*/  
   
sub =$[3].keys.count
segLengths = (getSegLengths $ 1 cum:true)
int animationRange.end
animationRange = interval 0 2000
deleteTarget 
   

spline_path = $.pos.controller.path
$.pos.controller.deleteTarget 1 
deletekeys $ #allkeys
$.pos.controller.appendTarget spline_path 100
addnewkey $ 0
addnewkey $ 100
   $.pos.controller.percent
   
   deletekey $.pos.controller.percent 1
   $.pos.controller.percent.keys[1]
  selectKey  $.pos.controller.percent 1
  
key_a = $.pos.controller.percent.keys[1]
key_a.selected = true 
key_a.time = 0 
getPropNames key_a

$.pos.controller.percent.keys[1].time = 0
$.pos.controller.percent.keys[2].time = 100
with animate on
(
	at time 100 $.pos.controller.percent=0
	at time 250 $.pos.controller.percent=100
)
   
   /*moveKey bhc i 10*/







rollout xxx "Untitled" width:162 height:300
(
	--linear_float()
	--tcb_rotation()
	--bezier_float()
	--bezier_position()
	local myController=linear_float()
	spinner ball_radius "Ball radius" range:[0,1000,1] controller:myController
	button apply "Apply Radius Controller"
	
	on apply pressed do
	(
		animate off at time 0 $ball.pos = [myController.value,0,0]
		$ball.pos.controller=myController
	)
)
createdialog xxx

/*
rollout xxx "Untitled" width:162 height:300
(
	local myController=bezier_float()
	spinner ball_radius "Ball radius" range:[0,1000,1] controller:myController
	button apply "Apply Radius Controller"
	
	on apply pressed do
	(
		animate off at time 0 $ball.radius=myController.value
		$ball.radius.controller=myController
	)
)
createdialog xxx
*/

utility spread "Spread objects" -- define the utility name and description string
(
	local last_amt = 0 -- define and initialize local variable
	checkbox x "Spread in x" -- create 3 checkboxes
	checkbox y "Spread in y"
	checkbox z "Spread in z"
	spinner spread "Spread amount:" range:[-1000,1000,0] -- create a spinner
	on spread changed amt do -- when spinner value changes...
	(
		delta = amt - last_amt -- calculate difference in current and previous
		for obj in selection do -- values for each selected object
		(
		-- calculate new position based on current position and selection center
		p = obj.pos + normalize (obj.pos - selection.center) * delta
		if x.checked then obj.pos.x = p.x -- if checkbox x checked, apply X position
		if y.checked then obj.pos.y = p.y -- if checkbox y checked, apply Y position
		if z.checked then obj.pos.z = p.z -- if checkbox z checked, apply Z position
		)
		last_amt = amt -- store spinner value as previous value
	) -- end of "on spread changed"
) -- end of utility definition


--assigns a controller:

$.visibility = bezier_float() 
$.visibility = C_MAXLS3DLODCtrl

$.visibility.controller
getVisController $

--set the current value to semi-visible:
$.visibility.controller.value = 0
$.visibility.controller.value = 1

$Sphere04.visibility.controller.value = 1
actionMan.executeAction 1 "650"  -- Track View: Delete Visibility Track

c= getVisController $
classof c == C_MAXLS3DLODCtrl


my_tracks = newTrackViewNode "Grinner"
happy_ctrl = bezier_float() 
addTrackViewController my_tracks happy_ctrl "Happy"
$.Controller = happy_ctrl


--rotate wheel at ground
Global rwag_last_key_whell_pos
Global rwag_current_angle

fn rotateWheelAtGround wheel rad =
(

	if not isValidNode wheel do return 0 
	
	if rwag_last_key_whell_pos == undefined do rwag_last_key_whell_pos = wheel.pos
	if rwag_current_angle == undefined do rwag_current_angle = 0	
	
	local w_dist = distance rwag_last_key_whell_pos wheel.pos 
	rwag_last_key_whell_pos = wheel.pos
		
	local w_diameter = abs (wheel.min - wheel.max).y
	rwag_current_angle += (360*w_dist) / (pi*(rad))--(pi*w_diameter)

	--format "current_angle:%\n" rwag_current_angle
	return rwag_current_angle
)
(
	--user variables
	local wheel = $wheel_2
	--controll first wheel
	(rotateWheelAtGround wheel 30.29)/100
)

rwag_last_key_whell_pos = u
rwag_current_angle = u



range = interval 50 100
setTimeRange $.controller range

fn pathConstaintLoop node path loopTime:100 =
(
	c = node.position.controller = path_constraint path:path axis:2 constantVel:on follow:on
	p = c.percent.controller
	
	enableORTs p on
	setBeforeORT p #cycle
	setAfterORT p #cycle

	deletekeys p #allkeys
	k = addnewkey p 0
	k.value = 0
	k = addnewkey p loopTime
	k.value = 100
)
(
	delete objects
	animationrange = interval 0 1000
	
	path = ellipse name:"Path" length:100 width:200 wirecolor:green
	node = box name:"Node" length:10 width:10 height:10 wirecolor:yellow
	
	pathConstaintLoop node path loopTime:100
)


pFlag = hasProperty mObject.Position.Controller "Path_Constraint"

getSegLengths $ 1 --geting length of spline

addnewkey $.pos.controller 100
deletekey $.pos.controller 1
deleteKeys $.pos.controller #allKeys
selectKeys <controller> [ <interval> | <time> ] 
deselectKeys <controller> [ <interval> | <time> ] 
selectKey <controller> <index_integer> 
isKeySelected <controller> <index_integer> 
deselectKey <controller> <index_integer> 
moveKeys <controller> <time> [#selection] 

reduceKeys <controller> <threshold> <step> [ <range> ]
reduceKeys $.pos.controller 0.5 1f
reduceKeys $baz.bend.angle.controller 0.1 0.5f (interval 20 75)

pc.percent.controller.keys[2].time = yourtime
pc.percent.controller.keys[2].value = yourvalue

temp=$ObjectOnSpline.pos.controller.Path_Constrain t.path

-- controller test bed 2
b=box height:10
at time 5 animate on b.height=50
at time 10 animate on b.height=100
bhc=b.height.controller
bhk=bhc.keys
addnewkey bhc 7
addnewkey bhc 9
for k in bhk do format "%:%\n" k.time k.value
selectKeys bhc (interval 7 9)
deleteKeys bhc #selection
bhk
addnewkey bhc 7
addnewkey bhc 9
selectKeys bhc (interval 7 9)
deleteKeys bhc #selection #slide
bhk
addnewkey bhc 7
addnewkey bhc 9
selectKeys bhc (interval 7 9)
deleteKeys bhc #selection #slide #rightToLeft
bhk
addnewkey bhc 8
i=getKeyIndex bhc 8
selectKey bhc i
moveKey bhc i 10
bhk
getKeyTime bhc 4
b.width.controller=noise_float()
numkeys b.width.controller


pc = $.pos.controller
show pc
getPropNames $
*/


/*
 fn getSubKeyInfo sub spaces:"" = (
   	for i = 1 to sub.numsubs do (
   		subSub = sub[i]
   		format "%%\n" spaces subSub
   		if ((subSub.keys != undefined) AND (subSub.keys.count > 0)) then (
   			for k in subSub.keys do (
   				local kVal
   				try ( kVal = k.value )
   				catch ( kVal = "-- inaccessible - master controller? --" )
   				format "%% -> %\n" spaces k kVal
   			)
   		)
   		getSubKeyInfo subSub spaces:(spaces + "  ")
   	)
   )
   getSubKeyInfo $*/