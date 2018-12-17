plugin material MyMaterial
	name:"VFB_BitmapMaterial"
	classID:#(0x69fedc0d, 0x7c79a4d2)
	extends:Standard replaceUI:true version:1
(
	parameters main rollout:params
	(
		trans type:#float default:27 ui:trans
		two type:#boolean default:false ui:two
		col type:#color default:blue ui:col
		--How can be put a bitmap from memory (not from disc) here ? 
		--dim type:#bitmap default:(bitmap 10 10 color:green) ui:dim
		dim type:#textureMap ui:dim

		on trans set val do delegate.opacity = val
		on two set val do delegate.twoSided = val
		on col set val do delegate.diffuse_color = val
	)
	rollout params "Glass Parameters"
	(
		spinner trans "Transparency: " fieldwidth:45 offset:[-90,0]
		checkbox two "Twosided: " align:#center offset:[-90,0]
		colorpicker col "Base color: " align:#center offset:[-90,0]
		mapButton dim "Bitmap" align:#center offset:[-90,0]
	)
	on create do 
	(
		delegate.opacityFalloff = 75-- setup initial material
		format "created: %\n" this
	)
	on clone orig do format "cloned: % : % : % : %\n" this orig (this == orig) (delegate == orig.delegate)
)
a=mymaterial()
b=copy a


FX_DEFAULTPATH = "$maps\\fx\\"
FX_TEXTURE = "Texture.fx"
plugin material MyExtendFX
name:"MyExtendFX"
classID:#( 645812,447325 )
extends:DirectX_9_Shader replaceUI:true version:1
(
	parameters MainParams rollout:RollParams
	(
		DiffuseMap type:#bitmap
		
		-- Set DiffuseMap activation value
		on DiffuseMapEnable set val do delegate.g_DiffuseMapEnable = val
	)
	
	rollout RollParams "Material Parameters"
	(
		button btnDiffuseMap "None"
		-- When pressing btn DiffuseMap button
		on btn DiffuseMap pressed do
		(
			bmp = selectbitmap caption: "Diffuse Map"
			if(bmp != undefined) do
			(
				delegate.g_ Diffuse Texture = bmp -- Set effect bitmap
				btnDiffuseMap.text = bmp.filename -- Change caption text
				DiffuseMap = bmp -- Set Paramblock value
			)
		)
	)
	
	on create do
	(
		-- Setup initial material
		delegate.effectfile = FX_DEFAULTPATH + FX_TEXTURE
		
	)
	
)	


plugin material MyMaterial
	name:"VFB_BitmapMaterial"
	classID:#(0x69fedc0d, 0x7c79a4d2)
	extends:Standard replaceUI:true version:1
(
	parameters main rollout:params
	(
		trans type:#float default:27 ui:trans
		two type:#boolean default:false ui:two
		col type:#color default:blue ui:col
		--How can be put a bitmap from memory (not from disc) here ? 
		--dim type:#bitmap default:(bitmap 10 10 color:green) ui:dim
		
		--dim type:#bitmap bitmap:(Bitmaptexture fileName:"C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\7printScreen.jpg") ui:dim
		--dim type:#bitmap diffusemap:(Bitmaptexture fileName:"C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\7printScreen.jpg") ui:dim

		dim type:#textureMap ui:dim

		on trans set val do delegate.opacity = val
		on two set val do delegate.twoSided = val
		on col set val do delegate.diffuse_color = val
	)
	rollout params "Glass Parameters"
	(
		local f = "C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\7printScreen.jpg"
		spinner trans "Transparency: " fieldwidth:45 offset:[-90,0]
		checkbox two "Twosided: " align:#center offset:[-90,0]
		colorpicker col "Base color: " align:#center offset:[-90,0]
		mapButton dim "Bitmap" align:#center offset:[-90,0] images:#( f, f, 1, 1, 1, 1, 1)
	)
	on create do 
	(
		delegate.opacityFalloff = 75-- setup initial material
		format "created: %\n" this
		--dim.diffusemap =(Bitmaptexture fileName:)
		--dim.images = #("C:\\Documents and Settings\\rbaca\\My Documents\\3dsmax\\sceneassets\\images\\7printScreen.jpg")
	)
	on clone orig do format "cloned: % : % : % : %\n" this orig (this == orig) (delegate == orig.delegate)
)
a=mymaterial()
b=copy a

plugin material MyMaterial
	name:"VFB_BitmapMaterial"
	classID:#(0x69fedc0d, 0x7c79a4d2)
	extends:Standard replaceUI:true version:1
(
	parameters main rollout:params
	(
		trans type:#float default:27 ui:trans
		two type:#boolean default:false ui:two
		col type:#color default:blue ui:col
		dim type:#textureMap ui:dim--diffuseMap:(BitmapTexture fileName:"") ui:dim
		mat type:#material ui:mat
		--dim type:#bitmap default:(bricks()) ui:dim

		on trans set val do delegate.opacity = val
		on two set val do delegate.twoSided = val
		on col set val do delegate.diffuse_color = val
	)
	rollout params "Glass Parameters"
	(
		spinner trans "Transparency: " fieldwidth:45 offset:[-90,0]
		checkbox two "Twosided: " align:#center offset:[-90,0]
		colorpicker col "Base color: " align:#center offset:[-90,0]
		imgTag itag "wfb"  bitmap:(bitmap 10 10 color:red)
		mapButton dim "Bitmap" align:#center offset:[-90,0]
		materialButton mat "mat" align:#center offset:[-90,0]
	)
	on create do 
	(
		delegate.opacityFalloff = 75-- setup initial material
		--delegate.diffuseMap = (BitmapTexture fileName:"")
		--delegate.DiffuseTexture = (BitmapTexture fileName:"")
		--delegate.diffuseMap = bricks()
		delegate.diffuseMap.bitmap = (BitmapTexture fileName:"C:\\temp\\calendar.jpg")
		delegate.diffuseMapEnable = true
		--delegate.maps = #(bitmap 10 10)--#("C:\\temp\\calendar.jpg")
		format "created: %\n" this
	)
	on clone orig do format "cloned: % : % : % : %\n" this orig (this == orig) (delegate == orig.delegate)
)
a=mymaterial()
b=copy a


/*

Parameter type 
 Rollout user-interface item
 
#integer 
 spinner, slider, radioButtons, checkbox, checkbutton
 
#float 
 spinner, slider
 
#time 
 spinner, slider
 
#color 
 Colorpicker
 
#angle 
 spinner, slider
 
#percent 
 spinner, slider
 
#colorChannel 
 spinner, slider
 
#boolean 
 checkbox, checkbutton
 
#node 
 pickButton
 
#textureMap 
 mapButton
 
#material 
 materialButton
 
#worldUnits 
 spinner, slider
 



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
*/




/*

mcsystem.show

showTextureMap $foo.material $foo.material.diffuseMap on

--load the background layer from a PSD file
theBmp = bitmapLayerManager.LoadLayer "c:/temp/test.psd" 0 true
--assign a bitmap texture to the first material in the MEdit
meditMaterials[1].diffusemap = bitmapTexture()
--assign the PSD background layer to the diffuse slot:
meditMaterials[1].diffusemap.bitmap = theBmp


tm = checker()
mat = standardMaterial diffuseMap:tm

$.material = standard diffuseMap:(bricks()) showInViewport:true


freeSceneBitmaps()

Frees up all the memory used by the image file bitmap caches. 
This is useful if memory is fragmented with a lot of different bitmaps 
and you want to have just the ones currently active reloaded.

*/