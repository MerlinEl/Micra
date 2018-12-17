fn DrawCross pos dir =
(
	--gw.resetUpdateRect()
	completeredraw()
	--gw.clearScreen (Box2 800 600 20 30 ) useBkg:false
	local GridTm = matrixFromNormal dir
	GridTm.row4 = pos
	gw.setTransform GridTm
	gw.setColor #line white
	
	--Line X
	gw.Polyline #([-10,0,0],[10,0,0]) false
	--Line Y
	gw.Polyline #([0,-10,0],[0,10,0]) false
	
	--gw.setTransform(Matrix3 1)
	gw.Text [1,0,0] "this is not working in my max v9"  color:green
	
	gw.enlargeUpdateRect #whole
	gw.updateScreen()
)

fn Find3DPoint msg ir obj faceNum shift ctrl alt =
(	
	local points = 0
	case msg of
	(
		#mouseMove:()
		--tracking mesh surface and drawing cross
		#freeMove: 
		(
			if ir != undefined do 
			(
				DrawCross ir.pos ir.dir
				--format "ir pos:%\tir dir:%\n" ir.pos ir.dir
			)
		)
		--geting pick point and most closest vertex around
		#mousePoint:
		(
			if ir != undefined do
			(
				format "picked face:%\n" faceNum
				format "intersect ray:%\n" ir
				format "position::%\n" ir.pos
				format "direction::%\n" ir.dir
points += 1

				local form = dotnetObject "form"
				local tlp  = dotNetObject "TableLayoutPanel"
				local btn = dotNetObject "Label"--"Button"
				local lbl = dotNetObject "Label" 
				--Form
				form.StartPosition = form.StartPosition.Manual
				form.bounds = netDrRect (mouse.screenpos) [20,22]
				form.FormBorderStyle = form.FormBorderStyle.none
				form.BackColor = netDrColor yellow
				form.ShowInTaskbar = false
				form.Name = "Form1"
				--Btn
				btn.size = netDrSize [24,24]
				btn.TextAlign = btn.TextAlign.MiddleCenter
				btn.margin  =  dotnetobject "padding" 2 
				btn.BackColor = netDrColor green
		 		btn.ForeColor = netDrColor white
				btn.text ="X"
				--Lbl
				lbl.size = netDrSize [40,24]
				lbl.BackColor = netDrColor green
		 		lbl.ForeColor = netDrColor white
				lbl.TextAlign = lbl.TextAlign.MiddleCenter
				lbl.margin  =  dotnetobject "padding" 2 
				lbl.text = "Point: " + points as string
				--Table
				tlp.bounds = netDrRect [2,2] [74,28] 
				tlp.BackColor = netDrColor blue
				tlp.ColumnCount = 2
				
				fn onBtnMouseClick s a =(s.parent.parent.close())
				dotNet.addEventHandler btn "MouseClick" onBtnMouseClick
				
				--Add Controls
				tlp.controls.addRange( #(lbl, btn) )
				form.controls.add( tlp )
				
				
				
				form.show(WindowWrapper)
				
			)
		)
		#mouseAbort:		
		(
			return #stop
		)
	)
	#continue
)

--Run Script--
(
	local obj = (selection as array)[1]
	if superClassOf obj != GeometryClass do return false
	local IntersectOjb = snapshot obj
	hide IntersectOjb
	mouseTrack on:IntersectOjb snap:#3D trackCallback:Find3DPoint
	if isValidNode IntersectOjb  do delete IntersectOjb
	
	--mouseTrack on:$ prompt:"Chose 3 points to create new grid... " snap:#3D trackCallback:Find3DPoint
)