--explode the objects into elements by smoothing groups

fn getSGarray obj = 
(
	local SGarray=for i=1 to 32 collect #()
	local theFaces=#{1..obj.numfaces}
	for f in theFaces do 
	(
		local SGnumber = getFaceSmoothGroup obj f
		local SGbitarray=#{}
		if SGnumber < 0 do 
		(
			SGbitarray[32]=true
			SGnumber -= 2^31
		)
		for i = 1 to 31 do 
		(
			SGbitarray[i] = (mod SGnumber 2 > .5)
			SGnumber /= 2
		)
		for sg in SGbitarray do append SGarray[sg] f
	)
	SGarray
)
	
obj = selection[1]
SGarray=getSGarray obj
	
for i=1 to 32 do 
(
	if SGarray[i].count!=0 do format "smoothing group % includes faces % \n" i SGarray[i]
)




--ClearSmoothingGroups
sel = selection[1]
max modify mode
subObjectLevel = 4
max select all
sel.buttonOp #ClearSmoothingGroups
--Autosmooth
sel = selection[1]
max modify mode
subObjectLevel = 4
max select all
sel.buttonOp #Autosmooth 
--SelectBySmoothingGroups
sel = selection[1]
max modify mode
subObjectLevel = 4
max select all
sel.buttonOp #SelectBySmoothingGroups 



fn setfacesmoothgroupB obj face sg_bitarray = 
( 
	local sgroup_val=0 
	for i in sg_bitarray do sgroup_val += 2^(i-1) 
	setfacesmoothgroup obj face sgroup_val 
	update obj 
)

fn getfacesmoothgroupB obj face = 
( 
	local sgroup_val=getfacesmoothgroup obj face 
	local sg_bitarray=#{} 
	if sgroup_val < 0 do 
	( 
		sg_bitarray[32]=true 
		sgroup_val -= 2^31 
	) 
	for i = 1 to 31 do 
	( 
		sg_bitarray[i]= (mod sgroup_val 2 > .5) 
		sgroup_val /= 2 
	) 
	sg_bitarray 
)
