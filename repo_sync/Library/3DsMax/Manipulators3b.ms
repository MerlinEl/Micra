plugin simpleManipulator UCSManipulator
	  name:"UCS"
	  classID:#(0x58cfb958, 0x2fea5145)
	  category:"Manipulators"
  (

  
	  parameters main rollout:paramRollout
	  ( 
		  size type:#float   animatable:false  ui:spn_size default: 1
		  showLabels type:#boolean animatable:false ui:chk_showLabels default:true
		  showXZ type:#boolean animatable:false ui:chk_showXZ default:false
		  showYZ type:#boolean animatable:false ui:chk_showYZ default:false
		xColor type:#color animatable:true ui:clr_xColor default:red
		yColor type:#color animatable:true ui:clr_yColor default:green
		zColor type:#color animatable:true ui:clr_zColor default:blue
		labelColor type:#color animatable:true ui:clr_labelColor default:yellow
	  )
  
	  rollout paramRollout "Parameters"
	  (
		  Spinner  spn_size "Icon Size:"  range:[0.01, 10000.0, 1.0]
		  checkbox chk_showLabels "Show Axis Labels" 
		  checkbox chk_showXZ "Show Z Axis In XZ Plane" 
		  checkbox chk_showYZ "Show Z Axis In YZ Plane" 
		
		colorpicker clr_xColor "X Axis Color:" align:#right
		colorpicker clr_yColor "Y Axis Color:" align:#right
		colorpicker clr_zColor "Z Axis Color:" align:#right
		colorpicker clr_labelColor "Label Color:" align:#right
		
	  )
  
	  on canManipulate target return false
  
	  tool create
	  (
		  on mousePoint click do
			 case click of
			 (
				1: 
				(
					theTM = matrix3 1
				  theTM.row4 = gridPoint
				  nodeTM = theTM
				)
				2: #stop
			 )
		  on mouseMove click do
		  (
			  case click of
			  (
				  2: (
					  size = length gridDist
					  )
			  )
		  )  
	  )
  
	  on updateGizmos do
	  (
		local redColor =	xColor/255.0
		local greenColor =  yColor/255.0
		local blueColor = zColor/255.0		
		local yellowColor = labelColor/255.0
		
		  this.clearGizmos()
		  
		  local flags = 0 
		  this.addGizmoMarker #asterisk [0,0,0] flags yellowColor redColor
  
		  local giz = manip.makeGizmoShape() 
		  giz.AddPoint ([-1.5,-1.5,0] * size)
		  giz.AddPoint ([5.5,-1.5,0]  * size)
		  giz.AddPoint ([5.5,-3,0] * size) 
		  giz.AddPoint ([8.5,0,0]  * size)
		  giz.AddPoint ([5.5,3,0]  * size)
		  giz.AddPoint ([5.5,1.5,0]  * size)
		  giz.AddPoint ([1.5,1.5,0]  * size)
		  this.addGizmoShape giz flags redColor redColor 
		  
		  if showLabels do
		  (
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([5.5,1,0] * size)
			  giz.AddPoint ([7,-1,0]  * size)
			  this.addGizmoShape giz flags yellowColor yellowColor 
			  
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([7,1,0] * size)
			  giz.AddPoint ([5.5,-1,0]  * size)
			  this.addGizmoShape giz flags yellowColor yellowColor 
		  )
		  
		  local giz = manip.makeGizmoShape() 
		  giz.AddPoint ([1.5,1.5,0]  * size)
		  giz.AddPoint ([1.5,5.5,0]  * size)
		  giz.AddPoint ([3,5.5,0]  * size)
		  giz.AddPoint ([0,8.5,0]  * size)
		  giz.AddPoint ([-3,5.5,0]  * size)
		  giz.AddPoint ([-1.5,5.5,0]  * size)
		  giz.AddPoint ([-1.5,-1.5,0]  * size)
		  this.addGizmoShape giz flags greenColor greenColor 
		  
		  if showLabels do
		  (
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([-0.7,7,0] * size)
			  giz.AddPoint ([0,6,0]  * size)
			  this.addGizmoShape giz flags yellowColor yellowColor 
			  
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([0.7,7,0] * size)
			  giz.AddPoint ([0,6,0]  * size)
			  this.addGizmoShape giz flags yellowColor yellowColor 
			  
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([0,6,0]  * size)
			  giz.AddPoint ([0,5,0]  * size)
			  this.addGizmoShape giz flags yellowColor yellowColor 			
		  )		
		  
		  if showXZ do
		  (
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([-1.5,0,0] * size)
			  giz.AddPoint ([-1.5,0,5.5] * size)
			  giz.AddPoint ([-3,0,5.5] * size)
			  giz.AddPoint ([0,0,8.5] * size)
			  giz.AddPoint ([3,0,5.5] * size)
			  giz.AddPoint ([1.5,0,5.5] * size)
			  giz.AddPoint ([1.5,0,0] * size)
			  giz.AddPoint ([-1.5,0,0] * size)			
			  this.addGizmoShape giz flags blueColor blueColor 	
  
			  if showLabels do
			  (
				  local giz = manip.makeGizmoShape() 
				  giz.AddPoint ([-0.7,0,7] * size)
				  giz.AddPoint ([0.7,0,7]  * size)
				  giz.AddPoint ([-0.7,0,5]  * size)
				  giz.AddPoint ([0.7,0,5]  * size)
				  this.addGizmoShape giz flags yellowColor yellowColor 
			  )	
		  )
		  if showYZ do
		  (
			  local giz = manip.makeGizmoShape() 
			  giz.AddPoint ([0,-1.5,0] * size)
			  giz.AddPoint ([0,-1.5,5.5] * size)
			  giz.AddPoint ([0,-3,5.5] * size)
			  giz.AddPoint ([0,0,8.5] * size)
			  giz.AddPoint ([0,3,5.5] * size)
			  giz.AddPoint ([0,1.5,5.5] * size)
			  giz.AddPoint ([0,1.5,0] * size)
			  giz.AddPoint ([0,-1.5,0] * size)			
			  this.addGizmoShape giz flags blueColor blueColor 		
			  
			  if showLabels do
			  (
				  local giz = manip.makeGizmoShape() 
				  giz.AddPoint ([0,-0.7,7] * size)
				  giz.AddPoint ([0,0.7,7]  * size)
				  giz.AddPoint ([0,-0.7,5]  * size)
				  giz.AddPoint ([0,0.7,5]  * size)
				  this.addGizmoShape giz flags yellowColor yellowColor 
			  )				
		  )
		  return "UCS"
	  )
  )