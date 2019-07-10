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
struct mcItem ( key, val, tag, index )

/**
*@example
	mco = mcObject()	
	mco.add "first" 100 --> OK
	mco.add "second" 200 --> OK
	mco.addMore #(

		mcItem "a" 1,
		mcItem "b" 2,
		mcItem "c" 3
	)
	mco.get "first" --> 100
	mco.keys() --> #("first", "second", "a", "b", "c")
	mco.values() --> #(100, 200, 1, 2, 3)
	
	or
	
	mo = (mcObject.new()).addMore #(

		mcItem "struc" "mcFile", 
		mcItem "func" "read", 
		mcItem "param" "c:\\temp\\test.txt"
	)
	get value by key	> mo.get "a"
	show all			> mo.print()
	loop access			> for k in mo.keys() do print k
	
	or 
	
	mo = (mcObject.new()).add "val_1" "1" 
	mo = (mcObject.new()).addMore (for i=1 to 10 collect mcItem ("val_"+i as String) (i as String))
	mo.print()
	
*/
struct mcObject ( --always create an instance
private	
	_keys = #(), _values = #(),
public
	fn getSource = getSourceFileName(), --get path of this script
	fn count = (_keys.count()),
	fn new = (mcObject()),
	fn keyIndex key = (finditem _keys key),		
	fn hasKey key = (keyIndex key > 0),
	fn keys = (_keys),
	fn values = (_values),
	fn add key val = (
	
		local key_index = keyIndex key
		--format "mcObject > add >  key:% val:% replace:%\n" key val (key_index>0)
		if key_index == 0 then ( --add
			
			_keys = append _keys key
			_values =  append _values val
		) else ( --replace
		
			_values[key_index] = val	
		)
		this
	),	
	fn get key = (
		
		local key_index = keyIndex key
		--format "mcObject > get >  key:% index:%\n" key key_index
		return if key_index > 0 then _values[key_index] else undefined
	),
	fn addMore itm_arr = (
	
		for itm in itm_arr do add itm.key itm.val	
		this
	),
	fn removeKey key = (
	
		local key_index = keyIndex key
		if key_index > 0 do (
		
			deleteitem _keys key_index
			deleteitem _values key_index
		)
	),
	fn toString = (
	
		local str = ""
		for i = 1 to _keys.count do (str += _keys[i] + ":" + _values[i] as string + " ")
		trimRight str --remove last space
	),
	fn print = (
	
		local str = "mcObject ("
		for i = 1 to _keys.count do (str +=  "\n\tkey:" + _keys[i] + " val:" + _values[i] as string)
		str += "\n)\n"
		format "%\n" str
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
Struct mcRect (

	mi, ma,						--min, max 
	fn wi = (abs(ma.x-mi.x)	),	--width 
	fn he = (abs(mi.y-ma.y)	),	--height  
	fn si = (ma - mi			),	--size
	fn le = (mi.x			),	--left
	fn ri = (ma.x			),	--right
	fn tp = (mi.y			),	--top
	fn bt = (ma.y			)	--bottom
)

/**
*@Usage > get rectangle from pos and size
*@Example
	
	rect = mcRect2D pos size
*/
Struct mcRect2D (

	pos, size, --input params
	mi, ma, left, right, top, bottom, width, height,
	fn onCreate = (
	
		if classOf pos != Point2 or classOf size != Point2 do return undefined
		mi = pos
		ma = [mi.x + size.x, mi.y + size.y]
		width 	= (abs(ma.x-mi.x))
		height 	= (abs(mi.y-ma.y))  
		size 	= (ma - mi		 )
		left 	= (mi.x			 )
		right	= (ma.x			 )	
		top 	= (mi.y			 )
		bottom	= (ma.y			 )
		OK
	),
	c = onCreate()
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

/**
*@Usage > get bounding box params (coords word)
*@Example
	
	bm = mcBoxMatrix selection[1]
	point pos:bm.left_center	wirecolor:yellow  --left center
	point pos:bm.right_center	wirecolor:yellow --right center
	point pos:bm.top_center		wirecolor:yellow --top center
	point pos:bm.bottom_center	wirecolor:yellow --bottom center
	point pos:bm.front_center	wirecolor:yellow --front center
	point pos:bm.back_center	wirecolor:yellow --back center
*/
struct mcBoxMatrix (
public
	obj,	--geometry object
	pos,	--pivot position(point)
	mi, ma,	--min(point), max(point)
	width, height, depth,	--widht(x), height(z), depth(y)
	center,					--box center(point)
	left, right, top, bottom, front, back, --border(value)
	left_center, right_center, front_center, back_center, top_center, bottom_center, --border cross(point)
	of_left, of_right, of_front, of_back, of_top, of_bottom, --pivot offset(value) from center
private
	fn onCreate = (
		
		if not (isValidNode obj) do return false
		pos 			= obj.pos
		mi   			= obj.min
		ma  			= obj.max
		width 			= abs (ma.x-mi.x)
		height			= abs (mi.z-ma.z)
		depth 			= abs (mi.y-ma.y)
		center 			= (mi + ma) / 2
		left 			= mi.x
		right 			= ma.x
		front 			= mi.y
		back			= ma.y
		top 			= ma.z
		bottom 			= mi.z
		left_center 	= [mi.x, center.y, center.z]
		right_center	= [ma.x, center.y, center.z]
		front_center	= [center.x, mi.y, center.z]
		back_center		= [center.x, ma.y, center.z]
		top_center		= [center.x, center.y, ma.z]
		bottom_center	= [center.x, center.y, mi.z]
		of_left 		= abs (pos.x - left)
		of_right		= abs (pos.x - right)
		of_front		= abs (pos.y - front)
		of_back 		= abs (pos.y - back)
		of_top 			= abs (pos.z - top)
		of_bottom		= abs (pos.z - bottom)
		true
	),
	c = onCreate()
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