--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 																							P3D CHANNEL INFO TOOLS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if(::gP3DChannelInfoTools != undefined and ::gP3DChannelInfoToolsUI != undefined) then destroyDialog ::gP3DChannelInfoToolsUI

global gP3DChannelInfoTools = undefined
global gP3DChannelInfoToolsUI = undefined

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROLLOUT
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
rollout dlgP3DChannelInfoToolsGUI "Channel Info Tools" width:176 height:576
(
		
	GroupBox 'grp1' "Clear channels" pos:[8,480] width:160 height:83 align:#left
	spinner 'spnClearFrom' "From:" pos:[16,500] width:37 height:16 range:[1,99,-1] type:#integer align:#left
	button 'btn_Clear' "Clear" pos:[80,529] width:76 height:24 align:#left

	
	GroupBox 'grp2' "Copy channels" pos:[8,232] width:160 height:232 align:#left
	spinner 'spnCopyFrom' "From:" pos:[20,256] width:37 height:16 range:[1,99,-1] type:#integer align:#left
	spinner 'spnCopyTo' "To:" pos:[104,256] width:42 height:16 range:[1,99,-1] type:#integer align:#left


	button 'btn_Copy' "Copy" pos:[16,288] width:64 height:24 align:#left
	button 'btn_Swap' "Swap" pos:[88,288] width:72 height:24 align:#left
	
	button 'btn_Copy_1234' "Copy 1 to 2,3,4" pos:[16,376] width:144 height:30 align:#left
	
	button 'btn_Copy_124' "Copy 1 to 2,4" pos:[16,336] width:144 height:30 align:#left

	spinner 'spnClearTo' "To:" pos:[96,500] width:42 height:16 range:[1,99,-1] type:#integer align:#left
	button 'btnInfo' "Info" pos:[16,184] width:144 height:20 align:#left
	GroupBox 'grp5' "Channel Info" pos:[8,160] width:160 height:56 align:#left
	GroupBox 'grp9' "Selection" pos:[9,12] width:159 height:132 align:#left
	radiobuttons 'rdoSelection' "" pos:[24,32] width:29 height:48 labels:#(">", "=", "<") columns:1 align:#left 
 
 
	spinner 'spnChannelCount' "" pos:[112,56] width:41 height:16 range:[0,10,0] type:#integer scale:1 align:#left
	label 'lbl3' "Channel count:" pos:[80,32] width:73 height:18 align:#left
	button 'btnSelectObjects' "Select Objects" pos:[16,104] width:144 height:28 align:#left 
 
 
	button 'btnCpy234' "Copy 2 to 3,4" pos:[16,416] width:144 height:30 align:#left
	
	on dlgP3DChannelInfoToolsGUI open do
	(
		spnClearTo.value 	= ::gSaveConfig.GetConfigProperty "P3DChannelInfoTools" 	"ClearTo"  	default:10
		spnCopyFrom.value 	= ::gSaveConfig.GetConfigProperty "P3DChannelInfoTools" 	"CopyFrom" default:1 
		spnCopyTo.value 	= ::gSaveConfig.GetConfigProperty "P3DChannelInfoTools" 	"CopyTo" default:9
		spnClearFrom.value 	= ::gSaveConfig.GetConfigProperty "P3DChannelInfoTools" 	"ClearFrom" default:9
	)
	
	on dlgP3DChannelInfoToolsGUI close do
	(
		::gSaveConfig.SetConfigProperty "P3DChannelInfoTools" "ClearTo" 	#integer spnClearTo.value 
		::gSaveConfig.SetConfigProperty "P3DChannelInfoTools" "CopyFrom" 	#integer spnCopyFrom.value
		::gSaveConfig.SetConfigProperty "P3DChannelInfoTools" "CopyTo" 	#integer spnCopyTo.value
		::gSaveConfig.SetConfigProperty "P3DChannelInfoTools" "ClearFrom" 	#integer spnClearFrom.value
		
	)
	
	on btn_Clear pressed do
	(	
		local sel = #()
		join sel selection
		if ::gP3DChannelInfoTools.TestSelection sel then
		(
			for j = 1 to sel.count do
			(
				::gP3DChannelInfoTools.ClearChannels sel[j] spnClearFrom.value spnClearTo.value
			)
		)
	)
	
	on btn_Copy pressed do
	(
		arrCopyTo = #(spnCopyTo.value)
		::gP3DChannelInfoTools.CopyChannels spnCopyFrom.value arrCopyTo
	)
	
	on btn_Swap pressed do
	(	
		::gP3DChannelInfoTools.SwapChannels spnCopyFrom.value spnCopyTo.value
	)
	
	on btn_Copy_1234 pressed do
	(
		::gP3DChannelInfoTools.CopyChannels 1 #(2,3,4)
	)
	
	on btn_Copy_124 pressed do
	(
		::gP3DChannelInfoTools.CopyChannels 1 #(2,4)
	)
	
	on btnInfo pressed do
	(
		ChannelInfo.dialog()
	)
	
	on btnSelectObjects pressed do
	(
		sel = #()
		::gP3DChannelInfoTools.SelectObjects &sel rdoSelection.state spnChannelCount.value
		print"after:"
		print sel
	)
	
	on btnCpy234 pressed do
	(
		::gP3DChannelInfoTools.CopyChannels 2 #(3,4)
	)
)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--	STRUCTURE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
struct sP3DChannelInfoTools
(
	
	
	public function CopyChannel &obj channelFrom channelTo=
	(		
		if ::gP3DChannelInfoTools.TestSelection obj then
		(
			local error = false
			if (not (::gP3DChannelInfoTools.TestIfChannelExist obj channelFrom)) then error = true
			if (channelFrom == channelTo) then error = true
			if (not error) then
			(	
				local numMaps = numMapsUsed obj
				while numMaps < channelTo +1 do
				(
					ChannelInfo.AddChannel obj
					
					numMaps = numMapsUsed obj
				)
					
				newName = "channel" + channelTo as string
				ChannelInfo.NameChannel obj 3 channelTo newName
				ChannelInfo.CopyChannel obj 3 channelFrom
				ChannelInfo.PasteChannel obj 3 channelTo
			)
			else ::P3DLogM ("Problem with copying channels on object: " + obj.name + "  Probably source channel does not exist.")
		)
		
	),
	
	private function SelectObjectsByRule &objs rule channelCount =
	(
		numChannels = 0
		local tempFilteredObjects = #()
		
		for obj in objs do
		(
			numChannels = numMapsUsed obj
			
			case numChannels of
			(
				0: numChannels = numChannels
				default: numChannels = numChannels - 1
			)
			
			if(rule == 1 and numChannels > channelCount)then append tempFilteredObjects obj
			else if(rule == 2 and numChannels == channelCount)then append tempFilteredObjects obj
			else if(rule == 3 and numChannels < channelCount)then append tempFilteredObjects obj
		)
		
		objs = tempFilteredObjects
	),
	
	
	public function FilterInstances  &inSelection =
	(
		mySelection = inSelection
		newSelection = #()
		for obj in mySelection do
		(
			myInstances = #()
			
			if InstanceMgr.GetInstances obj &myInstances > 0 then
			(
				if findItem newSelection myInstances[1] == 0 do
				(
					append newSelection myInstances[1]
					continue
				)
			)
		)
		inSelection = #()
		inSelection = newSelection
	),
	
	public function CopyModToInstanceStack obj modNames = 
	(
		if((instanceMgr.getInstances obj &instances) != 1)then
			(
				aModifiers = #()
				for myModifier in obj.modifiers do
				(
					for modName in modNames do
					(
							if (classof myModifier  == modName)then
							(
								append aModifiers myModifier
							)
					)
				)

				addModifier obj (Edit_Poly()) before:(aModifiers.count+1)
				for myModifier in aModifiers do
				(
					addModifier obj myModifier before:(aModifiers.count+1)
					deleteModifier obj 1
				)
			)

		print aModifiers
-- 		deleteModifier obj 1

-- 		maxOps.CollapseNodeTo obj 1 off
	),
	
	public function testCopyObjects =
	(
		selObj = $
		const = 300
		moveNumb = 300
		allObjs = #()
		for i=1 to 5 do
		(
			newObjClone = copy selObj
			append allObjs newObjClone
			move newObjClone [moveNumb,0,0]
			moveNumb = moveNumb + const
		)
		
		moveNumb = 300
		for i=1 to 5 do
		(
			newObjClone = instance selObj
			newObjClone.wirecolor = color 88 177 27

			append allObjs newObjClone
			move newObjClone [moveNumb,const,0]
			moveNumb = moveNumb + const
		)
		select allObjs
	),
	
	------------------------------------------------------------------------------
	public fn ColapseStack obj =
	(
		CopyModToInstanceStack obj #(UVW_Mapping_Paste, UVW_Mapping_Add, UVW_Mapping_Clear)
		maxOps.CollapseNodeTo obj 1 off
	),
	
	------------------------------------------------------------------------------
	public fn TestSelection sel =
	(
		if sel == undefined then return false
		return true
	),
	
	------------------------------------------------------------------------------
	public fn TestIfChannelExist obj index = 
	(
		local exist = false
		local myClass = classof obj
		if (myClass == PolyMeshObject or myClass == Editable_Poly) then
		(
			if (polyop.getMapSupport obj index) then exist = true
		) else (
			if (myClass == Editable_mesh) then
			(
				if (meshop.getMapSupport obj index) then exist = true
			)
		)		
		return exist			
	),
	
	------------------------------------------------------------------------------
	public fn ClearChannels obj indexFrom indexTo =
	(
		if superclassof obj != GeometryClass then return false
		for i = indexFrom to indexTo do
		(
			ChannelInfo.ClearChannel obj i 
		)
		gP3DChannelInfoTools.ColapseStack obj
	),
	
	public function SelectObjects &objs rule channelCount =
	(
		objs = geometry as array
		FilterInstances &objs
		
		SelectObjectsByRule &objs rule channelCount
		select objs
	),
	
	public function CopyChannels channelFrom arrChannelsTo =
	(
		local sel = #()
		join sel selection
		
		::gP3DChannelInfoTools.FilterInstances &sel
		for obj in sel do
		(
			AddModifier (obj) (Edit_Poly())
			for channelTo in arrChannelsTo do
			(
				CopyChannel &obj channelFrom channelTo
			)
			local numMaps = numMapsUsed obj
			ChannelInfo.ClearChannel obj numMaps
			ColapseStack obj
		)
		select sel
	),
	
	public function SwapChannels channelFrom channelTo=
	(
		local sel = #()
		join sel selection
		
		::gP3DChannelInfoTools.FilterInstances &sel
		for obj in sel do
		(
			AddModifier (obj) (Edit_Poly())
			local numMaps = numMapsUsed obj
			CopyChannel &obj channelFrom numMaps
			CopyChannel &obj channelTo channelFrom
			CopyChannel &obj numMaps channelTo
			ChannelInfo.ClearChannel obj numMaps
			ColapseStack obj
		)
		select sel
	),
	
	------------------------------------------------------------------------------
	public fn Init =
	(
		::P3DLogL "START: Channel Info Tools"
		createDialog ::gP3DChannelInfoToolsUI
		local dialogPos = ::gSaveConfig.GetConfigProperty "P3DChannelInfoTools" 	"Position"  default:[500,500]
		SetDialogPos ::gP3DChannelInfoToolsUI dialogPos
	),
	------------------------------------------------------------------------------
	public fn CloseDialog =
	(
		::P3DLogL "END: Channel Info Tools"
		if ChannelInfo.isChecked() then ChannelInfo.update() 
		local dialogPos = GetDialogPos ::gP3DChannelInfoToolsUI
		::gSaveConfig.SetConfigProperty "P3DChannelInfoTools" "Position" #point2 dialogPos
		DestroyDialog ::gP3DChannelInfoToolsUI
	)	
)


if(::gP3DChannelInfoToolsUI == undefined)then
(
	::gP3DChannelInfoToolsUI = dlgP3DChannelInfoToolsGUI
)

if(::gP3DChannelInfoTools == undefined)then
(
	::gP3DChannelInfoTools = sP3DChannelInfoTools()
)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MACRO SCRIPTS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
macroScript ChannelInfoTools
category:"Pivo3D"
tooltip:"Channel Info Tool"
buttonText:"Channel Info Tool"
Icon:#("PolyTools",16)
(
	on execute do (
		::gP3DChannelInfoTools.Init()
	)
)

-- ::gP3DChannelInfoTools.Init()