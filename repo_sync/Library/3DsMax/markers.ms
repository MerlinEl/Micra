global mcDistributorMarkers = #()

unregisterRedrawViewsCallback showmarkers

fn showMarkers =
(
	gw.setTransform (Matrix3 1)
	local mouse_pos = [mouse.pos.x, mouse.pos.y, 0]
	
	if selection.count != 0 do
	(
		local center_pos = gw.TransPoint selection[1].pos
		local left_pos = center_pos-[200,0,0]
		local right_pos = center_pos+[200,0,0]
		gw.wMarker center_pos #circle color:red 
		gw.wMarker left_pos #circle color:yellow
		gw.wMarker right_pos #circle color:yellow
		gw.wPolyline #(left_pos, right_pos) on rgb:#(orange,orange)
		mouse_pos.y = center_pos.y
		if mouse_pos.x >= left_pos.x and mouse_pos.x <= right_pos.x 
		then gw.wMarker mouse_pos #bigBox color:green
		else if mouse_pos.x >= left_pos.x then gw.wMarker right_pos #bigBox color:green
		else gw.wMarker left_pos #bigBox color:green
		mcDistributorMarkers = #(center_pos, left_pos, right_pos)
	)
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

registerRedrawViewsCallback showmarkers

--mouse.screenpos - mouse.pos + (gw.wTranspoint $.pos)

/*
fn showMarkers =
(
arr = #("point","hollowBox","plusSign","asterisk","xMarker",
"bigBox","circle","triangle","diamond","smallHollowBox",
"smallCircle","smallTriangle","smallDiamond")
for i=1 to arr.count do (
gw.hMarker [100, (50 + i*10), 50](arr[i] as name) )
gw.enlargeUpdateRect #whole
gw.updateScreen()
)
*/

/*
vp = transPoint (GetVert mesh v)
tp = Transpoint $Teapot002.pos
gw.hMarker (gw.hTranspoint$.pos) #point color:green
 ...

 it might be a little faster than Text...

 other thing is that all gw functions are pretty fast but cause a lot of memory leaking when they called from gw structure. It's better to put them first in local variables:

 ...
 local hTranspoint = gw.hTranspoint
 local hMarker = gw.hMarker

 fn show_PlaneSpeed =
 (
 gw.setTransform (matrix3 1)
 for t = animationrange.start to animationrange.end do at time t 
 (
 for obj in selection do 
 (
 hMarker (hTranspoint obj.pos) #point color:white
 )
 )
 gw.enlargeupdaterect #whole
 gw.updateScreen()
 )
 */