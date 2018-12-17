rollout rolx "Untitled" width:162 height:300
(
	local bm = bitmap 50 50 color:red
	ImgTag tag_01 "" pos:[36,62] width:24 height:24 bitmap:bm 
	on tag_01 mouseup  do (print "single")
	on tag_01 dblclick do (print "double")
)
createdialog rolx


/*
imgTag <name> [caption] [tooltip:<string>] [style:<key>] [bitmap:<bitmap>] [opacity:<float>] [transparent:<color>]
<ImgTag>.tooltip String default:""
<ImgTag>.bitmap Bitmap default:undefined 
<ImgTag>.style Key default:#bmp_stretch

#bmp_stretch
#bmp_tile
#bmp_center

<ImgTag>.opacity float default:0.0
<ImgTag>.transparent color default:(color 0 0 0)

Events

on <ImgTag> mousedown do <expr>
Called when the left mouse button is pressed down.

on <ImgTag> mouseup do <expr>
Called when the left mouse button is released.

on <ImgTag> click do <expr>
Called when the left mouse button is released.

on <ImgTag> dblclick do <expr>
Called when the left mouse button double clicked.

on <ImgTag> mouseover do <expr>
Called when the mouse is moved into the image area.

on <ImgTag> mouseout do <expr>
Called when the mouse is moved out of the image area.

on <ImgTag> rightclick do <expr>
Called when the right mouse button is released. Available in 3ds Max 8 and higher.

on <ImgTag> lbuttondown <Point2> <Flags> do <expr>
Called when the left mouse button has been pressed. Available in 3ds Max 8 and higher.

*/
