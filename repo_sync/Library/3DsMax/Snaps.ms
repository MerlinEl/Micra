--get state of vertex
snapmode.getOSnapItemName 5 1

--svitch vertex snap on/off
snapmode.setOSnapItemActive 5 1 (not (snapmode.getOSnapItemActive 5 1))

--svitch all snaps to off
for i = 1 to snapmode.numOSnaps do 
	for j = 1 to (snapmode.getOSnapNumItems i) 
		do if (snapmode.getOSnapItemActive i j)==on then
			snapmode.setOSnapItemActive i j (not (snapmode.getOSnapItemActive i j))

--svitch all snaps to on
for i = 1 to snapmode.numOSnaps do 
	for j = 1 to (snapmode.getOSnapNumItems i) 
		do if (snapmode.getOSnapItemActive i j)==off then
			snapmode.setOSnapItemActive i j (not (snapmode.getOSnapItemActive i j))

--collect state to array			
x=#()
for i = 1 to snapmode.numOSnaps do for j = 1 to (snapmode.getOSnapNumItems i) do if (snapmode.getOSnapItemActive i j) then x+=#(1) else x+=#(2)

--print name and state
for i = 1 to snapmode.numOSnaps do for j = 1 to (snapmode.getOSnapNumItems i) do 
format "%=%\n" (snapmode.getOSnapItemName i j) (snapmode.getOSnapItemActive i j)

		gco = modpanel.getcurrentobject()
		gco.vertexSnap = on --Enable/Disable the Vertex Snap
		gco.edgeSnap = on -- Enable/Disable the Edge Snap
		gco.gridSnap = on -- Enable/Disable the Grid Snap

/*
--Store snap property
UserSnap = snapMode.Active
UserVertSnap =  (snapmode.getOSnapItemActive 5 1)

--Set snap property
snapMode.Active = on
snapmode.setOSnapItemActive 5 1 on

--Restore snap property
if UserVertSnap then (snapmode.setOSnapItemActive 5 1 on)
else (snapmode.setOSnapItemActive 5 1 off)
if UserSnap then (snapMode.Active = true)
else  (snapMode.Active = off)
*/
