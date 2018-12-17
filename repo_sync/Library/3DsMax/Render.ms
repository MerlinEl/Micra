http://www.kxcad.net/autodesk/autodesk_maxscript_reference_9/Controlling_the_Renderer.htm


renderSceneDialog.close()
--enter my code
renderSceneDialog.open()

by setting escapeEnable=false so pressing Esc 
does not break your own code but only stops the renderer. 
If you want, you could set escapeEnable=true after exiting the loop.

		local fpath = dir + name +".jpg"
		format "filename:%\n" fpath
		render outputwidth:w outputheight:h outputFile:fpath vfb:on


	render_size = [renderWidth, renderHeight]
	image_aspect_ratio = getRendImageAspect()


local output_dithering = rendDitherTrue
rendDitherTrue = false

bm = render cancelled:&wasCancelled
if (not wasCancelled) do 

global out_file24 = bitmap 24 24


gc ()
out_file24 = bitmap 100 100
render to:out_file24 vfb:off
display out_file24
		
		
		
getProgressCancel()
progressUpdate()

 A low-overhead function that checks whether the user has canceled the operation via the Cancel button in the progress bar. 
	 You may want to call this function frequently within deep loops in your code to reduce cancel latency for the user, 
		 because you should only call progressUpdate() as needed to show significant progress bar changes to keep overhead low. 
	 The getProgressCancel() function, as well as progressUpdate(), displays a confirmation dialog 
	 if the use hits the cancel button and returns the cancel status from that confirmation. Unlike progressUpdate(), 
	 this function returns true if the user has made a confirmed cancel request and false otherwise.

/*
outputfile: c:\\temp\\test.jpg

antiAliasing:off
mapping::off

		for i = 0 to 14 do
		(
			pixel_line = getpixels input_file16 [(icon_number.value-1)*16,i] 16
			setpixels out_file16 [0,i] pixel_line


input_file24 = openbitmap (pathname.text+"\\"+lib_list[lls]+"_24i.bmp") 
pixel_line = getpixels input_file24a [(icon_number.value-1)*24,i] 24

pixel_line = getpixels input_file24m [(icon_number.value-1)*24,i] 24
setpixels out_file24m [0,i] pixel_line

preview_16i.images = #(out_file16, undefined, 1,1,1,1,1)

				for i = 0 to 23 do
				(
					input_line = getpixels input_file24 [0,i] input_file24.width
					setpixels output_file24 [0,i] input_line
					pixel_line = getpixels out_file24m [0,i] 24
					setpixels output_file24 [(icon_number.value-1)*24,i] pixel_line
				)

*/



global rendrCount = 0
global setUpRendr

fn setUpRendr =(format "rendrCount:%\n" (rendrCount += 1))

callbacks.removeScripts id:#jbwRender
callbacks.addScript #preRender "setUpRendr()" id:#jbwRender





globalSamplerClassByName
renderers
renderers.current = Default_Scanline_Renderer()
renderers.current.antiAliasing = true
renderers.current.antiAliasFilter = Area()
renderers.current.enablePixelSampler = true
renderers.current.globalSamplerEnabled = true
renderers.current.globalSamplerSampleMaps = true
renderers.current.globalSamplerClassByName

renderers.production.globalSamplerClassByName

scanlineRender.enablePixelSampler
scanlineRender.antiAliasing



		--store render setings
		local old_renderers                = renderers.current
		local old_antiAliasing             = renderers.current.antiAliasing
		local old_antiAliasFilter          = renderers.current.antiAliasFilter
		local old_enablePixelSampler       = renderers.current.enablePixelSampler
		local old_globalSamplerEnabled     = renderers.current.globalSamplerEnabled
		local old_globalSamplerSampleMaps  = renderers.current.globalSamplerSampleMaps
		local old_globalSamplerClassByName = renderers.current.globalSamplerClassByName
		--set render settings
		renderers.current                          = Default_Scanline_Renderer()
		renderers.current.antiAliasing             = chk_antialiasing.checked
		renderers.current.antiAliasFilter          = (execute ddl_filters.selected)()
		renderers.current.enablePixelSampler       = chk_global_ssampler.checked
		renderers.current.globalSamplerEnabled     = chk_global_ssampler.checked
		renderers.current.globalSamplerSampleMaps  = chk_global_ssampler.checked
		renderers.current.globalSamplerClassByName = ddl_samplers.selected
		--restore Render Settings
		renderers.current		                   = old_renderers
		renderers.current.antiAliasing	           = old_antiAliasing 
		renderers.current.antiAliasFilter	       = old_antiAliasFilter
		renderers.current.enablePixelSampler	   = old_enablePixelSampler
		renderers.current.globalSamplerEnabled	   = old_globalSamplerEnabled
		renderers.current.globalSamplerSampleMaps  = old_globalSamplerSampleMaps
		renderers.current.globalSamplerClassByName = old_globalSamplerClassByName
		
		
		
		
sceneRadiosity --type in what you know... you get back an interface value 
 <Interface:SceneRadiosity>
  
 showInterface sceneRadiosity --let's see what properties it has...
 Interface: SceneRadiosity
     Properties:
  	.radiosity : value : Read|Write|Validated by Validator function
     Methods:
  	<void>showPanel()
  	<void>closePanel()
  	<void>minimizePanel()
     Actions:
 OK
  
 sceneRadiosity.radiosity --ok, there is a .radiosity property - let's check out its value:
 ReferenceTarget:Light_Tracer
  
  show sceneRadiosity.radiosity  --aha, a Light_Tracer object! Let's show its properties:
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
 false
  
  sceneRadiosity.radiosity.rays --ok, now show me the rays (you can both get and set)
 250
 
 
 
 sceneRadiosity.radiosity = Light_Tracer()
sceneRadiosity.radiosity = undefined
sceneRadiosity.radiosity.bounces = 2
