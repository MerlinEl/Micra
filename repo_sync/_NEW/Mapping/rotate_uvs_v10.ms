--******************************************************************************************************
-- Created: 		10-05-2011
-- Last Updated:	10-05-2011
-- Version:			1.0
--
-- Author :  Kostadin Kotev / miau_u@yahoo.com /
-- Version:  3ds max 2009 (should work in older versions too!)
--
-- Discription:
-- 		Rotate the selected UV islands.
--	
-- Usage: 
--		UVW_Unwrap modifier must be applyed to object and the "Edit UVWs" rollout must be open.
--		Work only in Edge sub-object mode.
--		1. Select the method that you want to use:	
--			- "auto" - the script will automaticaly find the longest edge in each UV islands.
--			- "manual" - rotation/aligning around selected edge of each UV islands.
--		2. Press the "Hold Selection" button.
--		3. The "Horizontal" button will align the selected UVs horizontally around the selected edge of each UV isnalds.
--		4. The "Vertical" button will align the selected UVs vertically around the selected edge of each UV isnalds.
--		5. Set the point of rotation to center of selected edge or to one of the edge vertices.
--		6. Set the angle of rotation
--		7. "Rot CCW" - will rotate selected UVs counter clockwise.
--		8. "Rotate CW" - will rotate selected UVs clockwise.
--
--	Credits:
--		Hendrik-Jan Schoenmaker a.k.a. renderhjs:::: http://www.renderhjs.net/index_flash.htm
--******************************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK


macroscript RotateUVs_v10
category:"miauu"
tooltip:"Rotate UVs v1.0"
buttonText:"Rotate UVs"
(
	global rol_AngleRotateUVs
	try(destroyDialog rol_AngleRotateUVs)catch()
	rollout rol_AngleRotateUVs "Rotate UVs"
	(
		local uvIslands = #()
		local uvIslandLongEdge = #()
		local uv = undefined
		local subObjLevel = undefined
		local workingEdge = undefined
		local workingEdgesMM = undefined
		local RotateElementAlongLongestVert
		
		groupbox grpbox_mode "Mode:" pos:[2,2] width:116 height:33
			radiobuttons rb_workMode "" labels:#("auto", "manual") default:1 columns:2 pos:[4,17]

		checkbutton chkbtn_holdSelection "Hold Selection" pos:[2,37] width:116 highlightColor:red
		
		groupbox grpbox_align "Align:" pos:[2,60] width:116 height:38
			button btn_alignHoriz "Horizontal" pos:[4,75] width:55 height:20
			button btn_alignVert "Vertertical" pos:[61,75] width:55 height:20
		
		groupbox grpbox_rotPoint "Point of rotation:" pos:[2,100] width:116 height:60
			label lbl_v01 "vert 1   center   vert 2" pos:[4,120]
			radiobuttons rb_rotatPoint "" labels:#("     ", "    ", "  ") default:2 columns:3 pos:[10,135]
			
		spinner spn_gradToRotate "Angle" width:40 fieldWidth:40 pos:[42,165] range:[0,360,0] type:#float
		checkbutton chkbtn_help "?" pos:[104,165] width:15 height:15 tooltip:"Show Help."
		
		button btn_rotateCW "Rot CCW" pos:[2,185] width:55 height:25	
		button btn_rotateCCW "Rotate CW" pos:[63,185]  width:55 height:25		
		
		--	help
		label lbl_modeA "\"auto\"-will select the longest edge/edges." pos:[121 ,2]
		label lbl_modeM "\"manual\"-rotation around selected edge." pos:[121 ,18]
		label lbl_modeD1 "_________________________________" pos:[121 ,30]
		
		label lbl_alignH "\"Horizontal\"-align UVs horizontally." pos:[121 ,65]
		label lbl_alignV "\"Vertical\"-align UVs vertically." pos:[121 ,80]
		label lbl_modeD2 "_________________________________" pos:[121 ,92]
		
		label lbl_pOrV1 "\"vert1\"-rotate around edge vert 1." pos:[121 ,110]
		label lbl_pOrC "\"center\"-rotate around edge center." pos:[121 ,125]
		label lbl_pOrV2 "\"vert2\"-rotate around edge vert 2." pos:[121 ,140]
		label lbl_modeD3 "_________________________________" pos:[121 ,152]		
		
		label lbl_angle "Set the angle of rotation." pos:[121 ,165]
		
		label lbl_rotCCW "\"Rot.CCW\"-rotate UVs counter clockwise." pos:[121 ,184]
		label lbl_rotCW "\"Rot.CCW\"-rotate UVs clockwise." pos:[121 ,198]
			
--@ the next two functions are credited to Hendrik-Jan Schoenmaker a.k.a. renderhjs:::: http://www.renderhjs.net/index_flash.htm
		-- with some changes
		--calculate the angle difference between 2 deltas
		function get2VertsAngleDiff dx dy=
		(
			local _a_abs = mod ((atan2 dy dx)+4*360) 360	--the angle in closed 360 degrees			
			local _a_off = (mod _a_abs 90)	--angle offset
			if (_a_abs > 45 and _a_abs < 135) or (_a_abs > 225 and _a_abs < 335) then
			(
				_a_abs = "v"
			)
			else
			(
				_a_abs = "h"
			)
			if (_a_off > 45)then
			(
				_a_off = -(90 - _a_off)
			)
			return #(_a_off,_a_abs)
		)
		function fn_06__align_uv_shell_to_edge mode =
		(
			undo on
			(
				local _array = uv.getSelectedEdges()
							
				local _edge = (_array as array)[1] as integer
				--get the transformation info
				uv.edgeToVertSelect()
				_points = uv.getSelectedVertices() as array
				local ptA = uv.getVertexPosition 1 _points[1]
				local ptB = uv.getVertexPosition 1 _points[2]
				local dx = ptB.x - ptA.x
				local dy = ptB.y - ptA.y
				
				local a_off = get2VertsAngleDiff dx dy

				uv.unwrap2.selectElement()
				uv.unwrap2.RotateSelected (-a_off[1]  * 0.0174533) [(ptA.x + dx/2),(ptA.y + dy/2),0]
				uv.unwrap2.selectEdges #{_edge}

				local ptA = uv.getVertexPosition 1 _points[1]
				local ptB = uv.getVertexPosition 1 _points[2]
				local dx = ptB.x - ptA.x
				local dy = ptB.y - ptA.y
				local a_off = get2VertsAngleDiff dx dy
				
				if (a_off[1] != 0) then	
				(--stupid angle snap is on
					print("shut off the angle snap..")
					max angle snap toggle 	--shut it up
					uv.selectElement()
					uv.RotateSelected (-a_off[1]  * 0.0174533) [(ptA.x + dx/2),(ptA.y + dy/2),0]
					uv.selectEdges #{_edge}
				)

				if mode == "h" then
				(
					if a_off[2] == "v" do
					(
						RotateElementAlongLongestVert (degToRad 90)
					)
				)
				else
				(
					if a_off[2] == "h" do
					(
						RotateElementAlongLongestVert (degToRad 90)
					)
				)
			)
		)
--@//////////
		function RotateElementAlongLongestVert angleToRot =
		(
			uv.edgeToVertSelect()
			local edgeVerts = uv.getSelectedVertices() as array
			local edgeVerts01 = uv.getVertexPosition 0 edgeVerts[1]
			local edgeVerts02 = uv.getVertexPosition 0 edgeVerts[2]
			local distX = edgeVerts02.x - edgeVerts01.x
			local distY = edgeVerts02.y - edgeVerts01.y
			uv.selectElement()
			case rb_rotatPoint.state of
			(
				1: (uv.RotateSelected (angleToRot) [(edgeVerts01.x),(edgeVerts01.y),0])
				2: (uv.RotateSelected (angleToRot) [(edgeVerts01.x + distX/2),(edgeVerts01.y + distY/2),0])
				3: (uv.RotateSelected (angleToRot) [(edgeVerts02.x),(edgeVerts02.y),0])
			)
			uv.selectEdges workingEdge
		)		
		function FindLongestEdge =
		(
			workingEdge = undefined
			local allEdges = uv.getSelectedEdges() as array
			if allEdges.count != 0 then
			(
				local edgeDistArr = #(0, 0)
				for i = 1 to allEdges.count do
				(
					uv.selectEdges #{allEdges[i]}
					uv.edgeToVertSelect()
					local curVert = uv.getSelectedVertices() as array
					local v1Pos = uv.getVertexPosition 0 curVert[1]
					local v2Pos = uv.getVertexPosition 0 curVert[2]
					local curVertLenght = distance v1Pos v2Pos
					if curVertLenght > edgeDistArr[1] do
					(
						edgeDistArr[1] = curVertLenght
						edgeDistArr[2] = i
					)
				)
				workingEdge = #{allEdges[edgeDistArr[2]]}
				uv.selectEdges workingEdge
			)
			else
			(
				messagebox "Select some UV islands!" title:"miauu Script Error!!!"
				chkbtn_holdSelection.state = false
			)
		)
		function SeparateElemInEdgeMode =
		(
			allEdges = uv.getSelectedEdges()
			if not allEdges.isEmpty then
			(
				while not allEdges.isEmpty do
				(
					uv.selectEdges #{(allEdges as array)[1]}
					uv.SelectElement()
					elem01verts = uv.getSelectedEdges()
					append uvIslands elem01verts
					print rb_workMode.state
					case rb_workMode.state of
					(
						1:
						(
							FindLongestEdge()
							append uvIslandLongEdge workingEdge
						)
						2:
						(
							workingEdge = #{(allEdges as array)[1]}
							append uvIslandLongEdge workingEdge
						)
					)
					allEdges = allEdges-elem01verts
				)
			)
			else
			(
				messagebox "Select some UV islands!" title:"miauu Script Error!!!"
				chkbtn_holdSelection.state = false
			)
		)

		on chkbtn_holdSelection changed theState do
		(
			if theState then
			(
				uv = modpanel.getcurrentobject()
				print rb_workMode.state
				if rb_workMode.state == 1 then
				(					
					if classof (uv) == Unwrap_UVW then
					(
						uvIslands = #()
						case uv.getTVsubobjectMode() of
						(
							2: (SeparateElemInEdgeMode(); subObjLevel = 2)
							default:
							(
								messagebox "Go to Edge Sub-object mode!" title:"miauu Script Error!!!"
								chkbtn_holdSelection.state = false
							)
						)						
					)
					else
					(
						messagebox "Open the \"Edit UVWs\" window!" title:"miauu Script Error!!!"
						chkbtn_holdSelection.state = false
					)
				)
				else
				(
					if classof (uv) == Unwrap_UVW then
					(
						uvIslands = #()
						uvIslandLongEdge = #()
						case uv.getTVsubobjectMode() of
						(
							2: (SeparateElemInEdgeMode(); subObjLevel = 2)
							default:
							(
								messagebox "Go to Edge Sub-object mode!" title:"miauu Script Error!!!"
								chkbtn_holdSelection.state = false
							)
						)						
					)
					else
					(
						messagebox "Open the \"Edit UVWs\" window!" title:"miauu Script Error!!!"
						chkbtn_holdSelection.state = false
					)
				)
			)
			else
			(
				uvIslands = #()
				uvIslandLongEdge = #()
				workingEdge = undefined
			)
		)

		on btn_alignHoriz pressed do
		(
			if chkbtn_holdSelection.state == true do
			(
				for i=1 to uvIslandLongEdge.count  do
				(
					uv.selectEdges uvIslandLongEdge[i]
					fn_06__align_uv_shell_to_edge "h"
				)			
			)
		)
		on btn_alignVert pressed do
		(
			if chkbtn_holdSelection.state == true do
			(
				for i=1 to uvIslandLongEdge.count  do
				(
					uv.selectEdges uvIslandLongEdge[i]
					fn_06__align_uv_shell_to_edge "v"
				)
			)			
		)

		on btn_rotateCW pressed do
		(
			if chkbtn_holdSelection.state == true do
			(
				for i=1 to uvIslandLongEdge.count do
				(
					uv.selectEdges uvIslandLongEdge[i]
					RotateElementAlongLongestVert (degToRad spn_gradToRotate.value)
				)
			)
		)
		on btn_rotateCCW pressed do
		(
			if chkbtn_holdSelection.state == true do
			(
				for i=1 to uvIslandLongEdge.count do
				(
					uv.selectEdges uvIslandLongEdge[i]
					RotateElementAlongLongestVert -(degToRad spn_gradToRotate.value)
				)
			)
		)
		
		on chkbtn_help changed theState do
		(
			if theState then
			(
				for h = rol_AngleRotateUVs.width to 320 by 5 do
				(
					rol_AngleRotateUVs.width = h
					sleep 0.002
				)
			)
			else
			(
				for h = rol_AngleRotateUVs.width to 120 by -5 do
				(
					rol_AngleRotateUVs.width = h
					sleep 0.002
				)
			)
		)
	)
	createdialog rol_AngleRotateUVs 120 210 style:#(#style_titlebar, #style_sysmenu,#style_toolwindow)
)