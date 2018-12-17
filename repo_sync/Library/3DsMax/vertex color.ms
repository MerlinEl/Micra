Global displaySMGcolor
Global clearSMGcolor
Global displaySelectionSMGcolor
(
	fn getColor num =
	(
		case num of --Table 32 colors
		(
			1: green--color 255 255 255 --bila
			2: blue--color 252 241 3 --zluta
			3: white--color 254 252 20 --zluta2
			4: red--color 254 95 4 --oranz
			5: oringe--color 230 68 30 --oranz2
			6: purple--color 230 38 23 --cervena
			7: violet--color 203 22 37 --cervena2
			8: brown--color 147 27 24 --cervena3
			9: ping--color 90 62 110 --fialova
			10: color 115 98 168 --levandulova
			11: color 196 142 200 --serikova
			12: color 236 0 140 --ruzova
			13: color 240 110 169 --ruzova2
			14: color 24 42 170 --modra
			15: color 9 79 177 --horcova
			16: color 4 141 222 --modra3
			17: color 154 163 162 --stribrna
			18: color 168 151 82 --zlata
			19: color 138 112 55 --medena
			20: color 32 71 53 --zelena 
			21: color 0 133 62 --zelena2
			22: color 4 160 14 --zelena3
			23: color 60 173 33 --limetka
			24: color 109 124 105 --salvejova
			25: color 209 207 166 --bezova
			26: color 61 41 42 --hneda
			27: color 96 57 19 --hneda2
			28: color 177 98 31 --oriskova
			29: color  198 156 109 --pletova
			30: color 160 143 87 --hneda3
			31: color 35 35 35 --cerna
			32: color 108 129 124 --seda
		)
	)
	fn blend2Colors c1 c2 = ((c1+c2)/2)
	fn blendMoreColors arr =
	(
		local c = arr[1]
		for i=2 to arr.count do c=(c+arr[i])/2
		return c
	)
	fn isEditPoly obj = (classOf obj == editable_poly)
	fn getFaceSmoothgroups obj face = 
	( 
		local smgroup_val = polyOp.getFaceSmoothGroup obj face 
		local smg_bitarray = #{} 
		if smgroup_val < 0 do 
		( 
			smg_bitarray[32]=true 
			smgroup_val -= 2^31 
		) 
		for i = 1 to 31 do 
		( 
			smg_bitarray[i]= (mod smgroup_val 2 > .5) 
			smgroup_val /= 2 
		) 
		smg_bitarray 
	)
	fn displaySMGcolor_old = 
	(
		local obj = selection[1]
		if not isEditPoly obj do return false
		
		setCVertMode obj true
		--setShadeCVerts obj true
		
		for i=1 to obj.faces.count do
		(
			local smg = getFaceSmoothgroups obj i as array
			local face_verts = polyOp.getVertsUsingFace obj i
			local colors = for i in smg collect (getColor i)
			polyop.setvertcolor obj 0 face_verts (if colors.count > 1 then blendMoreColors colors else colors[1])
			completeRedraw()
		)	
		
	)
	fn displaySMGcolor = 
	(
		local obj = selection[1]
		if not isEditPoly obj do return false
		
		setCVertMode obj true
		--setShadeCVerts obj true
		
		for v=1 to obj.verts.count do
		(
			local vfaces = polyOp.getFacesUsingVert obj v as array
			local smgs = #{} 
			for f in vfaces do smgs += getFaceSmoothgroups obj f
			local colors = for s in (smgs as array) collect (getColor s)
	--format "colors:%\n" colors
			polyop.setvertcolor obj 0 v (if colors.count > 1 then blendMoreColors colors else colors[1])
		)	
		completeRedraw()
	)
	fn displaySelectionSMGcolor = 
	(
		local obj = selection[1]
		if not isEditPoly obj do return false
		
		setCVertMode obj true
		--setShadeCVerts obj true
		
		local sel_faces = polyOp.getFaceSelection obj
		local face_verts = #{}
		for f in sel_faces do face_verts += polyOp.getVertsUsingFace obj f
		
		for v in face_verts do
		(
			local vfaces = polyOp.getFacesUsingVert obj v as array
			local smgs = #{} 
			for f in vfaces do smgs += getFaceSmoothgroups obj f
			local colors = for s in (smgs as array) collect (getColor s)
	--format "colors:%\n" colors
			polyop.setvertcolor obj 0 v (if colors.count > 1 then blendMoreColors colors else colors[1])
		)	
		completeRedraw()
	)
	fn clearSMGcolor =
	(
		local obj = selection[1]
		if not isEditPoly obj do return false
		for i=1 to obj.verts.count do polyop.setvertcolor obj 0 i white
		setCVertMode obj false
		completeRedraw()
	)
)




/*
displaySMGcolor()
clearSMGcolor()
*/




/*
--the Vertex Color Channel is Map Channel #0
(
	n = converttopoly (box())
	polyop.setvertcolor n 0 #{1,4} red 
	polyop.setvertcolor n 0 #{2,5,7} blue 
	polyop.setvertcolor n 0 #{3} green 
	polyop.setvertcolor n 0 #{6,8} black
	
	format "red:%\n" (polyop.getvertsbycolor n red 0 0 0 channel:0) 
	format "blue:%\n" (polyop.getvertsbycolor n blue 0 0 0 channel:0) 
	format "green:%\n" (polyop.getvertsbycolor n green 0 0 0 channel:0) 
)	
	
--get vert color
vert_buffer = #()
for f in mesh.faces as bitarray do
(
	 gverts = getFace mesh f
	 mverts = getVCFace mesh f
	 for k=1 to 3 do
	 (
		  if vert_buffer[gverts[k]] == undefined do vert_buffer[gverts[k]] = #()
		  appendifunique vert_buffer[gverts[k]] mverts[k]  
	 )
)

-- 1. Take the index of the mesh vertex.
vIdx = m.verts[v].index
 
-- 2. Find out which faces reference the index of the vertex.
faces = (meshop.getFacesUsingVert m vIdx) as Array
 
-- 3. Note the number of the vertex (1st, 2nd or 3rd - .x, .y or .z) inside each face.
corners = for face in faces collect (findItem ((meshop.getVertsUsingFace m face) as Array) vIdx)
 
-- 4. For each face referencing the vertex, get the texture face with the same index.
texVertArrays = for face in faces collect (getTVFace m face)
 
-- 5. Get the index of the respective texture vertex from the face - 1st, 2nd or 3rd / .x, .y or .z 
texVerts = for i = 1 to texVertArrays.count collect (texVertArrays[i])[corners[i]] as Integer


*/

