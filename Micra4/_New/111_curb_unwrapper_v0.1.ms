
-- curb unwrapper(version 0.1, 6th may  2004)
-- MAX script, tested with 3ds MAX 5.1 

-- (c) 2004 Andrei Kletskov (111)
-- homepage: http://andklv.narod.ru 
-- e-mail: andklv@mail.ru 
-- please do not remove any copyrights from this script 

-- Description -- 
-- this script was designed to ease texturing of complex objects like curbs, sidewalks, roads, etc.
-- in fact this script unwraps texture coordinates to a line
-- generally the script is sucsessful, but it fails if geometry is uneven and sometimes it mixes rows of vertices. 
-- unfortunately this script does not count on different poligon sized
-- what you need to do to make this script work:
-- break your curb to parts with equal polygon lenghts
-- select a first row of vertices in an element
-- run script
-- script will unwrap vertices in lines
-- do the same with other elements
-- note: it is very important to start  with first row of vertices - this is a way the script works. sorry. 








rollout ak_curb_unwraper "Curb unwraper" width:162 height:300
(
	button btn1 "Unwrap!" pos:[5,5] width:107 height:30 
	label lbl1 "Width st." pos:[65,40] width:50 height:16
	label lbl2 "Length st." pos:[5,40] width:50 height:16	
	spinner lenStep "" pos:[5,60] width:50 height:16 range:[0,100000,0]
	spinner widStep "" pos:[60,60] width:50 height:16 range:[0,100000,0]
	checkbox vert "Vertical unwrap" pos:[5,80] width:100 height:16
	checkbox elem "Select element" pos:[5,100] width:100 height:16
	
	
	on btn1 pressed  do 
	(
	
		btn1.enabled = false

--- length steps
lengthSTEP = lenStep.value
--- width steps
widthSTEP = widStep.value
--- horizontal or vertical
VERTICAL = vert.state
--- select element
elementSELECT = elem.state

--- initial selection
y = $.modifiers[#unwrap_uvw].unwrap.getSelectedVertices()

--- initial selection aligning
j=0
for i in y do
(
	if VERTICAL then
		$.modifiers[#unwrap_uvw].unwrap.setVertexPosition 0 i [j,0,0]
	else
		$.modifiers[#unwrap_uvw].unwrap.setVertexPosition 0 i [0,j,0]
	j=j+widthSTEP
)

k=0
while true do
(
	k=k+lengthSTEP
	--- expand selection
	$.modifiers[#unwrap_uvw].unwrap.expandSelection() 
	--- select expanded
	h = $.modifiers[#unwrap_uvw].unwrap.getSelectedVertices() 
	--- added vertices during expand
	x=(h-y)
	--print x
	if x.isEmpty then exit
	$.modifiers[#unwrap_uvw].unwrap.selectVertices x	
	j=0
	for i in x do
	(
		--$.modifiers[#unwrap_uvw].unwrap.selectVertices #{i}
		if VERTICAL then
			$.modifiers[#unwrap_uvw].unwrap.setVertexPosition 0 i [j,k,0]
		else
			$.modifiers[#unwrap_uvw].unwrap.setVertexPosition 0 i [k,j,0]
		j=j+widthSTEP
	)
	y=h
)

--- selecting element
if elementSELECT then
	$.modifiers[#unwrap_uvw].unwrap2.selectElement()
else
	$.modifiers[#unwrap_uvw].unwrap.selectVertices #{}


		btn1.enabled = true
	)
)




rollout ak_about "About" width:162 height:300
(
	label lbl3 "(c) 2004" pos:[5,5] width:100 height:20
	label lbl4 "Andrei Kletskov (111)" pos:[5,20] width:110 height:20
	label lbl5 "http://andklv.narod.ru" pos:[5,35] width:110 height:20
	label lbl6 "andklv@mail.ru" pos:[5,50] width:100 height:20
)


rf = newRolloutFloater "CU" 130 172

addRollout ak_curb_unwraper rf  
addRollout ak_about rf 
ak_about.open = 0 
ak_curb_unwraper.widStep.value = 0.1
ak_curb_unwraper.lenStep.value = 0.5