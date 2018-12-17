fn ManipToBounds pos = 
(
	Local mini = $.min
	Local maxi = $.max
	
	case pos of 
	(
		#fld: pos:mini --Front.Left.Down
		#bru: pos:maxi --Back.Right.Up
		#flu: pos:[mini.x, mini.y, maxi.z]
		#frd: pos:[maxi.x, mini.y, mini.z]
		#fru: pos:[maxi.x, mini.y, maxi.z]
		#brd: pos:[maxi.x, maxi.y, mini.z]
		#blu: pos:[mini.x, maxi.y, maxi.z]
		#bld: pos:[mini.x, maxi.y, mini.z]
	)	
)


/* --BoundingBox
--FrontLeftDown
point pos:mini
--FrontLeftUp
point pos:[mini.x, mini.y, maxi.z]
--FrontRightDown
point pos:[maxi.x, mini.y, mini.z]
--FrontRightUp
point pos:[maxi.x, mini.y, maxi.z]
--BackRightUp
point pos:maxi
--BackLeftUp
point pos:[maxi.x, maxi.y, mini.z]
--BackRightDown
point pos:[mini.x, maxi.y, maxi.z]
--BackRightUp
point pos:[mini.x, maxi.y, mini.z]
*/ --BoundingBox


/* --cross
--Up
point pos:[sel.pos.x, sel.pos.y, sel.max.z]
--Down
point pos:[sel.pos.x, sel.pos.y, sel.min.z]
--Left
point pos:[sel.min.x, sel.pos.y, sel.pos.z]
--Right
point pos:[sel.max.x, sel.pos.y, sel.pos.z]
--Back
point pos:[sel.pos.x, sel.max.y, sel.pos.z]
--Front
point pos:[sel.pos.x, sel.min.y, sel.pos.z]
*/ --cross


