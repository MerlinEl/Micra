try (destroyDialog ::rol_MyPanel) catch()
 
rollout rol_MyPanel "My Panel"
(
    group "Random City Generator:"
    (
        button btn1 "Create Roads" width:120 height:18
		button addIntersection "Add Intersections at ends of the roads" width:200 height:18
		button capRoads "Add ends of the road" width:200 height:18
		spinner numRoads "Number of road curves:" range:[1,1000,20] 
		spinner roadCopies "Number of roads to make:" range:[1,1000,1] 
		spinner lengthRoad "Road length multiplier:" range:[750,50000,1000] 
		spinner numBldgs "Number of buildings per road:" range:[1,1000,100] 
    )
	
	fn drawRandomRoad curves =
	(
	ss = SplineShape pos:[0,0,0]
	ss.name = "roadSpline"
	addNewSpline ss
	addKnot ss 1 #corner #line [0,0,0]
	addKnot ss 1 #corner #line [100,0,0]
	i = 0
		while i < curves do
		(
			randx = random 200 1000
			randy = random -1000 1000
			addKnot ss 1 #corner #line [(randx+(lengthRoad.value*i)),randy,0]
			i = i + 1
		)

	updateShape ss
	ss
	)
	
	fn createCars i roadAsSpline =
	(
		clearSelection()
		car = Box name:"car" lengthsegs:1 widthsegs:1 heightsegs:1 length:40 width:100 height:60 mapcoords:on realWorldMapSize:on pos:[19432.5,2412.78,0] isSelected:on
		$car.pos.controller = Path_Constraint follow:on constantVel:on axis:0 path:roadAsSpline			
		car.name = ("car" + i as string)
		car.wirecolor = color 28 28 255
		
		clearSelection()
		carb = Box name:"carb" lengthsegs:1 widthsegs:1 heightsegs:1 length:40 width:100 height:60 mapcoords:on realWorldMapSize:on pos:[19432.5,2412.78,0] isSelected:on
		$carb.pos.controller = Path_Constraint follow:on constantVel:off axis:0 path:roadAsSpline			
		carb.name = ("carb" + i as string)
		carb.wirecolor = color 255 255 255
		
		/*
		carc = Box name:"carc" lengthsegs:1 widthsegs:1 heightsegs:1 length:40 width:100 height:60 mapcoords:on realWorldMapSize:on pos:[19432.5,2412.78,0] isSelected:on
		$carc.pos.controller = Path_Constraint follow:on constantVel:off axis:0 path:roadAsSpline			
		set animate on
		sliderTime = 0f
		$carccarc.pos.controller.Path_Constraint.controller.PERCENT = 50
		sliderTime = 0f
		$carc.pos.controller.Path_Constraint.controller.PERCENT = 100
		--carc.name = ("carc" + i as string)
		--set animate off
		*/

		)
		
     
    fn makebldg heightmod =
    (
		try (select $roadSection) catch()

		building = Box lengthsegs:1 widthsegs:1 heightsegs:1 length:178.968 width:165.15 height:195.379 pos:[0,0,0] isSelected:on
		
		copies = numBldgs.value

		i = 0
		while i < copies do
		(
			-- get percentage on spline
			perc = (i as float / (copies-1))

			-- get position on spline
			pnt = interpCurve3D $roadSpline 1 perc

			-- instance the object and position it on the spline
			b = instance building
			b.position = pnt
			coin = random 1 2
			b.wirecolor = color (random 100 150) (random 50 100) (random 80 100)
			if coin == 1 then
			(
				move b [0,-250,0]
			)
			else
			(
				move b [0,250,0]
			)
			i = i + 1
			if perc < 0.5 then
			(
				scale b [1,1,1 + ((perc as float)^2)*heightmod ]
			)
			else
			(
				reverseperc = 1-perc
				scale b [1,1,1 + ((reverseperc as float)^2)*heightmod ]
			)
		)	
    )
     
    on btn1 pressed do
    (
		--get the curve info from the UI
		sectionCount = numRoads.value
		
		--try to delete old road if there is one.
		try (delete $roadSection*) catch()
		
		i = 0
		lastRoadWasRotated = True
		while i < roadCopies.value do
		(
			--Listener Code to make a road cross section.
			Box name:"roadSection" lengthsegs:5 widthsegs:1 heightsegs:1 length:300 width:20.8569 height:10 mapcoords:on realWorldMapSize:on pos:[12.6496,-0.079895,0] isSelected:on
			modPanel.addModToSelection (Edit_Poly ()) ui:on
			subobjectLevel = 1
			modPanel.setCurrentObject $.modifiers[#Edit_Poly]
			$roadSection.wirecolor = color 50 50 50
			$roadSection.modifiers[#Edit_Poly].SetSelection #Vertex #{}
			$roadSection.modifiers[#Edit_Poly].Select #Vertex #{5..8, 17..20}
			actionMan.executeAction 0 "50002"  -- Tools: Select and Rotate
			macros.run "Tools" "SmartScale"
			$roadSection.modifiers[#Edit_Poly].SetOperation #Transform
			$roadSection.modifiers[#Edit_Poly].ScaleSelection  [1,2.58858,1] parent:(transMatrix [12.6496,-0.0799,0.0000]) axis:(transMatrix [12.6496,-0.0799,5.0000])
			$roadSection.modifiers[#Edit_Poly].Commit ()
			$roadSection.modifiers[#Edit_Poly].SetSelection #Vertex #{}
			$roadSection.modifiers[#Edit_Poly].Select #Vertex #{17..18}
			$roadSection.modifiers[#Edit_Poly].Select #Vertex #{19..20} invert:on
			actionMan.executeAction 0 "50001"  -- Tools: Select and Move
			$roadSection.modifiers[#Edit_Poly].SetOperation #Transform
			$roadSection.modifiers[#Edit_Poly].MoveSelection  [0,0,-6.14645] parent:(transMatrix [12.6496,-0.0799,0.0000]) axis:(transMatrix [12.6496,-0.0799,10.0000])
			$roadSection.modifiers[#Edit_Poly].Commit ()
			clearSelection()
			
			--create random spline tree and extrude the road cross section along it  using the function above
			drawRandomRoad sectionCount
			
			select $roadSection
			subobjectLevel = 4
			$roadSection.modifiers[#Edit_Poly].Select #Face #{12..16}
			$roadSection.modifiers[#Edit_Poly].SetOperation #ExtrudeAlongSpline
			$roadSection.modifiers[#Edit_Poly].extrudeAlongSplineNode = $roadSpline
			$roadSection.modifiers[#Edit_Poly].extrudeAlongSplineSegments = (3 * sectionCount)
			$roadSection.modifiers[#Edit_Poly].Commit ()
			
			--smooth the road so its no so blocky
			select $roadSection
			modPanel.addModToSelection (TurboSmooth ()) ui:on
				
			--move the spline and the road
			select #($roadSpline, $roadSection)
			if lastRoadWasRotated == True then
			(
				lastRoadWasRotated = False
				move $ [0, (1000 * i), 0]
			)
			else
			(
				rotate $ (angleaxis 90 [0,0,1])
				lastRoadWasRotated = True
				move $ [(1000 * i), 0, 0]
			)
			
			
			
			-- make the buildings using the above function. 
			makebldg (40 - i)
			
			--make cars
			createCars i $roadSpline
			
			-- rename the finished road so We don't mess withit later
			$roadSection.name = ("roadSection"+ i as string)
			$roadSpline.name = ("roadSpline"+ i as string)
			i = i + 1
			
			
		)
		scaleTime objects 1 100 5
		animationRange = interval 0 1000
    )
	
     on addIntersection pressed do
     (
		roadSection.modifiers[#Edit_Poly].Select #Face #{12..16}
		roadSection.modifiers[#Edit_Poly].extrudeFaceHeight = 38.3587
     )

	    
	 
)
 
createDialog rol_MyPanel height:200 width:300 pos:[150,200]