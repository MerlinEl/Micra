/**
*@Usage > Pivot Planter for Editable Poly
*@About > Many thanks to Enrico, DenisT and Bobo
*/
Global mcDynamicMeasure
Global mcDynamicMeasureEnabled = true --when manipulate is on this plugin will not work unless is enabled by (executing this script)
Global mcDynamicMeasureShowArrowsLength --ensure variable visibility
fn mcDynamicMeasureShowArrowsLength = (

	format "draw text\n"
	/*
	gw.setTransform(Matrix3 1)
	for i = 1 to pos_array.count do gw.text pos_array[i] text_array[i] color:yellow
	gw.enlargeUpdateRect #whole
	gw.updateScreen()*/
)
if mcDynamicMeasure != undefined then ( --switch

	manipulateMode = off  
	mcDynamicMeasure = undefined
	mcDynamicMeasureEnabled = false
	unRegisterRedrawViewsCallback mcDynamicMeasureShowArrowsLength
	
) else (
	
	--refresh Manipulators 
	local sel = selection as array
	if sel.count == 1 do ( 

		mcDynamicMeasureEnabled = true
		manipulateMode = off  
		clearselection()
		select sel
	)	
	
	registerRedrawViewsCallback mcDynamicMeasureShowArrowsLength
	mcDynamicMeasureEnabled = true
	manipulateMode = on

	--Start
	plugin simpleManipulator mcDynamicMeasure
	name:"Dynamic Measure"
	invisible:true
	replaceUI:true
	version: 1 -- set current version to 1
	classID:#(0x3689bc3f, 0x4836a795) --genClassID()
	(
		local g = [0, 1, 0], r = [1, 0, 0], y = [1, 1, 0], b = [0, 0, 1], w=[1, 1, 1]
		local gpos = #()
		on canManipulate target return (Superclassof target == GeometryClass and mcDynamicMeasureEnabled)
		on updateGizmos do (

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

			local p7  = bmin --LFD min  (Left Front Down)
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
			
			local flags_1 = gizmoActiveViewportOnly
			local flags_2 = gizmoActiveViewportOnly + GizmoDontHitTest
			local flags_3 = gizmoUseScreenSpace + gizmoActiveViewportOnly + GizmoDontHitTest
			local flags_4 = gizmoUseScreenSpace + gizmoActiveViewportOnly
			--#point #hollowBox #plusSign #asterisk #xMarker #bigBox #circle #triangle #diamond #smallHollowBox #smallCircle #smallTriangle #smallDiamond #dot #smallDot

			--create arrows  points
			this.addGizmoMarker #diamond p7  0 g r
			this.addGizmoMarker #diamond p8  0 g r
			this.addGizmoMarker #diamond p10 0 g r
			this.addGizmoMarker #diamond p14 0 g r

			fn drawLines g points = (

				for p in points do g.addPoint p
				g.startNewLine()
			)
			
			--draw bounding box
			local arrow_height = manip.makeGizmoShape()
			local arrow_length = manip.makeGizmoShape()
			local arrow_width = manip.makeGizmoShape()
			drawLines arrow_height #(p7, p8) --1 height arrow
			drawLines arrow_length #(p7, p10) --1 length arrow
			drawLines arrow_width #(p7, p14) --1 width arrow

			--gizTmp.transform tm --Apply transform(matrix3) to the shape
			--Add new shape to gizmo
			this.addGizmoShape arrow_height flags_1 b y -- unselColor selColor
			this.addGizmoShape arrow_length flags_1 g y
			this.addGizmoShape arrow_width flags_1 r y
			
			--test with geometry sphere
			--local gizSphere = manip.makeSphere p7 5 20 --pos, radius, segments
			--this.addGizmoMesh gizSphere gizmoActiveViewportOnly (orange/255.) (blue/255.)
			
			--this.addGizmoText ("width:") ((p7+p14)/2) 0 y b
			
			--return "Plant Pivot Here"
			
			/*gw.setTransform (Matrix3 1)
			local p3TargetScreenPos = gw.transPoint node.position
			this.addGizmoText "TestText" p3TargetScreenPos flags_4 g r 
			-- hack to force the gizmo update
			node.transform = node.transform*/
		)
		--on mouseMove screen_point gismo_index do ()
		--on mouseUp screen_point gismo_index do()
		on create do (
			
			---unRegisterRedrawViewsCallback mcDynamicMeasureShowArrowsLength
			--registerRedrawViewsCallback mcDynamicMeasureShowArrowsLength
			format "created\n"
		)
		--on load do (format "loaded\n")
	) 
)



/*
    unRegisterRedrawViewsCallback mcDynamicMeasureShowArrowsLength
    fn mcDynamicMeasureShowArrowsLength=
    (
    gw.setTransform(Matrix3 1)
    for o in objects where not o.isHidden do
    (
    gw.text o.pos (o.name) color:yellow
    gw.text (o.pos+[0,0,-2]) (o.pos as string) color:yellow
    ) 
    gw.enlargeUpdateRect #whole
    gw.updateScreen()
    )
    registerRedrawViewsCallback mcDynamicMeasureShowArrowsLength
    mcDynamicMeasureShowArrowsLength()




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
