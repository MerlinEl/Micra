

------------------------------------------------------------------------------------------------------------------------------
-- slice Tool v1.2.2 - 08/03/2019
-- Dev by Benjamin Boscher aka N00BYZOR
-- Free for all use and / or modifications.
-- If you modify the script please mention my name or my nickname (or both ^^)
-- Cheers ;)
-- http://www.scriptspot.com/3ds-max/scripts/slice-tool
------------------------------------------------------------------------------------------------------------------------------


try(destroyDialog SliceToolRollout)catch()
rollout SliceToolRollout "N00BYZOR's slice tool ;)" width:248 height:152
(
	local mySliceModifiers = #()
	local SliceAxis = #X
	local bUseDistance = False
	
	spinner 'NumberOfSlices' "Slices" pos:[150,10] width:67 height:16 range:[0,1000,1] type:#integer align:#left tooltip:"Number of slices"
	spinner 'DistanceBetweenSlices' "Distance" pos:[135,32] width:75 height:16 range:[0.1,100000,10] toolTip:"Distance between slices" align:#left
	GroupBox 'OptionsBox' "Options" pos:[8,8] width:115 height:136 align:#left
	button 'X_Button' "X" pos:[16,32] width:23 height:21 toolTip:"Slices along the X axis" align:#left
	button 'Y_Button' "Y" pos:[48,32] width:23 height:21 toolTip:"Slices along the Y axis" align:#left
	button 'Z_Button' "Z" pos:[80,32] width:23 height:21 toolTip:"Slices along the Z axis" align:#left
	checkbutton 'preview' "Preview" pos:[144,52] width:90 height:30 align:#left --highlightColor: [random 0 255, random 0 255, random 0 255]
	button 'Accept' "Accept" pos:[144,88] width:90 height:30 enabled:false align:#left
	label 'version' "v1.2.2" pos:[143,128] width:34 height:13 align:#left
	button 'AboutButton' "About" pos:[186,126] width:44 height:20 align:#left
	checkbox 'Split_Mesh' "Split mesh" pos:[16,69] width:72 height:15 toolTip:"Check the \"Split Mesh\" option in every slice modifier." align:#left
	checkbox 'Collapse_Stack' "Collapse stack" pos:[16,93] width:93 height:15 checked:false toolTip:"Collapse the modifier stack after accepting." align:#left
	checkbox 'ResetXFormCheckbox' "Reset XForm before slicing" pos:[16,112] width:93 height:27 checked:false toolTip:"Useful when your object's local pivot is not aligned with the world." align:#left

	fn SliceMesh Axis:#X UseDistance:#True=
	(
		if Axis == #X do
		(
			if ResetXFormCheckbox.checked do
			(
				ResetXForm $
				ConvertTo $ Editable_Poly
			)
			
			if UseDistance == True then
			(
				objTM = $.objectTransform
				TotalDistance = $.max.x - $.min.x
				DistanceX = DistanceBetweenSlices.value
				DistanceSum = DistanceX
				NewNumberOfSlices = 0
				
				while (DistanceSum < TotalDistance) do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.min.x,$.pos.y,$.pos.z] + [DistanceSum,0,0]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					mySlice.Slice_Plane.rotation.y_rotation = 90
					append mySliceModifiers mySlice
					DistanceSum += DistanceX
					NewNumberOfSlices += 1
				)
				NumberOfSlices.value = NewNumberOfSlices
			)
			else
			(
				objTM = $.objectTransform
				TotalDistance = $.max.x - $.min.x
				DistanceX = TotalDistance / (NumberOfSlices.value + 1)
				DistanceBetweenSlices.value = DistanceX
				
				for i = 1 to NumberOfSlices.value do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.min.x,$.pos.y,$.pos.z] + i * [DistanceX,0,0]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					mySlice.Slice_Plane.rotation.y_rotation = 90
					append mySliceModifiers mySlice
				)
			)
		)
		if Axis == #Y do
		(
			if ResetXFormCheckbox.checked do
			(
				ResetXForm $
				ConvertTo $ Editable_Poly
			)
			
			if UseDistance == True then
			(
				objTM = $.objectTransform
				TotalDistance = $.max.y - $.min.y
				DistanceY = DistanceBetweenSlices.value
				DistanceSum = DistanceY
				NewNumberOfSlices = 0
				
				while (DistanceSum < TotalDistance) do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.pos.x,$.min.y,$.pos.z] + [0,DistanceSum,0]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					mySlice.Slice_Plane.rotation.x_rotation = 90
					append mySliceModifiers mySlice
					DistanceSum += DistanceY
					NewNumberOfSlices += 1
				)
				NumberOfSlices.value = NewNumberOfSlices
			)
			else
			(
				objTM = $.objectTransform
				TotalDistance = $.max.y - $.min.y
				DistanceY = TotalDistance / (NumberOfSlices.value + 1)
				DistanceBetweenSlices.value = DistanceY
				
				for i = 1 to NumberOfSlices.value do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.pos.x,$.min.y,$.pos.z] + i * [0,DistanceY,0]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					mySlice.Slice_Plane.rotation.x_rotation = 90
					append mySliceModifiers mySlice
				)
			)
		)
		if Axis == #Z do
		(
			if ResetXFormCheckbox.checked do
			(
				ResetXForm $
				ConvertTo $ Editable_Poly
			)
			
			if UseDistance == True then
			(
				objTM = $.objectTransform
				TotalDistance = $.max.z - $.min.z
				DistanceZ = DistanceBetweenSlices.value
				DistanceSum = DistanceZ
				NewNumberOfSlices = 0
				
				while (DistanceSum < TotalDistance) do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.pos.x,$.pos.y,$.min.z] + [0,0,DistanceSum]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					--mySlice.Slice_Plane.rotation.y_rotation = 90
					append mySliceModifiers mySlice
					DistanceSum += DistanceZ
					NewNumberOfSlices += 1
				)
				NumberOfSlices.value = NewNumberOfSlices
			)
			else
			(
				objTM = $.objectTransform
				TotalDistance = $.max.z - $.min.z
				DistanceZ = TotalDistance / (NumberOfSlices.value + 1)
				DistanceBetweenSlices.value = DistanceZ
				
				for i = 1 to NumberOfSlices.value do
				(
					mySlice = SliceModifier()
					addmodifier $ mySlice --ui:off
					modTM = getModContextTM $ mySlice
					mySlice.Slice_Plane.position = (([$.pos.x,$.pos.y,$.min.z] + i * [0,0,DistanceZ]) * modTM * (inverse objTM))
					--mySlice.Slice_Plane.position = ([$.min.x,0,0] * modTM * (inverse objTM))
					--mySlice.Slice_Plane.rotation.y_rotation = 90
					append mySliceModifiers mySlice
				)
			)
		)
	)
	
	fn DeleteSlices =
	(
		for i in mySliceModifiers do
		(
			try(deleteModifier $ i)catch()
		)
		free mySliceModifiers
	)

	on SliceToolRollout close do
	(
		suspendEditing which:#modify
		DeleteSlices()
		resumeEditing which:#modify
	)
	on NumberOfSlices changed NewValue do
	(
		if selection.count == 1 then
		(
			if Preview.state == on do
			(
				--max create mode
				suspendEditing which:#modify
				bUseDistance = False
				DeleteSlices()
				SliceMesh Axis:SliceAxis UseDistance:bUseDistance
				--max modify mode
				resumeEditing which:#modify
				--completeRedraw()
			)
		)
	)
	on DistanceBetweenSlices changed NewValue do
	(
		if selection.count == 1 then
		(
			if Preview.state == on do
			(
				suspendEditing which:#modify
				bUseDistance = True
				DeleteSlices()
				SliceMesh Axis:SliceAxis UseDistance:bUseDistance
				resumeEditing which:#modify
				--completeRedraw()
			)
		)
	)
	on X_Button pressed do
	(
		SliceAxis = #X
		if Preview.state == on do
		(
			suspendEditing which:#modify
			DeleteSlices()
			SliceMesh Axis:SliceAxis UseDistance:bUseDistance
			resumeEditing which:#modify
		)
	)
	on Y_Button pressed do
	(
		SliceAxis = #Y
		if Preview.state == on do
		(
			suspendEditing which:#modify
			DeleteSlices()
			SliceMesh Axis:SliceAxis UseDistance:bUseDistance
			resumeEditing which:#modify
		)
	)
	on Z_Button pressed do
	(
		SliceAxis = #Z
		if Preview.state == on do
		(
			suspendEditing which:#modify
			DeleteSlices()
			SliceMesh Axis:SliceAxis UseDistance:bUseDistance
			resumeEditing which:#modify
		)
	)
	on preview changed PreviewState do
	(
		--Preview.HighlightColor = [random 0 255, random 0 255, random 0 255]
		if PreviewState == on then
		(
			if selection.count == 1 then
			(
				suspendEditing which:#modify
				SliceMesh Axis:SliceAxis UseDistance:bUseDistance
				completeRedraw()
				Accept.enabled = true
				resumeEditing which:#modify
			)
			else
			(
				if selection.count == 0 then
				(
					MessageBox "Selection is empty ! :o"
					Preview.state = off
				)
				else
				(
					MessageBox "Please select only one object ;)"
					Preview.state = off
				)
			)
		)
		else
		(
			suspendEditing which:#modify
			DeleteSlices()
			Accept.enabled = false
			resumeEditing which:#modify
		)
	)
	on Accept pressed do
	(
		if selection.count == 1 then
		(
			if Split_Mesh.checked do
			(
				for i in mySliceModifiers do
				(
					i.Slice_Type = 1
				)
			)
			if Collapse_Stack.checked then
			(
				free mySliceModifiers
				collapseStack $
				Preview.state = off
				Accept.enabled = false
			)
			else
			(
				free mySliceModifiers
				addmodifier $ (Edit_Poly())
				Preview.state = off
				Accept.enabled = false
			)
		)
		else
		(
			MessageBox "Selection is empty ! :o"
		)
	)
	
	rollout AboutRollout "About" width:424 height:248
	(
		
		local img_logo_01 = "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"
		local img_logo_02 = "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"
		local ConvertClass = dotNetClass "System.Convert"
		local ImageClass = dotNetClass "System.Drawing.Image"
		local Img01
		local Img02
		
		label lbl01 "		                  Slice Tool v1.2.2 - 08/03/2019\n		        Dev by Benjamin Boscher aka N00BYZOR\n		          Free for all use and / or modifications.\n    If you modify the script please mention my name or my nickname (or both ^^).\n				      Cheers :)" pos:[8,8] width:408 height:88
		dotNetControl N00BYButton "system.Windows.Forms.Button" pos:[130,120] width:150 height:76
		label lbl02 "You can find my other scripts on" pos:[64,216] width:160 height:13
		HyperLink ScriptSpotLink "my Scriptspot account" pos:[224,216] width:120 height:15 color:(color 0 221 241) hovercolor:(color 0 255 0) visitedcolor:(color 0 221 241) address:"http://www.scriptspot.com/3ds-max/scripts?search=n00byzor&date%5Bvalue%5D%5Byear%5D="
		label lbl6 "My portfolio:" pos:[176,96] width:72 height:16
		
		fn StringToImage str = -- http://lonerobot.net/
		(
			byteArr = ConvertClass.FromBase64String str
			memstream = dotnetobject "System.IO.MemoryStream" byteArr
			DecodedImg = ImageClass.fromstream memstream
			memstream.close() ; return DecodedImg
		)
		
		
		on AboutRollout open do
		(
			Img01 = (StringToImage img_logo_01)
			Img02 = (StringToImage img_logo_02)
			N00BYButton.image = Img01
		)
		on N00BYButton mouseEnter senderArg arg do
		(
			senderArg.image = Img02
		)
		on N00BYButton mouseLeave senderArg arg do
		(
			N00BYButton.image =  Img01
		)
		on N00BYButton click do
		(
			ShellLaunch "https://www.artstation.com/artist/n00byzor" ""
		)
	)
	on AboutButton pressed do
	(
		try(destroyDialog AboutRollout)catch()
		CreateDialog AboutRollout
	)
)
CreateDialog SliceToolRollout style:#(#style_titlebar, #style_sysmenu, #style_toolwindow) --bgColor:[random 0 255, random 0 255, random 0 255]