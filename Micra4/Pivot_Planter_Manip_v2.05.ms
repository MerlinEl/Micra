/**
*@Usage > Pivot Planter for Editable Poly
*@About > Many thanks to Enrico, DenisT and Bobo
*/
Global mcPivotPlanter
Global mcPivotPlanterEnabled = false --when manipulate is on this plugin will not work unless is enabled by (executing this script)
if mcPivotPlanter != undefined then ( --switch
	
	manipulateMode = off  
	mcPivotPlanter = undefined
	mcPivotPlanterEnabled = false
	
) else (
	
	local sel = selection as array
	local last_node = undefined
	mcPivotPlanterEnabled = true
	if sel.count == 1 do 
	(
		--refresh Manipulators 
		manipulateMode = off  
		clearselection()
		manipulateMode = on
		select sel
		
		--Start
		plugin simpleManipulator mcPivotPlanter
		name:"Pivot Planter"
		invisible:true
		replaceUI:true
		version: 1 -- set current version to 1
		classID:#(0x40571f72, 0xd47216e) --genClassID()
		(
			local g = [0, 1, 0], r = [1, 0, 0], y = [1, 1, 0], b = [0, 0, 1]
			local gpos = #()
			
			on canManipulate target return (Superclassof target == GeometryClass and mcPivotPlanterEnabled)
			on updateGizmos do (

				if node != last_node do ( --when selection changed revert xray visibility
					
					if last_node != undefined do last_node.xray = false
					last_node = node
				)
				/*
				else (
				
					format "node:% last node:% return OK\n" node last_node
					return OK
				)*/
				node.xray = true
				-- Clear the current gizmo cache
				this.clearGizmos()
				-- manipulator's transform in nodes's LOCAL coord system 
				local local_bbox = nodeLocalBoundingBox node --(required AvGuard Extension)
				-- compensate not reset xform
				local tm = node.objecttransform
				local bmin = local_bbox[1]*(inverse tm) 
				local bmax = local_bbox[2]*(inverse tm)
				local bbox_size = local_bbox[2] - local_bbox[1] -- w l h
				local center = (bmin + bmax)/2
				
				local p0 = center --center red
				local p1 = [center.x,center.y,bmin.z] --bottom green
				local p2 = [center.x,center.y,bmax.z] --top blue
				local p3 = [center.x,bmin.y,center.z] --front yellow
				local p4 = [center.x,bmax.y,center.z] --back gray
				local p5 = [bmin.x,center.y,center.z] --left white
				local p6 = [bmax.x,center.y,center.z] --right brown

				local p7  = bmin --LFD min
				local p8  = [bmin.x, bmin.y, bmax.z] --LFU
				local p9  = [bmin.x, bmax.y, bmax.z] --LBU
				local p10 = [bmin.x, bmax.y, bmin.z] --LBD
				local p11 = [bmax.x, bmax.y, bmin.z] --RBD
				local p12 = bmax --RBU max
				local p13 = [bmax.x, bmin.y, bmax.z] --RFU
				local p14 = [bmax.x, bmin.y, bmin.z] --RFD
				
				local p15 = [bmin.x, bmin.y, center.z] --LFM
				local p16 = [bmin.x, center.y, bmax.z] --LUM
				local p17 = [bmin.x, bmax.y, center.z] --LBM
				local p18 = [bmin.x, center.y, bmin.z] --LDM
				local p19 = [bmax.x, center.y, bmin.z] --RDM
				local p20 = [bmax.x, bmax.y, center.z] --RBM
				local p21 = [bmax.x, center.y, bmax.z] --RUM
				local p22 = [bmax.x, bmin.y, center.z] --RFM
				local p23 = [center.x, bmin.y, bmax.z] --FM
				local p24 = [center.x, bmax.y, bmax.z] --UM
				local p25 = [center.x, bmax.y, bmin.z] --BM
				local p26 = [center.x, bmin.y, bmin.z] --DM
				
				--collect positions for later use
				gpos = #(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,
				p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26)
				
				--#point #hollowBox #plusSign #asterisk #xMarker #bigBox #circle #triangle #diamond #smallHollowBox #smallCircle #smallTriangle #smallDiamond #dot #smallDot
				--create gismos in cros 
				this.addGizmoMarker #circle p0 0 g r
				this.addGizmoMarker #circle p1 0 g r
				this.addGizmoMarker #circle p2 0 g r
				this.addGizmoMarker #circle p3 0 g r
				this.addGizmoMarker #circle p4 0 g r
				this.addGizmoMarker #circle p5 0 g r
				this.addGizmoMarker #circle p6 0 g r  
				
				--create gismos in corners
				this.addGizmoMarker #circle p7  0 g r
				this.addGizmoMarker #circle p8  0 g r
				this.addGizmoMarker #circle p9  0 g r
				this.addGizmoMarker #circle p10 0 g r
				this.addGizmoMarker #circle p11 0 g r
				this.addGizmoMarker #circle p12 0 g r
				this.addGizmoMarker #circle p13 0 g r
				this.addGizmoMarker #circle p14 0 g r
				
				--create gismos in middle
				this.addGizmoMarker #smallHollowBox p15  0 y r
				this.addGizmoMarker #smallHollowBox p16  0 y r
				this.addGizmoMarker #smallHollowBox p17  0 y r
				this.addGizmoMarker #smallHollowBox p18 0 y r
				this.addGizmoMarker #smallHollowBox p19 0 y r
				this.addGizmoMarker #smallHollowBox p20 0 y r
				this.addGizmoMarker #smallHollowBox p21 0 y r
				this.addGizmoMarker #smallHollowBox p22 0 y r
				this.addGizmoMarker #smallHollowBox p23 0 y r
				this.addGizmoMarker #smallHollowBox p24 0 y r
				this.addGizmoMarker #smallHollowBox p25 0 y r
				this.addGizmoMarker #smallHollowBox p26 0 y r
				
				fn drawLines g points = (

					for p in points do g.addPoint p
					g.startNewLine()
				)
				
				--draw bounding box
				local bounding_box_shape = manip.makeGizmoShape()
				drawLines bounding_box_shape #(p10, p7, p8, p9, p10, p11, p12, p9) --1 half box
				drawLines bounding_box_shape #(p14, p11, p12, p13, p14, p7, p8, p13) --2 half box
				--gizTmp.transform tm --Apply transform(matrix3) to the shape
				--Add new box shape to gizmo
				this.addGizmoShape bounding_box_shape GizmoDontHitTest white gray -- unselColor selColor
				
				--format "gizmo aded:%\n" bounding_box_shape
				
				return "Plant Pivot Here"
			)
			--on mouseMove screen_point gismo_index do ()
			on mouseUp screen_point gismo_index do ( -- m --> Point2 screen pixel coordinates
	
				--format "node:%\tgismo index:%\tscreen point:%\tlocal pos:%\n" node.name gismo_index screen_point gpos[gismo_index+1]
				--if (target == undefined) do return false --fix double-drawing
				manipulateMode = off  
				mcPivotPlanter = undefined
				mcPivotPlanterEnabled = false
				node.xray = false
				undo "Pivot Plant" on (
					
					local local_pos = gpos[gismo_index+1]
					node.pivot = local_pos*node.objecttransform
				)
			)
		) 
	)
)



/*
this.clearGizmos() 
nodeTM = matrix3 1 
--Reverse any scewing caused by scale (if any)
preScale nodeTM (inverse (scaleMatrix thisNode.scale)).scalepart
--Rotate eyes to look up
rotateX nodeTM 90
giz = manip.makeGizmoShape()

local flags = gizmoActiveViewportOnly
local flags2 = gizmoUseScreenSpace + gizmoActiveViewportOnly + GizmoDontHitTest
this.addGizmoShape giz flags (orange/255.) (blue/255.)
this.addGizmoMesh mesh flags unselColor selColor
*/
