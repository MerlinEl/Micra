--nomralize_uv_elements
-----------------------------------------------
--v1.0 script for 3dstudio maxR5
--14.july 2004 | michael brempel | email@mbrempel.de
-----------------------------------------------
--script to normalize/resize uv-elements according to its object-surface-area
-----------------------------------------------
--how to use:
--unwrap your objects
--apply checkermaterial to the objects (to see the result)
--select the objects and run the script
--all checkers should have now the same size
-----------------------------------------------
--parameters:
--sclfactor: influences the resultsize, small values results in smaller uv-elements
--packuvs: if you want to rearrange the the rescaled uv-elements
-----------------------------------------------
--known bugs:
-----------------------------------------------
--still todo:
--calculate the real-uvarea-size (not only the rectangle)
-----------------------------------------------
fn main sclfactor packuvs channel=
(
	print sclfactor
	print packuvs
	print channel
	
	_datastring=""
	objlist=#()
	for obj in selection do
	(
		if(((classof obj)==Editable_Poly) or ((classof obj)==Editable_Mesh)) then
		(
			append objlist obj
		)
		else
		(
			_datastring+=(obj.name+" is not an EditablePoly or an EditableMesh -> ignored\n")
		)
	)
	
	for obj in objlist do
	(
		select obj
		--add uvw-modifier
		addmodifier obj (Unwrap_UVW ())
		mod=obj.modifiers[1]
		mod.unwrap.setMapChannel channel
		vcnt=mod.unwrap.numbervertices()
		mod.unwrap.selectVertices #{1..vcnt}
		
		--Anzahl der elemente ermitteln und vertexindex eines im element liegenden vertices merken
		vertelemarray=#()
		for i=1 to vcnt do vertelemarray[i]=0
		elem=0
		for v=1 to vcnt do
		(
			if(vertelemarray[v]==0)then
			(	--wenn vertex noch keinem element zugeordnet ist -> muss ein neues element sein
				mod.unwrap.selectVertices #{v}
				mod.unwrap2.SelectElement()
				elem+=1
				elemverts=mod.unwrap.getselectedvertices()
				for i in elemverts do
				(	--all diese vertices sind im element -> in vertelemarray markieren
					vertelemarray[i]=elem
				)
			)
		) 
		--print elem as string
		
		--array erstellen, in dem nur vertindex auf element gespeichert ist (elem-nr ist arrayindex)
		elemarray=#()
		for e=1 to elem do
		(
			for v=1 to vertelemarray.count do
			(
				if vertelemarray[v]==e then
				(	--vertexindex für element gefunden
					elemarray[e]=v
					exit
				)
			)
			e+=1
		)
		--print elemarray as string
		
		for i=1 to elemarray.count do
		(	--für jedes element skalierung der elemente vornehmen
			
			--uv-rectanglegröße ermitteln
			scl=1
			u1=999.0	--bottom-left
			v1=999.0	--bottom-left
			u2=-999.0	--top-right
			v2=-999.0	--top-right
			mod.unwrap.selectVertices #{elemarray[i]}
			mod.unwrap2.SelectElement()
			elemverts=mod.unwrap.getselectedvertices()
			for v in elemverts do
			(	--alle vertices des selektierten elements durchgehen
				uvw=mod.unwrap.getVertexPosition 0 v
				if u1>uvw.x then u1=uvw.x
				if v1>uvw.y then v1=uvw.y
				if u2<uvw.x then u2=uvw.x
				if v2<uvw.y then v2=uvw.y
			)
			
			--area der ausgewählten polys im 3d-space ermitteln
			mod.unwrap2.verttofaceselect()
			facearray=mod.unwrap2.getselectedfaces()
			--mod.unwrap.selectpolygons(facearray)
			xyzarea=0
			mymesh=snapshotAsMesh(obj)
			xyzarea=meshop.getFaceArea(mymesh)(facearray)
			delete mymesh
			--print ("xyzarea:"+xyzarea as string)
			
			--neue skalierung berechnen und uv-elemente skalieren
			uvarea=(u2-u1)*(v2-v1)
			xyzarea*=sclfactor
			--print ("uvarea:"+uvarea as string)
			scl=sqrt(xyzarea/uvarea)
			--print ("scl:"+scl as string)
			mod.unwrap.ScaleSelectedVerticesCenter scl 0
			
			--neu anordnen
			if(packuvs==true) then
			(
				mod.unwrap.selectVertices #{1..vcnt}
				mod.unwrap2.pack 0 0.0 false false false
			)
		)
	)
	select objlist
	_datastring="normalize_uv's done\n"+_datastring+""
	messagebox _datastring
)
--ROLLOUT---------------------------------------
(
rollout normalize_uv_elements "normalize_uv_elements"
(
	spinner spn1 "map-channel" width:60 height:16 range:[0,99,1] type:#integer align:#right
	checkbox c1 "pack uv's" checked:true align:#left
	spinner spn2 "scalefactor" width:60 height:16 range:[0.01,5.0,0.5] scale:0.01 fieldwidth:40 type:#float align:#right enabled:true
	button btn1 "go" width:50 height:17
	on btn1 pressed do
	(
		main spn2.value c1.checked spn1.value
	)
)

r_floater=newrolloutfloater "normalize_uv_elements" 150 121
addrollout normalize_uv_elements r_floater
)
-----------------------------------------------