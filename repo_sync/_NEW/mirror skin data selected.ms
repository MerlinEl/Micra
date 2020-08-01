-- Button CMW - Copy Mirrored Weight
-- Button PMW - Paste Mirrored Weight
-- Button MV - Mirror Weight using the max's default mirroring technique.
    (
    	on execute do
    	(
    		local rbn = #(
    			#( "hgbip_Spine",
    				"hgbip_Spine1",
    				"hgbip_Eye_R",
    				"hgbip_R_Clavicle_Help",
    				"hgbip_RUpArmTwist_Help",
    				"hgbip_Eye_L",
    				"hgbip_RUpArmTwist2_Help",
    				"hgbip_R_ForeTwist_Help",
    				"hgbip_Lid_R",
    				"hgbip_R_ForeTwist2_Help",
    				"hgbip_Lid_L",
    				"hgbip_R_Hand",
    				"hgbip_Head",
    				"hgbip_R_BackCloth",
    				"hgbip_L_BackCloth",
    				"hgbip_Brow_Inner_R",
    				"hgbip_R_Thigh_Help",
    				"hgbip_R_Calf_Help",
    				"hgbip_Brow_Outer_R",
    				"hgbip_R_Foot",
    				"hgbip_L_Thigh_Help",
    				"hgbip_Brow_Inner_L",
    				"hgbip_Brow_Outer_L",
    				"hgbip_L_Calf_Help",
    				"hgbip_L_Clavicle_Help",
    				"hgbip_R_Finger0",
    				"hgbip_R_Finger01",
    				"hgbip_R_Finger02",
    				"hgbip_R_Finger1",
    				"hgbip_R_Finger11",
    				"hgbip_R_Finger12",
    				"hgbip_R_Finger2",
    				"hgbip_R_Finger21",
    				"hgbip_R_Finger22",
    				"hgbip_R_Finger32",
    				"hgbip_R_Finger31",
    				"hgbip_R_Finger3",
    				"hgbip_R_Finger4",
    				"hgbip_R_Finger41",
    				"hgbip_R_Finger42",
    				"hgbip_Yaw",
    				"hgbip_R_Toe01",
    				"hgbip_LUpArmTwist_Help",
    				"hgbip_Lip_Down_R",
    				"hgbip_LUpArmTwist2_Help",
    				"hgbip_Lip_Down_L",
    				"hgbip_L_ForeTwist_Help",
    				"hgbip_L_ForeTwist2_Help",
    				"hgbip_Lip_Up_R",
    				"hgbip_L_Hand",
    				"hgbip_L_Finger0",
    				"hgbip_L_Finger01",
    				"hgbip_L_Finger02",
    				"hgbip_L_Finger1",
    				"hgbip_L_Finger11",
    				"hgbip_L_Finger12",
    				"hgbip_L_Finger2",
    				"hgbip_L_Finger21",
    				"hgbip_L_Finger22",
    				"hgbip_L_Finger3",
    				"hgbip_L_Finger31",
    				"hgbip_L_Finger32",
    				"hgbip_L_Finger4",
    				"hgbip_L_Finger41",
    				"hgbip_L_Finger42",
    				"hgbip_L_Foot",
    				"hgbip_Lip_Up_L",
    				"hgbip_L_Toe01",
    				"hgbip_Neck1",
    				"hgbip_Spine2_Scripted" ),
     
    			#( "hgbip_Spine",
    				"hgbip_Spine1",
    				"hgbip_Eye_L",
    				"hgbip_L_Clavicle_Help",
    				"hgbip_LUpArmTwist_Help",
    				"hgbip_Eye_R",
    				"hgbip_LUpArmTwist2_Help",
    				"hgbip_L_ForeTwist_Help",
    				"hgbip_Lid_L",
    				"hgbip_L_ForeTwist2_Help",
    				"hgbip_Lid_R",
    				"hgbip_L_Hand",
    				"hgbip_Head",
    				"hgbip_L_BackCloth",
    				"hgbip_R_BackCloth",
    				"hgbip_Brow_Inner_L",
    				"hgbip_L_Thigh_Help",
    				"hgbip_L_Calf_Help",
    				"hgbip_Brow_Outer_L",
    				"hgbip_L_Foot",
    				"hgbip_R_Thigh_Help",
    				"hgbip_Brow_Inner_R",
    				"hgbip_Brow_Outer_R",
    				"hgbip_R_Calf_Help",
    				"hgbip_R_Clavicle_Help",
    				"hgbip_L_Finger0",
    				"hgbip_L_Finger01",
    				"hgbip_L_Finger02",
    				"hgbip_L_Finger1",
    				"hgbip_L_Finger11",
    				"hgbip_L_Finger12",
    				"hgbip_L_Finger2",
    				"hgbip_L_Finger21",
    				"hgbip_L_Finger22",
    				"hgbip_L_Finger32",
    				"hgbip_L_Finger31",
    				"hgbip_L_Finger3",
    				"hgbip_L_Finger4",
    				"hgbip_L_Finger41",
    				"hgbip_L_Finger42",
    				"hgbip_Yaw",
    				"hgbip_L_Toe01",
    				"hgbip_RUpArmTwist_Help",
    				"hgbip_Lip_Down_L",
    				"hgbip_RUpArmTwist2_Help",
    				"hgbip_Lip_Down_R",
    				"hgbip_R_ForeTwist_Help",
    				"hgbip_R_ForeTwist2_Help",
    				"hgbip_Lip_Up_L",
    				"hgbip_R_Hand",
    				"hgbip_R_Finger0",
    				"hgbip_R_Finger01",
    				"hgbip_R_Finger02",
    				"hgbip_R_Finger1",
    				"hgbip_R_Finger11",
    				"hgbip_R_Finger12",
    				"hgbip_R_Finger2",
    				"hgbip_R_Finger21",
    				"hgbip_R_Finger22",
    				"hgbip_R_Finger3",
    				"hgbip_R_Finger31",
    				"hgbip_R_Finger32",
    				"hgbip_R_Finger4",
    				"hgbip_R_Finger41",
    				"hgbip_R_Finger42",
    				"hgbip_R_Foot",
    				"hgbip_Lip_Up_R",
    				"hgbip_R_Toe01",
    				"hgbip_Neck1",
    				"hgbip_Spine2_Scripted" )
    				)
    				
    		local rbc =#()
    				
    		local n = $
    		local m = n.modifiers[#skin]
    		local op = if classof n.baseobject == Editable_poly then polyop else meshop
    			
    		global ba = #(#(),#())
    		if ba[1].count > 0 then deleteItem ba[1] ba[1].count
    		if ba[2].count > 0 then deleteItem ba[2] ba[2].count
    		--print "------------"
    		--print ba[1].count
    		--if ba[1].count > 0 then for ind = 1 to ba[1].count do print print ba[ind]
    		--print "------------"
    		
    		for bc = 1 to skinOps.GetNumberBones m do
    		(
    			rbc[bc] = findItem rbn[2] (skinOps.GetBoneName m bc 1)
    			--print rbc[bc]
    		)
     
    		for vert=1 to op.getNumVerts n do
    		(
    			if skinOps.IsVertexSelected m vert == 1 then
    			(
    				for w=1 to skinOps.GetVertexWeightCount m vert do
    				(
    					local b = skinOps.GetVertexWeightBoneID m vert w
    					local bw = skinOps.GetVertexWeight m vert w
     
     					if ( finditem ba[1] rbc[b] ) == 0 then 
    					(
    						append ba[1] rbc[b]
    						append ba[2] bw
    						print b
    						print rbc[b]
    						print bw
    					)
    				)
    			)
    		)
    		
    		if ba[1].count == 0 then	return () else
    		(
    			print "------------"
    			print ba[1].count
    			for ind = 1 to ba[1].count do print ba[1][ind]
    			print "------------"
    		)
    		
    	)
    )
     
     
    macroScript t2_PasteMirroredWeight
    	category:"t2"
    	toolTip:"Paste mirrored weights"
    	buttonText:"PMW"
    (
    	on execute do
    	(
    		if ba[1].count == 0 then return ()
    		
    		local n = $
    		local m = n.modifiers[#skin]
    		local op = if classof n.baseobject == Editable_poly then polyop else meshop
    			
    		for vert=1 to op.getNumVerts n do
    		if skinOps.IsVertexSelected m vert == 1 then
    		(
    			skinOps.ReplaceVertexWeights m vert ba[1] ba[2]
    		)
    	)
    )
     
     
    macroScript t2_MirrorVertices
    	category:"t2"
    	toolTip:"Mirror Vertices"
    	buttonText:"MV"
    (
    	on execute do
    	(
    		
    		local n = $
    		local m = n.modifiers[#skin]
    		local op = if classof n.baseobject == Editable_poly then polyop else meshop
    			
    		for vert=1 to op.getNumVerts n do
    		if skinOps.IsVertexSelected m vert == 1 then
    		(
    				m.mirrorEnabled = on
    				skinOps.mirrorPaste m
    				m.mirrorEnabled = off
    		)
    	)
    )