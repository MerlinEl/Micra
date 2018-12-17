
--------------------------------------------------------------------
--------------------------------------------------------------------------

--hh = dotnet.loadassembly (mcPath()+"app/HitchHiker.dll")
--mcsystem.show hh

--------------------------------------------------------------------
--------------------------------------------------------------------------

dotnet.loadassembly (mcPath()+"app/HitchHiker.dll")

rollout HitchHikerRollout "" width:240 height:270
 (
	 dotNetControl HitchHiker "lonerobot.ui.controls.HitchHiker" pos:[0,0] width:240 height:270

	 on HitchHikerRollout open do
	 (
		--MCSYSTEM.SHOW HitchHiker.filetype
		HitchHiker.filetype = (dotnetclass "lonerobot.ui.controls.HitchHiker+filetypes").jpg
		HitchHiker.displaystyle = (dotnetclass "lonerobot.ui.controls.HitchHiker+displaystyles").imagetext
		HitchHiker.populate @"C:\Merlin\3DGallery2\Models\Mechanical\Connections"
	 )
	 
	 on HitchHikerRollout close do HitchHiker.housekeeping()
	 on HitchHiker thumbpicked sender args do
	 (
		 print args.FileName
		 print args.Image
	 )
 )
 createdialog HitchHikerRollout



--------------------------------------------------------------------
--------------------------------------------------------------------------

--hh = dotnet.loadassembly (mcPath()+"app/HitchHiker.dll")
--mcsystem.show hh


rollout MatteShadowHelper2 "Matte/Shadow Setup" width:722 height:979
(

	fn SetupUI =
	(
		MatteShadowHelper2.dncHHImageList.cache =  (dotnetclass "lonerobot.ui.controls.hitchhiker+cachestate").cache	
		MatteShadowHelper2.dncHHImageList.filetype =  (dotnetclass "lonerobot.ui.controls.hitchhiker+filetypes").png
		MatteShadowHelper2.dncHHImageList.thumbsize = dotnetobject "system.drawing.size" 136 77	
		MatteShadowHelper2.dncHHImageList.gap = 2
		MatteShadowHelper2.dncHHImageList.showtoolbar = true
		MatteShadowHelper2.dncHHImageList.thumbpanelbackcolor = MatteShadowHelper2.dncHHImageList.buttonbackcolor = DnColorClass.dimgray 
		MatteShadowHelper2.dncHHImageList.forecolor = DnColorClass.lightgray 		
		MatteShadowHelper2.dncHHImageList.populate ""	-- populate an empty string to enable the use of the favourites menu
		MatteShadowHelper2.dncImagePreview.scrollbarsvisible = false
		MatteShadowHelper2.dncImagePreview.fittoscreen()				
		MatteShadowHelper2.dncImagePreview.backcolor =DnColorClass.dimgray 	
	)
	button btnBrowse "Browse to Location" pos:[614,950] width:102 height:25 border:false
	dotNetControl dncHHImageList "Lonerobot.ui.controls.hitchhiker" pos:[0,0] width:722 height:475
)
createdialog MatteShadowHelper2