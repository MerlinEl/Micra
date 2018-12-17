--PAINT BASIC SHAPES


----------------------------------------------------
/* Function for paint horizontal vertical lines */
fn mcPaintHVLine bmp pos len color HV =
(
	case HV of
	(
		#H:for i=pos.x to pos.x+len do setpixels bmp [i,pos.y] #(color)
		#V:for i=pos.y to pos.y+len do setpixels bmp [pos.x,i] #(color)
	)
)
/* Call: mcPaintHVLine  x [10,30] 90 red #v */
----------------------------------------------------
/* Function fo paint a rectangle */
fn mcPaintRectangle bmp pos size color = 
(
	for a=pos.x to size.x do 
	for b=pos.y to size.y do 
	setpixels bmp [a,b] #(color)
)
/* Call: mcPaintRectangle x [10,10] [40,20] red */
----------------------------------------------------
/* Function for paint cross */
fn mcPaintCross bmp pos size color =
(
	local start_x = pos.x-size.x/2
	local start_y = pos.y-size.y/2
	for a=start_x to start_x+size.x do setpixels bmp [a,pos.y] #(color)
	for b=start_y to start_y+size.y do setpixels bmp [pos.x,b] #(color)
)
/* Call: mcPaintCross x [70,40] [20,20] red */
----------------------------------------------------
/* Function for paint corner */
fn mcPaintCorner bmp pos size color =
(
	for a=pos.x to pos.x+size/2 do setpixels bmp [a,pos.y] #(color)
	for a=pos.y-size/2 to pos.y do setpixels bmp [pos.x,a] #(color)
)
/* Call: mcPaintCorner x [60,30] 90 red */
----------------------------------------------------
/* Function for paint bounding rectngle */
fn mcPaintRectBounds bmp pos size color =
(
	for tb=pos.x to size.x do --top bottom
	( 
		setpixels bmp [tb,pos.y] #(color)
		setpixels bmp [tb,size.y] #(color)
	)
	for lr=pos.y to size.y do --left right 
	(
		setpixels bmp [pos.x,lr] #(color)
		setpixels bmp [size.x,lr] #(color)
	)
)
/* Call: mcPaintRectBounds x [60,30] 90 red */
----------------------------------------------------
/* Function for paint lines in angle */
fn mcPaintHVLineInAngle bmp pos len angle color HV =
(
	local a = pos.y
	case HV of
	(
		#H:for i=pos.x to pos.x+len do (a+=angle; setpixels bmp [i,a] #(color) )
		#V:for i=pos.y to pos.y+len do (a+=angle; setpixels bmp [a,i] #(color) )
	)
)
/* Call: mcPaintHVLineInAngle x [10,30] 90 0.5 = 0  red or 1 = 45 */
----------------------------------------------------
/* Function for paint poygon */
fn mcPaintTringle bmp pos size color =
(
	--base
	for i=0 to size.x do (setpixels bmp [pos.x-size.x/2+i, pos.y+size.y/2] #(color))
	--left diagonal
	for i=0 to size.y/2 do (setpixels bmp [pos.x-size.x/2+i, pos.y+size.y/2-i] #(color) )
	--right diagonal
	for i=0 to size.y/2 do (setpixels bmp [pos.x+size.x/2-i, pos.y+size.y/2-i] #(color) )
)
fn mcPaintCornerInAngle bmp pos size angle color =
(
)

/*
x= (bitmap 160 120)
mcPaintRectangle x [10,10] [40,20] red
mcPaintCross x [70,40] [20,20] red
mcPaintHVLine  x [10,30] 40 red #h
mcPaintCorner x [30,90] 90 red
mcPaintRectBounds x [10,10] [40,80] red
mcPaintLineInAngle x [10,30] 90 45 red
mcPaintLineInAngle x [10,30] 90 45 red
mcPaintHVLineInAngle x [10,30] 40 0.1 red #h
mcPaintTringle x [80,60] [40,40] red
display x
*/


/*
struct rect 
(
	
	mi, ma, 
	fn width  =(abs(ma.x-mi.x)), 
	fn height =(abs(mi.y-ma.y)), 
	fn size   =(point2 self.width self.height)
)
rect = rect mi:wMin ma:wMax
rA.mi.x = newPos.x

*/

/*
	fn drawMarker origBitmap oldPos pos &b = (		-- Draw marker on color map
		-- define the marker shape (circle)
		local posArr = #([-2,-5],[-1,-5],[0,-5],[1,-5],[2,-5], \
						 [-3,-4],[3,-4], \
						 [-4,-3],[4,-3], \
						 [-5,-2],[5,-2], \
						 [-5,-1],[5,-1], \
						 [-5,-0],[5,-0], \
						 [-5,1],[5,1],   \
						 [-5,2],[5,2],   \
						 [-4,3],[4,3],   \
						 [-3,4],[3,4],   \
						 [-2,5],[-1,5],[0,5],[1,5],[2,5])
		for y = -5 to 5 do
			for x = -5 to 5 do
				setPixels b (point2 (oldPos.x+x) (oldPos.y+y)) (getPixels origBitmap (point2 (oldPos.x+x) (oldPos.y+y)) 1)
		local col =  if ((getPixels b pos 1)[1]).v < (255*0.6) then white else black
		for i = 1 to posArr.count do
			setPixels b (pos+posArr[i]) #(col)
		prevPos = pos
	)
*/
