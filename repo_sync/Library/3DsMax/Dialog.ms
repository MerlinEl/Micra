--acces dialog inside a fn 
fn testfn var = 
(
	rollout test "Test"
	(
		local var
		button b1 "b1"
		on b1 pressed do (print var)
	)
	createdialog test 200
	test.var = var
) 
testfn 110 --call to function

-------
offset:[-5,-2]

style:#(#style_toolWindow, #style_sysMenu)
style:#(#style_border)
style:#(#style_toolwindow, #style_sysmenu, #style_resizing, #style_sunkenedge)

setDialogPos <Dialog> [24,40]
getDialogPos <Dialog>

unnDialog.controls --Returns an array of all controls in the rollout.
unnDialog.inDialog --return "true" if dialog visible else "false"
unnDialog.isDisplayed  --return "true" if dialog visible else "false"

unnDialog.ckb_1.visible
unnDialog.ckb_1.visible = true
--oldPos mcDialog
local oldPos = getINISetting (mPath()+"Micra.ini") "CustomMenu" "mcDialogPos"
if oldPos != (GetDialogPos mcDialog as string) then
(setDialogPos mcDialog (execute oldPos))

on <Rollout> open do
--Called when the dialog is opening.
on <Rollout> close do
--Called when the dialog is closing.
on <Rollout> moved <Point2> do
--Called when the dialog is being moved. 
on <Rollout> resized <Point2> do
--Called when the dialog is being resized.
on <Rollout> mousemove <Point2> do
--Called when the mouse is being moved within the dialogs client area.
on <Rollout> lbuttondown <Point2> do
--Called when the left mouse button is pressed down within the dialog.
on <Rollout> lbuttonup <Point2> do
--Called when the left mouse button is released.
on <Rollout> lbuttondblclk <Point2> do
--Called when left mouse button is double clicked within the dialog.
on <Rollout> mbuttondown <Point2> do
--Called when middle mouse button is pressed down within the dialog.
on <Rollout> mbuttonup <Point2> do
--Called when the middle mouse button is released.
on <Rollout> mbuttondblclk <Point2> do
--Called when middle mouse button is double clicked within the dialog.
on <Rollout> rbuttondown <Point2> do
--Called when right mouse button is pressed down within the dialog.
on <Rollout> rbuttonup <Point2> do
--Called when the right mouse button is released.
on <Rollout> rbuttondblclk <Point2> do
--Called when right mouse button is double clicked within the dialog

---------------------------------------------------
rollout testFocus "Test Focus"
(
edittext text1 "Test"
edittext text2 "Focus"
)
createDialog testFocus 200 100
setFocus testFocus.text2 --the second text field gets focus!
---------------------------------------------------
SetDialogBitmap movetestDialog (bitmap 258 76 color:blue)
SetDialogBitmap movetestDialog (bitmap 100 20 color:(color 0 0 0))

button btn_1 "" width:190 height:7 pos:[-2,-1] images:#((bitmap 190 7 color:gray),undefined,1,1,1,1,1) tooltip:"Click to"

createDialog ScriptDialog width:210 style:#(#style_border, #style_titlebar, #style_sysmenu, #style_minimizebox)






	button btn1 "1" width:24 height:24 align:#left offset:[-9,-1] across:9
	button btn2 "2" width:24 height:24 align:#left offset:[-9,-1]  
	button btn3 "3" width:24 height:24 align:#left offset:[-9,-1]
	button btn4 "4" width:24 height:24 align:#left offset:[-9,-1]
	button btn5 "5" width:24 height:24 align:#left offset:[-9,-1]
	button btn6 "6" width:24 height:24 align:#left offset:[-9,-1]
	button btn7 "7" width:24 height:24 align:#left offset:[-9,-1]
	button btn8 "8" width:24 height:24 align:#left offset:[-9,-1]
	button btn9 "9" width:24 height:24 align:#left offset:[-9,-1]
	button btn10 "1" width:24 height:24 align:#left offset:[-9,-5] across:9
	button btn11 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn12 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn13 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn14 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn15 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn16 "2" width:24 height:24 align:#left offset:[-9,-5] 
	button btn17 "2" width:24 height:24 align:#left offset:[-9,-5]
	button btn18 "2" width:24 height:24 align:#left offset:[-9,-5]
	
	
fn sendTextToBox text =
(
	rollout LocalDialog " EBox:" width:234 height:99
	(
		editText edt1 "" pos:[35,14] width:147 height:33
	)
	createdialog LocalDialog
	LocalDialog.edt1.text = text
)
sendTextToBox "Test Text"


fn getTextFromBox =
(
	rollout LocalDialog " EBox:" width:234 height:99
	(
		edittext edt1 "" pos:[40,40] width:147 height:16
		label lbl1 "Put You Text Here:" pos:[44,24] width:144 height:12
		button btn_cncl "Cancel" pos:[44,64] width:56 height:28
		button btn_ok "OK" pos:[132,64] width:56 height:28
		on LocalDialog open do (setFocus edt1)
		on btn_cncl pressed  do (edt1.text = ""; destroyDialog LocalDialog)
		on btn_ok pressed    do (destroyDialog LocalDialog)
	)	
	createdialog LocalDialog style:#(#style_border) modal:true
	return LocalDialog.edt1.text
)
my_string = getTextFromBox()