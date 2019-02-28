-- A common thing to do in a scripted material is to call functions as you would in a traditional rollout.
-- Get the value of an RGB (to convert ambient col to a value
fn rgbToLuminance = (
	local ambPoint3 = ambientColor as point3
	local r = ambPoint3.x
	local g = ambPoint3.y
	local b = ambPoint3.z
	local maxRGB = 0
	local minRGB = 0
	
	if r >= g then maxRGB = r
	if r >= b then maxRGB = r
	if g >= r then maxRGB = g
	if g >= b then maxRGB = g
	if b >= r then maxRGB = b
	if b >= g then maxRGB = b
	
	if r <= g then minRGB = r
	if r <= b then minRGB = r
	if g <= r then minRGB = g
	if g <= b then minRGB = g
	if b <= r then minRGB = b
	if b <= g then minRGB = b
	
	lumin = ((maxRGB + minRGB)/2)/255
)

--Another powerful feature is the ability to set 'presets' for values
struct brdfVar (glossiness, reflectance, specMult, whateverTheHellYouWant)
--now define the settings for different brdf defaults
brdfDefault = brdfVar	glossiness:32	reflectance:0
brdfMetal 	= brdfVar	glossiness:16	reflectance:.3
brdfWood	= brdfVar	glossiness:20	reflectance:0

/*One more powerful, common thing, is to use something like a drop down box with a "lookup" for another value
Won't do it here because I am using a default max shader and have no use for it.  But, for example, we could have a dropdownlist, and we
pass the selection to a function, which will associate the selection with an array of values.  We then use the numbers in that array to
fill in 'invisible' UI items and variables.*/



plugin material RM_Shader --specifies plugin as material, and internal name
	name:"Radiant Machine Shader" --extended script name
	classID:#(0x17d11e9c, 0x4817818)  --unique class id, use genClassID()
	extends:DirectX_9_Shader replaceUI:true version:1
(
	/*Scripted material plugin, like any scripted plugin, uses a "rollout" that the user interacts with, but
	listed first is a "parameters" area that is the middle point between the "rollout" and the actual thing you are
	effecting (in our case, an fx file).
	
	Another important thing to remember is that each "parameters" must have a corresponding "rollout".  I demonstrate having
	two parameters and rollouts for clarity, though the second doesn't do anything and is there merely as a demonstration for comprehensiveness.
	*/
	
	parameters param_perMat rollout:roll_perMat
	(
		--One thing we do not want to lose is the ability to change techniques.  Thus we need to make sure there is a rollout and parameter for technique
		g_technique	type:#integer default:1 ui:dd_tech
		on g_technique set val do (
			delegate.Technique = 0
			if val == 2 then delegate.Technique = 1
		)
		/*As this is the first parameter, let's dissect it.
		"g_technique" is the paramter name
		"type:#integer" can be #bitmap, #float, #integer, #color, #point3, or #point4, a note about the latter 3 later on
		"default:" is the default value and should be set according to the ui element type (drop downs are 1 based while some other UI elements are 0 based)
		"ui:dd_tech" is the corresponding UI/rollout item
		
		"on g_technique set val do" means that when the parameter changes (which, remember, happens whenever the assigned ui element changes)
		we will perform this action.  Also keep in mind that "val" holds the value of the ui item (which has to be a number, cannot be a string.  Remember
		that each parameter needs a corresponding shader constant/variable, which can only be numbers.
		
		"delegate.Technique" is the variable name of the delegate (set on the "create" action) as in the .fx file.
		For consistency I make the parameter name the same as the fx constant name, but this isn't neccessary.
		
		A dropdownlist is 1-based, while techniques are 0 based.  Thus we can either associate values by hand as above
		or try a "newVal = val - 1; delegate.Technique = newVal"
		*/
		
		my_minUCoord type:#float default:0 ui:sld_minUCoord
		on my_minUCoord set val do (
			delegate.minUCoord = val
		)
		/*Yet another feature we can do with scripted materials: have "hidden" variables.  You FX file can have any number of hidden 
		variables that never show up in the material UI.  Many times they are hidden and set with functions and UI actions (such as a 
		macro launched on a UI button press)
		
		Related to this, remember that the shader constants don't need to be used in the shader itself, they just need to be set up.  Many times
		I've put variables in the scripted material, that aren't used in the shader, to be used later in something like an XML export for a string lookup
		This topic will be covered in a separate tutorial, using what we've learned here.  An example would be having a drop down box with "2" as "Metal"
		so when we choose "2" we can then associate it with a string later on, even though this data CANNOT be stored in the scripted material (given the
		restriction that we cannot store strings in the scripted material/fx file)
		*/		
		
		--Textures are handled slightly differently than most UI items, though most work comes in the rollout UI item
		difTex type:#bitmap ui:btn_difTex
		on difTex changed val do (
			delegate.g_DiffuseTexture = val
		)
		normTex type:#bitmap ui:btn_normTex
		on normTex changed val do (
			delegate.g_NormalTexture = val
		)
	)

	--Parameters for Primary Tint Mask Variables/rollout
	parameters param_tintP rollout:roll_tintP
	(
		--Material Info
		g_glossiness type:#integer default:32 ui:spn_glossiness
		on g_glossiness set val do (
			delegate.g_glossiness = val --this is the shader value!
		)
		g_reflectance type:#float default:0 ui:spn_reflectance
		on g_reflectance set val do (
			delegate.g_reflectance = val
		)
		--Here is an example of something we would possibly use as an integer to string lookup as mentioned above, for an XML export
		g_brdf type:#integer default:1 ui:dd_brdf
		on g_brdf set val do (
			delegate.brdf = val
		)
		
		--Using a type:#color
		g_ambientColor type:#color default:[127,127,127] ui:col_ambientColor
		on g_ambientColor set val do (
			delegate.ambientColor = val
		)
	)	
	
	/*
	I will lay out exactly what we are doing here by explaining each UI element, so you can follow along.  I'm giving somewhat of 
	a smorgasbord of techniques and methods here, so I want to make sure things are clear and explained properly, while giving the 
	reader knowledge not just on the very introductory functional level, but to stimulate the wide possibilities.
	*/

	rollout roll_tintP "Material Properties"
	(
		spinner spn_glossiness 	"Glossiness     " 	type:#integer	range:[2, 512, 32]	fieldwidth:30
		spinner spn_reflectance	"Reflectance  " 	type:#float		range:[0, 1, 0] 	fieldwidth:30
		--The above are simply spinners for materials
		
		dropdownlist dd_brdf	"BRDF/Material Type"	width:120 default:1 height:50  items:#("Default","Metal","Wood", "Custom")
		button btn_brdfAssign "Defaults from BRDF" width:120 height:16
		--This is the beginning of something really cool you can do.  Below we will use this drop down list as part of a number of
		--interesting methods
	
		colorpicker	col_ambientColor "AmbientColor      "	color:[127,127,127] fieldWidth:16	height:16	modal:false
		button btn_ambientColorReset	"R"		height:16 width:16
		--We have a button to choose a color to tint an object, and another button to reset the value
		--You could also have one to choose a random color, for example, or choose from a series of palette choices, etc.
		
		--EVENTS
		
		--Reset Tint
		--Very simple, we just reset the tint color to neutral grey
		on btn_ambientColorReset pressed do (
			col_ambientColor.color = color 127 127 127
		)
		
		--More complex now.  What we are doing is selecting a BRDF from a known texture location based on the user selection
		--If "Custom" is selected, we will allow the user to choose his own BRDF texture.
		--It is also possible to use this with something like the "Auto-Assign textures" technique below	
		on dd_brdf selected sel do (
			brdfString = assignBRDF sel
			brdfPath = "C:\\magicka\\trunk\\source\\Magicka\\Framework\\Art\\Textures\\"
			brdfSuffix = "BRDF.png"
			
			try (
				brdfTex = openBitMap (brdfPath + brdfString + brdfSuffix)
				brdfTexString = brdfTex as string
				brdfTexName = filenameFromPath brdfTexString
				delegate.g_BRDFTextureP = brdfTex
			) catch (messageBox "Please update C:\magicka\trunk\sourfce\Magicka\Framework\Art\Textures\ " )
			
			--if Custom is selected let's open a file dialog for a custom bitmap
			if sel == 17 then (
				brdfTexCus = selectBitMap caption:"Select Custom BRDF Texture"
				if brdfTexCus != undefined then (
					brdfTexCusString = brdfTexCus as string
					brdfTexCusName = filenameFromPath brdfTexCusString
					delegate.g_BRDFTexture = brdfTexCus
				)
			)
		)
		
		--Above we created a number of structures with default values for glossiness and reflectance.  We assign the values
		--in those structs based on the BRDF selected, to give the user a good starting point, especially when a dozen or so values
		--may be involved.
		on btn_brdfAssign pressed do (
			local num = dd_brdf.selection
			if num == 1 then brdfStruct = brdfDefault
			else if num == 2 then brdfStruct = brdfMetal
			else if num == 3 then brdfStruct = brdfWood
			else brdfStruct = brdfDefault --fallback
			spn_glossiness.value = brdfStruct.glossiness
			spn_reflectance.value	= brdfStruct.reflectance
		)
		
	)--end roll_tintP
	
	rollout roll_perMat "Material Variables"
	(
		
		/*Here is one of those 'hidden' UI items that we can use in the shader (or just use to hold extra info).
		The way we assign this variable is entirely unrelated to this UI item, but we use it to "hold on to" the variable
		We could, for example, use a button to launch a script so we can choose a UV box, and then record the data in
		any number of hidden variables.  Or, we could do something like store a number of values in these hidden variables
		based on the selection of a dropdownlist, etc.  Also, please take note of the 'material editor must be open' caveat*/
		spinner sld_minUCoord visible:false
		
		--Choosing the material technique
		dropdownlist dd_tech	"Material Technique"	items:#("Front faces","backfaces") width:100
		
		--Textures
		/*We have a button that auto-assigns textures by looking in a number of places for appropriately named textures.
		If none are found, we fall back to a default texture in a known location.
		We also allow the user to choose a texture manually by clicking on the appropriate texture button*/		
		button btn_autoTex	"Auto-Assign Textures" width:110 height:16
		button	btn_difTex 	"Diffuse Texture"		width:180 height:16
		button btn_normTex	"Normal Texture"		width:180 height:16
		--One thing I am trying to figure out is a way to have the button text be replaced with the path of the texture.
		--I can replace it, but it doesn't remain if I close and open the material editor, having to do with another
		--caveat explained in the intro (every UI element needs a shader constant to 'stick').  If you have a solution, please email me.
		
		--EVENTS
		on btn_autoTex pressed do
		(
			/*We want to look in three places.  Here they are arbitrary, but let me explain what we did on DDi:
			We looked for: First, a folder down from the current max file, whereever it is, based on the name of 
			the selected object.  We could also base where we look on the text entered in an edittext box in the UI.
			Second, we look in another known directory based on the selected object name.
			Third, we have a fallback to use at a known path, and tell the user the auto-find failed.
			*/
			
			local rootPath = getDir #maxRoot
			local uiRoot = getDir #ui
			
			--We would do this for each texture we want to auto-find.
			--Since we want to look in 3 places, we use a nested try-catch.  The first successful result will work, so the first place
			--we look in should be in the inner-most but first try, and the last fall-back the outermost and last catch
			--Diffuse
			try (
				try (
					difTex = openBitMap (maxFilePath + "Diffuse.tga")
				)
				catch (
					difTex = openBitMap (rootPath + "maps\\truthRocksD.tga")
				)
			)
			catch (
				messageBox "Your Diffuse Texture is missing"  --we want to tell the user if we can't find his texture
				difTex = openBitMap (uiRoot + "Icons\\bip_ikkey_i.bmp") --not useful, but just
					--to find something if you forget to put the texture in the right spot
			)
			delegate.g_DiffuseTexture = difTex --delegate IS THE FX FILE!  Here we set the g_DiffuseTexture (the diffuse texture
			--sampler) to use the difTex we found
			
			--Normal
			try (
				try (
					normTex = openBitMap (maxFilePath + "Normal.tga")
				)
				catch (
					normTex = openBitMap (rootPath + "maps\\truthRocksN.tga")
				)
			)
			catch (
				messageBox "Your Diffuse Texture is missing"  --we want to tell the user if we can't find his texture
				normTex = openBitMap (uiRoot + "Icons\\bip_ikkey_i.bmp")
			)
			delegate.g_NormalTexture = normTex --delegate IS THE FX FILE!  Here we set the g_DiffuseTexture (the diffuse texture
			--sampler) to use the difTex we found
		)--end autoTex
	
		--here we want to open an explorer window for the user to find his diffuse texture
		on btn_difTex pressed do
		(
			try (
				difTex = selectbitmap caption: "Diffuse Map"
				if difTex != undefined then
				(
					delegate.g_DiffuseTexture = difTex
				)
			) catch ()
		)
		on btn_normTex pressed do
		(
			try (
				 normTex = selectbitmap caption: "Normal Map"
				 if normTex != undefined then
				 (
					delegate.g_NormalTexture = normTex
				 )
			) catch ()
		)
	
	)--end roll_perMat
	
	on create do
	(
		local rootPath = getDir #maxRoot
		local uiRoot = getDir #ui
		effectfile = (rootPath + "\\maps\\fx\\scriptedMatTutorial.fx")  --set the effect file when we apply the scripted material
		delegate.effectfile = effectfile
		
		--if we don't load a brdf right away, it will just be black, which means we won't get lighting.
		try (
			delegate.g_BRDFTexture = openBitMap (rootPath + "maps\\defaultBRDF.tga")
		) catch (messageBox "BRDF not found, please choose manually" )
	)
)