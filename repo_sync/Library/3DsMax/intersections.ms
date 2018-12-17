
(
	struct object_data (obj, ray)
	fn getObjIntersection ray =
	(
		--collect all visible objects in scene
		local objs = for o in objects where not o.isHidden collect o
		local od = #()
		local ray_dist    = #()
		--collect objects shoted by ray
		for o in objs do
		(
			local i = intersectRay o ray
			if i!= undefined do 
			(
				od += #(object_data o i)
				ray_dist    += #(distance ray.pos i.pos)
			)
		)
		if od.count      == 0
		then return undefined
		else if od.count == 1
		then return od[1] 
		else --return the closest object to ray begin
		(
			copy_ray_dist = #()+ray_dist --4fun
			sort copy_ray_dist
			return od[findItem ray_dist copy_ray_dist[1]]
		)
	)
	tool getObjectFromRay
	(
		--local PaintMarker
		on start do --create marker
		(
			max select none
			PaintMarker = circle radius:10 pos:ir.pos wireColor:(color 80 250 80) displayRenderMesh:true name:"PaintMarker" thickness = 2
		)
		on mousePoint clickno do
		(
			if clickno > 1 --move marker ower surfaces or grid
			(
				local viewPoint_ray = mapScreentoWorldRay viewPoint
				local obj_data = getObjIntersection viewPoint_ray
				if obj_data != undefined
				then 
				(
					--select obj_data.obj 
					PaintMarker.pos = obj_data.ray.pos
					PaintMarker.dir = obj_data.ray.dir
					format "picked obj:%\n" obj_data
				)
				else 
				(
					--max select none
					PaintMarker.pos = worldPoint
					PaintMarker.dir = viewPoint_ray.dir
					format "picked ground:worldPoint\tray:%\n" (ray worldPoint viewPoint_ray.dir)
				)
				--#stop
			)
		)
		on stop do
		(
			delete PaintMarker
		)
	)
	starttool getObjectFromRay
)