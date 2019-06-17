/*
Functions for working with the Slice Modifier more efficiently

Written by Shawn Olson ( http://www.shawnolson.net )
Copyright (c) 2017-2018 All Rights Reserved

This set of functions included in Wall Worm and Wall Worm Pro
https://wallworm.com

*/
(
	::WallWormSliceModTools = attributes WallWormSliceModTools 
	version:4
	attribId:#(0x6f221056, 0x22733e9f) 
	(

		local wallworm = true
		local thisMod, CAparams
		parameters main rollout:slicerollout (
			KeepSlicing type:#boolean default:true ui:chkKeepSlicing
			cap type:#boolean default:true ui:chkCap
		)
		
		function canUse message:true = (
			if ::wallwormSlicemodOps == undefined then (
				if message == true then (
					if (querybox "Wall Worm Slice Modifier Tools not installed. Do you want to download?") then (
						shellLaunch "https://wallworm.com/ww_destinations.php?destination=slicetools" ""
					)
				)
				false
			) else true
		)
		
		function addSliceMod Slice_Type:1 Faces___Polygons_Toggle:1 = (
			local sm = (SliceModifier Slice_Type:Slice_Type Faces___Polygons_Toggle:Faces___Polygons_Toggle)
			addModifier $ sm
			if canUse() then (
				::wallwormSlicemodOps.addMod sm
				sm.KeepSlicing = KeepSlicing
				--sm.Slice_Type=Slice_Type
				sm.Faces___Polygons_Toggle=Faces___Polygons_Toggle
				sm.cap = cap
			)
			sm
		)		
		--refresh set to true always because we can't be certain this is applied to a slicemod
		function getMod refresh:true = (
			if NOT isValidNode thisMod  OR refresh == true then thisMod = (refs.dependents this immediateOnly:true)[1]
			if (thisMod == undefined OR classof thisMod != SliceModifier) AND classof $ != UndefinedClass then (
				--thisMod might not be a slidemodifier because a custom attribute can collapse down to base object
				thisMod = addSliceMod()
			)
			thisMod
		)

		function GoAgain addCap:true  = (
			getMod()
			local Slice_Type = case of (
				(thisMod != undefined):(thisMod.Slice_Type)
				(::wallwormSlicemodOps != Undefined):(::wallwormSlicemodOps.Slice_Type)
				default:1
			)
			local Faces___Polygons_Toggle = case of (
				(thisMod != undefined):(thisMod.Faces___Polygons_Toggle)
				(::wallwormSlicemodOps != Undefined):(::wallwormSlicemodOps.Faces___Polygons_Toggle)
				default:1
			)
			if $ != undefined then (
				if addCap then (
					addModifier $ (Cap_Holes Smooth_New_Faces:1 Smooth_With_Old_Faces:0 Make_All_New_Edges_Visible:0 )
				)
				local sm = addSliceMod Slice_Type:Slice_Type Faces___Polygons_Toggle:Faces___Polygons_Toggle
				sm
			)
		)
		
		function getTrans = (
			local objToTest = $
			if classof objToTest == ObjectSet then (
				objToTest = objToTest[1]
			)
			getMod()
			inverse (objToTest.transform * inverse (getModContextTM  objToTest thisMod))
		)
		
		function doSlice = (
			getMod()
			if thisMod != undefined then (
				
				local inv = getTrans()
				local p1 = pickPoint()
				if p1 != undefined AND p1 != #rightClick then (
					local p2 =pickPoint  rubberband:p1
					if p2 != undefined  AND p2 != #rightClick then (
						local pp3 = mouse.screenpos
						local r = mapScreenToWorldRay pp3
						local dir = normalize (p2 - p1)
						local rdir = r.dir
						local c = cross dir rdir
						local theMatrix = (matrix3 dir rdir c p2) * inv
						thisMod.Slice_Plane.transform = theMatrix
						if keepSlicing then (
							local sm = GoAgain addCap:(keepSlicing AND cap)
							if sm != undefined then (
								sm.doSlice()
							)
						)						
					)
				)
			)	else format "no node\n"
		)

		rollout slicerollout "Slice Tools" (
			
			Group "Slice Tools Version 1.21" (
				Label lblBy "Developed by " align:#left across:2
				HyperLink hpyerWW "Wall Worm" address:"https://wallworm.com" Color:blue visitedColor:blue hoverColor:red align:#right
			)
			
			Button btnAlign "Align To Face" tooltip:"Click a face to align the slice plane to." width:160
			on btnAlign pressed do (
				if (canUse()) then (
					::wallwormSlicemodOps.currentSlice = getMod()
					with undo off mouseTrack trackCallback:::wallwormSlicemodOps.pickingFace
				)
			)
			CheckBox chkCap "Always Cap" tooltip:"When on, each new slice or collapse will Cap Holes."  align:#left
			CheckBox chkKeepSlicing "Keep Slicing until Right-Click" align:#left
			Button btnQuickSlice "Quick Slice"  width:160 tooltip:"Slice based off of two points from the viewport perspective."
			
			on btnQuickSlice pressed do (
				doSlice()
			)
			
			Button btnCapSlice "Cap-n-Slice"  width:160 tooltip:"Cap this Slice results and add another Slice modifier."
			on btnCapSlice pressed do (
				GoAgain addCap:true
			)
			
			
			Group "Collapse" (
				Spinner spMatID "Explicit Material" type:#integer range:[1,99,1] align:#right tooltip:"When Cap Material is set to Explicit ID, this is the material ID that will be used."
				DropDownList drpMatIDPolicy "Cap Material" items:#("Automatic","Explicit ID","Default From Cap") tooltip:"Rule for applying material ID to capped faces. Automatic will look for an existing material named \"slice\" or \"tools/toolsnodraw\" and use that ID if found or append to the material id list if not; Explicit will set all capp materials to ID specified above; Default From Cap uses the one provided by Max."
				Button btnCapCollapse "Cap-n-Collapse" width:160 tooltip:"Collapse this node to an Editable Poly with some cleanup functions that add UVW to capped faces and apply materials."
				Button btnCapCollapseExplode "Cap-Collapse-Explode" tooltip:"Similar to Cap-n-Collapse except also explodes the objects into their elements."
			)
			on spMatID changed val do (
				if (canUse()) then (
					::wallwormSlicemodOps.MatID = val
					::wallwormSlicemodOps.saveSettings()
				)
			)
			on drpMatIDPolicy selected sel do (
				if (canUse()) then (
					::wallwormSlicemodOps.MatIDPolicy = sel
					::wallwormSlicemodOps.saveSettings()
				)
			)
			
			function collapseme objs = (
				
				addModifier objs (Cap_Holes Smooth_New_Faces:1 Smooth_With_Old_Faces:0 Make_All_New_Edges_Visible:0 )
				addModifier objs (Turn_to_Poly keepConvex:true requirePlanar:true planarThresh:4 removeMidEdgeVertices:true selectionLevel:4)
				
				local vSel = Poly_Select()
				modPanel.addModToSelection vSel ui:on
				setselectionlevel vSel #Face
				local uvM = UVWMap maptype:4 width:128 length:128 height:128
				modPanel.addModToSelection uvM  ui:on
					
				local matM
				case drpMatIDPolicy.selection of (
					1:(
						local useMatID
						if ::wallwormSlicemodOps == undefined then (
							if (querybox "Wall Worm Slide Mod Tools not installed. Fall back to explicit Mat ID?") then (
								useMatID = spMatID.value
							)
						) else (
							useMatID = ::wallwormSlicemodOps.getNextHighestMaterialID $
						)
						if useMatID != undefined then (
							matM = MaterialModifier materialid:useMatID
						)
					)
					2:(matM = MaterialModifier materialid:spMatID.value)
					default:(
						
					)
				)

				if matM != undefined then (
					modPanel.addModToSelection matM  ui:on
				)
				convertToPoly objs
			) 
			
			
			
			on btnCapCollapse pressed do (
				undo "Cap-n-Collapse" on (
					collapseme $
				)
			)
			on btnCapCollapseExplode pressed do (
				if (canUse()) then (
					undo "Cap-Collapse-Explode" on (
						collapseme $
						local newNodes = #()
						for obj in (selection as array) do (
							local res = ::wallwormSlicemodOps.breakIntoElements obj
							if res != undefined AND res.count > 0 then join newNodes res
						)
						if newNodes.count > 0 then (
							select newNodes
						)
					)
				) else messagebox "Wall Worm Slide Mod Tools not installed. Explode not available."
			)
			
			
			checkbox chkAutoAdd "Always Add Slice Tools" tooltip:"When on, slice tools will be added to the Slice Modifier every time one is added to an object."
			on chkAutoAdd changed stat do (
				if (canUse()) then (
					::wallwormSlicemodOps.AutoSliceMod = stat
					::wallwormSlicemodOps.saveSettings()
				)
			)
			
			Button btnSaveCurrentSliceAsDefault "Save Defaults" tooltip:"Save the current settings to an INI as defaults."
			on btnSaveCurrentSliceAsDefault pressed do (
				getMod()
				if thisMod != undefined AND (canUse()) then (
					::wallwormSlicemodOps.Slice_Type = thisMod.Slice_Type
					::wallwormSlicemodOps.Faces___Polygons_Toggle = thisMod.Faces___Polygons_Toggle
					::wallwormSlicemodOps.saveSettings()
				)
			)
			on slicerollout open do (
				if ::wallwormSlicemodOps != undefined then (
					chkAutoAdd.checked = ::wallwormSlicemodOps.AutoSliceMod
					spMatID.value = ::wallwormSlicemodOps.MatID
					drpMatIDPolicy.selection = ::wallwormSlicemodOps.MatIDPolicy
				) else format "Wall Worm Slide Mod Tools not installed... no saved defaults.\n"
			)
		)
		function resetThis = (
			thisMod = undefined
		)
		on create do (
			resetThis()
		)
		on clone original do (
			original.resetThis()
			resetThis()--just in case the modifiers are not instances
		)
	)

	::wallwormSlicemodHelp = struct wallwormSlicemodHelp (
		ini = "$userscripts\\WallWorm.com\\config\\slicemod.ini",
		Slice_Type = 1,
		Faces___Polygons_Toggle =1,
		AutoSliceMod = true,
		sliceMatNames = #("tools/toolsnodraw","slice"),
		MatID=1,
		MatIDPolicy = 1, --1 = Auto Add; 2 = Assign Manual ID; 3 = Do Nothing
		currentSlice,
		function getSettings = (
			
			local sliceMatNamesTemp = getINISetting ini "Slice" #sliceMatNames
			if sliceMatNamesTemp != undefined AND sliceMatNamesTemp != "" then (
				sliceMatNamesTemp = filterString sliceMatNamesTemp ","
				if sliceMatNamesTemp.count  > 0 then (
					sliceMatNames = sliceMatNamesTemp
				)
			)
			
			MatIDPolicy  =  (getINISetting ini "Slice" #MatIDPolicy)
			if MatIDPolicy == undefined then MatIDPolicy = 1
			MatIDPolicy = MatIDPolicy as Integer
			if MatIDPolicy < 1 then MatIDPolicy = 1 else if MatIDPolicy > 3 then MatIDPolicy = 3

			
			MatID  =  (getINISetting ini "Slice" #MatID)
			if MatID == undefined then MatID = 1
			MatID = MatID as Integer
			if MatID < 1 then MatID = 1 else if MatID > 99 then MatID = 99
			
			
			AutoSliceMod  = case (getINISetting ini "Slice" #AutoSliceMod) of (
				true:(true)
				false:(false)
				"true":(true)
				"false":(false)
				"TRUE":(true)
				"FALSE":(false)
				1:(true)
				0:(false)
				default:true
			)
			Slice_Type  = case (getINISetting ini "Slice" #Slice_Type) of (
				true:(1)
				false:(0)
				"true":(1)
				"false":(0)
				"TRUE":(1)
				"FALSE":(0)
				1:(1)
				0:(0)
				default:1
			)
			Faces___Polygons_Toggle  = case (getINISetting ini "Slice" #Faces___Polygons_Toggle) of (
				true:(1)
				false:(0)
				"true":(1)
				"false":(0)
				"TRUE":(1)
				"FALSE":(0)
				1:(1)
				0:(0)
				default:1
			)
		),
		getElementUsingFace = polyop.getElementsUsingFace,
		detachFacesM = polyop.detachFaces,
		function GetElements obj = (
			local elements = #()
			local facesInProcessedPolygons = #{}
			for i = 1 to obj.numfaces do (
				if facesInProcessedPolygons[i] == false then (
					faces = (getElementUsingFace obj #(i))
					append elements faces
					facesInProcessedPolygons += faces
				)
			)
			elements
		),
		function breakIntoElements obj  = (
			local newBlocks = #()
			if superclassof obj == GeometryClass then (
				max create mode
				with redraw off (
					local elements = GetElements obj
					local mat = obj.mat
					local startName = obj.name
					if elements.count > 1 then (
						--only use multi-element objects.... those with one element don't need exploded
						for element in elements  do (
							local thisname = (timestamp()) as string + "tempnamecut"
							detachFacesM obj element delete:false asNode:true name:thisname
							local newnode = getNodeByName thisname
							if isValidNode newnode	then (
								newnode.name = uniquename startName
								newnode.mat = mat
								newNode.pivot = newNode.center
								resetXForm newNode
								convertToPoly newnode
								append newBlocks newNode								
							)
						)
						delete obj
					) else (
						append newBlocks obj
					)
				)
			)
			newBlocks
		),
		function addMod sl = (
			if NOT isProperty sl #WallWormSliceModTools then (
				custAttributes.add sl ::WallWormSliceModTools
				sl.getMod()
				sl.Slice_Type = Slice_Type
				sl.Faces___Polygons_Toggle = Faces___Polygons_Toggle
			)
		),
		function getSliceMatID obj = (
			local matID
			local mat = obj.mat
			if classof mat == MultiMaterial then (
				for i =  1 to mat.numsubs WHILE matID == undefined do (
					local thisM = mat.materialList[i]
					if thisM != undefined AND findItem sliceMatNames (toLower thisM.name) > 0  then matID = i
					if thisM == undefined then (
						local thisN = mat.names[i]
						if thisN != undefined AND  findItem sliceMatNames (toLower thisN) > 0  then matID = i
					)
				)
			)
			matID
		),
		function getNextHighestMaterialID obj = (
			if classof obj == ObjectSet then (
				obj = obj[1]
			)
			local matID = getSliceMatID obj
			if matID == undefined then (
				local m = snapshotasmesh obj
				local mFaces = #{}
				for f = 1 to m.numfaces do (
					mFaces[(getFaceMatID  m f)] = true
				)
				delete m
				matID = mFaces.numberset + 1				
			)
			matID
		),
		function pickingFace msg ir obj faceNum shift ctrl alt = (
			local node, face, faceid
			case msg of (
				#mousePoint:
				(
					wray = mapScreenToWorldRay mouse.pos
					inodes = intersectRayScene wray
					inodes = for obj in inodes WHERE NOT obj[1].ishiddenInVpt AND NOT isGroupHead obj[1] collect obj
					if inodes.count > 0 then (
						function sortByDistance n1 n2 pos:[0, 0, 0] = (
							--provide by denisT
							local d1 = distance n1[2].pos pos
							local d2 = distance n2[2].pos pos
							if d1 > d2 then 1 else if d1 < d2 then -1 else 0
						)
						qsort inodes sortByDistance pos:wray.pos
						node = inodes[1][1]
						local r = (intersectRay node wray)
						forcecompleteredraw()
						local inv = currentSlice.getTrans()
						local theMatrix = matrixFromNormal r.dir
						translate theMatrix r.pos
						
						
						
						theMatrix *= inv
						
						
						
						currentSlice.Slice_Plane.transform = theMatrix
					)
				)
			)
			if msg == #mouseAbort then (
				currentSlice = undefined
				#abort
			) else #continue
		),
		function AutoSliceModCallback = (
			local res = callbacks.notificationParam()
			if isValidNode res[1] AND classof res[2] == SliceModifier then (
				local sl = res[2]
				addMod sl
			)
		),
		function initiateCallbacks = (
			callbacks.removeScripts id:#WallWormAutoSliceModID
			if AutoSliceMod == true then (
				callbacks.addScript #postModifierAdded "::wallwormSlicemodOps.AutoSliceModCallback()" id:#WallWormAutoSliceModID
				--this means that the Normal Tools custom attribute will be added to all edit normals modifiers added to objects
			)
		),
		function saveSettings = (
			local cansave = doesFileExist ini
			if (cansave == false) then (
				
				local inifolder = pathConfig.convertPathToAbsolute (pathConfig.removePathLeaf ini)
				if (makeDir inifolder all:true == false) then (
					format "Config Directory doesn't exist\n"
					false
				) else cansave = true
			)
			
			if cansave then (
				setINISetting ini "Slice" #Faces___Polygons_Toggle	(Faces___Polygons_Toggle as string)
				setINISetting ini "Slice" #Slice_Type (Slice_Type as string)
				setINISetting ini "Slice" #AutoSliceMod (AutoSliceMod as string)
				setINISetting ini "Slice" #MatID	(MatID as string)
				setINISetting ini "Slice" #MatIDPolicy (MatIDPolicy as string)			
				
				local sliceMatNamesTemp = stringstream ""
				for i = 1 to sliceMatNames.count do (
					format "%" sliceMatNames[i] to:sliceMatNamesTemp
					
					if i != sliceMatNames.count do (
						format "," to:sliceMatNamesTemp
					)
				)
				setINISetting ini "Slice" #sliceMatNames (sliceMatNamesTemp as string)				
			) else format "Slice Tool Settings not saved... perhaps a permission write error.\n"
			initiateCallbacks()
			cansave
		)
	)

	::wallwormSlicemodOps = ::wallwormSlicemodHelp()
	::wallwormSlicemodOps.getSettings()
	::wallwormSlicemodOps.initiateCallbacks()
)