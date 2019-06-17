--Andrew Romanenkov, COPATHuK@gmail.com, www.dtf.ru
--Life for YALT and night on graveyard!--
--ANdre EmpowErs Love And Killing!!!


macroScript Grid_Slicer
	Category: "Editable Polygon Object"
	ButtonText: "Grid Slicer"
	internalCategory: "Editable Polygon Object"
	toolTip: "Grid Slicer"
(	 
	Xmax
	Xmin
	Ymax
	Ymin
	SPlane
	selFace
	VertsArray
	RayPlus
	SliceValue
	
----round function---- need to fix float bugs
	fn round_to val n:3 = 
(
local mult = 10.0 ^ n
(floor ((val * mult) + 0.5)) / mult
)

--Func creates help dummy grid and invisible dummy with given direction (imho it is easy to calc so)
fn CreateGrid pos:[0,0,0] lsegs:4 =  (
				 SLPlane  = plane name:"SLPlane" length:(4*SliceValue) width:(4*SliceValue) lengthsegs:lsegs widthsegs:4 wirecolor:red
				setTransformLockFlags $SLPlane  #{4,5,7,8,9}
				try (delete $InvisDummy) catch true
				InvisDummy  = box name:"InvisDummy" length:1 width:1  height:10
				setTransformLockFlags $InvisDummy  #{4,6}
				$InvisDummy.dir = [1,0,0]
				$InvisDummy.parent = $SLPlane
				hide $InvisDummy
				)



							---making slice function---
							--------------------------------


	fn SliceGrid A  =
(
					
					If A == 1 then   								--Negative X direction, if slice direction will go from Xmin, Ymax and up
						(
					SPlane  = (ray [Xmax,Ymin,0]  RayPlus)
					SPlane.pos = $SLPlane.pos - ((RayPlus*SliceValue)*(floor (distance $SLPlane.pos [Xmax,Ymin,0]/SliceValue)+1))
						for i=1 to (floor (distance [Xmin,Ymax,0] [Xmax,Ymin,0]/SliceValue)+1) do 
						 	(

						SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
						selFace = polyop.getFaceSelection $ as array
						PolyOp.slice $  selFace SPlane 
							)
						selFace = polyop.getFaceSelection $ as array
						) 
----------
						If A == 2 then   							--Positive X direction...from Xmin, Ymin, and up
						(
						SPlane  = (ray [Xmin,Ymin,0]  RayPlus)
						SPlane.pos = $SLPlane.pos - ((RayPlus*SliceValue)*(floor (distance $SLPlane.pos [Xmin,Ymin,0]/SliceValue)+1))
						
						for i=1 to (floor (distance [Xmin,Ymin,0] [Xmax,Ymax,0]/SliceValue)+1) do 
						 	(
						SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
						selFace = polyop.getFaceSelection $ as array
						PolyOp.slice $  selFace SPlane 
							)
						selFace = polyop.getFaceSelection $ as array
						) 
---------------
						If A == 3 then 							 -- X ==0
						(
					SPlane  = (ray [Xmin,Ymin,0]  RayPlus)
					SPlane.pos  = [$SLPlane.pos[1] - ((floor ((distance [Xmin,0,0]  [$SLPlane.pos[1],0,0])/SliceValue)+1)*SliceValue),$SLPlane.pos[2] - ((floor ((distance [0,Ymin,0]  [0,$SLPlane.pos[2],0])/SliceValue)+1)*SliceValue),0]

						while SPlane.pos[2]<Ymax do 
						 	(
						SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
						selFace = polyop.getFaceSelection $ as array
						PolyOp.slice $  selFace SPlane 
							)

						) 
-----------------
						If A == 4 then   							-- Y ==0  
						(
					SPlane  = (ray [Xmin,YMin,0]  RayPlus)
					SPlane.pos  = [$SLPlane.pos[1] - ((floor ((distance [Xmin,0,0]  [$SLPlane.pos[1],0,0])/SliceValue)+1)*SliceValue),$SLPlane.pos[2] - ((floor ((distance [0,Ymin,0]  [0,$SLPlane.pos[2],0])/SliceValue)+1)*SliceValue),0]
					
						while SPlane.pos[1]<Xmax do 
						 	(
						SPlane.pos=SPlane.pos+(SPlane.dir*SliceValue)
						selFace = polyop.getFaceSelection $ as array
						PolyOp.slice $  selFace SPlane 
							)

						) 

)

	
	

	
---------Making Rollout


	rollout Troll "Grid Slicer" width:158 height:162
(
		
		button but1 "Create Slice Plane Helper" pos:[1,1] width:155 height:21
		button but2 "Slice!" pos:[49,89] width:105 height:32
		radiobuttons rdo1 "Choose Slice Type" pos:[5,75] width:43 height:46 labels:#("Line", "Grid") default:1 columns:1
		spinner s1 "Slice Distance" pos:[11,28] width:141 height:16 range:[0,100,1] type:#float
		slider sld1 "" pos:[0,43] width:170 height:25 range:[0,100,1] type:#integer orient:#horizontal ticks:25
		checkbox chk1 "Delete dummy on close" pos:[5,121] width:147 height:17 checked:true
		checkbox chk2 "Save undo" pos:[5,141] width:76 height:15
		button btn3 "Undo" pos:[80,137] width:73 height:21
						
						
						
						
		
	
							
						
						
						
on Troll open do
		(
		names = for i in objects collect i.name
		try (delete $InvisDummy) catch true
		if findItem names "SLPlane" != 0 then
		(
		Planetrans = $SLPlane.transform
		CreateGrid lsegs:1
		$SLPlane.transform = Planetrans
		)
		
		)

on Troll close do
		(		
				if chk1.checked == true then
				try (
				delete $SLPlane
				delete $InvisDummy
				) catch true
		)
		
on but1 pressed do
		(	
			try (delete $InvisDummy) catch true
			SliceValue = s1.value
			names = for i in objects collect i.name
			if findItem names "SLPlane" == 0 then
			(
				if rdo1.state ==1 then CreateGrid lsegs:1 
				if rdo1.state ==2 then CreateGrid lsegs:4
			)
			 else 
			 (	 select $SLPlane
			 max zoomext sel all
			 messagebox "Already Exists!"
			 )
		 )
		on but2 pressed do
		(	
		fn PrepSlice = (		
							ResetXForm $
							collapsestack $
							if chk2.checked == true then holdMaxFile()                                          --- hold if needed
							
							SliceValue = s1.value
								------computing min/max points
							VertsArray = polyOp.getVertsUsingFace $ (polyOp.getFaceSelection $) as array
							Xmax = (PolyOp.getvert $ VertsArray[1] )[1]
							Xmin = (PolyOp.getvert $ VertsArray[1] )[1]
							Ymin = (PolyOp.getvert $ VertsArray[1] )[2]
							Ymax = (PolyOp.getvert $ VertsArray[1] )[2]
							for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[1] > Xmax  then Xmax = (PolyOp.getvert $ VertsArray[v])[1] )
							for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[2] > Ymax  then Ymax = (PolyOp.getvert $ VertsArray[v])[2] )
							for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[1] < Xmin  then Xmin = (PolyOp.getvert $ VertsArray[v])[1] )
							for v=1 to VertsArray.count do (  if (PolyOp.getvert $ VertsArray[v])[2] < Ymin  then Ymin = (PolyOp.getvert $ VertsArray[v])[2] )
		
							
						---------computing positive Y only ray--------------
						-------------------------------------------------------------------
						
						names = for i in objects collect i.name
						if findItem names "InvisDummy" == 0 then CreateGrid lsegs:4
		
		
					   	RayPlus=$InvisDummy.dir
						RayPlus = [round_to RayPlus[1], round_to RayPlus[2],0]
						if (RayPlus[1]<=0 and RayPlus[2]<=0) then
							( 
							--messagebox "3!"
							RayPlus = [abs RayPlus[1], abs RayPlus[2],0]
							)
							else
							If (RayPlus[1]>0; RayPlus[2]<0) then
							(
							--messagebox "4!"
							RayPlus = [-RayPlus[1], -RayPlus[2],0]
							)
						RayPlus = [round_to RayPlus[1], round_to RayPlus[2],0]
						
						--print RayPlus
					
		
		
		if  rdo1.state ==1 then (
						case  of (
						(RayPlus[1] == 0) : SliceGrid 3
						(RayPlus[2] == 0) : SliceGrid 4
						(RayPlus[1]<0 and RayPlus[2] !=0) : SliceGrid 1
						(RayPlus[1]>0 and RayPlus[2] !=0) : SliceGrid 2
											)
						)
						
						
		if  rdo1.state ==2 then (
						
		
						case  of (
						(RayPlus[1] == 0) : SliceGrid 3
						(RayPlus[2] == 0) : SliceGrid 4
						(RayPlus[1]<0 and RayPlus[2] !=0) :SliceGrid 1
						(RayPlus[1]>0 and RayPlus[2] !=0) : SliceGrid 2
											)
		
		--rotating vector
			If RayPlus[1]>0 then
			RayPlus = [-RayPlus[2], RayPlus[1],0]
			else
			RayPlus  = [RayPlus[2],-RayPlus[1],0]
							
						case  of (
						(RayPlus[1] == 0) : SliceGrid 3
						(RayPlus[2] == 0) : SliceGrid 4
						(RayPlus[1]<0 and RayPlus[2] !=0) : SliceGrid 1
						(RayPlus[1]>0 and RayPlus[2] !=0) : SliceGrid 2
											)
							)
		
		
		
		
		redrawViews()
		)
		
		
		
							-----------------Checking selection-----------------
			if (selection.count != 0 and (classof $ ==Editable_Poly or classof $ == Editable_mesh))
							then
								(
								if classof $ == Editable_Poly then
																				( 
															if subobjectlevel == 4 then
																				 (
															if (PolyOp.getfaceselection $ as array).count != 0 then PrepSlice() else messagebox "No faces selected!"
																				) else messagebox "No faces selected!"
																				)
															
								if classof $ == Editable_Mesh then
															if subobjectlevel == 4 then
															( if (getfaceselection $ as array).count !=0 then
																(
															convertTo $ PolyMeshObject
															subobjectlevel = 4
															if (PolyOp.getfaceselection $ as array).count != 0 then PrepSlice()  else messagebox "No faces selected!"
															convertTo $ TriMeshGeometry
															subobjectlevel = 4
															)  else messagebox "No faces selected!"
															)  else messagebox "No faces selected!"
								)
		
								else messagebox "Select Mesh or Poly!"					
							
								
								
		)
		
		on rdo1 changed state do
		( 
		names = for i in objects collect i.name
		if rdo1.state ==1 then
			if findItem names "SLPlane" != 0 then $SLPlane.lengthsegs = 1
		
		if rdo1.state ==2 then 
			if findItem names "SLPlane" !=0 then $SLPlane.lengthsegs = 4
		)
		on s1 changed value do
		(
		names = for i in objects collect i.name
		if findItem names "SLPlane" != 0 then
				(	$SLPlane.length = 4*s1.value
					$SLPlane.width = 4*s1.value
				)
		)
		on sld1 changed value do
		( 
		s1.value =sld1.value
		names = for i in objects collect i.name
		if findItem names "SLPlane" != 0 then
			(	$SLPlane.length = 4*s1.value
				$SLPlane.width = 4*s1.value
			)
		
		)
		on btn3 pressed do
			fetchMaxFile quiet:true
	)
createdialog Troll
)
