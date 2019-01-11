--------------------------------------------------------------------------------
/* mcObjects by Orien 2019 */
--------------------------------------------------------------------------------
Global mcItem
Global mcObject
Global mcSize
Global mcRect
Global mcCube
/*
*@Used Structures
	none - this is base
*
*@Used Objects
	none - this is base
*
*/

/**
*@example
mcItem "a" 23
*/
struct mcItem (
	
	key, val, tag, index	
)

/**
*	@example
*	mcO = mcObject()	
*	mcO.add "ren" 12 -- OK
*	mcO.get "ren" -- 12
*	mcO.keys -- #("ren")
*	mcO.values -- #(12)
*/
struct mcObject ( --always create instance
	
	keys = #(), values = #(),
	fn getSource = getSourceFileName(), --get path of this script
	fn add key val = (
	
		local key_index = findItem keys key
		--format "mcObject > add >  key:% val:% replace:%\n" key val (key_index>0)
		if key_index == 0 then ( --add
			
			keys = append keys key
			values =  append values val
		) else ( --replace
		
			values[key_index] = val	
		)
	),
	fn get key = (
		
		local key_index = findItem keys key
		--format "mcObject > get >  key:% index:%\n" key key_index
		return if key_index > 0 then values[key_index] else undefined
	),
	/**
	local mco = mcObject()
	mco.addMore #(

		mcItem "a" 1,
		mcItem "b" 2,
		mcItem "c" 3
	)
	mcGM.setParam "edit_action_data" mco
	local mco2 = mcGM.getParam "edit_action_data"
	mco2.get "c"
	*/
	fn addMore itm_arr = (
	
		for itm in itm_arr do add itm.key itm.val	
	)
)

/*
si = mcSize 20 45
si.w -- 20
*/
Struct mcSize (w, h)

/*
bo = mcBounds [0, 0] [200, 400]
bo.pos -- [0, 0]
*/
Struct mcBounds (pos, size)

/*
re = rect()
rct = re mi:[0,10] ma:[40,60]
rct.wi()
rct.he()
rct.si()
*/
Struct mcRect 
(
	mi, ma,                  --min, max 
	fn wi =(abs(ma.x-mi.x)), --width 
	fn he =(abs(mi.y-ma.y)), --height  
	fn si =(ma - mi       )  --size
)
/*
cu = cube2()
cub = cu mi:$.min ma:$.max
cub.mi
cub.he()
cub.si()
*/

Struct mcCube
(
	mi, ma,                  --min, max
	fn wi =(abs(ma.x-mi.x)), --width
	fn he =(abs(mi.y-ma.y)), --height 
	fn le =(abs(mi.z-ma.z)), --lenhth
	fn si =(ma - mi       )  --size
)


/* --3d bounding box
		for v = 1 to verts.count do
		(
			local p = polyOp.getVert obj v --vert pos
			if type == #local do p *= inverse obj.transform
			if maxX != undefined then
			(
				if p.x < minX then minX = p.x
				if p.y < minY then minY = p.y
				if p.z < minZ then minZ = p.z
				
				if p.x > maxX then maxX = p.x
				if p.y > maxY then maxY = p.y
				if p.z > maxZ then maxZ = p.z
			)
			else
			(
				maxX = minX = p.x
				maxY = minY = p.y
				maxZ = minZ = p.z
			)
		)
*/