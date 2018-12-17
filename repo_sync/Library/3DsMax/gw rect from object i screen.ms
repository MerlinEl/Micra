      global easyViewSelectionBBox
      unRegisterRedrawViewsCallback easyViewSelectionBBox
      
      fn easyViewSelectionBBox =
      (
      	nodes = for node in selection where iskindof node GeometryClass collect node
      	if nodes.count > 0 do
      	(
      		view = viewport.activeViewport
      		local bmin = [1e9,1e9,0], bmax = [-1e9,-1e9,0]
      
      		gw.setTransform (matrix3 1)
      		transPoint = gw.hTransPoint
      		for node in nodes do
      		(
      			mesh = snapshotasmesh node
      			for v=1 to mesh.numverts do
      			(
      				vp = transPoint (GetVert mesh v)
      				if vp.x < bmin.x do bmin.x = vp.x
      				if vp.x > bmax.x do bmax.x = vp.x
      				if vp.y < bmin.y do bmin.y = vp.y
      				if vp.y > bmax.y do bmax.y = vp.y
      			)
      			free mesh
      		)
      		w = (bmax.x - bmin.x) as integer
      		h = (bmax.y - bmin.y) as integer
      		rect = box2 bmin.x bmin.y w h
      		gw.hPolyline #(bmin, point3 bmax.x bmin.y 0, bmax, point3 bmin.x bmax.y 0) on rgb:#(orange,orange,orange,orange)
      		gw.hText (bmin + [5,h-20,0]) ("Size: [" + (w as string) + ", " + (h as string) + "]") color:orange
      		gw.enlargeUpdateRect rect
      		gw.updateScreen()
      	)
      )
      registerRedrawViewsCallback easyViewSelectionBBox
      completeRedraw()