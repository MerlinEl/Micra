----------------------------------
----------------------------------
--RENDER TO TEXTURE BY MATERIALS--
----------------------------------
----------------------------------

--Rise Self Illum Amount to 100 %
fn flattenMaterialsColors =
(
	--collect all object assinged to projection
	local shell_obj = selection[1]
	local mod_proj = shell_obj.modifiers[#projection]
	if mod_proj == undefined do return false
	local objs = for i=1 to mod_proj.numObjects() collect mod_proj.getObjectNode i
	--collect materials assinged to objects
	local mats = for i in objs collect i.material
	--change self properties for each one
	for i in mats do 
	(
		if       (classOf i) == Multimaterial then
		(
			for y in i where (classOf y) == Standardmaterial do 
			(
				y.selfIllumAmount = 100
				y.specularLevel = 0
				y.glossiness = 0
				y.opacity = 100
			)
		)
		else if  (classOf i) == Standardmaterial do 
		(
			i.selfIllumAmount = 100
			i.specularLevel = 0
			i.glossiness = 0
			i.opacityq = 100
		)
	)
)
/*
--generate new materials
(
	--collect all object assinged as reference geometry in projection
	local shell_obj = selection[1]
	local mod_proj = shell_obj.modifiers[#projection]
	local objs = for i=1 to mod_proj.numObjects() collect mod_proj.getObjectNode i
	--collect materials assinged to objects
	local mats = for i in objs collect i.material
	--create a multisubobject material with 20 elements
	local multi_mat = multimaterial numsubs:20
	--generate diferent color for each material
	fn generateColors num:10 =
	(
		local color_collection = #()
		while color_collection.count <= num and not keyboard.escPressed do
		(
			print color_collection.count
			local c = color (random 0 255) (random 0 255) (random 0 255)
			if findItem color_collection c == 0 do color_collection += #(c)
		)
		return color_collection 
	)
	color_array = generateColors num:20
	for i = 1 to multi_mat.numsubs do
	(
		multi_mat[i].diffuse = color_array[i]
		multi_mat[i].selfIllumAmount = 100
	)
	for i in objs do i.material = multi_mat
)
*/

/*
(
	 --node = mod_proj.getObjectNode i
	-- ids = mod_proj.getObjectMtlIds node i #(1,2,3,4,5,6,7,8,9,10)
--<integer>getObjectMtlIds <node>node <index>objIndex <&integer array>mtlIDs
--<integer>checkDuplicateMatIDs <node>node <&bitArray>dupFaces
	--format "node:%\tids:%\n" node ids
)
*/
