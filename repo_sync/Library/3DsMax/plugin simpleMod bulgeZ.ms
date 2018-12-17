plugin simpleMod bulgeZ
name:"BulgeZ"
classID:#(0xa4741be, 0x953eaf3)
version:1
(
parameters main rollout:params
(
	amplitude type:#float ui:spn_amplitude default:1
	wavecount type:#float ui:spn_wavecount default:1
	phase type:#float ui:spn_phase default:0
	limit type:#boolean ui:chk_limit default:false
	maxLimit type:#float ui:spn_maxLimit default:100
	minLimit type:#float ui:spn_minLimit default:0
)
rollout params "BulgeZ Parameters"
(
	spinner spn_amplitude "Amplitude: " type:#float range:[0,1000,1]
	spinner spn_wavecount "Wave Count: " type:#float range:[0,1000,1]
	spinner spn_phase "Phase:" type:#float range:[-100000,100000,0] scale:0.01
	group "Limits"
	(
		checkbox chk_limit "Limit Effect" align:#right offset:[8,-5]
		spinner spn_maxLimit "Upper Limit %:" range:[-1000,1000,100] 
		spinner spn_minLimit "Lower Limit %:" range:[-1000,1000,0] 
	)
)
on map i p do
(
	local v = normalize [p.x-center.x, p.y-center.y,0]
	local pzn = p.z/(max.z-min.z)
	if not limit or (pzn >= minLimit*0.01 and pzn <= maxLimit*0.01) do
		p +=  v*amplitude*(cos (360*(pzn-phase)*wavecount))
	p
)
on modLimitZMin do if limit then minLimit*0.01*(max.z-min.z) else 0.0
on modLimitZMax do if limit then maxLimit*0.01*(max.z-min.z) else 0.0
on modLimitAxis do #z
)