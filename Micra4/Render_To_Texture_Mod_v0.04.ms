--Render_To_Texture_Mod
Global mcRenderToTextureModDialog

if mcRenderToTextureModDialog != undefined do destroyDialog mcRenderToTextureModDialog
rollout mcRenderToTextureModDialog "Untitled" width:504 height:232
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	-------------------------------------------------
	GroupBox grp1 "Render To Texture:" pos:[4,4] width:496 height:224
	GroupBox grp2 "Maps:" pos:[12,56] width:116 height:144
	GroupBox grp3 "Lighting:" pos:[132,56] width:184 height:144
	GroupBox grp4 "Render:" pos:[324,56] width:168 height:168
	
	button btn_render "Render" pos:[12,204] width:304 height:20
	button btn_dir "Dir..." pos:[448,24] width:44 height:20
	button btn_close "*" pos:[488,4] width:12 height:12
	
	edittext edt_path "" pos:[8,24] width:436 height:20 enabled:false
	
	checkbox chk_1 "Difuse Map" pos:[20,76] width:104 height:20
	checkbox chk_2 "Normal Map" pos:[20,96] width:104 height:20
	checkbox chk_3 "Specular Map" pos:[20,116] width:104 height:20
	checkbox chk_4 "Light Map" pos:[20,136] width:104 height:20
	checkbox chk_5 "ShadowsMap" pos:[20,156] width:104 height:20
	checkbox chk_6 "Ambient Occ" pos:[20,176] width:104 height:20
	
	checkbox chk_global_ssampler "Enable Global Supersampler" pos:[332,160] width:152 height:20
	checkbox chk_show_render "Show Render Window" pos:[332,204] width:156 height:16 checked:true
	checkbox chk_ali "Add Ambient Lights" pos:[140,80] width:120 height:16 checked:true
	checkbox chk_light_tracer "Light Tracer" pos:[140,100] width:88 height:16
	checkbox chk_antialiasing "Antialiasing" pos:[332,116] width:152 height:20
	
	dropdownList ddl_render_size "Render Size:" pos:[412,72] width:72 height:40 items:#("64", "128", "256", "512", "1024", "2048")
	dropdownList ddl_file_type "File Type:" pos:[332,72] width:72 height:40 items:#(".png", ".tga", ".bmp", ".jpg")
	dropDownList ddl_filters "" pos:[372,136] width:112 height:21 items:#("Area", "Blackman", "Blendfilter", "Catmull_Rom", "Cook_Variable", "Cubic", "Mitchell_Netravali", "Plate_Match_MAX_R2", "Quadratic", "Sharp_Quadratic", "Soften, Video")
	dropDownList ddl_samplers "" pos:[332,180] width:156 height:21 items:#("Max 2.5 Star", "Hammersley", "Adaptive Halton", "Adaptive Uniform", "fRTextureAA")
	
	label lbl_01 "Top Light Multiplier:" pos:[140,152] width:108 height:16
	label lbl_02 "Bottom Light Multiplier:" pos:[140,176] width:108 height:16
	label lbl_03 "Filter:" pos:[332,140] width:32 height:16
	
	spinner spn_toplight "" pos:[252,148] width:56 height:16 range:[0,100,0] type:#float scale:0.01
	spinner spn_bottomlight "" pos:[252,172] width:56 height:16 range:[0,100,0] type:#float scale:0.01
	
	-->Functions
	fn loadInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		local chk = #(chk_1, chk_2, chk_3, chk_4, chk_5, chk_6)
		for i=1 to chk.count do 
		(
			local state = getIniSetting Micra.UserSettings "RenderToTextureMod" chk[i].name
			if state != "" do chk[i].state  = execute state
		)
		local ali = getIniSetting Micra.UserSettings "RenderToTextureMod" "Ambient Lights" 
		if ali  != "" do chk_ali.checked = execute ali
		local ren = getIniSetting Micra.UserSettings "RenderToTextureMod" "Show Rendering"
		if ren  != "" do chk_show_render.checked = execute ren
		local fty = getIniSetting Micra.UserSettings "RenderToTextureMod" "File Type"
		if fty  != "" do ddl_file_type.selection = execute fty
		local rsi = getIniSetting Micra.UserSettings "RenderToTextureMod" "Render Size"
		if rsi  != "" do ddl_render_size.selection = execute rsi
		local tli = getIniSetting Micra.UserSettings "RenderToTextureMod" "Top Light"
		if tli  != "" then spn_toplight.value    = execute tli else spn_toplight.value    = 0.1
		local bli = getIniSetting Micra.UserSettings "RenderToTextureMod" "Bottom Light"
		if bli  != "" then spn_bottomlight.value = execute bli else spn_bottomlight.value = 0.08
		---render
		local ant = getIniSetting Micra.UserSettings "RenderToTextureMod" "Antialiasing"
		if ant  != "" do chk_antialiasing.checked = execute ant 
		local fil = getIniSetting Micra.UserSettings "RenderToTextureMod" "Filter"
		if fil  != "" do ddl_filters.selection = execute fil
		local egs = getIniSetting Micra.UserSettings "RenderToTextureMod" "Enable Global Supersampler"
		if egs  != "" do chk_global_ssampler.checked = execute egs
		local smp = getIniSetting Micra.UserSettings "RenderToTextureMod" "Sampler"
		if smp  != "" do ddl_samplers.selection = execute smp
		--Advanced Lighting / light tracer
		local lit = getIniSetting Micra.UserSettings "RenderToTextureMod" "Light Tracer"
		if lit != "" do chk_light_tracer.checked = execute lit
	)
	fn saveInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		local chk = #(chk_1, chk_2, chk_3, chk_4, chk_5, chk_6)
		for i=1 to chk.count do setIniSetting Micra.UserSettings "RenderToTextureMod" chk[i].name (chk[i].checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Ambient Lights" (chk_ali.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Show Rendering" (chk_show_render.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "File Type" (ddl_file_type.selection as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Render Size" (ddl_render_size.selection as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Top Light" (spn_toplight.value as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Bottom Light" (spn_bottomlight.value as string)
		---render
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Antialiasing" (chk_antialiasing.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Filter" (ddl_filters.selection as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Enable Global Supersampler" (chk_global_ssampler.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Sampler" (ddl_samplers.selection as string)
		--Advanced Lighting / light tracer
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Light Tracer" (chk_light_tracer.checked as string)
	)
	fn collectCheckedElements =
	(
		local ele = #(CompleteMap, NormalsMap, specularMap, LightingMap, ShadowsMap, Ambient_Occlusion)
		local chk = #(chk_1, chk_2, chk_3, chk_4, chk_5, chk_6)
		for i=1 to chk.count where chk[i].checked == true collect ele[i]
		--for i=1 to 6 where (execute ("mcRenderToTextureModDialog"+"chk_"+i as string+".checked") == true) collect ele[i]
	)
	fn RenderToTextureMod = 
	(
		local objToBake = selection[1]
		local fPath     = edt_path.text
		----error catch----
		if not doesFileExist fPath do return false
		if objToBake == undefined or objToBake.modifiers[ #Projection ] == undefined do return false --check selected object modiffier
		----error catch----
		local fType = ddl_file_type.text 
		local renderSize = ddl_render_size.text as integer
		local bakeProperties = objToBake.INodeBakeProperties
		local bakeInterface  = objToBake.INodeBakeProjProperties --rene <
			bakeInterface.enabled = true --rene
			bakeInterface.projectionMod = objToBake.modifiers[#Projection] --rene >
		local showRendering  = chk_show_render.checked
		local elementsArray = collectCheckedElements()
		
		for i in elementsArray do
		(
			local ele_id = case i of -- elements ID table
			(
				CompleteMap       :"_d"
				NormalsMap        :"_n"
				specularMap       :"_s"
				LightingMap       :"_l"
				ShadowsMap        :"_h"
				Ambient_Occlusion :"_o"
			)
			
			local fName = objToBake.name + ele_id --append element ID to file name
			
			LM_Var = i()  --makes element reference
			LM_Var.filetype          = (fPath+fName+fType)
			LM_Var.enabled           = true
			LM_Var.autoSzOn          = false
			LM_Var.outputSzX         = renderSize
			LM_Var.outputSzY         = renderSize
			LM_Var.filenameUnique    = false
			LM_Var.filterOn          = true
			LM_Var.targetMapSlotName = ""
			
			bakeProperties.addBakeElement LM_Var
		)
		
		if bakeProperties.NumBakeElements() == 0 do return false
		
		bakeProperties.bakeChannel = 1
		bakeProperties.bakeEnabled = true
		bakeProperties.nDilations = 4 --padding
		--store render setings
		local old_renderer                 = renderers.current
		renderers.current                 = Default_Scanline_Renderer()
		/*
		local old_antiAliasFilter          = renderers.current.antiAliasFilter
		local old_enablePixelSampler       = renderers.current.enablePixelSampler
		local old_globalSamplerEnabled     = renderers.current.globalSamplerEnabled
		local old_globalSamplerSampleMaps  = renderers.current.globalSamplerSampleMaps
		local old_globalSamplerClassByName = renderers.current.globalSamplerClassByName
		*/
		--store Advanced Lighting / light tracer
		local old_sceneRadiosityType    = sceneRadiosity.radiosity -- for disable set to undefined
		local old_sceneRadiosityBounces, old_sceneRadiosityRays
		if old_sceneRadiosityType != undefined do
		(
			old_sceneRadiosityBounces    = sceneRadiosity.radiosity.bounces
			old_sceneRadiosityRays       = sceneRadiosity.radiosity.rays
		)
		--set render settings
		renderers.current.antiAliasFilter          = (execute ddl_filters.selected)()
		renderers.current.enablePixelSampler       = chk_global_ssampler.checked
		renderers.current.globalSamplerEnabled     = chk_global_ssampler.checked
		renderers.current.globalSamplerSampleMaps  = chk_global_ssampler.checked
		renderers.current.globalSamplerClassByName = ddl_samplers.selected
		--Set Advanced Lighting / light tracer if not exiest in scene
		if chk_light_tracer.checked and classOf old_sceneRadiosityType != Light_Tracer do
		(
			sceneRadiosity.radiosity = Light_Tracer()
			sceneRadiosity.radiosity.bounces = 2
			sceneRadiosity.radiosity.rays = 500
		)
		--wasCanceled = false
		--render rendertype:#bakeSelected to:bmap vfb:showRendering cancelled:&wasCanceled disableBitmapProxies:true
		render rendertype:#bakeSelected vfb:showRendering progressBar:(not showRendering) \
		outputSize:[renderSize,renderSize] antiAliasing:chk_antialiasing.checked
		/*
		antiAliasFilter:Area()
		enablePixelSampler:off
		*/
		--restore Render Settings
		renderers.current		                   = old_renderer
		/*
		renderers.current.antiAliasFilter	       = old_antiAliasFilter
		renderers.current.enablePixelSampler	   = old_enablePixelSampler
		renderers.current.globalSamplerEnabled	   = old_globalSamplerEnabled
		renderers.current.globalSamplerSampleMaps  = old_globalSamplerSampleMaps
		renderers.current.globalSamplerClassByName = old_globalSamplerClassByName
		*/
		--restore Advanced Lighting / light tracer
		if old_sceneRadiosityType == undefined 
		then
		(
			sceneRadiosity.radiosity = undefined
		)
		else if chk_light_tracer.checked do
		(
			sceneRadiosity.radiosity = old_sceneRadiosityType
			if classOf old_sceneRadiosityType == Light_Tracer do
			(
				sceneRadiosity.radiosity.bounces = old_sceneRadiosityBounces
				sceneRadiosity.radiosity.rays    = old_sceneRadiosityRays
			)
		)
		--clear lelements
		bakeProperties.removeAllBakeElements()
		bakeProperties.bakeEnabled = false
		return OK
	)
	-->DialogProp --------------------------------------------------------------------
	on mcRenderToTextureModDialog rbuttonup pos do (destroyDialog mcRenderToTextureModDialog)
	on mcRenderToTextureModDialog open do
	(
		loadInterface()
		edt_path.text = maxFilePath
	)
	on mcRenderToTextureModDialog close do 
	( 
		mcCall.saveIniDialog "mcRenderToTextureModDialog" "Properties_2"
		saveInterface()
	)
	-->MoveMode
	on mcRenderToTextureModDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcRenderToTextureModDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcRenderToTextureModDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcRenderToTextureModDialog DmPos
	)
	--Actions -----------------------------------------------------------------------
	on btn_render pressed  do
	(
		if chk_ali.checked 
		then
		(
			--turn off old lights if exist
			struct lightParam (obj = #(), state = #())
			local old_lights = lightParam()
			for i in objects where superClassOf i == light do
			(
				old_lights.obj += #(i)
				old_lights.state += #(i.enabled)
				i.enabled = false -- turn off
			)
			--create new lights
			local ali = mcAction.create_ambient_lights multiA:spn_toplight.value multiB:spn_bottomlight.value
			RenderToTextureMod()
			--delete new lights
			delete ali
			--turn on old lights if exist
			if old_lights.obj.count != 0 do 
			(
				for i=1 to old_lights.obj.count do old_lights.obj[i].enabled = old_lights.state[i]
			)
		)
		else (RenderToTextureMod())
		
		setFocus mcRenderToTextureModDialog
	)
	on btn_dir pressed  do
	(
		local dir  = getSavePath caption:" Chose Dir..." initialDir:maxFilePath
		if dir != undefined do edt_path.text = dir+"\\"
	)
	on btn_close pressed do (destroyDialog mcRenderToTextureModDialog)
)
mcCall.createIniDialog "mcRenderToTextureModDialog" "Properties_2"


/*
not works 
render enablePixelSampler:true  PixelSampler:"Hammersley"
render enablePixelSampler:true PixelSampler:"Max 2.5 Star"
render enablePixelSampler:true PixelSampler:"Adaptive Uniform"
render enablePixelSampler:false
*/


/*
   .rays : integer
   .sky_lights : float
   .bounces : integer
   .ray_bias : float
   .filter_size : float
   .sky_lights_on : boolean
   .global_multiplier : float
   .object_multiplier : float
   .color_bleed : float
   .color_filter : RGB color
   .extra_ambient : RGB color
   .cone_angle : float
   .volumes_on : boolean
   .volumes : float
   .adaptive_undersampling_on : boolean
   .initial_sample_spacing : integer
   .subdivide_down_to : integer
   .subdivision_contrast : float
   .show_samples : boolean
   .rayengine
   .rayengine2

*/