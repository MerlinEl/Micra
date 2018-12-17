--create local bounding box from vertex selection
--created by Martin Capousek and Rene Baca 2011
(
	struct MATRIX_3
	(
		m00,m01,m02,
		m10,m11,m12,
		m20,m21,m22
	)

	struct BOUNDING_BOX
	(
		volume, center, halfsize, orientation 
	)

	local st_orientation = MATRIX_3()
	local st_boundingbox = BOUNDING_BOX()

	local final_angle_x
	local final_angle_y
	local final_angle_z
	
	fn setOrientation x_angle y_angle z_angle =
	(
		local cos_x = cos x_angle
		local sin_x = sin x_angle
		
		local cos_y = cos y_angle
		local sin_y = sin y_angle

		local cos_z = cos z_angle
		local sin_z = sin z_angle
		
		local sin_x_sin_y = (sin_x*sin_y)
		local cos_x_sin_y = (cos_x*sin_y)
		
		st_orientation.m00 = (cos_y*cos_z)
		st_orientation.m01 = (cos_y*sin_z)
		st_orientation.m02 = (-sin_y)

		st_orientation.m10 = (sin_x_sin_y*cos_z)-(cos_x*sin_z)	
		st_orientation.m11 = (sin_x_sin_y*sin_z)+(cos_x*cos_z)	
		st_orientation.m12 = (sin_x * cos_y)

		st_orientation.m20 = (cos_x_sin_y*cos_z)+(sin_x*sin_z)
		st_orientation.m21 = (cos_x_sin_y*sin_z)-(sin_x*cos_z)
		st_orientation.m22 = (cos_x * cos_y)
	)
	
	fn getAxisX = [st_orientation.m00,st_orientation.m01,st_orientation.m02]
	fn getAxisY = [st_orientation.m10,st_orientation.m11,st_orientation.m12]
	fn getAxisZ = [st_orientation.m20,st_orientation.m21,st_orientation.m22]

	fn computeBoundingBox points_array =
	(
		--get axes from struct orientation
		local x_axis = getAxisX()
		local y_axis = getAxisY()
		local z_axis = getAxisZ()
		--compute bounding box for given orientation
		local p, proj
		local x_min = y_min = z_min = 1000000000.0
		local x_max = y_max = z_max = -1000000000.0
		
		for p in points_array do
		(
			proj = dot p x_axis
			x_min = amin x_min proj
			x_max = amax x_max proj
			
			proj = dot p y_axis
			y_min = amin y_min proj
			y_max = amax y_max proj
			
			proj = dot p z_axis
			z_min = amin z_min proj
			z_max = amax z_max proj
		)
		--compute volume for bounding box
		local x_range = x_max - x_min
		local y_range = y_max - y_min
		local z_range = z_max - z_min
		local volume  = x_range*y_range*z_range
		
		if volume >= st_boundingbox.volume do return false
		
		--we found a better (tighter)bounding box
		local x_half = x_range*0.5
		local y_half = y_range*0.5
		local z_half = z_range*0.5
		
		st_boundingbox.volume = volume
		st_boundingbox.orientation = st_orientation
		st_boundingbox.halfsize = [x_half, y_half, z_half]
		st_boundingbox.center = x_axis*(x_min+x_half)+y_axis*(y_min+y_half)+z_axis*(z_min+z_half)
		return true
	)

	fn createLocalBoundingBox =
	(
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local verts_bitarray = polyOp.getVertSelection obj
		if verts_bitarray.numberset == 0 do return false
		local points_array = (for v in verts_bitarray collect polyOp.getVert obj v)
		
		local step = 10.0
		local apply = 0
		st_boundingbox.volume = 1000000000.0
		
		for xa=0 to 90.0 by step do
		(
			for ya=0 to 90.0 by step do
			(
				for za=0 to 90.0 by step do
				(
					setOrientation xa ya za
					if (computeBoundingBox points_array) do
					(
						apply+=1
						format "vol:%\n" st_boundingbox.volume
						final_angle_x = xa
						final_angle_y = ya
						final_angle_z = za
					)
				)
			)
		)
		format "apply:%\n" apply
		local len = st_boundingbox.halfsize.y*2
		local wid = st_boundingbox.halfsize.x*2
		local hei = st_boundingbox.halfsize.z*2
		local cen = st_boundingbox.center -- (getAxisZ()) * st_boundingbox.halfsize.z
		--cen.z -= hei.z/2
		local bbox = box length:len width:wid height:hei --pos:cen dir:(getAxisZ())
		
		bbox.pivot = (bbox.min+bbox.max)/2
		bbox.pos = cen
		bbox.rotation.x_rotation = final_angle_x
		bbox.rotation.y_rotation = final_angle_y
		bbox.rotation.z_rotation = final_angle_z
		
		--material
		local mat = standardMaterial opacity:24 diffuse:(color 196 37 248) selfIllumAmount:64
		bbox.material = mat
		bbox.name = uniqueName "UCX_"
		select bbox

	)

	createLocalBoundingBox() 
	format "bounding box:%\n" st_boundingbox
)
-------
/*
--rozbor max fungci
--fn dotProduct v1 v2 = ( v1.x*v2.x+v1.y*v2.y+v1.z*v2.z )
--fn deg2Rad deg = ( deg*(pi/180.0) )


--orientation
MATRIX_3 m00:0.999249 m01:0.0274018 m02:-0.0274121 m10:-0.0266507 m11:0.999269 m12:0.0274018 m20:0.028143 m21:-0.0266507 m22:0.999249
--center
[59.1568,11.1534,159.806]
*/
