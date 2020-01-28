(
  	struct mapvert ( used, unused, newindex, fn OnEdge = (used > 0 and unused > 0;) )
  
  --*************************************************************************************************************
  -- detaches map faces to a map element returning the new map verts indices as a bitarray
  	
  	fn detachMapFaces pObj mapChan faces = if polyop.getMapSupport pObj mapChan do
  	(
  		nummapverts = polyop.getNumMapVerts pObj mapChan;
  		nummapfaces = polyop.getNumMapFaces pObj mapChan;
  
  		map = #(); -- initialize the vert mapping
  		map.count = nummapverts;
  		for i = 1 to nummapverts do map[i] = mapvert 0 0 -1; 
  
  		for f = 1 to nummapfaces do -- collect the usage
  		(
  			used = faces[f];
  			mapface = polyop.getmapface pObj mapChan f;
  			for v in mapface where v != -1 do if used then map[v].used += 1 else map[v].unused += 1;		
  		)
  		newvertcount = map.count; -- get the new map vert count and add the verts to the map channel	
  		for i in map where i.OnEdge() do newvertcount += 1;
  		polyop.setNumMapVerts pObj mapChan newvertcount keep:true;
  		newvertindex = map.count + 1; -- duplicate the border verts	
  		for i = 1 to map.count where map[i].OnEdge() do 
  		(
  			map[i].newindex = newvertindex;
  			polyop.setMapVert pObj mapchan newvertindex (polyop.getMapVert pObj mapchan i);
  			newvertindex += 1;
  		)
  		for f in faces do	-- re-assign the face indexing	to the new verts
  		(
  			mapface = polyop.getmapface pObj mapChan f;	
  			for v = 1 to mapface.count where (newindex = map[mapface[v]].newindex) != -1 do mapface[v] = newindex;
  			polyop.setmapface pObj mapChan f mapface;
  		)
  		free map;
  		#{(nummapverts+1)..newvertcount};
  	)	
  
  --*************************************************************************************************************
  
  	fn getMapVertsUsingMapFaces pObj mapChan faces =
  	(
  		nmapverts = polyop.getNumMapVerts pObj mapChan;
  		mapverts = #{};
  		mapverts.count = nmapverts;
  		
  		for f in faces do
  		(
  			verts = polyop.getmapface pObj mapChan f;
  			for v in verts do mapverts[v] = true;
  		)
  		mapverts;
  	)
  
  --*************************************************************************************************************
  	
  	fn getMapFacesUsingVert pObj mapChan vert =
  	(
  		nmapfaces = polyop.getNumMapFaces pObj mapChan; 
  		mapfaces = #{};
  		mapfaces.count = nmapfaces;
  		
  		for f = 1 to nmapfaces do
  		(
  			verts = polyop.getmapface pObj mapChan f;
  			for v in verts where vert == v do 
  				mapfaces[f] = true;
  		)
  		mapfaces;
  	)	
  		
  --*************************************************************************************************************	
  	
  	fn collectMapVertsAsPoint2 pObj mapChan verts = 
  	(
  		for v in verts where (vert = polyop.getmapvert pObj mapChan v) != undefined collect [vert.x, vert.y];
  	)	
  
  --*************************************************************************************************************
  
  	fn getStartFace pObj mapChan verts =
  	(
  		minx = 99999999.0;
  		miny = 99999999.0;
  		vert = 0;
  		for v in verts do
  		(
  			mv = polyop.getmapvert pObj mapChan v;
  			if mv.x < minx and mv.y < miny then
  			(
  				minx = mv.x;
  				miny = mv.y;
  				vert = v;
  			)
  		)
  		fi = 0;
  		if vert != 0 then
  			fi = (getMapFacesUsingVert  pObj mapChan vert as array)[1];
  		fi;
  	)
  	
  	
  --*************************************************************************************************************
  
  	fn dot2 a b = (a.x * b.x + a.y * b.y;)
  
  --*************************************************************************************************************
  -- calculate the min bounding rectangle for a set of points	
  
  	fn MinAreaRect pnts &c &u &v &w &h =
  	(
  		minArea = 999999999.0;
  		numpnts = pnts.count;
  		
  		j = numpnts;
  		for i = 1 to numpnts do
  		(	
  			e0 = normalize (pnts[i] - pnts[j]);
  			e1 = [-e0.y,e0.x];
  			
  			min0 = min1 = max0 = max1 = 0.0;
  			
  			for k = 1 to numpnts do
  			(	
  				d = pnts[k] - pnts[j];
  				dp = dot2 d e0;
  				if dp < min0 then min0 = dp;
  				if dp > max0 then max0 = dp;
  				dp = dot2 d e1;
  				if dp < min1 then min1 = dp;
  				if dp > max1 then max1 = dp;
  			)
  			temp_area = (max0 - min0) * (max1 - min1);
  			if 	temp_area < minArea then
  			(
  				minArea = temp_area;
  				w = (max0 - min0);
  				h = (max1 - min1);
  				c = pnts[j] + 0.5 * ((min0 + max0) * e0 + (min1 + max1) * e1);
  				u = e0;
  				v = e1;
  			)
  			j = i;
  		)
  		minArea;
  	)	
  	
  --*************************************************************************************************************	
  	
  	fn transformMapVerts pObj  mapChan verts tm =
  	(
  		for v in verts do
  			polyop.setmapvert pObj mapChan v ((polyop.getmapvert pObj mapChan v) * tm);
  	)		
  	
  --*************************************************************************************************************	
  	
  	fn cwdir f deg = ((mod (f + deg - 2) deg) + 1; )
  	fn ccwdir f deg = ((mod f deg) + 1; )
  	
  --*************************************************************************************************************	
  
  	fn getRowQuadFaces pObj faces startface dirfn =
  	(
  		row = #(startface);
  		verts = polyop.getvertsusingface pObj (faces - #{startface});
  		fverts = polyop.getfaceverts pObj startface;
  		temp = fverts as bitarray;
  		startvert = ((temp - verts * temp) as array)[1];
  		
  		do
  		(
  			fverts = polyop.getfaceverts pObj row[row.count];
  			fi = finditem fverts startvert;
  			nextvert = fverts[dirfn fi fverts.count];
  			startvert = nextvert;
  			nextface = polyop.getfacesusingvert pObj nextvert * faces - #{row[row.count]};
  			if not nextface.isEmpty then
  				append row (nextface as array)[1];
  		)while not nextface.isEmpty;	
  		row
  	)
  	
  --*************************************************************************************************************	
  	
  	fn getFaceRowsFromFaces pObj mapChan startface faces = 
  	(
  		rowstarts = getRowQuadFaces pObj faces startface cwdir;
  		rows = #();
  		rows.count = rowstarts.count;
  		for r = 1 to rows.count do
  		(
  			rows[r] = getRowQuadFaces pObj faces rowstarts[r] ccwdir;
  			faces -= rows[r] as bitarray;	
  		)
  		rows;
  	)
  	
  --*************************************************************************************************************
  	
  	fn getFaceCol facegrid col = ( for r in facegrid collect r[col];)
  	
  --*************************************************************************************************************	
  	
  	fn gridifyMapping pObj mapChan faces facegrid borderverts =
  	(
  		h = facegrid.count;
  		w = 0;
  		for a in facegrid do if a.count > w then w = a.count;
  			
  		if h > 1 then
  		(	
  			bedgeverts = getMapVertsUsingMapFaces pObj mapChan facegrid[1] - getMapVertsUsingMapFaces pObj mapChan facegrid[2];
  			for v in bedgeverts do
  			(
  				mv = polyop.getmapvert pObj mapChan v;
  				mv.y = 0.0;
  				polyop.setmapvert pObj mapChan v mv;
  			)
  	
  			for r = 1 to h-1 do
  			(
  				rowverts = 	getMapVertsUsingMapFaces pObj mapChan facegrid[r] * getMapVertsUsingMapFaces pObj mapChan facegrid[r+1];
  				for v in rowverts do
  				(
  					mv = polyop.getmapvert pObj mapChan v;
  					mv.y = (r * 1.0/h);
  					polyop.setmapvert pObj mapChan v mv;
  				)
  			)	
  			tedgeverts = getMapVertsUsingMapFaces pObj mapChan facegrid[h] - getMapVertsUsingMapFaces pObj mapChan facegrid[h-1];
  			for v in tedgeverts do
  			(
  				mv = polyop.getmapvert pObj mapChan v;
  				mv.y = 1.0;
  				polyop.setmapvert pObj mapChan v mv;
  			)
  		)
  		if w > 1 then
  		(
  			ledgeverts = getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid 1) - 
  												getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid 2);
  			for v in ledgeverts do
  			(
  				mv = polyop.getmapvert pObj mapChan v;
  				mv.x = 0.0;
  				polyop.setmapvert pObj mapChan v mv;
  			)
  			for c = 1 to w-1 do
  			(
  				colverts = 	getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid c) * 
  								getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid (c+1));
  				for v in colverts do
  				(
  					mv = polyop.getmapvert pObj mapChan v;
  					mv.x = (c * 1.0/w);
  					polyop.setmapvert pObj mapChan v mv;
  				)
  			)
  			redgeverts = getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid w) - 
  							getMapVertsUsingMapFaces pObj mapChan (getFaceCol facegrid (w-1)) ;
  			for v in redgeverts do
  			(
  				mv = polyop.getmapvert pObj mapChan v;
  				mv.x = 1.0;
  				polyop.setmapvert pObj mapChan v mv;
  			)	
  		)	
  	)	
  	
  --*************************************************************************************************************	
  	
  	fn GridMapFaces pObj mapChan faces =
  	(	
  		borderverts = detachMapFaces pObj 1 faces;
  		verts = getMapVertsUsingMapFaces pObj 1 faces;
  		pnts = 	collectMapVertsAsPoint2 pObj 1 verts;
  		c = u = v = [0,0];
  		w = h = 0.0;	
  		MinAreaRect pnts &c &u &v &w &h		
  		tm = inverse (matrix3 [u.x,u.y,0.0] [v.x,v.y,0.0]  [0,0,1] [c.x, c.y, 0]);		
  		tm *= (scalematrix [1.0/w,1.0/h,0.0]);
  		tm *= (transMatrix  [0.5,0.5,0.0]);		
  		transformMapVerts pObj 1 verts tm;
  		startface = getStartFace pObj 1 verts;	
  		facerows = getFaceRowsFromFaces pObj 1 startface faces	
  		gridifyMapping pObj 1 faces facerows borderverts;
  	)	
  )