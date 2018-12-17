--light mapp channel to 2 
--press shift button to weld vertices

fn addLightMap num =
(
	local spacing = 0.01
	local obj = selection[1]
	if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode mode:#modify
	if obj == undefined do return false
	modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 1")
	local gco = modPanel.getCurrentObject()
	local verts = #{1..gco.NumberVertices()}
	
	if keyboard.shiftPressed do
	(
		gco.selectVertices verts
		gco.setWeldThreshold 0.001
		gco.weld()
	)
	--gco.copy()
	channelInfo.CopyChannel obj 3 1
	channelInfo.PasteChannel obj 3 2
	channelInfo.update()

	modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 2")
	--completeRedraw()
	gco = modPanel.getCurrentObject()
	gco.setMapChannel num
	modPanel.validModifier gco -- lol , if not check , not works
	--format "is valid:%\n" (modPanel.validModifier gco)
	--format "modifier:%\tverts num:%\n" gco verts 
	gco.selectVertices verts
	--gco.paste false
	gco.pack 0 spacing true true true
	gco.selectVertices verts
	gco.scaleSelectedCenter .95 0 --x,y
)

addLightMap 2

