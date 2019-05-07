Global mcDivideEdgeDialog
if mcDivideEdgeDialog != undefined do destroyDialog mcDivideEdgeDialog
rollout mcDivideEdgeDialog "Divide Edge" width:240 height:52
(
	GroupBox 'grp1' "Settings:" pos:[4,4] width:232 height:44 align:#left
	spinner 'spn_cnt' "" pos:[96,24] width:64 height:16 range:[2,100,1] type:#integer align:#left
	label 'lbl1' "steps:" pos:[12,24] width:80 height:16 align:#left
	button 'btn_split' "Split" pos:[166,20] width:64 height:24 align:#left
	fn multiDivideEdges = (
		
		local obj = selection[1]
		subobjectlevel = 1 ; max select none ; subobjectlevel = 2
		undo "Divide Edge" on  for i=1 to spn_cnt.value do (
			
			local eSel = polyOp.getEdgeselection obj.baseobject 
			for i in eSel do obj.EditablePoly.divideEdge i 0.5 select:on
		)
		subobjectlevel = 1
	)
	on btn_split pressed do (multiDivideEdges())
)
createDialog mcDivideEdgeDialog
	
/*
if keyboard.shiftPressed then 
*/
	
	
	
	