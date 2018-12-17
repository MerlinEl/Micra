MatEditor.Open()
if MatEditor.isOpen() do MatEditor.Close()


fn copyStandardMaterial mat =
(
	if classOf mat != Standardmaterial do return false
	if mat.shaderType != 1 do retrun false
	struct MAT_DATA (nam,tex,cam,cdi,csp,spe,glo,sof,opa,ilu,wir,fma,fac,sid)
	local nam = mat.name
	local tex = mat.diffusemap
	local cam = mat.ambientColor
	local cdi = mat.diffuseColor
	local csp = mat.specularColor
	local spe = mat.specular
	local glo = mat.glossiness
	local sof = mat.soften
	local opa = mat.opacity
	local ilu = mat.selfIllumination
	local wir = mat.wire
	local fma = mat.faceMap
	local fac = mat.faceted
	local sid = mat.twoSided
	MAT_DATA nam tex cam cdi csp spe glo sof opa ilu wir fma fac sid
)
global STANDARD_MATERIAL_DATA
STANDARD_MATERIAL_DATA = copyStandardMaterial selection[1].material

fn pasteStandardMaterial data =
(
	if data == undefined do return false
	local obj = selection[1]
	if obj == undeifned do return false
	local mat = obj.material = standardMaterial()
	--mat.name = data.nam
	mat.diffusemap = data.tex  
	mat.ambientColor = data.cam
	mat.diffuseColor = data.cdi
	mat.specularColor = data.csp
	mat.specular = data.spe
	mat.glossiness = data.glo
	mat.soften = data.sof
	mat.opacity = data.opa
	mat.selfIllumination = data.ilu
	mat.wire = data.wir
	mat.faceMap = data.fma
	mat.faceted = data.fac
	mat.twoSided = data.sid
)
pasteStandardMaterial(STANDARD_MATERIAL_DATA) 


meditMaterials.DirectX_Manager.enabled = off

sceneMaterials.count
for i in sceneMaterials do print i

showTextureMap $.material[1] $.material[1].diffusemap off
showTextureMap $.material $.material.diffuseMap on
$.material.showInViewport=off
--------------------------------------------
$.material = meditMaterials[1]
meditMaterials[1].name = "Test_1"
meditMaterials["Test_1"].diffuse = red
--------------------------------------------
selected_material_num = medit.GetActiveMtlSlot()
selected_material = meditMaterials[selected_material_num]
case (classOf selected_material) of
(
	Multimaterial:1 -- zobrazis tabulku s prejmenovanim submaterialu
	Standard:2 -- zobrazis tabulku s prejmenovanim jednoduchych materialu
)
selected_material.name



for m in meditMaterials do print m.diffuseMap
meditMaterials[1]=standard()
print meditMaterials.count -- number of slots
$.material.name
meditMaterials[1].name

meditMaterials[1].diffusemap = bitmapTexture()
meditMaterials[1].diffusemap.bitmap = x
$.mat = x
$.material.diffusemap = bitmapTexture()
x = selectBitmap()
showTextureMap meditMaterials[1] on --show map in viewport

newMaterial = standard diffuse:(color 250 255 255)

$.Material = standard diffuse:(color 250 255 255)
$.Material = standard diffuse:red
$.Material = standard diffuse:white

mat = standardMaterial diffuseMap:tm 
$.material = mat
---------------------------------------------------
meditMaterials[1].diffusemap = bitmapTexture()
meditMaterials[1].diffusemap.bitmap = x

$.Material.diffusemap = bitmapTexture()
$.Material.diffusemap.bitmap = x
---------------------------------------------------
mat = Standardmaterial ()
mat.name = tr_info_array[a][2]
mat.diffuseMap = Bitmaptexture fileName:tr_info_array[a][1]

--------------------------------------------------------------------------
		local mat = Standardmaterial ()
		local mat.name = tr_info_array[a][2]
		local mat.diffuseMap = Bitmaptexture fileName:tr_info_array[a][1]	
--------------------------------------------------------------------------

--select edge border by materail ID
(

	theEP = selection[1].baseobject
	edgeSelArray = #()
	eCount = polyOp.getNumEdges theEP
	for e = 1 to eCount do
	(
		theFaces = (polyOp.getFacesUsingEdge theEP #(e)) as array
		if theFaces.count == 2 then
		(
			if polyOp.getFaceMatID theEP theFaces[1] != polyOp.getFaceMatID theEP theFaces[2] then
			append edgeSelArray e
		)
	)
	polyOp.setEdgeSelection theEP edgeSelArray
	max Modify Mode
	modPanel.setCurrentObject theEP
	subObjectLevel = 2

)



--->   select by material
--#label l1 "select all sceneobjects which uses the same material"
--#label l2 "than the selected object(s)"
--#label l3 "!!FUNZT NOCH NICHT RICHTIG! (problem: alles auswählen)"
--if objcount==1 then
--(
--	matarray=#()
--	for obj in selection do
--	(
--		if obj.material!=undefined then append matarray obj.material
--	)
--	--PROBLEM!!!
--	objarray=(rootnode/* as array)
--	objarray2=#()
--	for obj in objarray do
--	(
--		for mat in matarray do
--		(
--			if obj.material==mat then append objarray2 obj
--		)
--	)
--	select objarray2
--)


--->   select by texture
--#label l1 "selects all objects which uses this texture"
--#label l2 "no nested multi/sub-materials"
--#edittext tex "texturename" text:"wood_1.bmp" align:#left
--if objcount==1 then
--(
--	tex=r_ui.tex.text
--	objarray=#()
--)
--if classof $.material==multimaterial then
--(
--	for i=1 to $.material.count do
--	(
--		if (findstring $.material.material[i].diffusemap.bitmap.filename tex)!=undefined then
--		(
--			append objarray $
--			exit
--		)
--	)
--)
--else
--(
--	if (findstring $.material.diffusemap.bitmap.filename tex)!=undefined then
--		append objarray $
--)
--if objcount==selection.count then
--(
--	select objarray
--	objarray=undefined
--)

--->   reload all diffusemap-images
--#label l1 "no nested multi/submaterial"
--if classof $.material==multimaterial then
--(
--	for i=1 to $.material.count do
--	(
--		try
--			$.material.material[i].diffusemap.reload()
--		catch()
--	)
--)
--else
--(
--	try
--		$.material.diffusemap.reload()
--	catch()
--)

->   rename Materials in Multimaterial by Texture (4spirit)
#label l1 "renames the Materials in a Multi/Sub-Material"
#label l2 "using the texture as materialname"
for i in $.material do
(
	$.material.material[i].name=getfilenamefile($.material.material[i].diffusemap.bitmap.filename)
)

->   rename material
#edittext _name "new materialname:" fieldWidth:117 align:#left across:2
#label l1 "+ objectname" offset:[45,0]
$.material.name=r_ui._name.text+($.name)


$.material
$.numsubs

--
theMat = multiMaterial()
theMat.materialList.count
--
theMat.numsubs
theMat.materialIDList





--convert wirecolor to multi material

fn mcConvertWireToMaterial =
(
	local sel, mm
	
	sel = ($selection as array)
	if sel.count == 0 do return false
	if sel.count == 1 then
	(
		mm = standard diffuse:(sel[1].wirecolor) name:(sel[1].name)
	)
	else
	(
		mm = multimaterial numsubs:(sel.count) name:(sel[1].name)
		for i=1 to sel.count do mm[i].diffuse = sel[i].wirecolor
	)
	--$.material = mm
)

mcConvertWireToMaterial()

$.material = mm

fn mcConvertWireToMaterial =
(
	local sel = ($selection as array)
	if sel.count == 0 do return false
	for i in sel do i.material = standard diffuse:(i.wirecolor) name:(i.name)
)




mm = multimaterial numsubs:3 name:"Sem01"
mm[1].name = "red"
mm[2].name = "oringe"
mm[3].name = "green"
$Semaphore01.material = mm

--Turn off
$Semaphore01.material[1].Diffuse = color 100 0 0 -- Red
$Semaphore01.material[1].selfIllumAmount = 0

$Semaphore01.material[2].Diffuse = color 100 50 0 -- Oringe
$Semaphore01.material[2].selfIllumAmount = 0

$Semaphore01.material[3].Diffuse = color 0 50 0 --Green
$Semaphore01.material[3].selfIllumAmount = 0


--Turn on
$Semaphore01.material[1].Diffuse = color 255 0 0 -- Red
$Semaphore01.material[1].selfIllumAmount = 50

$Semaphore01.material[2].Diffuse = color 255 110 0 -- Oringe
$Semaphore01.material[2].selfIllumAmount = 50

$Semaphore01.material[3].Diffuse = color 0 255 0 -- Green
$Semaphore01.material[3].selfIllumAmount = 50

/*
for i=1 to $.material.count do
findstring $.material.material[i].diffusemap.bitmap.filename tex

sceneMaterials -- system global, the materials in the scene
sceneMaterials.count
mat = sceneMaterials[81]
classOf mat
file = mat.filename
filenameFromPath file
setMeditMaterial 2 sceneMaterials["wall3"]
*/

for m in sceneMaterials do
(
	local mat = m
	
	if classOf mat == Bitmaptexture then
	(
		local file = mat.filename
		format "Bitmaptexture:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
	)
	else if classOf mat == LS3DMaterial then
	(
		if classOf mat.diffusemap != Mix then
		(
			local file = mat.diffusemap.filename
			format "LS3DMaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
		)
		else
		(
			local file = mat.diffusemap.map1.filename
			format "LS3DMaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
		)
	)
	else if classOf mat == Standardmaterial then
	(
		if classOf mat.diffusemap != Mix then
		(
			local file = mat.diffusemap.filename
			format "Standardmaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
		)
		else
		(
			local file = mat.diffusemap.map1.filename
			format "Standardmaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
		)
	)
	else if classOf mat == Multimaterial do
	(
		for i in mat do 
		(
			if classOf i == LS3DMaterial do
			(
				if classOf i.diffusemap != Mix then
				(
					local file = i.diffusemap.filename
					format "LS3DMaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
				)
				else
				(
					local file = i.diffusemap.map1.filename
					format "LS3DMaterial:(%)\tfile:(%)\n" mat.name (filenameFromPath file)
				)
			)
		)
	)
)




--mm[1].Diffuse = color 100 0 0 -- Red


sceneMaterials["chram"].maps
sceneMaterials["chram"].diffuseMap
sceneMaterials["chram"].matid()
sceneMaterials["chram"].adTextureLock = on
showproperties sceneMaterials["chram"]






.shaderType (Shader_Type) : integer
  .wire : boolean
  .twoSided (Two_sided) : boolean
  .faceMap (Face_Map) : boolean
  .faceted : boolean
  .shaderByName (Shader_Name) : string
  .opacityType (Opacity_Type) : integer
  .opacity : percent
  .filterColor (Filter_Color) : RGB color
  .filterMap (Filter_Map) : texturemap
  .opacityFallOffType (Falloff_Type) : integer
  .opacityFallOff (Falloff) : percent
  .ior (Index_of_Refraction) : float
  .wireSize (Wire_Size) : float
  .wireUnits (Wire_Units) : integer
  .applyReflectionDimming (Apply_Reflection_Dimming) : boolean
  .dimLevel (Dim_Level) : float
  .reflectionLevel (Reflection_Level) : float
  .sampler (Pixel_Sampler) : integer
  .samplerQuality (Sampler_Quality) : float
  .samplerEnable (Sampler_Enable) : boolean
  .samplerAdaptThreshold (Adaptive_Threshold) : float
  .samplerAdaptOn (Adaptive_On) : boolean
  .subSampleTextureOn (SubSample_Textures) : boolean
  .samplerAdvancedOptions (Advanced_Options) : boolean
  .samplerByName (Sampler_Name) : string
  .UserParam0 (Optional_Param0) : float
  .UserParam1 (Optional_Param1) : float
  .samplerUseGlobal (Use_Global_Settings) : boolean
  .mapEnables (Map_Enables) : boolean array
  .maps : texturemap array
  .mapAmounts (Map_Amounts) : percent array
  .adTextureLock (Ambient_Diffuse_Texture_Lock) : boolean
  .ambientMap (alias for maps[0])
  .ambientMapAmount (alias for mapAmounts[0])
  .ambientMapEnable (alias for mapEnables[0])
  .bumpMap (alias for maps[8])
  .bumpMapAmount (alias for mapAmounts[8])
  .bumpMapEnable (alias for mapEnables[8])
  .diffuseMap (alias for maps[1])
  .diffuseMapAmount (alias for mapAmounts[1])
  .diffuseMapEnable (alias for mapEnables[1])
  .displacementMap (alias for maps[11])
  .displacementMapAmount (alias for mapAmounts[11])
  .displacementMapEnable (alias for mapEnables[11])
  .filterMap (alias for maps[7])
  .filterMapAmount (alias for mapAmounts[7])
  .filterMapEnable (alias for mapEnables[7])
  .glossinessMap (alias for maps[4])
  .glossinessMapAmount (alias for mapAmounts[4])
  .glossinessMapEnable (alias for mapEnables[4])
  .opacityMap (alias for maps[6])
  .opacityMapAmount (alias for mapAmounts[6])
  .opacityMapEnable (alias for mapEnables[6])
  .reflectionMap (alias for maps[9])
  .reflectionMapAmount (alias for mapAmounts[9])
  .reflectionMapEnable (alias for mapEnables[9])
  .refractionMap (alias for maps[10])
  .refractionMapAmount (alias for mapAmounts[10])
  .refractionMapEnable (alias for mapEnables[10])
  .selfIllumMap (alias for maps[5])
  .selfIllumMapAmount (alias for mapAmounts[5])
  .selfIllumMapEnable (alias for mapEnables[5])
  .specularLevelMap (alias for maps[3])
  .specularLevelMapAmount (alias for mapAmounts[3])
  .specularLevelMapEnable (alias for mapEnables[3])
  .specularMap (alias for maps[2])
  .specularMapAmount (alias for mapAmounts[2])
  .specularMapEnable (alias for mapEnables[2])
  .bounce (Bounce_Coefficient) : float
  .staticFriction (Static_Friction) : float
  .slidingFriction (Sliding_Friction) : float
  .matid () : float
  .matguid (Material_GUID) : string
  .noExposureControl : boolean
  .exposureControlInvertSelfIllum : boolean
  .exposureControlInvertReflection : boolean
  .exposureControlInvertRefraction : boolean
  .ambient (Ambient_Color) : RGB color
  .diffuse (Diffuse_Color) : RGB color
  .specular (Specular_Color) : RGB color
  .adTextureLock (Ambient_Diffuse_Texture_Lock) : boolean
  .adLock (Ambient_Diffuse_Lock) : boolean
  .dsLock (Diffuse_Specular_Lock) : boolean
  .useSelfIllumColor (Use_Self_Illum_Color) : boolean
  .selfIllumAmount (Self_Illumination) : percent
  .selfIllumColor (Self_Illum_Color) : RGB color
  .specularLevel (Specular_Level) : percent
  .glossiness : percent
  .soften : float
----------------------------------------------------------- 
--load the background layer from a PSD file

theBmp = bitmapLayerManager.LoadLayer "c:/temp/test.psd" 0 true

--assign a bitmap texture to the first material in the MEdit

meditMaterials[1].diffusemap = bitmapTexture()

--assign the PSD background layer to the diffuse slot:

meditMaterials[1].diffusemap.bitmap = theBmp

-----------------------------------------------------------
obj = selection[1]
bi = bitmap 128 128 color:green
pic = Bitmaptexture fileName:""
mat = standard diffuse:green diffuseMap:pic name:"mem shader test"
obj.material = mat

showTextureMap obj.material on

bt = bitmapTexture()
if classof bt == BitmapTexture do 
(
	bt.reload()
	bt.viewImage()
)

obj.material.diffuseMap = bt


dif_map = meditMaterials[1].diffusemap 
if classof dif_map == BitmapTexture do dif_map.viewImage()



bm1 bitmap 256 256 filename:"C:\temp\Alpha.tga"
save bm1
bm1 = openBitmap "C:\temp\Alpha.tga"
print bm1.hasAlpha



local m = standard()
      local myBitmap = Bitmaptexture fileName:myTiffs[i]
      m.diffuseMapEnable = on
      m.diffusemap = myBitmap 
      m.diffuseMap.alphaSource = 2
      m.diffuseMapAmount = 100


/*
usedMaps()

This method returns an array containing the 
filename strings of all bitmap textures used by the current scene.

freeSceneBitmaps()

Frees up all the memory used by the image file bitmap caches. 
This is useful if memory is fragmented with a lot of 
different bitmaps and you want to have just the ones currently active reloaded.



textureMap


RLA, RPF and OpenEXR can all save Z-Depth as part of their file format. Most other applications won't read these, however (combustion does, of course - Photoshop can with ProEXR if you're using the OpenEXR format, and I think it might open RLA with the Z-Buffer (but none of the others?)).

If you absolutely must have a separate file...
Have you looked at the File Output render effect? This render effect has a Z-Depth output option.

If you absolutely must write your own, look into...
<bitmap>getChannelAsMask <bitmap with Z-Buffer> #zdepth
Which will automatically use the closest to furthest z-depth values to map to a greyscale output. You can't specify the min/max ranges yourself.

If you have to specify the min/max ranges yourself, then use:
<array (with single float value)>getChannel <bitmap with Z-Buffer> [x,y] #zdepth
Then map that float value to the greyscale range you desire. Note that you can't get a whole row at a time as you could with getPixels - only 1 pixel at a time.. so it can be rather slow.

*/
