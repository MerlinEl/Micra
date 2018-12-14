--bezpecnostni pauza
if unnamedRollout != undefined do destroyDialog unnamedRollout
rollout unnamedRollout "Untitled" width:80 height:54
(
	local ticks = 60*60 -- 1h
	groupBox grp1 "Doctor:" pos:[4,4] width:72 height:44
	label lbl1 "00:00:00" pos:[16,24] width:44 height:16
	timer tmr1 "Timer" pos:[8,12] width:24 height:24 interval:1000 active:false --interval 1sec
	button btn_close "x" pos:[64,4] width:12 height:12

	fn translateTicksToTime t =
	(
		local sec = t
		local min = sec/60
		local hod= min/60
		
		sec = (mod sec 60) as integer
		min = (mod min 60) as integer
		hod = (mod hod 60) as integer
		
		return (hod as string)+":"+(min as string) +":"+(sec as string)
	)
	fn resetTimer =
	(
		ticks = 60*60
		lbl1.text = translateTicksToTime ticks
		tmr1.active = true
	)
	fn stopTimer = (tmr1.active = not tmr1.active)
	on tmr1 tick do
	(
		ticks -=1
		lbl1.text = translateTicksToTime ticks
		if ticks <= 0 do 
		(
			tmr1.active = false 
			if not queryBox "It is time to take a break my friend :-)" title:"Doctor:" do 
			--wait ten min and show up again
			(
				ticks = 60*10 --10min
				tmr1.active = true
			)
		)
	)
	on btn_close pressed  do (destroyDialog unnamedRollout)
	--on unnamedRollout open do tmr1.active = true
	on unnamedRollout lbuttonup pos do (stopTimer())
	on unnamedRollout rbuttonup pos do (resetTimer())
)
createDialog unnamedRollout style:#(#style_sysmenu) pos:[(getMAXWindowSize()).x-96,22]