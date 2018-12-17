Global mc2LocalTime

fn mycb = 
(
	local ts = timeStamp() -- get current time
	local text_pos=[50,50,0]
	local view_text = ( (ts / 1000.0) as string + " sec")
	local update_rect = box2 (text_pos.x) (text_pos.y-(gw.getTextExtent view_text).y) 0 0  --<upperleft_point2> <lowerRight_point2>
	--
	local rect = gw.getTextExtent view_text
	update_rect.w = rect.x+1
	update_rect.h = rect.y+1
	-- draw the time in the viewport
	gw.wText text_pos view_text
	gw.enlargeUpdateRect update_rect --#whole
	gw.updateScreen()
	gw.resetUpdateRect()
	gw.clearscreen update_rect useBkg:true
	if keyboard.escPressed and keyboard.shiftPressed do 
	(
		mc2LocalTime.stop()
		completeRedraw()
	)
)
-- create dotNet elements
mc2LocalTime = dotNetObject "System.Windows.Forms.Timer"
mc2LocalTime.interval = 1 -- == every 1 ms   1000 == every 1 sec
dotnet.addEventHandler mc2LocalTime "tick" mycb
mc2LocalTime.start()

-- stop the timer
/*
mc2LocalTime.stop()
completeRedraw()
*/



(
	local t = dotNetObject "Timer"
	local tick = 0
	t.interval = 1000
	
	fn closeDialogFBXImporter = --closeDialog "FBX Import"
	(
		print tick
		tick += 1
		if tick > 3 do
		(
			local ace = UIAccessor.GetPopupDialogs()
			for i in ace where findString (UIAccessor.GetWindowText i) "FBX Import" != undefined do 
			(
				--UIAccessor.CloseDialog i
				UIAccessor.PressButtonByName i "Cancel"
				exit
			)
			t.stop()
			print "0"
		)
	)
	print "1"
	dotnet.addEventHandler t "tick" closeDialogFBXImporter
	t.start()
)