(
obj = $
threshold = 0.01 --choose the needed threshold : higher value creates more connections
numverts = polyOp.getNumVerts obj
getverts = polyOp.getvert
cutverts = polyop.cutvert
a = #()
b = #()

on_X = true --Cut on X Axis
on_Y = true --Cut on Y Axis
	
for i = 1 to numverts do 
(
	for j = 1 to numverts do
	(
		a = getverts obj i
		b = getverts obj j
		if a != b do
		(
			if on_X == true do if (b.x-threshold) <= a.x and a.x <= (b.x+threshold) then cutverts $ i b [0,0,1]
			if on_Y == true do if (b.y-threshold) <= a.y and a.y <= (b.y+threshold) then cutverts $ i b [0,0,1]
		)
	)
)
update obj
)