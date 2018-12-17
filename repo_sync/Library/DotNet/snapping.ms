fn mc2FormSnap formA pos =
(
	if formA == undefined or classOf formA != dotNetObject or not formA.HasChildren or pos == undefined do return false
	local wMax = sysInfo.DesktopSize - 6
	local wMin = [4, 4]
	local dPos = [formA.location.x, formA.location.y] --A form pos
	local dSiz = [formA.width, formA.height] --A form size
	local rW   = mc2Rect mi:wMin ma:wMax --min/max from windows size
	local rA   = mc2Rect (p=copy dPos) ((p+[formA.width,formA.height])+[0,4])--min max from picked dialog
	
	--get bounds rect from picked dialog
	local x = rA.mi.x
	local y = rA.mi.y
	
	--Zadr???
	local newPos = mouse.screenpos - pos
	rA.mi.x = newPos.x
	rA.ma.x = x + dSiz.x
	rA.mi.y = newPos.y
	rA.ma.y = y + dSiz.y + 4
	
	local sDist = rW.ma.x / 200-- set snap distance
	
	--get visible Dialog names
	local allDialogs = getINISetting mc2TempProfileIni "Properties_1" + getINISetting mc2TempProfileIni "Properties_2"
	local visDialogs = for i in allDialogs where (execute (i+" != undefined")) and (execute(i+".HasChildren")) collect i
	
	for i in visDialogs do
	(
		--B dialog name
		local formB = (execute i)
		--B dialog pos 
		local bpos  = [formB.location.x, formB.location.y]
		--min max from B (visible) dialogs
		local rB = mc2Rect bpos ((bpos+[formB.width, formB.height])+[0,4])
		
		--Left
		if rA.mi.x < rB.ma.x+sDist and rA.mi.x > rB.ma.x-sDist and 
		rA.ma.y > rB.mi.y and rA.mi.y < rB.ma.y
		then rA.mi.x = rB.ma.x+6
		--Zadr???
		rA.ma.x = rA.mi.x + dSiz.x
		--Right
		if rA.ma.x > rB.mi.x-sDist and rA.ma.x < rB.mi.x+sDist and 
		rA.ma.y > rB.mi.y and rA.mi.y < rB.ma.y
		then rA.mi.x = (rB.mi.x-dSiz.x)-6
		--Top
		if rA.ma.y > rB.mi.y-sDist and rA.ma.y < rB.mi.y+sDist and 
		rA.ma.x > rB.mi.x and rA.mi.x < rB.ma.x 
		then rA.mi.y = (rB.mi.y-dSiz.y)-6
		--Zadr???
		rA.ma.y = rA.mi.y + dSiz.y
		--Bottom
		if rA.mi.y < rB.ma.y+sDist and rA.mi.y > rB.ma.y-sDist and 
		rA.ma.x > rB.mi.x and rA.mi.x < rB.ma.x 
		then rA.mi.y = rB.ma.y+2
	)

	--if is in Left bound
	if rA.mi.x < rW.mi.x+sDist 
	then x = 0 
	else 
	--if is in Right bound
	if rA.mi.x+dSiz.x > rW.ma.x-sDist 
	then x = (rW.ma.x-dSiz.x) 
	else x = rA.mi.x		
	--if is in Top bound
	if rA.mi.y < rW.mi.y+sDist 
	then y = 0 
	else 
	--if is in Bottom bound
	if rA.mi.y+dSiz.y > rW.ma.y-sDist 
	then y = (rW.ma.y-dSiz.y)
	else y = rA.mi.y
	
	--final move action
	if (dPos.x != x or dPos.y != y) do formA.location = netDrPoint [x, y]
)