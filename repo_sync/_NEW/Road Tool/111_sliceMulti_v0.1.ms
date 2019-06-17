-- type: maxscript 
-- name: sliceMulti
-- author: Andrei Kletskov (111) - http://andklv.narod.ru
-- description: this script makes multiple slices in editable poly, it is handy if you need to cut 
--					a lot of parallel lines. Just set the Slice Plane as needed, set the distance 
-- 					and push one of the buttons. Small checkbox in upper right makes the first cut
--					in the position, where you have the plane initially. You can set your own number 
--					of cuts in addition to preset 1 10 and 20. And also a button to reset the plane.
-- history:
-- v0.1 - 15 april 2011 - initial version




d = 50 -- distance
s = 100 -- size
nr = ray [0,0,0] [0,0,0] -- ray


rollout sm "111_SM v.01"
(
	fn sm a = --- one cut fn
	(
		r = polyop.getSlicePlane $ size:&s
		nr.dir = r.dir
		nr.pos = r.pos + r.dir*d
		if a == false then
		(
			polyop.slice $ $.selectedFaces r
		)
		else
		(
		polyop.slice $ $.selectedFaces nr
		polyop.setSlicePlane $ nr s 
		)
		update $
	)
	
	checkbox ch1 "" checked:true pos:[135,1]
	
	fn smn n =  ----- n cut fn
	(
		undo on
		(
			try
			(
				for i = 1 to n do
				(
					if ch1.state == true then sm false
					ch1.state = false
					sm true
				)
			)
			catch
			(
				messagebox "error!"
			)
		)
	)
	

	label l1 "set the Slice Plane first" pos:[2,1]
	label l0 "sf" pos:[125,1]

	label l2 "distance:" pos:[2,16] width:50
	spinner s2 "" type:#float range:[0,10000,50] pos:[45,16] width:50
	button b1 "1" pos:[2,34] width:20
	button b2 "10" pos:[23,34] width:20
	button b3 "20" pos:[43,34] width:20
	button b4 "n" pos:[63,34] width:20
	spinner s1 "n:" type:#integer range:[1,1000,50] pos:[90,38] width:58

	button b5 "reset SP" pos:[98,16] height:16 width:50
	
	on s2 changed a do (d = a)
	
	on b1 pressed do smn 1
	on b2 pressed do smn 10
	on b3 pressed do smn 20
	on b4 pressed do smn s1.value
	on b5 pressed do 
	(
		polyop.resetSlicePlane $
		--update $
	)



)
CreateDialog sm 150 57
