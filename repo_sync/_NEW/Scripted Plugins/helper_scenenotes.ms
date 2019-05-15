-- Scene Notes Helper v.1 [2010-11-13] by Anubis [project3d.narod.ru]
-- Install: put the script in stdplugs\stdscripts folder
plugin Helper SceneNotes
	name:"SceneNotes"
	classID:#(0x17ccec38, 0x57492a70)
	category:"Standard"
	extends:Dummy
(
	local meshObj
	parameters pblock rollout:params
	(
		Comments type:#string ui:txtNotes
		ShowOnLoad type:#boolean default:false ui:PopUp
	)
	rollout params "Parameters"
	(
		checkbox PopUp "Show On Load"
		edittext txtNotes width:140 height:260 align:#right
	)
	on getDisplayMesh do -- >> 3ds Max 7 and higher
	(
		if meshObj == undefined do
		(
			meshObj = createInstance Plane length:10 width:10 \
			lengthsegs:1 widthsegs:1 mapCoords:false
		)
		meshObj.mesh
	)
	on attachedToNode node do (node.wirecolor = red)
	tool create
	(
		on mousePoint click do
		(
			nodeTM.translation = gridPoint;#stop
		)
	)
	on postLoad do
	(
		if ShowOnLoad and this.Comments != undefined do
		(
			format "----------------------\n"
			format "-- [ % ] --\n\n" (refs.dependentNodes this firstOnly:on).name
			format "%\n\n" this.Comments
			actionMan.executeAction 0 "40472"  -- open Listener
		)
	)
)
/*
Tips & Tricks
---------------

-- get all SceneNotes instances:
	allNotes = getClassInstances SceneNotes
-- print all their comments:
	for n in allNotes where n.Comments != undefined do print n.Comments
-- use formating:
	for n in allNotes where n.Comments != undefined do (
		format "----------------------\n"
		format "-- [ % ] --\n\n" (refs.dependentNodes n firstOnly:on).name
		format "%\n\n" n.Comments
	)
-- format to the Listener only active SceneNotes:
	for n in allNotes where n.Comments != undefined \
		and n.ShowOnLoad == true do (
		format "----------------------\n"
		format "-- [ % ] --\n\n" (refs.dependentNodes n firstOnly:on).name
		format "%\n\n" n.Comments
	)

*/
