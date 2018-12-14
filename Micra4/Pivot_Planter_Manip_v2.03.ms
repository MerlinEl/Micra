--Pivot Planter for Editable Poly
(
	local sel = selection as array
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
		(
			local g = [0, 1, 0], r = [1, 0, 0], y = [1, 1, 0], b = [0, 0, 1]
			local gpos = #()
			on canManipulate target return (classOf target == Editable_Poly)
			on updateGizmos do
			(
				if not node.xray do node.xray = true
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
				
				local p0 = center --center
				local p1 = [center.x,center.y,bmin.z] --bottom
				local p2 = [center.x,center.y,bmax.z] --top
				local p3 = [bmin.x,center.y,center.z] --front
				local p4 = [bmax.x,center.y,center.z] --back
				local p5 = [center.x,bmin.x,center.z] --left
				local p6 = [center.x,bmax.x,center.z] --right
		
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
				
				--create gismos in cros
				this.addGizmoMarker #asterisk p0 0 y r --#diamond p0 0 g r
				this.addGizmoMarker #circle p1 0 g r
				this.addGizmoMarker #circle p2 0 g r
				this.addGizmoMarker #circle p3 0 g r
				this.addGizmoMarker #circle p4 0 g r
				this.addGizmoMarker #circle p5 0 g r
				this.addGizmoMarker #circle p6 0 g r  
				
				--create gismos in corners
				this.addGizmoMarker #asterisk p7  0 y r
				this.addGizmoMarker #asterisk p8  0 y r
				this.addGizmoMarker #asterisk p9  0 y r
				this.addGizmoMarker #asterisk p10 0 y r
				this.addGizmoMarker #asterisk p11 0 y r
				this.addGizmoMarker #asterisk p12 0 y r
				this.addGizmoMarker #asterisk p13 0 y r
				this.addGizmoMarker #asterisk p14 0 y r
				
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
				
				return "Plant Pivot Here"
			)
			on mouseUp m which do -- m --> Point2 screen pixel coordinates, which --> gismo number 
			(
				--format "m:%\twhich:%\tlocal_pp:%\n" m which gpos[which+1]
				--if keyboard.controlPressed then
				(
					undo "Pivot Plant" on node.pivot = gpos[which+1]*node.objecttransform
						manipulateMode = off  
				)
			)
		) 
	)
)
--many thanks to Enrico, DenisT and Bobo
