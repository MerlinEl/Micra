try
(
	PostDelete_NodeEventCallback.enabled = off
	PostDelete_NodeEventCallback = undefined
)
catch()

callbacks.removescripts id:#delete_same_class
callbacks.removeScripts id:#undo
callbacks.removeScripts id:#redo

global NodesForDeletion = #()
global objCount = objects.count


fn PostDelete_Callback event handles = 
(
	nodes = for node in NodesForDeletion where isvalidnode node collect node
	NodesForDeletion = #()
	if nodes.count > 0 do	undo "Post Delete" on delete nodes
	redrawViews()
)

fn preDeleteWholeClass =
(
	if PostDelete_NodeEventCallback != undefined and not PostDelete_NodeEventCallback.enabled do
		NodesForDeletion = #()

	if not theHold.Redoing() do
	(
		node = callbacks.notificationParam()
		if isvalidnode node do
		(
			join NodesForDeletion (for n in (getclassinstances (classof node) astrackviewpick:on) where isvalidnode n.client and n != n.client collect n.client)
		)
	)
)

fn undo_Callback =
(
	if (callbacks.notificationParam()) == "Post Delete" do with undo off (max undo)
)

fn redo_Callback =
(
	if objects.count != objCount and (callbacks.notificationParam()) == "Create Selection Set" do
	(
		max redo
		objCount = objects.count
	)
)


PostDelete_NodeEventCallback = NodeEventCallback deleted:(with undo on (PostDelete_Callback))
callbacks.addscript #nodePreDelete "preDeleteWholeClass()" id:#delete_same_class
callbacks.addScript #sceneUndo "undo_Callback()" id:#undo
callbacks.addScript #sceneRedo "redo_Callback()" id:#redo


delete objects
with redraw off
(
	for k=0 to 4 do box pos:[k*30,0,0] width:20 length:20 height:20
	for k=0 to 4 do cylinder pos:[k*30,40,0] radius:10
	for k=0 to 4 do sphere pos:[k*30,80,0] radius:10
)