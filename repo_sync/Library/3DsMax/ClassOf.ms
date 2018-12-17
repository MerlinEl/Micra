classOf "1"== string
classOf 1 == integer  
  
  Float 
  Integer 
  String 
  BitArray 
  Point3
  Ray
  Quat
  AngAxis
  EulerAngles
  Matrix3
  Point2
  Color


(
	local newSel=#()
	for obj in geometry where (isProperty obj "numFaces") do (
		if obj.numFaces>3 do (append newsel obj)
		)
	select newSel
)

hasProperty $Box01 "name" 
isProperty $Box01 #radius --test for radius in a Box