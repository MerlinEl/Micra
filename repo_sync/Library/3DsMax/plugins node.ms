/* denisT collection 2012 */

plugin Modifier XTarget
name:"XTarget"
classID:#(0x00001967, 0x04062012)
extends:EmptyModifier
replaceUI:on
silentErrors:on
version:1
( 
	parameters mian rollout:main
	(
		radius type:#float animatable:on default:0 ui:ui_radius
		height type:#float animatable:on default:0 ui:ui_height
		yaw type:#float animatable:on default:0 ui:ui_yaw
		pinch type:#float animatable:on default:0 ui:ui_pinch
		roll type:#float animatable:on default:0 ui:ui_roll
		spin_speed type:#float animatable:on default:0 ui:ui_spin_speed
	)
	rollout main "Parameters"
	(
		group "Camera Translation: " 
		(
			spinner ui_radius "Radius: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,0]
			spinner ui_height "Height: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,-2]
		)
		group "Camera Rotation: "
		(
			spinner ui_yaw "Yaw: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,0]
			spinner ui_pinch "Pinch: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,-2]
			spinner ui_roll "Roll: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,-2]
		)
		group "Target Animation: "
		(
			spinner ui_spin_speed "Spin Speed: " type:#float fieldwidth:56 range:[-1e9,1e9,0] align:#right offset:[0,0] tooltip:"Angular Velocity (deg/sec)"
		)
	)
	on attachedtonode node do if iskindof node TargetCamera do
	(
		target = node.target
		c = node.controller = transform_script()
		c.addtarget "TM" target[#transform]
		c.addtarget "radius" this[#radius]
		c.addtarget "height" this[#height]
		c.addtarget "yaw" this[#yaw]
		c.addtarget "pinch" this[#pinch]
		c.addtarget "roll" this[#roll]

		ss = ""
		ss += "prerotateX TM 90\n"
		ss += "pretranslate TM [0,height,radius]\n"
		ss += "prerotate TM (rotateYPRMatrix yaw pinch roll).rotation"
		c.setexpression ss

		c = target.rotation.controller[3].controller = float_script()
		c.addtarget "speed" this[#spin_speed]

		ss = "S*(degtorad speed)"
		c.setexpression ss
		
--		format "attached % %\n" node target
	)
)
/* the Sample
with redraw off
(
	delete objects 
	cam = TargetCamera name:"XTargetCamera" target:(Targetobject name:"XTargetCamera.Target") isselected:on
	addmodifier cam (XTarget())
)
 */