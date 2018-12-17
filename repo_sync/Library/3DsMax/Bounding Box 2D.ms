fn getBox2 obj align:#world debug:false =
(
	struct RECT 
	(
		LD, RU, --left_down ,right_up 
		fn w      =(abs(LD.x-RU.x)), --width 
		fn h      =(abs(LD.y-RU.y)), --height  
		fn size   =(RU - LD       ), --size
		fn center =((LD + RU)/2   ), --center
		fn scale val =(           ), --resize box
		fn rectify=(              )  --set all sides to same size
	)
	--object, vertices, left_down, left_up, right_down, right_up, vert pos
	local obj, verts, LD, LU, RD, RU, vp 
	verts = polyOp.getVertSelection obj
	for v in verts do 
	(
		vp = polyOp.getVert obj v
		--format "ld:%\tlu:%\trd:%\tru:%\n" ld lu rd ru
		--print vp
		if LD == undefined
		then 
		(
			LD = copy (LU = copy (RD = copy (RU = vp)))
		)
		else
		(
			case align of
			(
				#world:	
				(
					if vp.x < LD.x do LD.x = LU.x = vp.x
					if vp.x > RD.x do RD.x = RU.x = vp.x
					if vp.y < LD.y do LD.y = RD.y = vp.y
					if vp.y > LU.y do LU.y = RU.y = vp.y
				)
				#selection:
				(
					--if vp.x < LD.x and vp.y < LD.y do LD = vp
					--if vp.x > RU.x and vp.y > RU.y do RU = vp
					/*
					if vp.x < LD.x and vp.y < LD.y do LD = vp
					if vp.x < LU.x and vp.y > LU.y do LU = vp
					if vp.x > RD.x do RD = vp
					if vp.y > RU.y do RU = vp
					*/
					if vp.x < LD.x do LD = vp
					if vp.y < LU.y do LU = vp
					if vp.x > RD.x do RD = vp
					if vp.y > RU.y do RU = vp
				)
			)
		)
	)
	if debug do --test in 3d plane in max scene
	(
		/*
		delete $point_rect_*
		for i in geometry do getBox2 i align:#selection debug:true
		getBox2 $ debug:true
		*/
		point pos:LD name:"point_rect_ld" wirecolor:red    --left_down 
		--point pos:LU name:"point_rect_lu" wirecolor:blue   --left_up 
		--point pos:RD name:"point_rect_rd" wirecolor:yellow --right_down
		point pos:RU name:"point_rect_ru" wirecolor:green  --right_up 
		point pos:((LD+RU)/2) name:"point_rect_ce" wirecolor:white  --center
	)
	--<lowerleft_point2> <upperRight_point2>--
	--retRUn RECT [LD.x, LD.y] [RU.x, RU.y] 
)
--create a plane from top view and select some vertices
--bo=getBox2 selection[1] align:#selection debug:true
/*
bo.w()
bo.h()
bo.center()
bo.size()
uv1.rotateSelectedVerticesCenter (sweepAngle* PI/180)
*/