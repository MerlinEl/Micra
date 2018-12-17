plugin shape Extended_Circle
name:"Circle2"
classID:#(0x69005aed, 0x2edd186a)
extends:circle version:1
invisible:true
replaceUI:true
category:"Splines"
( 
	local helpers = #()
	fn redistributeConstrainObjects helpers =
	(
		local percent = 0
		local incr =  (100/helpers.count)
		for i in helpers do
		(			
			percent +=incr
			/*format "percent:%\n" percent*/
			i.pos.controller.PERCENT = percent
		)
	)
	fn addToConstrain parent percent =
	(
		local obj  = dummy pos: [0,0,0] boxsize: [5,5,5] name:(uniqueName "morpher_tag_")
		obj.pos.controller = Path_Constraint ()
		obj.pos.controller.appendTarget parent 100
		obj.pos.controller.follow = on
		obj.pos.controller.PERCENT = percent
		return obj
	)
	fn addRemoveConstrain val  =
	(
		print val
		if val > helpers.count 
		then 
		(
			--print "add" 
			local percent = (100/(helpers.count+1))
			local thisNode = (refs.dependentNodes this)[1]
			helpers += #(addToConstrain thisNode percent)
			redistributeConstrainObjects helpers
		)
		else if val != helpers.count do
		(
			--print "remove"
			if helpers.count > 2 do 
			(
				delete helpers[helpers.count]
				deleteItem helpers helpers.count
				redistributeConstrainObjects helpers
			)
		)	
		updateInterface
	)
	fn findItemString arr str  ignoreCase:true =
	(
		if  ignoreCase then 
		(
			local lower_arr = for i in arr collect toLower i
			local lower_str = toLower str
			return ( findItem lower_arr lower_str != 0 )
		)
		else return ( findItem arr str != 0 )
	)
	fn notDupplicateFound items txt =
	(
		if findItemString items txt then
			(
				messageBox ("Name: [ "+ txt +" ] is used. Try something else." ) title:"Dupplicate Found!"
				return false
			)
			else return true
	)
	fn selectPoint  txt =
	(
		print txt
	)
	parameters main rollout:params
	(
		control_points type:#integer ui:control_points default:4
		circle_radius type:#integer ui:circle_radius default:10
	)
	rollout params "Parameters"
	(
		spinner circle_radius "Radius:" range:[0,10000,0] type:#float /*scale:0.001*/
		spinner control_points "Points:" range:[2,10,4] type:#integer
		on circle_radius changed val do (this[#Circle].radius = val)
		on control_points changed val do (addRemoveConstrain val)
	)
	rollout interpoints "Interpoints"
	(
		listBox lbx "" pos:[2,2] width:158 height:6 items:(for i in helpers collect i.name)--#("p1","p2","p3","p4")
		editText edt "" pos:[0,88] width:159 height:20
		button btn_add "Add" pos:[4,112] width:48 height:24
		button btn_ren "Rename" pos:[56,112] width:52 height:24
		button btn_del "Del" pos:[112,112] width:48 height:24
		on lbx selected sel do (selectPoint  lbx.items[sel])
		on lbx doubleClicked sel do (edt.text = lbx.items[sel])
		on btn_ren pressed do (if edt.text !="" and  lbx.selection != 0 and notDupplicateFound  lbx.items edt.text  do (lbx.selected = edt.text) )
		on btn_add pressed do ( if edt.text !="" and notDupplicateFound  lbx.items edt.text do (lbx.items += #(edt.text ))) -- lbx.selection
		on btn_del pressed do ( if  lbx.selection != 0 do lbx.items = deleteItem lbx.items lbx.selection) -- lbx.selection
	)
	on update do
	(
		/*print delegate.radius*/
	)
	tool create
	(
		on mousePoint click do
		(
			case click of
			(
				1: 
				(
					coordsys grid nodeTM.translation = gridPoint
					local thisNode = (refs.dependentNodes this)[1]
					local percent = 0
					for i=1 to 4 do 
					(	
						helpers[i] = addToConstrain thisNode percent
						percent += (100/4)
						/*format "percent:%\t node:%\t helpers:%\n" percent obj helpers.count*/
					)
					thisNode.wirecolor = green
					thisNode.name = (uniqueName "morpher_prent_")
					/*
					this[#Circle].render_renderable = true
					this[#Circle].render_displayRenderMesh = true
					*/
					/*mcSystem.show node*/
					/*this[#Circle].position = gridPoint
					delegate.radius = abs(gridDist.y)
					this[#Circle].radius
					*/
				)
				/*1: coordsys grid (node.radius = gridPoint)*/
			)
		)
		 
		on mouseMove click do
		(
		case click of
		  (
			2: 
			(
				this[#Circle].radius = circle_radius = abs(gridDist.y)
				/*d1.pos  = (normalize (d1.pos - nodeTM.translation)) * abs(gridDist.y) + nodeTM.translation*/
			)
			/*3: (control_points = abs(gridDist.y))*/
			3: (#stop)
		  )
		)
	)--end create
	
	
	/*
	tool create
	(
		local startPoint
		on mousePoint click do
		case click of
		(
			1: startPoint = nodeTM.translation = gridPoint
			3: #stop
		)
		on mouseMove click do
		case click of
		(
			2: 
			(
				delegate.width= abs gridDist.x
				delegate.length= abs gridDist.y
				nodeTM.translation = startpoint + gridDist/2.
			)
			3: delegate.corner_radius = amax 0 -gridDist.x
		)
	)
	*/
)


/*
this 
PropNames: #(#control_points, #circle_radius, #Circle)
PropNames: #(#name, #position, #rotation, #scale, #material, #pivot, #target, #parent, #children, #min, #max, #center, #dir, #objectoffsetpos, #objectoffsetrot, #objectoffsetscale, #objecttransform, #modifiers, #isDeleted, #custAttributes, ...)

*/