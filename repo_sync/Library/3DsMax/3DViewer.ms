rollout ro_3DViewer_1 "3D Viewer Test"
(
	---------------------------------------------------
	local objGeometry, meterLib, vLight, vCam
	local isPlaying = false
	local temp_obj_Name = "c:\\temp\\__tempObjExport.x"
	---------------------------------------------------
	groupbox grp_3DView pos:[5,0] width:320 height:325
	activeXControl ax_3DCtrl "DirectAnimation.DirectAnimationWindowedIntegratedMediaControl.1" pos:[15,15] width:300 height:300
	button ui_LoadSelected "Load Selected Object" pos:[10,330] width:150
	checkbutton ui_PlayRotation "Play Rotation" pos:[160,330] width:150 enabled:false

	function create3DViewport objFile =
	(
	--- initialize and fill viewport
	meterLib = ax_3DCtrl.MeterLibrary
	ax_3DCtrl.Image = meterLib.SolidColorImage meterLib.black
	ax_3DCtrl.BackgroundImage = meterLib.SolidColorImage meterLib.black
	ax_3DCtrl.updateInterval = 0.1
	--- Create Camera
	dim = 1000.1
	vCam = (meterLib.PerspectiveCamera (10*dim) (0.1*dim)).Transform (meterLib.Translate3 0 0 0.01)
	vCam = vCam.transform (meterLib.Rotate3Degrees (meterLib.YVector3) (10))
	--- Create Light
	vLight = meterLib.PointLight.Transform (meterLib.Translate3 (dim/2) (dim/4) (1.5*dim) )
	--- Load Object
	loadedObjGeometry = ( (meterLib.ImportGeometry (objFile)).DiffuseColor (meterLib.Red))
	objGeometry = loadedObjGeometry.Transform (meterLib.Scale3 0.01 0.01 0.01)
	--- Render View
	finalImg = (meterLib.UnionGeometry (objGeometry) (vLight)).Render (vCam)
	ax_3DCtrl.Image = finalImg
	ax_3DCtrl.start()
	)
	
	on ui_PlayRotation changed state do
	(
		if state == true then
		(
		if isPlaying == false then ax_3DCtrl.stop()
		
		--- give object constant rotationspeed
		objGeometry = objGeometry.transform (meterLib.Rotate3RateDegrees (meterLib.XVector3) (20))
		objGeometry = objGeometry.transform (meterLib.Rotate3RateDegrees (meterLib.YVector3) (20))
		objGeometry = objGeometry.transform (meterLib.Rotate3RateDegrees (meterLib.ZVector3) (20))
		
		--- render
		finalImg = (meterLib.UnionGeometry (objGeometry) (vLight)).Render (vCam)
		ax_3DCtrl.Image = finalImg
		ax_3DCtrl.start()
		isPlaying = true
		)
	
		if state == false then
		(
			ax_3DCtrl.pause()
			ax_3DCtrl.stop()
		)
	)
)
createdialog ro_3DViewer_1