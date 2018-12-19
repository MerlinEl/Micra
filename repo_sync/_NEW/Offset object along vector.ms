--Offset object along vector | .ms
fn GenPos posA posB offset: = (posB-(normalize (posB-posA))*offset)

delete objects
	
inset = 10
ptStart = [100,75,0]
ptEnd = [250,175,10] 
	
p1 = point pos:ptStart size:5 wirecolor:green cross:true box:false
p2 = point pos:ptEnd size:5 wirecolor:green cross:true box:false
sp = splineshape wirecolor:green
addNewSpline sp
addKnot sp 1 #corner #line ptStart
addKnot sp 1 #corner #line ptEnd
updateShape sp	
	
p3 = point pos:(GenPos p1.pos p2.pos offset:inset) size:5 wirecolor:yellow cross:true box:true
p4 = point pos:(GenPos p2.pos p1.pos offset:inset) size:5 wirecolor:yellow cross:true box:true
print (distance p1 p3)
 	
--Placed object along vector | .ms
fn GenPos posA posB offset: = (posB+(normalize (posB-posA))*offset)

p1 = point pos:[5,5,0] size:5 wirecolor:blue
p2 = point pos:[-5,-5,10] size:5 wirecolor:red
p3 = point pos:(GenPos p1.pos p2.pos offset:5) size:5 wirecolor:yellow
print (distance p1 p3)