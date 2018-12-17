rollout aa "Untitled" width:162 height:300
(
	ImgTag oAbout_2 "" pos:[0,8] width:162 height:116
	on aa moved pos do
		()

	on oAbout_2 mouseover do (print "mouse up")
	on oAbout_2 mousedown do (print "mouse down")
	
	--on aa mousemove x do (print "mouse move")  --ok
	
	on aa lbuttondown x do (print "mouse left down")
	on aa rbuttondown x do (print "mouse right down")
	on aa lbuttondblclk x do (print "left double")
	on aa rbuttondblclk x do (print "right double")
	
	on aa moved pos do (print "moved")
	on aa close  do (print "closed")

)
createdialog aa


--pick 2 points with 3d and rubberband
		(
		sp1 = pickpoint prompt:"\nSelect first point:"
		sp2 = pickpoint prompt:"\nSelect second point:" rubberband:sp1
		print (distance sp1 sp2)
		)
---------------------------------------------
-----------------------------------------------

 try(destroyDialog TestRoll)catch()
 
 Rollout TestRoll "test"
 (
 	local size = 200
 	Label lblX
 	Label lblY
 	Label lblK
 	Label lblCross "+" pos: [(size/2)-3,(size/2)-7]
 	
 	Local followMouse = false
 	fn moveCross pos =
 	(
 		p = [pos.x-3,pos.y-7]
 		lblCross.pos = p
 	)
 	fn reportXY pos =
 	(
 		lblX.text = pos.x as string
 		lblY.text = pos.Y as string
 		lblk.text = if keyboard.controlPressed then "ctrl" else ""
 		moveCross pos 
 	)
 	on TestRoll lbuttondown pos do
 	(
 		followMouse = true
 		setSysCur #select
 		reportXY pos
 	)
 	on TestRoll lbuttonup pos do followMouse = false
 	on testRoll mousemove pos do 
 	(
 		if followMouse do reportXY pos
 	)
 	on TestRoll Rbuttondown pos do
 	(
 		followMouse = false
 		
 	)
 )
 
 createDialog TestRoll 200 200
