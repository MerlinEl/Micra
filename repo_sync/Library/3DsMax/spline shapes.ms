spp=mcCreate.pointsFromSpline $
--debug
for i=1 to spp.count do for p in spp[i] do point pos:p

for i in spp do print i

--arrow Y
sp1= #
(
	[-0.2,1.42706,0],
	[-0.2,-0.14027,0],
	[-0.950979,-0.14027,0],
	[-0.0812519,-1.42705,-2.16527e-007],
	[0.950979,-0.14027,0],
	[0.2,-0.14027,0],
	[0.2,1.42706,0],
	[-0.2,1.42706,0]
)
--arrow CW
sp2= #
(
	[0.364336,0.9358,0],[0.317504,0.583026,0],[0.699567,0.402785,0],
	[0.841289,0.0730993,0],[0.776447,-0.281485,0],[0.540419,-0.511438,0],
	[0.17719,-0.584585,0],[-0.126295,-0.46535,0],[-0.280116,-0.247122,0],
	[-0.315151,-0.0166116,0],[0.180311,-0.015682,0],[-0.46935,0.749659,0],
	[-1.19129,-0.0303035,0],[-0.674101,-0.0324515,0],[-0.63834,-0.341285,0],
	[-0.461903,-0.679046,0],[-0.140909,-0.903034,0],[0.271381,-0.9358,0],
	[0.714841,-0.827787,0],[1.09664,-0.453396,0],[1.19129,0.104062,0],
	[0.916809,0.667235,0],[0.364336,0.9358,0]
)
--arrow CCW
sp3= #
(
	[-0.364336,0.9358,0],[-0.317504,0.583026,0],[-0.699567,0.402785,0],
	[-0.841289,0.0730993,0],[-0.776447,-0.281485,0],[-0.540419,-0.511438,0],
	[-0.17719,-0.584585,0],[0.126295,-0.46535,0],[0.280116,-0.247122,0],
	[0.315151,-0.0166116,0],[-0.180311,-0.015682,0],[0.46935,0.749659,0],
	[1.19129,-0.0303035,0],[0.674101,-0.0324515,0],[0.63834,-0.341285,0],
	[0.461903,-0.679046,0],[0.140909,-0.903034,0],[-0.271381,-0.9358,0],
	[-0.714841,-0.827787,0],[-1.09664,-0.453396,0],[-1.19129,0.104062,0],
	[-0.916809,0.667235,0],[-0.364336,0.9358,0]
)
--mirror
sp4 = #
(
	#([-0.196439,-1.16108,0], [-0.196439,1.16108,0], [0.203561,1.16108,0], [0.203561,-1.16108,0], [-0.196439,-1.16108,0]),
	#([1.15357,-0.899712,0], [0.207069,-0.0299847,0], [1.15357,1.00225,0], [1.15357,-0.899712,0]),
	#([-1.15357,0.843361,0], [-0.207068,-0.0263665,0], [-1.15357,-1.0586,0], [-1.15357,0.843361,0])
)

spline1 = mcCreate.splinesFromPoints sp2 color:green
spline2 = mcCreate.splinesFromPoints sp3 color:green
$.pivot = ($.min+$.max)/2




--------------------------------------------------------------------------

--------------------------------------------------------------------------
fn createBoxDummy w h l clr:green=
(

	local mi=[-(l/2),-(w/2),0]
	local ma=[l/2,w/2,h]
	
	local line_arrays = #
	(
		#(mi ,[mi.x, mi.y, ma.z], [mi.x, ma.y, ma.z],[mi.x, ma.y, mi .z],mi),
		#(ma ,[ma.x, mi.y, ma.z], [ma.x, mi.y, mi.z],[ma.x, ma.y, mi .z],ma),
		#(mi ,[ma.x, mi.y, mi.z]),
		#([mi.x,ma.y,mi.z] ,[ma.x, ma.y, mi.z]),
		#([mi.x,ma.y,ma.z] ,[ma.x, ma.y, ma.z]),
		#([mi.x,mi.y,ma.z] ,[ma.x, mi.y, ma.z])
	)
	fn splineFromPoints sps num points_array =
	(
		addNewSpline sps
		for p in points_array do (addKnot sps num #corner #line p)
	)
	local sps = SplineShape pos:line_arrays[1][1] 
	for s=1 to line_arrays.count do (splineFromPoints sps s line_arrays[s] )
	
	updateShape sps
	sps.wirecolor = clr
	sps.pivot = (sps.min+sps.max)/2
)
 createBoxDummy 10 10 10


fn drawBoundingBox line_arrays =
(
	gw.setTransform(Matrix3 1)
	gw.setColor #line red
	for li in line_arrays do gw.polyline li false
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

fn drawBBoxesForSelection =
(
	for o in selection where classOf o == SplineShape do 
	(	
		local splines_count = numSplines o
		local line_arrays = for s=1 to splines_count collect
		(
			local verts_count = (numKnots o s)
			for v=1 to verts_count collect (getKnotPoint o s v)
		)
		drawBoundingBox line_arrays
	)
)

unregisterRedrawViewsCallback drawBBoxesForSelection
registerRedrawViewsCallback drawBBoxesForSelection 
completeRedraw()



	/*
	local p = #([-1,-1,0],[1,-1,0],[-1,1,0],[1,1,0],[-1,-1,2],[1,-1,2],[-1,1,2],[1,1,2])
	
	local p1=[-5,-5,0], p2=[5,-5,0], p3=[-5,5,0], p4=[5,5,0], p5=[-5,-5,10], p7=[5,-5,10], p8=[-5,5,10], p9=[5,5,10]
	*/
	
