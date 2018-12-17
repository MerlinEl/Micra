
--get the closest face to you
 	fn hitTest =
 	(
 		theRay=mapScreenToWorldRay mouse.pos
 		dist=undefined
 		theHit=undefined
 		for x in objects do 
 		(
 			hitRay=intersectRay x theRay
 			if hitRay!=undefined then
 			(
 				tempDist=distance hitRay.pos theRay.pos
 				if dist==undefined or tempDist<dist then
 				(
 					dist=tempDist
 					theHit=hitRay
 				)
 			)
 		)
 		theHit
 	)
	
ra = hitTest()
point pos:ra.pos dir:ra.dir	
intersectRayEx $ ra
	
--get a position on the grid:
pixelpos = mouse.pos 
gw.mapCPToWorld (mapScreenToCP pixelpos)



--This script will place a point helper on the home grid (or a user grid when it's activated) at the current mouse position.
point pos:((gw.getPointOnCP mouse.pos) * (getCPTM()))



--And here is a hit test for an object if any one is interested. It returns the ray of the face that it hits.
fn hitTest =
(
	theRay=mapScreenToWorldRay mouse.pos
	hitRay=intersectRay $ theRay
)

--or
fn hitTest =
(
theRay=mapScreenToWorldRay mouse.pos
for x in objects do
(
hitRay=intersectRay x theRay
if hitRay!=undefined then
(
return hitRay
)
)
undefined
)

