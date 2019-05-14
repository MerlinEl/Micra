-- Hangar 13
-- https://hangar13games.com
-- Copyright (c) 2017 Hangar13. All Rights Reserved
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



gCAHookTest = attributes 'P3D:~Export~HookShotEdge~'
attribID:#(0x7bcc8596, 0x6e209ba1)
(
	local aggregatedCADescriptor = undefined -- for aggregation of parameters in DataManager, here is some  aggregation info and callbacks
	
	parameters main rollout:params
	(
		HSE_normal		type:#string		default:"0 0 0"
		HSE_point1		type:#string		default:"0 0 0"
		HSE_point2		type:#string		default:"0 0 0"
		-----------------------------------------------------------------------------------
		point1X		type:#float ui:spnPoint11 default:0
		point1Y		type:#float ui:spnPoint12 default:0
		point1Z		type:#float ui:spnPoint13 default:0
		
		point2X		type:#float ui:spnPoint21 default:0
		point2Y		type:#float ui:spnPoint22 default:0
		point2Z		type:#float ui:spnPoint23 default:0
		
		normalX		type:#float ui:spnNormal1 default:0
		normalY		type:#float ui:spnNormal2 default:0
		normalZ		type:#float ui:spnNormal3 default:0
	)

	rollout params "Hook Shot"
	(
		group "Point 1"
		(
			spinner spnPoint11			"X:"		type:#Float	across:3 offset:[0,0] width:60 height:17 range:[-99999999, 99999999, 0]
			spinner spnPoint12			"Y:"		type:#Float	across:3 offset:[0,1] width:60 height:17 range:[-99999999, 99999999, 0]
			spinner spnPoint13			"Z:"		type:#Float	across:3 offset:[0,2] width:60 height:17 range:[-99999999, 99999999, 0]
		)		

		group "Point 2"
		(
			spinner spnPoint21			"X:"		type:#Float	across:3 offset:[0,0] width:60 height:17 range:[-99999999, 99999999, 0]
			spinner spnPoint22			"Y:"		type:#Float	across:3 offset:[0,1] width:60 height:17 range:[-99999999, 99999999, 0]
			spinner spnPoint23			"Z:"		type:#Float	across:3 offset:[0,2] width:60 height:17 range:[-99999999, 99999999, 0]
		)

		group "Normal"
		(
			spinner spnNormal1			"X:"		type:#Float	across:3 offset:[0,0] width:60 height:17 range:[-99999999, 99999999, 0] enabled: false
			spinner spnNormal2			"Y:"		type:#Float	across:3 offset:[0,1] width:60 height:17 range:[-99999999, 99999999, 0] enabled: false
			spinner spnNormal3			"Z:"		type:#Float	across:3 offset:[0,2] width:60 height:17 range:[-99999999, 99999999, 0] enabled: false
		)		
				
		
		imgtag aggregatedCATag1 height:0 -- for aggregation of parameters in DataManager
		imgtag aggregatedCATag2 height:0 -- for aggregation of parameters in DataManager

		function Point3ToString input =
		(
			if classof input != point3 then return ""
			local result = input[1] as string + " " + input[2] as string + " " + input[3] as string
			result
		)
		
		function StringToPoint3 input =
		(
			local result = undefined
			local filtered = filterstring input " "
			if filtered.count == 3 then (
				result = [filtered[1] as float, filtered[2] as float, filtered[3] as float]
			)
			result
		)
		
		function UpdateParams =
		(
			HSE_normal = Point3ToString [spnNormal1.value as float, spnNormal2.value as float, spnNormal3.value as float]
			HSE_point1 = Point3ToString [spnPoint11.value as float, spnPoint12.value as float, spnPoint13.value as float]
			HSE_point2 = Point3ToString [spnPoint21.value as float, spnPoint22.value as float, spnPoint23.value as float]			
		)
		
		fn SetObjecPosFromCA val hookPart:#main dir:#X =
		(
			local dependency	= (refs.dependents params.owner)[1] 
			local obj, objPos
			
			Case (hookPart) of (
				#main : (
					obj = (refs.dependentNodes dependency firstOnly:false baseObjectOnly:True)[1]
				)
				#target : (
					obj = ((refs.dependentNodes dependency firstOnly:false baseObjectOnly:True)[1]).second
				)
			)
			objPos = obj.pos
			
			Case (dir) of (
				#X : (
					obj.pos = [val, objPos[2], objPos[3]]
				)
			
				#Y : (
					obj.pos = [objPos[1], val, objPos[3]]
				)
				
				#Z : (
					obj.pos = [objPos[1], objPos[2], val]
				)
			)
			redrawViews()
		)
	

		fn onParameterChange parameterName =
		( -- for aggregation of parameters in DataManager. This function is the same for all custom attributes
			UpdateParams()

			if (aggregatedCADescriptor == undefined) then
				return()
			aggregatedCADescriptor.onParameterChange parameterName
			aggregatedCADescriptor.SetDialogTagProperties aggregatedCATag1 aggregatedCATag2
		)	

		
		on spnPoint11 changed val do (
			onParameterChange "HSE_point1"
			SetObjecPosFromCA val hookPart:#main dir:#X
			UpdateParams()
		)
		on spnPoint12 changed val do (
			onParameterChange "HSE_point1"
			SetObjecPosFromCA val hookPart:#main dir:#Y
			UpdateParams()
		)
		on spnPoint13 changed val do(
			onParameterChange "HSE_point1"
			SetObjecPosFromCA val hookPart:#main dir:#Z
			UpdateParams()
		)
		
		on spnPoint21 changed val do(
			onParameterChange "HSE_point2"
			SetObjecPosFromCA val hookPart:#target dir:#X
			UpdateParams()
		)
		on spnPoint22 changed val do(
			onParameterChange "HSE_point2"
			SetObjecPosFromCA val hookPart:#target dir:#Y
			UpdateParams()
		)
		on spnPoint23 changed val do(
			onParameterChange "HSE_point2"
			SetObjecPosFromCA val hookPart:#target dir:#Z
			UpdateParams()
		)
			
		on spnNormal1 changed val do onParameterChange "HSE_normal"
		on spnNormal2 changed val do onParameterChange "HSE_normal"
		on spnNormal3 changed val do onParameterChange "HSE_normal"
		
		on params open do
		(
			if (aggregatedCADescriptor != undefined) then
			(
				aggregatedCADescriptor.SetDialogTagProperties aggregatedCATag1 aggregatedCATag2
			)
			
-- 			local tempValue = StringToPoint3 HSE_normal
-- 			spnNormal1.value = tempValue[1] as Float
-- 			spnNormal2.value = tempValue[2] as Float
-- 			spnNormal3.value = tempValue[3] as Float
-- 			
-- 			tempValue = StringToPoint3 HSE_point1
-- 			spnPoint11.value = tempValue[1] as Float
-- 			spnPoint12.value = tempValue[2] as Float
-- 			spnPoint13.value = tempValue[3] as Float
-- 			
-- 			tempValue = StringToPoint3 HSE_point2
-- 			spnPoint21.value = tempValue[1] as Float
-- 			spnPoint22.value = tempValue[2] as Float
-- 			spnPoint23.value = tempValue[3] as Float			
		)		
	)
)

