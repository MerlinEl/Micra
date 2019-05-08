-- Tape Annotate v1.01
-- Author: Paul Bertino
-- 07/24/09
--
-- Description:
-- Displays tape-length and name information in the viewport.
--
-- notes:
-- Effects all tapes currently visible.  Displays the user defined tape length at the base of the tape
-- and the distance to the target at the target.
-- I work in inches, so displaying "in." is hard-coded.  Change that part of the code, or remove it to make it go away.
-- Run the script again to turn it off.
-- ideas/requests/problems?  email: bertino@gmail.com 
--
-- fixed in version 1.1
-- -toggle on and off fixed. 

macroScript TapeAnnotate category:"My Tools" --edit the category as you see fit
(
global TapeAnnotateEnabled = false
	unRegisterRedrawViewsCallback showObjectNames

	fn showObjectNames=
	(	
	gw.setTransform(Matrix3 1)
	for o in Helpers where not o.isHidden and classof o == tape and o != Target do
		(
	dist = o.targetDistance
	gw.text (o.Pos+[0, 0,0]) ("("+o.name+")"+(" Length: "+o.length as string+" in.")) color:yellow
	gw.text (o.target.pos+[0,0,0]) ("("+o.name+")"+(distance o o.target as string+" in.")) color:yellow
		)	--end o loop
gw.enlargeUpdateRect #whole
gw.updateScreen()
	) -- end function
on isChecked return TapeAnnotateEnabled 

on execute do
(
	TapeAnnotateEnabled  = not TapeAnnotateEnabled 
    if TapeAnnotateEnabled then
(
unRegisterRedrawViewsCallback showObjectNames
RegisterRedrawViewsCallback showObjectNames
showObjectNames()
)
else
(
	unRegisterRedrawViewsCallback showObjectNames 	
	max views redraw
)
)
)