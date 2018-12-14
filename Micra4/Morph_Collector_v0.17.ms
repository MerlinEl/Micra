--------------------------------------------------------------------------
					/*MORPH COLLECTOR*/
						/*2012*/
--------------------------------------------------------------------------
Global MorphCollector

plugin modifier MorphCollector
name:"Morph Collector"
classID:#(0x6b0f2189, 0x17b2df79)
(
	parameters param_main rollout:main
	(
		--baseobj_name type:#stringTab tabSize:0 tabSizeVariable:true
		ring_names type:#stringTab tabSize:0 tabSizeVariable:true
		ring_positions type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_rotations type:#point3Tab tabSize:0 tabSizeVariable:true
		ring_radius type:#indexTab tabSize:0 tabSizeVariable:true
	)
	rollout main "Ring Collection:"
	(
		listBox ring_list "" pos:[7,8] width:147 height:8  items:(ring_names as array)
	)
)


