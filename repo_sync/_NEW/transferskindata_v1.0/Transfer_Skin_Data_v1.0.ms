/*
Copyright 2015, Michael Lawler
	Email:			archangel35757@yahoo.com
	Title:			Transfer Skin Data
	Description:	This script allows a user to swap out skeletons by transferring Skin Modifier data. This is 
					done by saving skin envelope data on the current skeleton and then reloading the skin modifier
					data (bones and skin weights) onto a new skeleton merged into the scene (that replaced the old skeleton).
	Version:		1.0
	Date:  			July 23, 2015 (original creation date)
	
	Change History: 
	v0.9	23 JUL 2015	--	Initial release
	v1.0	10 MAR 2016	--	Added buttons to delete custom attributes that hold temporary scene skinned objects and skin data
						--	Added error trapping for missing envelope files
	v1.0	11 MAR 2016 --	Added option to browse for missing envelope files
						--	Added check for instanced skin modifiers and make them unique (see fn hasSkinMod)
						--	Added more error trapping to catch out-of-sequence usage
	v1.0	14 MAR 2016 --	Released
	
*/

--global variables
global envFormat = undefined
global SkinData_rll
global skeletonFilename = "*.max"


--customAttribute definitions
skinObj = attributes skinObj
(
	parameters skinObjParams
	(
		-- must be a nodeTab type to hold node objects
		skinObjList		type:#nodeTab	tabSizeVariable:true
	)	
)

skinData = attributes skinData
(
	parameters skinParams
	(
		-- must be a stringTab type because bone objects will get deleted and re-imported
		boneList		type:#stringTab		tabSizeVariable:true
		boneCount		type:#integer		default:0
	)		
)


--function definitions
fn hasSkinMod = (
	if ( custAttributes.count rootNode == 0 ) do (
		--add the custom attribute on the rootNode
		custAttributes.add rootNode skinObj
		
		for o in objects where ( superClassOf o == GeometryClass and o.modifiers.count > 0 ) do 
		(
			for i = 1 to o.modifiers.count do 
			(
				if ( (classOf o.modifiers[i]) == Skin ) do
				(
					--check for instanced skin modifier and make unique if possible
					if InstanceMgr.CanMakeModifiersUnique o o.modifiers[i] do (
						InstanceMgr.MakeModifiersUnique o o.modifiers[i] #individual
					)
										
					--add this object to the list of objects having skin modifier
					append rootNode.skinObjList o

					--add the custom attribute to hold skin data onto this object
					if not isProperty o "skinData" do (
						custAttributes.add o skinData
					)
				)
			)
		)
	)
)

fn cleanSkinMod = (
	--disable the button after user presses it... so they don't accidentally attempt 2nd try
	SkinData_rll.btn_CleanSkin.enabled = false
	
	for o in rootNode.skinObjList do 
	(
		select o
		max modify mode
		modPanel.setCurrentObject o.modifiers[#Skin]
		
		--now remove all bones from this skin modifier
		if skinOps.GetNumberBones o.modifiers[#Skin] > 0 do (
			for i = o.boneCount to 1 by -1 do
			(
				skinOps.SelectBone o.modifiers[#Skin] i
				skinOps.removebone o.modifiers[#Skin]
			)
		)
		
		deselect o
	)
	
	--enable the delete old bones button
	SkinData_rll.btn_DeleteOldBones.enabled = true
)

fn deleteOldBones = (
	--disable the button after user presses it... so they don't accidentally attempt 2nd try
	SkinData_rll.btn_DeleteOldBones.enabled = false
	
	for o in rootNode.skinObjList do 
	(
		for i = 1 to o.boneList.count do 
		(
			try (
				tempBone = getNodeByName o.boneList[i] exact:true ignoreCase:true all:false
				if isValidNode tempBone do (
					delete tempBone
				)
			)
			catch ()
		)
	)
	
	--enable the merge skeleton button
	SkinData_rll.btn_MergeSkeleton.enabled = true
)

fn saveSkinModData = (
	local numBones = 0
	local envFilename = undefined
	local count = 0
	
	if rootNode.skinObjList.count > 0 do 
	(
		--disable the button after user presses it... so they don't accidentally duplicate the bone list
		SkinData_rll.btn_SaveENVData.enabled = false
		
		format "Writing Skin envelope files...\n" to:Listener
		
		for o in rootNode.skinObjList do 
		(	
			count += 1 --loop counter
			if o.boneCount == 0 then
			(
				for i = 1 to o.modifiers.count do 
				(
					if ( (classOf o.modifiers[i]) == Skin ) do
					(
						--now access the skin modifier data
						select o
						max modify mode
						modPanel.setCurrentObject o.modifiers[#Skin]
						numBones = skinOps.GetNumberBones o.modifiers[#Skin]
						
						--store number of bones in this skin modifier on current object
						o.boneCount = numBones
						
						if numBones > 0 then 
						(
							--save envelope data to file
							if envFormat == 1 then 
							( 
								--binary file type
								envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".env"
								print envFilename to:Listener
								skinOps.saveEnvelope o.modifiers[#Skin] envFilename
							)
							else
							(
								--ASCII file type
								envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".envASCII"
								print envFilename to:Listener

								skinOps.saveEnvelopeAsASCII o.modifiers[#Skin] envFilename
							)
							
							--now lets iterate thru the bone list and get the bone names under this skin modifier
							for j = 1 to numBones do
							(
								--store bone names
								append ( o.boneList ) ( skinOps.GetBoneName o.modifiers[#Skin] j 1 )
							)
						)
						else (
							tempMessage = "No bones assigned to [ " + o.name + " ].  No envelope file written."
							format "...No bones assigned to [ % ].  No envelope file written.\n" o.name to:Listener
							messageBox tempMessage title:"Warning!"
						)
						
						deselect o
					)
				)
			)
			else if o.boneCount > 0 do (
				--access the skin modifier data
				select o
				max modify mode
				modPanel.setCurrentObject o.modifiers[#Skin]
				numBones = skinOps.GetNumberBones o.modifiers[#Skin]
				
				if numBones != o.boneCount do (
					tempMessage = "For object: [ " + o.name + " ] \n\n" +
								  "Skin Modifier bone count does not equal CustAttr boneCount."
					messageBox tempMessage title:"Warning!"
				)
				
				if numBones > 0 then 
				(
					--save envelope data to file
					if envFormat == 1 then 
					( 
						--binary file type
						envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".env"
						print envFilename to:Listener
						skinOps.saveEnvelope o.modifiers[#Skin] envFilename
					)
					else
					(
						--ASCII file type
						envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".envASCII"
						print envFilename to:Listener

						skinOps.saveEnvelopeAsASCII o.modifiers[#Skin] envFilename				
					)
					
				)
				else (
					tempMessage = "No bones assigned to [ " + o.name + " ].  No envelope file written."
					format "...No bones assigned to [ % ].  No envelope file written.\n" o.name to:Listener
					messageBox tempMessage title:"Warning!"
				)
				
				deselect o
			)
			
			--update the progress bar
			(SkinData_rll.pbar_SaveSkinData).value = ( ( (count as float) / (rootNode.skinObjList.count) ) * 100 ) as integer
			
			--update numeric percentage
			(SkinData_rll.lab2).text = ( (SkinData_rll.pbar_SaveSkinData).value as string ) +"%"
			
		)
		
		--enable the Load ENV button
		SkinData_rll.btn_CleanSkin.enabled = true
		
	)
)

fn loadSkinModData = (
	local envFilename = undefined
	local count = 0
	local envType = undefined
	
	--disable the button after user presses it... so they don't accidentally attempt 2nd try
	SkinData_rll.btn_LoadENVData.enabled = false
	
	if ( isProperty rootNode "skinObj" ) and ( rootNode.skinObjList.count > 0 ) then (
	
		format "\nLoading Skin envelope files...\n" to:Listener
		
		bSkipObject = false
		
		for o in rootNode.skinObjList do 
		(
			count += 1 --loop counter
			select o
			
			--get the envelope filename for this object
			if envFormat == 1 then (
				envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".env"
				envType = ".env"
			)
			else (
				envFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + o.name + ".envASCII"
				envType = ".envASCII"
			)
			
			-------------------
			if not doesFileExist envFilename do (
				tempMessage = "Cannot find envelope file for object:\n" + o.name + "\nWould you like to browse for file?"
				if queryBox (tempMessage) title:"File Missing..." then (
					envFilename = getOpenFileName caption:"Open Skin Envelope File:" filename:envFilename types:"Binary (*.env)|*.env|ASCII (*.envASCII)|*.envASCII|"
					envType = getFilenameType envFilename
				)
				else ()
			)
			-------------------
			
			--Add check to ensure envelope file exists and has not been moved or accidentally deleted
			if doesFileExist envFilename then (
				--here we need to check if skin modifier exists and if not add one		
				max modify mode
				if o.modifiers[#Skin] == undefined then (
					addModifier o (Skin())
					modPanel.setCurrentObject o.modifiers[#Skin]
				)
				else (
					modPanel.setCurrentObject o.modifiers[#Skin]
				)
			
				for i = 1 to o.boneList.count do 
				(
					tempBone = getNodeByName o.boneList[i] exact:true ignoreCase:true all:false

					if tempBone == undefined then (
						format "Failed to find bone [ % ] in scene.\n" o.boneList[i] to:Listener
						tempMessage = "Failed to find bone [ " + o.boneList[i] + " ] in scene used by object [ " + o.name + " ].\nDo you wish to continue loading envelopes for this object?\n"
						if queryBox tempMessage title:"Warning!" then (
							bSkipObject = false
						)
						else ( 
							exit with bSkipObject = true
						)
					)
					else if isValidNode tempBone then (
						try (

								--check to make sure bone doesn't already exist in skin modifier
								numBones = skinOps.GetNumberBones o.modifiers[#Skin]
								
								if numBones == 0 then (
									--add it to the skin modifier
									skinOps.addbone o.modifiers[#Skin] tempBone 1
								)
								else (
									bBoneExists = false
									
									for j = 1 to numBones do
									(
										--compare bone names
										skinModBoneName = ( skinOps.GetBoneName o.modifiers[#Skin] j 1 )
										
										if tempBone.name == skinModBoneName do (
											--names match! Therefore bone is already in modifier... do not append!
											bBoneExists = true
											exit
										)
									)
									
									--add it to the skin modifier
									if not bBoneExists do (
										skinOps.addbone o.modifiers[#Skin] tempBone 1
									)
								)
								
						)
						catch (
							format "Failed to add bone [ % ] to Skin Modifier on object [ % ].\n" tempBone.name o.name to:Listener
						)
					)
					else ()
				)
				
				if not bSkipObject do (
					--skinOps.resetAllBones o.modifiers[#Skin]
					skinOps.Invalidate o.modifiers[#Skin] 1	
					
					--reLoad the envelope data	
					if envType == ".env" then (
						skinOps.loadEnvelope o.modifiers[#Skin] envFilename
					)
					else (
						skinOps.loadEnvelopeAsASCII o.modifiers[#Skin] envFilename
					)
				)
				
				--update the progress bar
				(SkinData_rll.pbar_LoadSkinData).value = ( ( (count as float) / (rootNode.skinObjList.count) ) * 100 ) as integer
				
				--update numeric percentage
				(SkinData_rll.lab3).text = ( (SkinData_rll.pbar_LoadSkinData).value as string ) + "%"			

			)
			else (
				tempMessage = "Cannot find envelope file for object:  " + o.name
				format "Cannot find envelope file for object:  %\n" o.name to:Listener
				messageBox ( tempMessage ) title:"Warning!"
			)
			
			deselect o

		)
	)
	else (
		tempMessage = "Skinned Objects List Custom Attribute data is missing in scene."
		print tempMessage to:Listener
		messageBox ( tempMessage ) title:"Warning!"
	
	)
	
	--refresh progressBar to overcome window clipping
	setFocus SkinData_rll.pbar_LoadSkinData
	--re-enable the button after function has finished...
	SkinData_rll.btn_LoadENVData.enabled = true
)


--Authorship rollout
rollout Authorship_rll "About" width:300 height:150 (
	label lab0 "Save and Load Skin Envelopes for Mesh Objects allowing"
	label lab1 "transfer of skin data between identical skeletons."
	edittext edtxt_Version "Version" fieldWidth:60 offset:[0,8] text:("1.0") align:#center
	label lab2 "Copyright \xa9 2015, Michael Lawler" height:14 align:#center offset:[0,8]
	HyperLink lab5Email "(archangel35757\x40yahoo.com)" color:blue hoverColor:(color 108 8 136) align:#center address:"mailto:archangel35757\x40yahoo.com"
	button btn_Ok "Ok" width:100 offset:[0,2]
	
	--Event handlers
	on btn_Ok pressed do (
		DestroyDialog Authorship_rll
	)
)


--User interface rollout
rollout SkinData_rll "Skin Envelopes Manager" width:330 height:300 (
	group "About"
	(
		edittext edtxt_Version "Version" fieldWidth:60 text:("1.0" )  readOnly:true
		button btn_Author "Authorship..." width:90 height:25 offset:[107,-27]
	)
	
	group ""
	(
		label envLabel "ENV File Format: " align:#left
		radiobuttons rdo_ENVFormat "" labels:#("Binary","ASCII") default:1 offset:[-10,-19]
		button btn_SaveENVData "Save ENV" align:#left width:75 height:25
		progressBar pbar_SaveSkinData value:0 color:blue offset:[80,-24] width:200
		label lab2 "0%" offset:[144,-18]
		button btn_CleanSkin "Remove Bones from Skin Modifiers" width:304 height:25 offset:[0,7] enabled:false
		button btn_DeleteOldBones "Delete Old Bones from Scene" width:304 height:25 enabled:false
		button btn_MergeSkeleton "Merge Skeleton" width:90 height:25 align:#left enabled:false
		edittext edtxt_SkeletonPath "" fieldWidth:210 offset:[90,-24] text:skeletonFilename readOnly:true
		button btn_LoadENVData "Load ENV" align:#left width:75 height:25 offset:[0,2]
		progressBar pbar_LoadSkinData value:0 color:green offset:[80,-24] width:200
		label lab3 "0% " offset:[144,-18]
		label lab4 "" offset:[0,-5] --add extra space for group box
	)
	
	button btnDelObjCA "Delete Object CA" width:95 height:25 align:#left offset:[0,6] toolTip:"Deletes SkinData Custom Attribute from Objects"
	button btnDelRootCA "Delete Root CA" width:95 height:25 offset:[0,-30] enabled:false toolTip:"Deletes Skinned Objects List Custom Attribute from rootNode"
	button btnReset "Reset" width:75 height:25 align:#right offset:[0,-30] toolTip:"Resets buttons and progress bars"

	
	--Event handlers
	on SkinData_rll open do
	(
		envFormat = rdo_ENVFormat.state
		txtWarning = "This script is not compatible with instanced Skin Modifiers.\n" +
					 "Therefore, executing this script will make any instanced skin\n" +
					 "modifiers unique.  If you wish to proceed-- press YES.  Otherwise,\n" +
					 "press NO to exit script and your scene will be unaffected."
		if queryBox txtWarning title:"Warning!" then (
			hasSkinMod()
		)
		else ( 
			DestroyDialog SkinData_rll 
			completeRedraw()
		)
	)
	
	on btn_Author pressed do 
	(
		CreateDialog Authorship_rll modal:true
	)
	
	on rdo_ENVFormat changed state do 
	(
		envFormat = state
	)
	
	on btn_SaveENVData pressed do 
	(
		saveSkinModData()
	)
	
	on btn_CleanSkin pressed do 
	(
		cleanSkinMod()
	)
	
	on btn_DeleteOldBones pressed do 
	(
		deleteOldBones()
	)
	
	on btn_MergeSkeleton pressed do 
	(
		skeletonFilename = getMAXOpenFileName filename:skeletonFilename
		edtxt_SkeletonPath.text = skeletonFilename
		mergeMAXFile skeletonFilename #prompt
		
		--refresh viewports
		redrawViews()
	)
	
	on btn_LoadENVData pressed do 
	(
		loadSkinModData()
	)
	
	on btnDelObjCA pressed do 
	(
		if queryBox "Are you sure you want to delete the skin data custom attribute from all objects?" title:"Caution..." then (
			try (
				--delete the skin data custom attribute from each skinned object
				for o in rootNode.skinObjList do (
					custAttributes.delete o 1
				)
				
				btnDelRootCA.enabled = true
			)
			catch ()
		)
		else ()

	)
	
	on btnDelRootCA pressed do 
	(
		if queryBox "Are you sure you want to delete the list of skinned objects in the scene?" title:"Caution..." then (
			--delete the rootNode custom attribute holding list of skinned objects
			try ( custAttributes.delete rootNode 1 )
			catch ()
			DestroyDialog SkinData_rll 
		)
		else ()

	)
	
	on btnReset pressed do 
	(		
		--reset buttons and progress bars
		btn_SaveENVData.enabled = true
		btn_LoadENVData.enabled = true
		pbar_SaveSkinData.value = 0
		lab2.text = "0%"
		pbar_LoadSkinData.value = 0
		lab3.text = "0%"
		btnDelRootCA.enabled = false
	)
	
)

CreateDialog SkinData_rll