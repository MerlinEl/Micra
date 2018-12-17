--select faces from selected face with same size
face_area = polyop.getFaceArea $ ((polyop.getfaceselection $) as array)[1] 
identical_faces = for i=1 to $.faces.count where (polyop.getFaceArea $ i) == face_area collect i
polyOp.setFaceSelection $ identical_faces

--select faces from selected face which size is lower than her double size
face_area = polyop.getFaceArea $ ((polyop.getfaceselection $) as array)[1] 
identical_faces = for i=1 to $.faces.count where (polyop.getFaceArea $ i) < face_area*2 collect i
polyOp.setFaceSelection $ identical_faces