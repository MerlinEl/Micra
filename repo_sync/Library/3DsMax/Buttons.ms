
	local orange_bitmap = bitmap 100 100 color:orange
	local green_bitmap = bitmap 100 100 color:green
button btn_dock_top ""  height:24 images:#(green_bitmap , green_bitmap , 1, 1, 1, 1, 1) 

rollout xRollout2 "Modeler" width:162 height:339
(
	button btno6 "Aff" pos:[104,136] width:24 height:24  toolTip:"Aff"
	on xRollout2 open  do (if x == false then btno6.enabled = false)
	--enabledIn:#("max", "viz") --pfb: 2003.12.12 added product switch 
	--On btno6 IsVisible Return Filters.Is_EPoly()
	--On btno6 IsEnabled Return Filters.Is_EPoly()
		on btno6 pressed do
			(
			if is #sLev_x and is #poly then
				(
				if $.ignoreBackfacing == on then $.ignoreBackfacing = off
				else $.ignoreBackfacing = on
				)
			--btno6.enabled = false
			)
)
----------------------------------------------------------------------------
xFloater = newrolloutfloater "Micra" 152 700 0 100 -- Create Micra Floater
----------------------------------------------------------------------------
addRollout xRollout2  xFloater rolledUp:false    -- (Modeler)




mcDialog.btn_C5.visible = off


theButton.images = #(theBmp, undefined, 1,1,1,1,1 )
mc2DialogEditMode.btn_icn.images = mc2Call.getIcon 3



	on btn9 pressed  do
	(
		print "pressed"
	)
	on btn9 rightclick do 
	(
		print "RC"
	)
	
	
fn drawButton type size =
(
	local bgColor = (colorMan.getColor #background   )*255
	local hiColor = (colorMan.getColor #hilight      )*255
	local shColor = (colorMan.getColor #shadow       )*255
	local pbColor = (colorMan.getColor #pressedButton)*255
	local colorArray = case type of
	(
		#up      : #(bgColor, hiColor, shColor)
		#down    : #(pbColor, shColor, hiColor)
		#hilight : #(bgColor, green  , green  )
	)
	local img = (bitmap size.x size.y color:colorArray[1])
	--draw lines in X
	for i=0 to size.x do                     
	(
		setpixels img [i,       0] #(colorArray[2])--top
		setpixels img [i,size.y-1] #(colorArray[3])--bottom	
	)
	--draw lines in Y
	for i=0 to size.y do                     
	(
		setpixels img [0,       i] #(colorArray[2])--left
		setpixels img [size.x-1,i] #(colorArray[3])--right	
	)
	return img
)

--display rolx.tag_01.bitmap
/*
	fn mcInicializeButtons =
	(
		PaintButtonTest.itg_1.bitmap = (mcCreateColorButton [76,56] #up)
		PaintButtonTest.itg_2.bitmap = (mcCreateColorButton [24,24] #up)
	)
	fn mcButtonState type =
	(	 	
		case type of
		(
			#down:
			(
				if keyboard.controlPressed then 
				(BtnColorSwitch = on ; mcCreateColorButton [76,56] #downcl)
				else 
				if keyboard.shiftPressed then 
				(BtnColorSwitch = off ; mcCreateColorButton [76,56] #down )
				else
				if BtnColorSwitch 
				then mcCreateColorButton [76,56] #downcl
				else mcCreateColorButton [76,56] #down
			)
			#up:
			(
		 		if BtnColorSwitch
				then mcCreateColorButton [76,56] #upcl
				else mcCreateColorButton [76,56] #up
			)
		)
	)
	on PaintButtonTest open do ( mcInicializeButtons() )
	on itg_1 mousedown do itg_1.bitmap = mcButtonState #down
	on itg_1 mouseup do itg_1.bitmap = mcButtonState #up
	on itg_1 mouseout do itg_1.bitmap = mcButtonState #up
	--on <ImgTag> mouseover do <expr>
	on itg_2 mousedown do itg_2.bitmap = (mcCreateColorButton [24,24] #down)
	on itg_2 mouseup do itg_2.bitmap = (mcCreateColorButton [24,24] #up)
	on itg_2 mouseout do itg_2.bitmap = (mcCreateColorButton [24,24] #up)
*/
